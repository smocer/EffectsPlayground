//
//  PSDDetails.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import SwiftUI
import Combine

private let ciContext = CIContext()

private var timer: Timer?

struct PSDDetails: View {
    private let inputImage: UIImage
    @State
    private var settings: PSDSettings
    @State
    private var saveButtonText = "Save to gallery"
    @State
    private var isSaveButtonDisabled = false

    init(inputImage: UIImage, settings: PSDSettings = .default) {
        self.inputImage = inputImage
        self.settings = settings
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                let image = render()

                Button(saveButtonText) {
                    isSaveButtonDisabled = true
                    saveButtonText = "Saving..."
                    let imageSaver = ImageSaver() { _ in
                        saveButtonText = "✅ Saved successfully"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            saveButtonText = "Save to gallery"
                            isSaveButtonDisabled = false
                        }
                    } onError: { error in
                        saveButtonText = "❌ Error: \(error.localizedDescription)"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            saveButtonText = "Save to gallery"
                            isSaveButtonDisabled = false
                        }
                    }
                    imageSaver.writeToPhotoAlbum(image: image)
                }
                .disabled(isSaveButtonDisabled)

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
        let filter = FilterPSD()
        filter.inputImage = CIImage(image: inputImage)!
        filter.settings = settings
        let result = filter.outputImage!
        let cgImage = ciContext.createCGImage(result, from: result.extent)!
        return UIImage(cgImage: cgImage)
    }
}

struct PSDDetails_Preview: PreviewProvider {
    static var previews: PSDDetails {
        PSDDetails(inputImage: UIImage(named: "woman-with-short-haircut-short-sleeved-shirt-stands-front-building")!)
    }
}
