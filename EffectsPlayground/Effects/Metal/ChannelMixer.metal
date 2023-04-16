//
//  ChannelMixer.metal
//  EffectsPlayground
//
//  Created by Egor Butyrin on 14.04.2023.
//

#include <metal_stdlib>
using namespace metal;
#include <CoreImage/CoreImage.h>
#include "ColorConversion.h"

extern "C" { namespace coreimage {
    float4 channelMixer(sampler src, float4 redOutput, float4 greenOutput, float4 blueOutput) {
        const float2 pos = src.coord();
        const float3 col = src.sample(pos).rgb;

        const float origL = rgb2lab(col.rgb).x;

        // https://docs.gimp.org/en/gimp-filter-channel-mixer.html
        const float r = dot(col, redOutput.rgb) + dot(col, float3(redOutput.a));
        const float g = dot(col, greenOutput.rgb) + dot(col, float3(greenOutput.a));
        const float b = dot(col, blueOutput.rgb) + dot(col, float3(blueOutput.a));

        auto result = float3(r, g, b);

        result = rgb2lab(result);
        result.x = origL;
        result = lab2rgb(result);

        return float4(result, 1.0);
    }
}
}

