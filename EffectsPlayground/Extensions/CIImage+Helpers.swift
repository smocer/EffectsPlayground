//
//  CIImage+Helpers.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import Foundation
import CoreImage

extension CIImage {
    func withOpacity(alpha: Double) -> CIImage {
        guard let overlayFilter: CIFilter = CIFilter(name: "CIColorMatrix") else { fatalError() }
        let alphaVector: CIVector = CIVector(x: 0, y: 0, z: 0, w: alpha)
        overlayFilter.setValue(self, forKey: kCIInputImageKey)
        overlayFilter.setValue(alphaVector, forKey: "inputAVector")

        return overlayFilter.outputImage!
    }

    func movedToZeroOrigin() -> CIImage {
        transformed(by: CGAffineTransform(
            translationX: -extent.minX,
            y: -extent.minY
        ))
    }

    func aligningOrigin(to newOrigin: CGPoint) -> CIImage {
        transformed(by: CGAffineTransform(
            translationX: -extent.minX + newOrigin.x,
            y: -extent.minY + newOrigin.y
        ))
    }

    func scaledToSize(_ size: CGSize) -> CIImage {
        transformed(by: CGAffineTransform(
            scaleX: size.width / extent.width,
            y: size.height / extent.height
        ))
    }

    func transformExtent(to newExtent: CGRect) -> CIImage {
        scaledToSize(newExtent.size).aligningOrigin(to: newExtent.origin)
    }

    func centerCropped(toSize dstSize: CGSize) -> CIImage {
        let cropOrigin = CGPoint(
            x: (extent.width - dstSize.width) / 2 + extent.origin.x,
            y: (extent.height - dstSize.height) / 2 + extent.origin.y)
        return cropped(to: CGRect(origin: cropOrigin, size: dstSize))
    }

    func cropExtraTransparentPixelsFromEdges(context: CIContext) -> CIImage {
            let cgImage = cgImage ?? context.createCGImage(self, from: extent)!

            let width = cgImage.width
            let height = cgImage.height

            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bytesPerPixel = 4
            let bytesPerRow = bytesPerPixel * width
            let bitsPerComponent = 8
            let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

            guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo),
                  let ptr = context.data?.assumingMemoryBound(to: UInt8.self) else {
                return self
            }

            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

            var minX = width
            var minY = height
            var maxX: Int = 0
            var maxY: Int = 0

        for x in 1 ..< width {
            for y in 1 ..< height {
                let i = bytesPerRow * Int(y) + bytesPerPixel * Int(x)
                let a = CGFloat(ptr[i + 3]) / 255.0

                if a > 0.05 {
                    if (x < minX) { minX = x }
                    if (x > maxX) { maxX = x }
                    if (y < minY) { minY = y }
                    if (y > maxY) { maxY = y }
                }
            }
        }

        let rect = CGRect(x: CGFloat(minX),y: CGFloat(minY), width: CGFloat(maxX-minX), height: CGFloat(maxY-minY))
        return CIImage(cgImage: cgImage.cropping(to: rect)!)
    }
}
