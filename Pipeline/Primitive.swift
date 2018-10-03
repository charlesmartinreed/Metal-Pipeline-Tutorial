//
//  Primitive.swift
//  Pipeline
//
//  Created by Charles Martin Reed on 10/2/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import Foundation
import MetalKit

class Primitive {
    class func makeCube(device: MTLDevice, size: Float) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        let mesh = MDLMesh(boxWithExtent: [size, size, size], segments: [1, 1, 1], inwardNormals: false, geometryType: .triangles, allocator: allocator)
        return mesh
    }
}
