//
//  PSDSettings.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import Foundation
import CoreGraphics
import CoreImage
import CoreImage.CIFilterBuiltins

struct PSDSettings {
    var photoFilter: PhotoFilter
    var colorBalance: ColorBalance
    var channelMixer: ChannelMixer
    var overlay: Overlay

    struct PhotoFilter {
        var isOn: Bool = true
        var density: Double = 0
        var color: CGColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
    }

    struct ColorBalance {
        var isOn: Bool = true
        // from -1 to 1
        var midtones: Vector = .init(x: 0, y: 0, z: 0)
    }

    struct ChannelMixer {
        var isOn: Bool = true
        // x - red, y - green, z - blue, w - total (see sliders in photopea)
        // from -2 to 2
        var redOutput: Vector   = .init(x: 1, y: 0, z: 0, w: 0)
        var greenOutput: Vector = .init(x: 0, y: 1, z: 0, w: 0)
        var blueOutput: Vector  = .init(x: 0, y: 0, z: 1, w: 0)
    }

    struct Overlay {
        enum BlendMode {
            case divide
            case hardLight
        }

        var isOn: Bool = true
        var opacity: Double = 0
        var imageName: String = "psd1overlay"
        var blendMode: BlendMode = .hardLight
    }

    static let `default` = Self(
        photoFilter: PhotoFilter(),
        colorBalance: ColorBalance(),
        channelMixer: ChannelMixer(),
        overlay: Overlay()
    )
}

extension PSDSettings {
    static let psd1 = Self(
        photoFilter: PhotoFilter(
            isOn: true,
            density: 0.66,
            color: CGColor(red: 234 / 255, green: 176 / 255, blue: 18 / 255, alpha: 1)
        ),
        colorBalance: ColorBalance(
            isOn: true,
            midtones: Vector(x: 0.12, y: -0.47, z: 0.10)
        ),
        channelMixer: ChannelMixer(
            isOn: true,
            redOutput: Vector(x: 1.52, y: -0.42, z: 0.83, w: -0.72),
            greenOutput: Vector(x: 0, y: 1, z: 0, w: 0),
            blueOutput: Vector(x: 0, y: 0, z: 1, w: 0)
        ),
        overlay: Overlay(
            isOn: true,
            opacity: 0.82,
            imageName: "psd1overlay",
            blendMode: .divide
        )
    )

    static let psd2 = Self(
        photoFilter: PhotoFilter(
            isOn: true,
            density: 0.91,
            color: CGColor(red: 234 / 255, green: 177 / 255, blue: 18 / 255, alpha: 1)
        ),
        colorBalance: ColorBalance(
            isOn: true,
            midtones: Vector(x: 0.12, y: -0.47, z: 0.10)
        ),
        channelMixer: ChannelMixer(
            isOn: true,
            redOutput: Vector(x: 1.52, y: -0.42, z: 0.83, w: -0.72),
            greenOutput: Vector(x: 0, y: 1, z: 0, w: 0),
            blueOutput: Vector(x: 0, y: 0, z: 1, w: 0)
        ),
        overlay: Overlay(
            isOn: true,
            opacity: 0.33,
            imageName: "psd2overlay",
            blendMode: .hardLight
        )
    )
}

extension PSDSettings.Overlay.BlendMode {
    func ciFilter() -> CIFilter & CICompositeOperation {
        switch self {
        case .divide:
            return CIFilter.divideBlendMode()
        case .hardLight:
            return CIFilter.hardLightBlendMode()
        }
    }
}
