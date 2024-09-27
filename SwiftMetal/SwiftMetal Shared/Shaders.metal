#include <metal_stdlib>

using namespace metal;

struct customVertex{
    float2 position;
    float3 color;
};

struct customVertexOut{
    //non mi è chiaro questo attributo ma credo che sia relativo alla simd
    float4 position [[position]];
    float3 color;
};


/// executed for every vertex
//vid : Vertex Index
//vertices : vertex buffer. On CPU defined as float[6] can be interpreted here ad float2[3] without cast
vertex customVertexOut vertexFunction(uint vid [[vertex_id]], constant customVertex* vertices [[buffer(0)]]) {
    customVertexOut out;
    out.position = float4(vertices[vid].position, 0.0, 1.0);
    out.color = vertices[vid].color;
    
    return out;
}

/// Return RGBA color of the pixel
//[[stage_in]] is the attribute to read the vertex shader data
fragment float4 fragmentFunction(customVertexOut inVertex [[stage_in]]) {
    return float4(inVertex.color , 1.0);
}
