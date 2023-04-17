//
//  EffectsShowcaseView.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 07.04.2023.
//

import SwiftUI
import CoreImage
import YPImagePicker

struct EffectsShowcaseView: View {
    @State
    private var items = EffectsShowcase.shared.renderExamples()
    @State
    private var isPickerPresented = false
    @State
    private var screenWidth: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        NavigationStack {
            ScrollView([.vertical], showsIndicators: true) {
                VStack {
                    Button("Choose another photo") {
                        isPickerPresented = true
                    }
                    .sheet(isPresented: $isPickerPresented) {
                        YPImageControllerSUIWrapper(vc: makePicker())
                    }

                    Spacer(minLength: 16)

                    NavigationLink {
                        PSDDetails(inputImage: EffectsShowcase.shared.selectedImage, settings: .psd1)
                    } label: {
                        Text("PSD 1 Details")
                    }

                    Spacer(minLength: 16)

                    NavigationLink {
                        PSDDetails(inputImage: EffectsShowcase.shared.selectedImage, settings: .psd2)
                    } label: {
                        Text("PSD 2 Details")
                    }

                    Spacer(minLength: 16)

                    ForEach(items) { item in
                        HStack {
                            let halfScreen = screenWidth * 0.5
                            let scaleValue = halfScreen / item.image.size.width
                            let scale = CGSize(width: scaleValue, height: scaleValue)
                            Image(uiImage: EffectsShowcase.shared.selectedImage)
                                .scaleEffect(scale)
                                .frame(width: halfScreen, height: item.image.size.height * scaleValue)
                            Image(uiImage: item.image)
                                .scaleEffect(scale)
                                .frame(width: halfScreen, height: item.image.size.height * scaleValue)
                        }

                        Text(item.name)
                            .frame(width: screenWidth)
                    }
                }
                .frame(width: screenWidth)
            }.onRotate { orientation in
                switch orientation {
                case .unknown, .portrait, .portraitUpsideDown, .faceUp, .faceDown:
                    screenWidth = UIScreen.main.bounds.width
                case .landscapeLeft, .landscapeRight:
                    screenWidth = UIScreen.main.bounds.height
                @unknown default:
                    fatalError()
                }
            }
        }
    }

    private func makePicker() -> YPImagePicker {
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.showsCrop = .none
        config.screens = [.library]
        let imagePicker = YPImagePicker(configuration: config)
        imagePicker.didFinishPicking { items, cancelled in
            isPickerPresented = false
            if cancelled {
                return
            }
            guard case let .photo(photo) = items.first! else {
                return
            }
            EffectsShowcase.shared.selectedImage = photo.image
            self.items = EffectsShowcase.shared.renderExamples()
        }
        return imagePicker
    }
}

fileprivate struct YPImageControllerSUIWrapper: UIViewControllerRepresentable {
    fileprivate let vc: UIViewController

    func makeUIViewController(context: Context) -> some UIViewController {
        vc
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
