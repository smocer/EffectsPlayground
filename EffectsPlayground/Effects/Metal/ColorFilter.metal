//
//  ColorFilter.metal
//  EffectsPlayground
//
//  Created by Egor Butyrin on 13.04.2023.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h>
#include "ColorConversion.h"

extern "C" { namespace coreimage {
    float4 colorFilter(sampler src, float density, float3 colorizeCol) {
        float2 pos = src.coord();
        float4 col = src.sample(pos);

        const float origL = rgb2lab(col.rgb).x;

        auto result = colorizeCol * col.rgb;

        result = rgb2lab(result);
        result.x = origL;
        result = lab2rgb(result);

        return float4(mix(col.rgb, result, density), 1.0);
    }
}
}
