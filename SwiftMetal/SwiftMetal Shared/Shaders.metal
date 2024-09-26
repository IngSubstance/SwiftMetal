#include <metal_stdlib>

using namespace metal;

/// executed for every vertex
//vid : Vertex Index
//vertices : vertex buffer. On CPU defined as float[6] can be interpreted here ad float2[3] without cast
vertex float4 vertexFunction(uint vid [[vertex_id]], constant float2* vertices [[buffer(0)]]) {
    return float4(vertices[vid], 0.0, 1.0);
}

/// Return RGBA color of the pixel
fragment float4 fragmentFunction() {
    return float4(0.2, 0.7, 0.9, 1.0);
}
