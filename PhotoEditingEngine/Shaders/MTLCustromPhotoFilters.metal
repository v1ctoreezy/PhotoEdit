//
//  MTLCustromPhotoFilters.metal
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 04.07.2025.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float2 position;
    float2 texCoord;
};

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexOut vertex_passthrough(uint vertexID [[vertex_id]],
                                    const device VertexIn* vertexArray [[buffer(0)]]) {
    VertexIn inVertex = vertexArray[vertexID];
    
    VertexOut out;
    out.position = float4(inVertex.position, 0, 1);
    out.texCoord = inVertex.texCoord;
    return out;
}

fragment float4 standartColor(VertexOut in [[stage_in]],
                              texture2d<float> inputTexture [[texture(0)]],
                              sampler inputSampler [[sampler(0)]]) {
    float4 color = inputTexture.sample(inputSampler, in.texCoord);
    return color;
}

fragment float4 invertColors(VertexOut in [[stage_in]],
                             texture2d<float> inputTexture [[texture(0)]],
                             sampler inputSampler [[sampler(0)]]) {
    float4 color = inputTexture.sample(inputSampler, in.texCoord);
    return float4(1.0 - color.rgb, color.a);
}

fragment float4 linearBurn(VertexOut in [[stage_in]],
                           texture2d<float> inputTexture [[texture(0)]],
                           sampler inputSampler [[sampler(0)]]) {
    float4 color = inputTexture.sample(inputSampler, in.texCoord);
    return color;
}

// Photo Instruments Shaders
fragment float4 expositionFilter(VertexOut in [[stage_in]],
                                texture2d<float> inputTexture [[texture(0)]],
                                sampler inputSampler [[sampler(0)]],
                                constant float &exposition [[buffer(0)]]) {
    float4 color = inputTexture.sample(inputSampler, in.texCoord);
    
    // Apply exposition adjustment
    // Exposition typically affects brightness by multiplying RGB values
    float exposureMultiplier = pow(2.0, exposition);
    color.rgb *= exposureMultiplier;
    
    return color;
}

fragment float4 contrastFilter(VertexOut in [[stage_in]],
                              texture2d<float> inputTexture [[texture(0)]],
                              sampler inputSampler [[sampler(0)]],
                              constant float &contrast [[buffer(0)]]) {
    float4 color = inputTexture.sample(inputSampler, in.texCoord);
    
    // Apply contrast adjustment
    // Contrast affects the difference between light and dark areas
    float contrastFactor = (contrast + 1.0) / (1.0 - contrast);
    color.rgb = (color.rgb - 0.5) * contrastFactor + 0.5;
    
    return color;
}

fragment float4 saturationFilter(VertexOut in [[stage_in]],
                                texture2d<float> inputTexture [[texture(0)]],
                                sampler inputSampler [[sampler(0)]],
                                constant float &saturation [[buffer(0)]]) {
    float4 color = inputTexture.sample(inputSampler, in.texCoord);
    
    // Apply saturation adjustment
    // Convert to grayscale and blend with original based on saturation
    float gray = dot(color.rgb, float3(0.299, 0.587, 0.114));
    color.rgb = mix(float3(gray), color.rgb, 1.0 + saturation);
    
    return color;
}

fragment float4 whiteBalanceFilter(VertexOut in [[stage_in]],
                                  texture2d<float> inputTexture [[texture(0)]],
                                  sampler inputSampler [[sampler(0)]],
                                  constant float &whiteBalance [[buffer(0)]]) {
    float4 color = inputTexture.sample(inputSampler, in.texCoord);
    
    // Apply white balance adjustment
    // White balance affects color temperature
    float temperature = whiteBalance * 0.1; // Scale down the effect
    
    // Warm/cool adjustment
    if (temperature > 0) {
        // Warm (more red/yellow)
        color.r += temperature * 0.1;
        color.g += temperature * 0.05;
    } else {
        // Cool (more blue)
        color.b += abs(temperature) * 0.1;
    }
    
    return color;
}
