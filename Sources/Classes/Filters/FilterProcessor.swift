//
//  FilterProcessor.swift
//  MediaWatermark-iOS
//
//  Created by sergey on 4/19/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import MetalPerformanceShaders

public class FilterProcessor: NSObject, MTKViewDelegate {
    var context: GraphicContext?
    var mtkView: MTKView?
    var mPipeline: MTLComputePipelineState?
    var mTexture: MTLTexture?
    var completionClosure: ((_ success: Bool, _ image: UIImage?, _ error: Error?) -> ())?
    var filter: MediaFilter! = nil
    var mainView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    init(mediaFilter: MediaFilter) {
        super.init()
        
        filter = mediaFilter
        context = GraphicContext()
    }
    
    func processImage(image: UIImage, completion: @escaping ((_ success: Bool, _ image: UIImage?, _ error: Error?) -> ())) {
        mtkView = MTKView(frame: mainView.bounds)
        mainView.addSubview(mtkView!)
        
        mtkView?.device = context!.mDevice!
        mtkView?.delegate = self
        mtkView?.framebufferOnly = false
        mtkView?.autoResizeDrawable = false
        mtkView?.drawableSize = image.size
        
        
        
        completionClosure = completion
        
        let shader = context?.mLibrary?.makeFunction(name: "compute_shader")
        
        do {
            mPipeline = try context?.mDevice?.makeComputePipelineState(function: shader!)
            
            let textureLoader = MTKTextureLoader(device: context!.mDevice!)
            mTexture = try textureLoader.newTexture(cgImage: image.cgImage!, options: [MTKTextureLoader.Option.SRGB: false])
            
        } catch {
            completionClosure!(false, nil, error)
        }
    }
    
    public func draw(in view: MTKView) {
        let commandBuffer = context!.mCommandQueue!.makeCommandBuffer()!
        let drawingTexture = view.currentDrawable!.texture
        
        let threadGroupCount = MTLSizeMake(16, 16, 1)
        let threadGroups = MTLSizeMake(drawingTexture.width / threadGroupCount.width, drawingTexture.height / threadGroupCount.height, 1)
        
        let encoder = commandBuffer.makeComputeCommandEncoder()!
        encoder.setComputePipelineState(mPipeline!)
        encoder.setTexture(mTexture, index: 0)
        encoder.setTexture(drawingTexture, index: 1)
    
        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        encoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
        completionClosure!(true, UIImage.image(fromTexture: mtkView!.currentDrawable!.texture), nil)

    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print()
    }
}
