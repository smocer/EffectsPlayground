//
//  FilterPSD1.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 14.04.2023.
//

import CoreImage
import Metal
import UIKit
import CoreImage.CIFilterBuiltins
import SwiftUI

final class FilterPSD1: CIFilter {
    @objc dynamic
    var inputImage: CIImage?
    var settings: Settings = .default

    private let kernelColorFilter: CIKernel
    private let kernelColorBalance: CIKernel
    private let kernelChannelMixer: CIKernel

    override init() {
        let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
        let data = try! Data(contentsOf: url)
        kernelColorFilter = try! CIKernel(functionName: "colorFilter", fromMetalLibraryData: data)
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
            guard let photoFilterResult = kernelColorFilter.apply(
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
            let overlay = CIImage(image: UIImage(named: "psd1overlay")!)!
                .cropped(to: result.extent)

            let transparentOverlay = setOpacity(image: overlay, alpha: settings.overlay.opacity)

            let divideBlendFilter = CIFilter.divideBlendMode()
            divideBlendFilter.inputImage = transparentOverlay
            divideBlendFilter.backgroundImage = result
            guard let composited = divideBlendFilter.outputImage else {
                return nil
            }

            result = composited
        }

        return result
    }
}

private func setOpacity(image: CIImage, alpha: Double) -> CIImage {
    guard let overlayFilter: CIFilter = CIFilter(name: "CIColorMatrix") else { fatalError() }
    let alphaVector: CIVector = CIVector(x: 0, y: 0, z: 0, w: alpha)
    overlayFilter.setValue(image, forKey: kCIInputImageKey)
    overlayFilter.setValue(alphaVector, forKey: "inputAVector")

    return overlayFilter.outputImage!
}

extension FilterPSD1 {
    struct Settings {
        var photoFilter: PhotoFilter
        var colorBalance: ColorBalance
        var channelMixer: ChannelMixer
        var overlay: Overlay

        struct PhotoFilter {
            var isOn = true
            var density = 0.66
            var color = CGColor(red: 234 / 255, green: 176 / 255, blue: 18 / 255, alpha: 1)
//            var color = Vector(x: 234 / 255, y: 176 / 255, z: 18 / 255)
        }

        struct ColorBalance {
            var isOn = true
            // from -1 to 1
            var midtones = Vector(x: 0.12, y: -0.47, z: 0.10)
        }

        struct ChannelMixer {
            var isOn = true
            // x - red, y - green, z - blue, w - total (see sliders in photopea)
            // from -2 to 2
            var redOutput = Vector(x: 1.52, y: -0.42, z: 0.83, w: -0.72)
            var greenOutput = Vector(x: 0, y: 1, z: 0, w: 0)
            var blueOutput = Vector(x: 0, y: 0, z: 1, w: 0)
        }

        struct Overlay {
            var isOn = true
            var opacity = 0.82
        }

        static let `default` = Self(
            photoFilter: PhotoFilter(),
            colorBalance: ColorBalance(),
            channelMixer: ChannelMixer(),
            overlay: Overlay()
        )
    }
}
