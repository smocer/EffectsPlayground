//
//  PSD1Details.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import SwiftUI

private let ciContext = CIContext()

struct PSD1Details: View {
    private let inputImage: UIImage
    @State
    private var settings: FilterPSD1.Settings = .default

    init(inputImage: UIImage) {
        self.inputImage = inputImage
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                let image = render()
                let screenWidth = UIScreen.main.bounds.width
                let scaleValue = screenWidth / image.size.width
                let scale = CGSize(width: scaleValue, height: scaleValue)

                Image(uiImage: image)
                    .scaleEffect(scale)
                    .frame(width: screenWidth, height: image.size.height * scaleValue)

                Text("Filter settings")
                    .font(.title)

                Spacer()

                VStack {
                    settings.makeSwiftView(binding: $settings)
                }
                .padding()
            }
        }
    }

    private func render() -> UIImage {
        let filter = FilterPSD1()
        filter.inputImage = CIImage(image: inputImage)!
        filter.settings = settings
        let result = filter.outputImage!
        let cgImage = ciContext.createCGImage(result, from: result.extent)!
        return UIImage(cgImage: cgImage)
    }
}

struct PSD1Details_Preview: PreviewProvider {
    static var previews: PSD1Details {
        PSD1Details(inputImage: UIImage(named: "woman-with-short-haircut-short-sleeved-shirt-stands-front-building")!)
    }
}
