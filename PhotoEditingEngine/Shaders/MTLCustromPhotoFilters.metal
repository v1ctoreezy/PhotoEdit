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
