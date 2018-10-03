//
//  Renderer.swift
//  Pipeline
//
//  Created by Charles Martin Reed on 10/2/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import Foundation
import MetalKit


// create initializer
class Renderer: NSObject {
    
    //MARK:- Properties
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    
    var timer: Float = 0
    
    // no reference to MTLLibrary because we won't need to keep one.
    
    init(metalView: MTKView) {
        // initialize the GPU and create the command queue
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("GPU not available")
        }
        metalView.device = device
        Renderer.commandQueue = device.makeCommandQueue()
        
        //MARK:- Mesh setup
        let mdlMesh = Primitive.makeCube(device: device, size: 1)
        do {
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch let error {
            print(error.localizedDescription)
        }
        
        //MARK:- Buffer setup
        // adding our mesh data to a buffer, before passing to pipline
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        //MARK:- Library and Pipeline descriptor/state setup
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        // this tells the GPU how to interpret the vertex data presented by the buffer
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            print(error.localizedDescription)
        }
        
        super.init()
        
        metalView.clearColor = MTLClearColorMake(1.0, 1.0, 0.8, 1.0)
        metalView.delegate = self // lets renderer call the MTKViewDelegate drawing methods
    }
}

extension Renderer: MTKViewDelegate {
    //MARK:- Delegate methods
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // called every time the size of the window changes
    }
    
    func draw(in view: MTKView) {
        // MARK:- Set up for the render command encoder and drawable textures
        guard let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
                return
        }
        
        //MARK:- Drawing code
        //give data and pipeline state to the cPU and issue draw call
        
        //MARK:- Moving the cube!
        timer += 0.05 // add timer to every frame
        var currentTime = sin(timer) // because we need values between -1 an 1 to move the vertices, we can use sin
        
        renderEncoder.setVertexBytes(&currentTime, length: MemoryLayout<Float>.stride, index: 1) //we can use setVertexBytes instead of MTLBuffer because we're sending a small amount of data to the GPU, less than 4KB
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}
