import Metal
import MetalKit
import simd

struct Vertex {
    //use simd, to match with shader's type
    var position : simd_float2
    var color : simd_float3
}

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
    var vertexDescriptor : MTLVertexDescriptor
    
    init?(metalKitView: MTKView) {
        self.device = metalKitView.device!
        self.commandQueue = self.device.makeCommandQueue()!
        
        //vertex descriptors
        self.vertexDescriptor = MTLVertexDescriptor()
        
        vertexDescriptor.layouts[30].stride = MemoryLayout<Vertex>.stride
        vertexDescriptor.layouts[30].stepRate = 1
        vertexDescriptor.layouts[30].stepFunction = MTLVertexStepFunction.perVertex
        
        //position attriubute
        vertexDescriptor.attributes[0].format = MTLVertexFormat.float2
        vertexDescriptor.attributes[0].offset = MemoryLayout.offset(of: \Vertex.position)!
        vertexDescriptor.attributes[0].bufferIndex = 30
        
        //color attribute
        vertexDescriptor.attributes[1].format = MTLVertexFormat.float3
        vertexDescriptor.attributes[1].offset = MemoryLayout.offset(of: \Vertex.color)!
        vertexDescriptor.attributes[1].bufferIndex = 30
        
        
        
        //compile Shaders.metal file
        self.library = device.makeDefaultLibrary()!
        self.vertexFunction = library.makeFunction(name: "vertexFunction")!
        self.fragmentFunction = library.makeFunction(name: "fragmentFunction")!
        
        ///Create Rendering Pipeline State
        ///Object that old hte compilaed shader and other relates information
        let renderPipelineStateDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineStateDescriptor.vertexFunction = vertexFunction
        renderPipelineStateDescriptor.fragmentFunction = fragmentFunction
        renderPipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        ///Pixel format rgb10a2 means that each pixel will have 10 bits for R, G and B and 2 bits for Alpha
        renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        do{
            self.renderPipelineState = try device.makeRenderPipelineState(descriptor: renderPipelineStateDescriptor)
        } catch
        {
            print("Failed to create render pipeline state")
        }
         
        ///Create Vertex Buffer for a Quad
        let vertices: [Vertex] = [
            Vertex(position: simd_float2(-0.5, -0.5), color: simd_float3(1.0, 0.0, 0.0)), //vertex 0
            Vertex(position: simd_float2( 0.5, -0.5), color: simd_float3(0.0, 1.0, 0.0)), //vertex 1
            Vertex(position: simd_float2( 0.5,  0.5), color: simd_float3(0.0, 0.0, 1.0)), //vertex 2
            Vertex(position: simd_float2(-0.5, -0.5), color: simd_float3(1.0, 0.0, 0.0)), //vertex 0
            Vertex(position: simd_float2( 0.5,  0.5), color: simd_float3(0.0, 0.0, 1.0)), //vertex 2
            Vertex(position: simd_float2(-0.5,  0.5), color: simd_float3(1.0, 0.0, 1.0))  //vertex 3
        ]
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
        
        //Bind vertex buffer.  Index 30 is the highest buffer index, chosed to left free the 0th
        renderEncode.setVertexBuffer(self.vertexBuffer, offset: 0, index: 30)
        
        //Render
        renderEncode.drawPrimitives(type: MTLPrimitiveType.triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncode.endEncoding()
        
        
        let drawable = view.currentDrawable!
        commandBuffer.present(drawable)
        
        
        commandBuffer.commit()
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //Size has changed
    }
}
