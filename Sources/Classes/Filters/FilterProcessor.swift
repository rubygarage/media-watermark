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
        
        let filterName = (filter is ColorFilter || filter is SepiaFilter) ? filter.name : "default_shader"
        let shader = context?.mLibrary?.makeFunction(name: filterName)
        
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
        #if (arch(arm) || arch(arm64)) && os(iOS)

        let commandBuffer = context!.mCommandQueue!.makeCommandBuffer()!
       
        let drawingTexture = view.currentDrawable!.texture
       
        let threadGroupCount = MTLSizeMake(16, 16, 1)
        let threadGroups = MTLSizeMake(drawingTexture.width / threadGroupCount.width, drawingTexture.height / threadGroupCount.height, 1)
        
        let encoder = commandBuffer.makeComputeCommandEncoder()!
        encoder.setComputePipelineState(mPipeline!)
        encoder.setTexture(mTexture, index: 0)
        encoder.setTexture(drawingTexture, index: 1)
        
        let filterConfiguration = FilterConfiguration()
        filterConfiguration.view = view
        filterConfiguration.encoder = encoder
        filterConfiguration.sourceTexture = mTexture
        filterConfiguration.destinationTexture = drawingTexture
        filterConfiguration.filter = filter
        filterConfiguration.commandBuffer = commandBuffer
        
        if filter.hasCustomShader {
            FilterShaderParamManager.manageParameters(configuration: filterConfiguration)
        }

        encoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupCount)
        encoder.endEncoding()
        
        if !filter.hasCustomShader {
            FilterShaderParamManager.manageParameters(configuration: filterConfiguration)
        }
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
        completionClosure!(true, processFinished, UIImage.image(fromTexture: mtkView!.currentDrawable!.texture), nil)
        #endif
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderTimesCount += 1
    }
}
