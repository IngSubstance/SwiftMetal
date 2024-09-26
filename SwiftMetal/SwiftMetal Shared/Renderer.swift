import Metal
import MetalKit
import simd

class Renderer: NSObject, MTKViewDelegate {
    /// GPU handle
    var device: MTLDevice
    /// DescriptionCommand buffer to send command to GPU
    var commandQueue: MTLCommandQueue
    ///The library is the whole compiled Shaders.metal file
    var library : MTLLibrary
    var vertexFunction : MTLFunction
    var fragmentFunction : MTLFunction
    var renderPipelineState: MTLRenderPipelineState?
    var vertexBuffer : MTLBuffer
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        //compile Shaders.metal file
        self.library = device.makeDefaultLibrary()!
        self.vertexFunction = library.makeFunction(name: "vertexFunction")!
        self.fragmentFunction = library.makeFunction(name: "fragmentFunction")!
        
        ///Create Rendering Pipeline State
        ///Object that old hte compilaed shader and other relates information
        var renderPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineStateDescriptor.vertexFunction = vertexFunction
        renderPipelineStateDescriptor.fragmentFunction = fragmentFunction
        ///Pixel format rgb10a2 means that each pixel will have 10 bits for R, G and B and 2 bits for Alpha
        renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        do{
            self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineStateDescriptor)
        } catch
        {
            print("Failed to create render pipeline state")
        }
         
        ///Create Vertex Buffer
        let vertices: [Float] = [ -0.5, -0.5, 0.5, -0.5, 0.0, 0.5]
        self.vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout.stride(ofValue: vertices[0]), options: MTLResourceOptions.storageModeShared)!
    }

    func draw(in view: MTKView) {
        let commandBuffer = self.commandQueue.makeCommandBuffer()!
        
        let renderPassDescriptor = view.currentRenderPassDescriptor!
        ///attachment is an object which describes how we render to this texture
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        
        //Create render command encoder
        let renderEncode = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        //Bind render pipeline state
        renderEncode.setRenderPipelineState(self.renderPipelineState!)
        
        //Bind vertex buffer
        renderEncode.setVertexBuffer(self.vertexBuffer, offset: 0, index: 0)
        
        //Render
        renderEncode.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 3)
        
        renderEncode.endEncoding()
        
        
        let drawable = view.currentDrawable!
        commandBuffer.present(drawable)
        
        
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //Size has changed
    }
}
