//
//  FilterShaderProvider.swift
//  MediaWatermark-iOS
//
//  Created by sergey on 5/10/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Foundation

class FilterShaderProvider {
    class func provideShader(filter: MediaFilter) -> String {
        if filter is ColorFilter {
            return FilterShaderProvider.provideColorFilterShader()
        } else if filter is SepiaFilter {
            return FilterShaderProvider.provideSepiaFilterShader()
        }
        return FilterShaderProvider.defaultShader()
    }
    
    private class func defaultShader() -> String {
        return " #include <metal_stdlib>\n" +
            "using namespace metal;" +
            "kernel void default_shader(texture2d<float, access::read> input [[texture(0)]]," +
            "                         texture2d<float, access::write> output [[texture(1)]]," +
            "                         uint2 gid [[thread_position_in_grid]])" +
            "{}"
    }
    
    private class func provideColorFilterShader() -> String {
        return " #include <metal_stdlib>\n" +
        "using namespace metal;" +
        "kernel void color_shader(texture2d<float, access::read> input [[texture(0)]]," +
        "                         texture2d<float, access::write> output [[texture(1)]]," +
        "                         const device float* data [[ buffer(0) ]]," +
        "                         uint2 gid [[thread_position_in_grid]])" +
        "{" +
        "    float4 color = input.read(gid);" +
        "    float average = (color.r + color.g + color.b) / 3.0;" +
        "    float4 grayScale = float4(average, average, average, 1.0);" +
        "    float4 colorToApply = float4(data[0], data[1], data[2], 1.0);" +
        "    float4 result = grayScale * colorToApply;" +
        "    output.write(float4(result.r, result.g, result.b, 1), gid);" +
        "}"
    }
    
    private class func provideSepiaFilterShader() -> String {
        return " #include <metal_stdlib>\n" +
            "using namespace metal;" +
            "kernel void sepia_shader(texture2d<float, access::read> input [[texture(0)]]," +
            "                         texture2d<float, access::write> output [[texture(1)]]," +
            "                         const device float* data [[ buffer(0) ]]," +
            "                         uint2 gid [[thread_position_in_grid]])" +
            "{" +
                "float4 color = input.read(gid);" +
                "float outputRed = (color.r * .393) + (color.g *.769) + (color.b * .189);" +
                "float outputGreen = (color.r * .349) + (color.g *.686) + (color.b * .168);" +
                "float outputBlue = (color.r * .272) + (color.g *.534) + (color.b * .131);" +
                "output.write(float4(outputRed, outputGreen, outputBlue, 1), gid);" +
            "}"
    }
}
