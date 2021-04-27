//
//  ModiStream.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/24.
//

import Foundation

class ModiStream : NSObject {
    
    enum STREAM_TYPE {
        case INTERPRETER
    }
    
    enum STREAM_RESPONSE {
        case SUCCESS
        case DUPLICATE
        case UNDEFINED
        case TIMEOUT
    }
    
    private var moduleId : Int = 0
    private var streamId : UInt8 = 0
    private var streamType : STREAM_TYPE = STREAM_TYPE.INTERPRETER
    private var streamBody : Array<UInt8> = []
        
    func makeStream(moduleId : Int, streamId : Int, streamType : STREAM_TYPE, streamBody : Array<UInt8>) -> Self {
        
        self.moduleId = moduleId
        self.streamId = UInt8(streamId)
        self.streamType = streamType
        self.streamBody = streamBody
        
        return self
    }
}
