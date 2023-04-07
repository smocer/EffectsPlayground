//
//  CompositeFilter.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 07.04.2023.
//

import CoreImage

final class CompositeFilter: CIFilter {
    @objc dynamic
    var inputImage: CIImage?

    var inputFilters: [CIFilter] = []

    override func setDefaults() {
        inputFilters = []
    }

    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Composite filter",

            "inputImage": [kCIAttributeIdentity: 0,
                kCIAttributeClass: "CIImage",
                kCIAttributeDisplayName: "Image",
                kCIAttributeType: kCIAttributeTypeImage],
        ]
    }

    override var outputImage: CIImage? {
        guard let inputImage else {
            return nil
        }
        return inputFilters.reduce(inputImage) { partialResult, filter in
            filter.setValue(partialResult, forKey: "inputImage")
            return filter.outputImage!
        }
    }
}
