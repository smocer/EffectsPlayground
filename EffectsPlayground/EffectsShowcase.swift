//
//  EffectsShowcase.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 07.04.2023.
//

import Foundation
import CoreImage
import UIKit

struct ShowcaseItem: Identifiable {
    var id: ObjectIdentifier {
        ObjectIdentifier(image)
    }

    let image: UIImage
    let name: String
}

final class EffectsShowcase {
    static let shared = EffectsShowcase()

    var selectedImage: UIImage = UIImage(named: "woman-with-short-haircut-short-sleeved-shirt-stands-front-building")!

    private let ciContext = CIContext()
    private let ciFilters: [CIFilter] = [
        makeFilterPSD1(),
        makeTransverseChromaticAberration(),
        makeChromaticAberration(),
        makeAberrationWithNoise(),
        makeTransverseAberrationWithNoise(),
        makeStaticVHS(),
    ]

    private init() {}

    func renderExamples() -> [ShowcaseItem] {
        let inputImage = CIImage(image: selectedImage)!
        let items: [ShowcaseItem] = ciFilters.compactMap { filter in
            filter.setValue(inputImage, forKey: "inputImage")
            guard let outImage = filter.outputImage else {
                return nil
            }
            guard let cgImage = ciContext.createCGImage(outImage, from: outImage.extent) else {
                return nil
            }
            let uiImage = UIImage(cgImage: cgImage)
            var name = filter.name
            if let composed = filter as? CompositeFilter {
                name += composed.inputFilters.dropLast(1).reduce(": ", { partialResult, filter in
                    partialResult + filter.name + ", "
                })
                name += composed.inputFilters.last.map { $0.name } ?? ""
            } else if let lut = filter as? FilterColorCube, let lutName = lut.lutName {
                name += ": \(lutName)"
            }
            return ShowcaseItem(image: uiImage, name: name)
        }
        return items
    }
}

private func makeTransverseChromaticAberration() -> CIFilter {
    let transverseChromaticAberration = TransverseChromaticAberration()
    transverseChromaticAberration.inputBlur = 20
    transverseChromaticAberration.inputFalloff = 0.2
    transverseChromaticAberration.inputSamples = 10
    return transverseChromaticAberration
}

private func makeChromaticAberration() -> CIFilter {
    let chromaticAberration = ChromaticAberration()
    chromaticAberration.inputAngle = 0
    chromaticAberration.inputRadius = 3
    return chromaticAberration
}

private func makeAberrationWithNoise() -> CIFilter {
    let chromaticAberration = makeChromaticAberration()
    let noise = NoiseFilter()
    noise.inputAmount = 0.3
    let composed = CompositeFilter()
    composed.inputFilters = [chromaticAberration, noise]
    return composed
}

private func makeTransverseAberrationWithNoise() -> CIFilter {
    let chromaticAberration = makeTransverseChromaticAberration()
    let noise = NoiseFilter()
    noise.inputAmount = 0.3
    let composed = CompositeFilter()
    composed.inputFilters = [chromaticAberration, noise]
    return composed
}

private func makeStaticVHS() -> CIFilter {
    StaticVHS()
}

private func makeLUTs() -> [CIFilter] {
    try! ColorCubeLoader(bundle: .main).load()
}

private func makeFilterPSD1() -> CIFilter {
    FilterPSD1()
}
