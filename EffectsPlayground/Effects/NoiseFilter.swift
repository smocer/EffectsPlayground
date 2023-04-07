//
//  NoiseFilter.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 07.04.2023.
//

import CoreImage

final class NoiseFilter: CIFilter {
    @objc dynamic
    var inputImage: CIImage?

    var inputAmount: CGFloat = 0.1

    let addNoiseKernel = CIColorKernel(source:
"""
        kernel vec4 addNoise(sampler image, float amount)
        {
            vec2 uv = destCoord();
            float noise = (fract(sin(dot(uv, vec2(12.9898,78.233)*2.0)) * 43758.5453));
            vec4 tex = sample(image, samplerTransform(image, uv));
            return tex - noise * amount;
        }
"""
    )

    override func setDefaults() {
        inputAmount = 0.1
    }

    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Composite filter",

            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],

            "inputAmount": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDisplayName: "Amount",
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }

    override var outputImage: CIImage? {
        guard let addNoiseKernel else {
            return inputImage
        }

        guard let inputImage else {
            return nil
        }

        return addNoiseKernel.apply(extent: inputImage.extent, arguments: [
            inputImage,
            inputAmount
        ])
    }
    
}
