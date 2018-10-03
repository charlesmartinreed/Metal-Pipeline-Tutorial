//
//  Shaders.metal
//  Pipeline
//
//  Created by Charles Martin Reed on 10/2/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// this attribute corresponds to position, it references the vertex descriptor we set up in Renderer
struct VertexIn {
    float4 position [[ attribute(0) ]];
};

// our actual vertex shader; takes VertexIn data type, returns float4
// stage_in attribute refers to the current index 
vertex float4 vertex_main(const VertexIn vertexIn [[ stage_in ]],
                          constant float &timer [[ buffer(1) ]]) {
    float4 position = vertexIn.position;
    //position.y += timer; // move up by the "timer" each frame
    position.x += timer;
    return position;
};

fragment float4 fragment_main() {
    //returns an interpolated (this is default, vs. flat) red fragmentr
    return float4(1, 0, 0, 1);
};
