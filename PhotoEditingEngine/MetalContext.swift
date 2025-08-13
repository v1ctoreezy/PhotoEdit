//
//  MetalContext.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 03.07.2025.
//

import Foundation
import MetalKit

final class MetalContext {
    var device: MTLDevice
    var commandQueue: MTLCommandQueue
    
    init(device: MTLDevice) {
        self.device = device
        self.commandQueue = device.makeCommandQueue()!
    }
}
