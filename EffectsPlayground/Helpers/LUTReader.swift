//
//  LUTReader.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 08.04.2023.
//

import Foundation

struct RGB {
    let r: Float
    let g: Float
    let b: Float
    let a: Float

    init?(string: String) {
        let rgb = string.split(separator: " ")
        guard
            rgb.count == 3,
            let r = Float(rgb[0]),
            let g = Float(rgb[1]),
            let b = Float(rgb[2])
        else {
            return nil
        }
        self.r = r
        self.g = g
        self.b = b
        self.a = 1
    }

    subscript(_ i: Int) -> Float {
        switch i {
        case 0: return r
        case 1: return g
        case 2: return b
        case 3: return a
        default: fatalError("Index is out of range")
        }
    }
}

func readLUT(fileURL: URL) -> (Data, Int) {
    let debugStart = Date()
    let string = try! String(contentsOfFile: fileURL.path, encoding: .utf8)
    let sizeTitle = "LUT_3D_SIZE"
    var sizeString = ""
    var currentIdx = string.range(of: sizeTitle)!.upperBound
    while !CharacterSet.newlines.contains(string.unicodeScalars[currentIdx]) {
        let current = string.unicodeScalars[currentIdx]
        if CharacterSet.decimalDigits.contains(current) {
            sizeString.unicodeScalars.append(current)
        }
        currentIdx = string.index(after: currentIdx)
    }
    let dimension = Int(sizeString)!

    let lines = string.split(separator: "\n")
    let pixels = lines.compactMap { RGB(string: String($0)) }

    let dataCount = dimension * dimension * dimension * 4
    let cubeData = UnsafeMutablePointer<Float>.allocate(capacity: dataCount)

    var c = cubeData
    pixels.forEach { pixel in
        for i in (0..<3) {
            (c + i).initialize(to: pixel[i])
        }
        c += 4
    }
    print("ℹ️ Time elapsed: \(Date().timeIntervalSince(debugStart))s")

    let lutData = Data(
        bytesNoCopy: UnsafeMutableRawPointer(cubeData),
        count: dataCount * MemoryLayout<Float>.stride,
        deallocator: .free
    )

    return (lutData, dimension)
}
