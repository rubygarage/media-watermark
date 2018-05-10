//
//  shader.metal
//  metal_test
//
//  Created by sergey on 6/8/17.
//  Copyright © 2017 rubygarage. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void compute_shader(texture2d<float, access::read> input [[texture(0)]],
                           texture2d<float, access::write> output [[texture(1)]],
                           const device float* data [[ buffer(0) ]],
                           uint2 gid [[thread_position_in_grid]])
{

// -- color shader -- //
    
//    float4 color = input.read(gid);
//
//    float average = (color.r + color.g + color.b) / 3.0;
//    float4 grayScale = float4(average, average, average, 1.0);
//
//    float4 colorToApply = float4(data[0], data[1], data[2], 1.0);
//
//    float4 result = grayScale * colorToApply;
//
//    output.write(float4(result.r, result.g, result.b, 1), gid);
    
// -- sepia shader -- //
    
//    float4 color = input.read(gid);
//
//    float outputRed = (color.r * .393) + (color.g *.769) + (color.b * .189);
//    float outputGreen = (color.r * .349) + (color.g *.686) + (color.b * .168);
//    float outputBlue = (color.r * .272) + (color.g *.534) + (color.b * .131);
//
//    output.write(float4(outputRed, outputGreen, outputBlue, 1), gid);
    
    

}
