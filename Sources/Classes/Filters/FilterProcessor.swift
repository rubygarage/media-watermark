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
    var completionClosure: ((_ success: Bool, _ finished: Bool, _ image: UIImage?, _ error: Error?) -> ())?
    var filter: MediaFilter! = nil
    
    private var renderTimesCount: Int = 0
    private var processFinished: Bool = false
    
    init(mediaFilter: MediaFilter) {
        super.init()
        
        filter = mediaFilter
        context = GraphicContext(mediaFilter: filter)
    }
    
    func processImage(image: UIImage, completion: @escaping ((_ success: Bool, _ finished: Bool, _ image: UIImage?, _ error: Error?) -> ())) {
        mtkView = MTKView(frame: CGRect.zero)
        
        mtkView?.device = context!.mDevice!
        mtkView?.delegate = self
        mtkView?.framebufferOnly = false
        mtkView?.autoResizeDrawable = false
        mtkView?.drawableSize = image.size
        
        completionClosure = completion
        
        let shader = context?.mLibrary?.makeFunction(name: filter.name)
        
        do {
            mPipeline = try context?.mDevice?.makeComputePipelineState(function: shader!)
             
            let textureLoader = MTKTextureLoader(device: context!.mDevice!)
            mTexture = try textureLoader.newTexture(cgImage: image.cgImage!, options: [MTKTextureLoader.Option.SRGB: false])
            
            mtkView!.draw()
            
            for i in 0...renderTimesCount {
                processFinished = i == renderTimesCount
                mtkView!.draw()
            }
        } catch {
            completionClosure!(false, false, nil, error)
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
    
//        let colorFilter = filter as! ColorFilter
//
//        var data = [CFloat(colorFilter.r), CFloat(colorFilter.g), CFloat(colorFilter.b)]
//        let dataBuffer = view.device!.makeBuffer(bytes: &data, length: MemoryLayout.stride(ofValue: data), options: [])
//        encoder.setBuffer(dataBuffer!, offset: 0, index: 0)
        
        FilterShaderParamManager.manageParameters(fromFilter: filter, toEncoder: encoder, withView: view)
        
        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        encoder.endEncoding()
        
//        let blurFilter = MPSImageGaussianBlur(device: context!.mDevice!, sigma: 45.0)
//        blurFilter.encode(commandBuffer: commandBuffer, sourceTexture: mTexture!, destinationTexture: drawingTexture)
        
//        let sobelFilter = MPSImageSobel(device: context!.mDevice!)
//        sobelFilter.encode(commandBuffer: commandBuffer, sourceTexture: mTexture!, destinationTexture: drawingTexture)
        
//                let thresholdFilter = MPSImageThresholdToZero(device: context!.mDevice!, thresholdValue: 0.5, linearGrayColorTransform: nil)
//                thresholdFilter.encode(commandBuffer: commandBuffer, sourceTexture: mTexture!, destinationTexture: drawingTexture)
//
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
        completionClosure!(true, processFinished, UIImage.image(fromTexture: mtkView!.currentDrawable!.texture), nil)
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderTimesCount += 1
    }
}
