import CoreGraphics
import Foundation
import ImageIO

public enum ColorCubeLoaderError: Error {
    case failedToGetDimensionFromFilename(String)
    case failedToCreageCGDataProvider(String)
    case failedToCraeteCGImageSource(String)
}

/// An object for loading color-cube image from bundle.
/// It finds based on specified naming-rule.
///
/// `LUT_<Dimension>_<filterName>.<extension {jpg, png}>`
public final class ColorCubeLoader {
    public let bundle: Bundle

    public init(bundle: Bundle) {
        self.bundle = bundle
    }

    func load() throws -> [FilterColorCube] {
        let rootPath = bundle.bundlePath as NSString
        let fileList = try FileManager.default.contentsOfDirectory(atPath: rootPath as String)

        let filters =
        try fileList
            .filter { $0.hasPrefix("LUT_") }
            .sorted()
            .map { path -> FilterColorCube in

                let url = URL(fileURLWithPath: rootPath.appendingPathComponent(path))

                guard let dimension = takeDimension(from: path) else {
                    throw ColorCubeLoaderError.failedToGetDimensionFromFilename(path)
                }

                guard let dataProvider = CGDataProvider(url: url as CFURL) else {
                    throw ColorCubeLoaderError.failedToCreageCGDataProvider(path)
                }

                guard let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil) else {
                    throw ColorCubeLoaderError.failedToCraeteCGImageSource(path)
                }

                let name = (path as NSString).deletingPathExtension
                    .replacingOccurrences(of: "LUT_\(dimension)_", with: "")

                let filter = FilterColorCube()
                filter.dimension = dimension
                filter.lutImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
                filter.lutName = (path as NSString).lastPathComponent
                return filter
            }
        return filters
    }

    func load(at url: URL) throws -> FilterColorCube {
        let filename = url.lastPathComponent

        guard let dimension = takeDimension(from: filename) else {
            throw ColorCubeLoaderError.failedToGetDimensionFromFilename(filename)
        }

        guard let dataProvider = CGDataProvider(url: url as CFURL) else {
            throw ColorCubeLoaderError.failedToCreageCGDataProvider(filename)
        }

        guard let imageSource = CGImageSourceCreateWithDataProvider(dataProvider, nil) else {
            throw ColorCubeLoaderError.failedToCraeteCGImageSource(filename)
        }

        let filter = FilterColorCube()
        filter.dimension = dimension
        filter.lutImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
        filter.lutName = filename
        return filter
    }

    private func takeDimension(from string: String) -> Int? {
        enum Static {
            static let regex: NSRegularExpression = {
                let pattern = "LUT_([0-9]+)_.*"
                let regex = try! NSRegularExpression(pattern: pattern, options: [])
                return regex
            }()
        }

        guard
            let matched = Static.regex.firstMatch(
                in: string,
                options: [],
                range: NSRange(location: 0, length: string.count)
            )
        else {
            return nil
        }

        let numberString = (string as NSString).substring(with: matched.range(at: 1))

        return Int(numberString)
    }
}
