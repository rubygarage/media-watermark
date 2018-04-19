//
//  Images.swift
//  MediaWatermark
//
//  Created by Sergei on 04/05/2017.
//  Copyright © 2017 rubygarage. All rights reserved.
//

import Metal
import UIKit

let kImageBitsPerComponent: Int = 8
let kImageBitsPerPixel: Int = 32
let kImageBytesCount: Int = 4

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
    
    class func image(fromTexture: MTLTexture) -> UIImage {
        let width = fromTexture.width
        let height = fromTexture.height
        
        let rowBytes = width * kImageBytesCount
        let textureResize = width * height * kImageBytesCount
        
        let memory = malloc(textureResize)
        
        fromTexture.getBytes(memory!, bytesPerRow: rowBytes, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.first.rawValue
        
        let releaseMaskImagePixelData: CGDataProviderReleaseDataCallback = { (info: UnsafeMutableRawPointer?, data: UnsafeRawPointer, size: Int) -> () in
            return
        }
        
        let provider = CGDataProvider(dataInfo: nil, data: memory!, size: textureResize, releaseData: releaseMaskImagePixelData)
        let cgImageRef = CGImage(width: width,
                                 height: height,
                                 bitsPerComponent: kImageBitsPerComponent,
                                 bitsPerPixel: kImageBitsPerPixel,
                                 bytesPerRow: rowBytes,
                                 space: colorSpace,
                                 bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo),
                                 provider: provider!,
                                 decode: nil,
                                 shouldInterpolate: true,
                                 intent: CGColorRenderingIntent.defaultIntent)
        
        return UIImage(cgImage: cgImageRef!)
    }
}
