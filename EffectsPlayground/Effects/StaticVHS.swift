//
//  StaticVHS.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 08.04.2023.
//

import CoreImage
import UIKit

final class StaticVHS: CIFilter {

    @objc dynamic
    var inputImage: CIImage?

    enum Const {
        static let fontRelativeSize: CGFloat = 0.02
        static let textRelativeInsets = UIEdgeInsets(top: 0.05, left: 0, bottom: 0, right: 0.1)
    }

    override var outputImage: CIImage? {
        let overlayText = "PAUSE   I I"
        guard let inputImage else {
            return nil
        }
        let imageWithText = addTextToImage(text: overlayText, image: inputImage)

        let lutURL = Bundle.main.url(forResource: "LUT_64_2", withExtension: "jpg")!
        let lutFilter = try! ColorCubeLoader(bundle: .main).load(at: lutURL)
        lutFilter.inputImage = imageWithText

        guard let lutedImage = lutFilter.outputImage else {
            return imageWithText
        }

        let blurFilter = CIFilter(name: "CIMotionBlur", parameters: [
            kCIInputImageKey: lutedImage,
            kCIInputAngleKey: 3,
            kCIInputRadiusKey: 2
        ])

        return blurFilter?.outputImage ?? lutedImage
    }

    func addTextToImage(text: String, image: CIImage) -> CIImage? {
        // Create a CIFilter for adding text to the image
        let text = NSAttributedString(string: text, attributes: [
            .font: UIFont(name: "HelveticaNeue", size: image.extent.height * Const.fontRelativeSize)!,
            .foregroundColor: UIColor.white
        ])
        let textFilter = CIFilter(name: "CIAttributedTextImageGenerator", parameters: [
            "inputText": text,
            "inputScaleFactor": 2
        ])!

        // Get the output CIImage from the text filter
        guard let textImage = textFilter.outputImage else {
            return nil
        }

        let textImageTransformed = textImage.transformed(by: CGAffineTransform(
            translationX: image.extent.width * (1 - Const.textRelativeInsets.right) - textImage.extent.width,
            y: image.extent.height * (1 - Const.textRelativeInsets.top) - textImage.extent.height
        ))

        // Create a CIFilter for compositing the text image over the input image
        let compositingFilter = CIFilter(name: "CISourceOverCompositing")!
        compositingFilter.setValue(textImageTransformed, forKey: kCIInputImageKey)
        compositingFilter.setValue(image, forKey: kCIInputBackgroundImageKey)

        // Get the output CIImage from the compositing filter
        guard let outputImage = compositingFilter.outputImage else {
            return nil
        }

        return outputImage
    }
}
