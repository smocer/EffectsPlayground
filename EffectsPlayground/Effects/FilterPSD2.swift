//
//  FilterPSD2.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 16.04.2023.
//

import CoreImage
import Metal
import UIKit
import CoreImage.CIFilterBuiltins

private enum Const {
    enum ColorFilter {
        static let density = NSNumber(floatLiteral: 0.66)
        // rgb
        static let color = CIVector(x: 234 / 255, y: 176 / 255, z: 18 / 255)
    }

    enum ColorBalance {
        // from -1 to 1
        static let midtones = CIVector(x: 0.12, y: -0.47, z: 0.10)
    }

    enum ChannelMixer {
        // x - red, y - green, z - blue, w - total (see sliders in photopea)
        static let redOutput = CIVector(x: 1.52, y: -0.42, z: 0.83, w: -0.72)
        static let greenOutput = CIVector(x: 0, y: 1, z: 0, w: 0)
        static let blueOutput = CIVector(x: 0, y: 0, z: 1, w: 0)
    }

    enum Overlay {
        static let opacity = 0.33
    }
}

final class FilterPSD2: CIFilter {
    @objc dynamic
    var inputImage: CIImage?

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

        guard let colorFilterResult = kernelColorFilter.apply(
            extent: inputImage.extent,
            roiCallback: { _, _ in
                inputImage.extent
            }, arguments: [
                inputImage,
                Const.ColorFilter.density,
                Const.ColorFilter.color,
            ])
        else {
            return nil
        }

        guard let colorBalanceResult = kernelColorBalance.apply(
            extent: colorFilterResult.extent,
            roiCallback: { _, _ in
                colorFilterResult.extent
            }, arguments: [
                colorFilterResult,
                Const.ColorBalance.midtones,
            ])
        else {
            return nil
        }

        guard let channelMixerResult = kernelChannelMixer.apply(
            extent: colorBalanceResult.extent,
            roiCallback: { _, _ in
                colorBalanceResult.extent
            }, arguments: [
                colorBalanceResult,
                Const.ChannelMixer.redOutput,
                Const.ChannelMixer.greenOutput,
                Const.ChannelMixer.blueOutput,
            ])
        else {
            return nil
        }

        let overlay = CIImage(image: UIImage(named: "psd1overlay")!)!
            .cropped(to: channelMixerResult.extent)

        let transparentOverlay = setOpacity(image: overlay, alpha: Const.Overlay.opacity)

        let divideBlendFilter = CIFilter.divideBlendMode()
        divideBlendFilter.inputImage = overlay
        divideBlendFilter.backgroundImage = channelMixerResult

        let composited = divideBlendFilter.outputImage
        return composited
    }
}

private func setOpacity(image: CIImage, alpha: Double) -> CIImage {
    guard let overlayFilter: CIFilter = CIFilter(name: "CIColorMatrix") else { fatalError() }
    let alphaVector: CIVector = CIVector(x: 0, y: 0, z: 0, w: alpha)
    overlayFilter.setValue(image, forKey: kCIInputImageKey)
    overlayFilter.setValue(alphaVector, forKey: "inputAVector")

    return overlayFilter.outputImage!
}
