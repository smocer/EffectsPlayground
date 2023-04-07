//
//  ChromaticAberration.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 07.04.2023.
//

import CoreImage

fileprivate let tau: CGFloat = .pi * 2

/// `RGBChannelCompositing` filter takes three input images and composites them together
/// by their color channels, the output RGB is `(inputRed.r, inputGreen.g, inputBlue.b)`
class RGBChannelCompositing: CIFilter
{
    var inputRedImage : CIImage?
    var inputGreenImage : CIImage?
    var inputBlueImage : CIImage?

    let rgbChannelCompositingKernel = CIColorKernel(source:
        "kernel vec4 rgbChannelCompositing(__sample red, __sample green, __sample blue)" +
        "{" +
        "   return vec4(red.r, green.g, blue.b, 1.0);" +
        "}"
    )

    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "RGB Compositing",

            "inputRedImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Red Image",
                kCIAttributeType: kCIAttributeTypeImage],

            "inputGreenImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Green Image",
                kCIAttributeType: kCIAttributeTypeImage],

            "inputBlueImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Blue Image",
                kCIAttributeType: kCIAttributeTypeImage]
        ]
    }

    override var outputImage: CIImage!
    {
        guard let inputRedImage = inputRedImage,
            let inputGreenImage = inputGreenImage,
            let inputBlueImage = inputBlueImage,
            let rgbChannelCompositingKernel = rgbChannelCompositingKernel else
        {
            return nil
        }

        let extent = inputRedImage.extent.union(inputGreenImage.extent.union(inputBlueImage.extent))
        let arguments = [inputRedImage, inputGreenImage, inputBlueImage]

        return rgbChannelCompositingKernel.apply(extent: extent, arguments: arguments)
    }
}

/// `ChromaticAberration` offsets an image's RGB channels around an equilateral triangle
class ChromaticAberration: CIFilter
{
    @objc dynamic
    var inputImage: CIImage?

    var inputAngle: CGFloat = 0
    var inputRadius: CGFloat = 2

    let rgbChannelCompositing = RGBChannelCompositing()

    override func setDefaults()
    {
        inputAngle = 0
        inputRadius = 2
    }

    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Chromatic Abberation",

            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],

            "inputAngle": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 0,
                kCIAttributeDisplayName: "Angle",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: tau,
                kCIAttributeType: kCIAttributeTypeScalar],

            "inputRadius": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "NSNumber",
                kCIAttributeDefault: 2,
                kCIAttributeDisplayName: "Radius",
                kCIAttributeMin: 0,
                kCIAttributeSliderMin: 0,
                kCIAttributeSliderMax: 25,
                kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }

    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }

        let redAngle = inputAngle + tau
        let greenAngle = inputAngle + tau * 0.333
        let blueAngle = inputAngle + tau * 0.666

        let redTransform = CGAffineTransformMakeTranslation(sin(redAngle) * inputRadius, cos(redAngle) * inputRadius)
        let greenTransform = CGAffineTransformMakeTranslation(sin(greenAngle) * inputRadius, cos(greenAngle) * inputRadius)
        let blueTransform = CGAffineTransformMakeTranslation(sin(blueAngle) * inputRadius, cos(blueAngle) * inputRadius)

        let red = inputImage.applyingFilter(
            "CIAffineTransform",
            parameters: [kCIInputTransformKey: NSValue(cgAffineTransform: redTransform)]
        ).cropped(to: inputImage.extent)

        let green = inputImage.applyingFilter(
            "CIAffineTransform",
            parameters: [kCIInputTransformKey: NSValue(cgAffineTransform: greenTransform)]
        ).cropped(to: inputImage.extent)

        let blue = inputImage.applyingFilter(
            "CIAffineTransform",
            parameters: [kCIInputTransformKey: NSValue(cgAffineTransform: blueTransform)]
        ).cropped(to: inputImage.extent)

        rgbChannelCompositing.inputRedImage = red
        rgbChannelCompositing.inputGreenImage = green
        rgbChannelCompositing.inputBlueImage = blue

        let finalImage = rgbChannelCompositing.outputImage

        return finalImage
    }
}
