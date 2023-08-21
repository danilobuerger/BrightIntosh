//
//  Overlay.swift
//  BrightIntosh
//
//  Created by Niklas Rousset 12.07.23.
//

import Cocoa
import MetalKit

class Overlay: MTKView, MTKViewDelegate {
    private let colorSpace = CGColorSpace(name: CGColorSpace.extendedLinearSRGB)
    
    private var commandQueue: MTLCommandQueue?
    
    private var fragmentColor = vector_float4(1.0, 1.0, 1.0, 1.0)
    
    private let screen: NSScreen
    
    init(frame: CGRect, screen: NSScreen) {
        self.screen = screen
        super.init(frame: frame, device: MTLCreateSystemDefaultDevice())
        
        guard let device else {
            fatalError("No metal device")
        }
        
        autoResizeDrawable = false
        drawableSize = CGSize(width: 1, height: 1)
        
        commandQueue = device.makeCommandQueue()
        
        if commandQueue == nil {
            fatalError("Could not create command queue")
        }
        
        delegate = self
        preferredFramesPerSecond = screen.maximumFramesPerSecond
        colorPixelFormat = .rgba16Float
        colorspace = colorSpace
        clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0)
        
        if let layer = self.layer as? CAMetalLayer {
            layer.wantsExtendedDynamicRangeContent = true
            layer.isOpaque = false
            layer.pixelFormat = .rgba16Float
        }
        
        
        
        screenUpdate(screen: screen)
    }
    
    func activateHighlightMode() {
        if let layer = self.layer as? CAMetalLayer {
            layer.compositingFilter = "multiply"
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func screenUpdate(screen: NSScreen) {
        let maxEdrValue = screen.maximumExtendedDynamicRangeColorComponentValue
        let maxRenderedEdrValue = screen.maximumReferenceExtendedDynamicRangeColorComponentValue
        
        let factor = maxEdrValue / max(maxRenderedEdrValue, 1.0) - 1.0
        clearColor = MTLClearColorMake(factor, factor, 0.0, 1.0)
    }
    
    func draw(in view: MTKView) {
        guard let commandQueue = commandQueue,
              let renderPassDescriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
}
