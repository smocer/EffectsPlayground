//
//  FilterPSD.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 14.04.2023.
//

import CoreImage
import Metal
import UIKit
import CoreImage.CIFilterBuiltins

final class FilterPSD: CIFilter {
    @objc dynamic
    var inputImage: CIImage?
    var settings: PSDSettings = .default

    private let kernelPhotoFilter: CIKernel
    private let kernelColorBalance: CIKernel
    private let kernelChannelMixer: CIKernel

    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        kernelPhotoFilter = try! CIKernel(functionName: "colorFilter", fromMetalLibraryData: data)
        kernelColorBalance = try! CIKernel(functionName: "colorBalance", fromMetalLibraryData: data)
        kernelChannelMixer = try! CIKernel(functionName: "channelMixer", fromMetalLibraryData: data)
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var outputImage: CIImage? {
        guard let inputImage else {
            return nil
        }

        var result = inputImage

        if settings.photoFilter.isOn {
            guard let photoFilterResult = kernelPhotoFilter.apply(
                extent: result.extent,
                roiCallback: { _, _ in
                    result.extent
                }, arguments: [
                    result,
                    NSNumber(value: settings.photoFilter.density),
                    settings.photoFilter.color.ciVector,
                ])
            else {
                return nil
            }
            result = photoFilterResult
        }

        if settings.colorBalance.isOn {
            guard let colorBalanceResult = kernelColorBalance.apply(
                extent: result.extent,
                roiCallback: { _, _ in
                    result.extent
                }, arguments: [
                    result,
                    settings.colorBalance.midtones.ciVector,
                ])
            else {
                return nil
            }
            result = colorBalanceResult
        }

        if settings.channelMixer.isOn {
            guard let channelMixerResult = kernelChannelMixer.apply(
                extent: result.extent,
                roiCallback: { _, _ in
                    result.extent
                }, arguments: [
                    result,
                    settings.channelMixer.redOutput.ciVector,
                    settings.channelMixer.greenOutput.ciVector,
                    settings.channelMixer.blueOutput.ciVector,
                ])
            else {
                return nil
            }
            result = channelMixerResult
        }

        if settings.overlay.isOn {
            let overlay = CIImage(image: UIImage(named: settings.overlay.imageName)!)!
                .transformExtent(to: result.extent)
                .withOpacity(alpha: settings.overlay.opacity)

            let blendFilter = settings.overlay.blendMode.ciFilter()
            blendFilter.inputImage = overlay
            blendFilter.backgroundImage = result
            guard let composited = blendFilter.outputImage else {
                return nil
            }

            result = composited
        }

        return result
    }
}
