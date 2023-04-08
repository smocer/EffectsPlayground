import CoreGraphics
import CoreImage

/// A Filter using LUT Image (backed by CIColorCubeWithColorSpace)
/// About LUT Image -> https://en.wikipedia.org/wiki/Lookup_table
final class FilterColorCube: CIFilter {
    @objc dynamic
    var inputImage: CIImage?
    var lutName: String?
    var amount: Double = 1
    var lutImage: CGImage?
    var dimension: Int?

    override var outputImage: CIImage? {
        guard let image = inputImage,
              let lutImage,
              let dimension
        else {
            return nil
        }

        let f: CIFilter = ColorCubeHelper.makeColorCubeFilter(
            lutImage: lutImage,
            dimension: dimension
        )

        f.setValue(image, forKeyPath: kCIInputImageKey)

        let background = image
        let foreground = f.outputImage!.applyingFilter(
            "CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: 1, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 1, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: CGFloat(amount)),
                "inputBiasVector": CIVector(x: 0, y: 0, z: 0, w: 0),
            ])

        let composition = CIFilter(
            name: "CISourceOverCompositing",
            parameters: [
                kCIInputImageKey : foreground,
                kCIInputBackgroundImageKey : background
            ])!

        return composition.outputImage!
    }
}
