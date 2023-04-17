//
//  ImageSaver.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import Foundation
import UIKit

class ImageSaver: NSObject {
    private let onSuccess: (UIImage) -> Void
    private let onError: (Error) -> Void

    init(
        onSuccess: @escaping (UIImage) -> Void = { _ in },
        onError: @escaping (Error) -> Void = { _ in }
    ) {
        self.onSuccess = onSuccess
        self.onError = onError
    }

    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error {
            return onError(error)
        }

        onSuccess(image)
    }
}
