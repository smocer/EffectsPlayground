//
//  Vector.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import CoreImage

struct Vector {
    var x: CGFloat = 0
    var y: CGFloat = 0
    var z: CGFloat = 0
    var w: CGFloat = 0
}

extension Vector {
    var ciVector: CIVector {
        CIVector(x: x, y: y, z: z, w: w)
    }
}

extension CGColor {
    var ciVector: CIVector {
        CIVector(values: components!, count: components!.count - 1)
    }
}
