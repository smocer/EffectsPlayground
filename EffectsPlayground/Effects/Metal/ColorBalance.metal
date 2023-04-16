//
//  ColorBalance.metal
//  EffectsPlayground
//
//  Created by Egor Butyrin on 14.04.2023.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h>
#include "ColorConversion.h"

float3 invLerp(float3 a, float3 b, float3 t)
{
    return (t - a) / (b - a);
}

extern "C" { namespace coreimage {
    float4 colorBalance(sampler src, float3 midtones) {
        const float2 pos = src.coord();
        const float3 col = src.sample(pos).rgb;

        const float origL = rgb2lab(col.rgb).x;

        float3 shift = mix(midtones, float3(0.0), abs(col.rgb - 0.5));

        auto result = col + shift;
        result = clamp(result, 0.0, 1.0);

        result = rgb2lab(result);
        result.x = origL;
        result = lab2rgb(result);

        return float4(result, 1.0);
    }
}
}
