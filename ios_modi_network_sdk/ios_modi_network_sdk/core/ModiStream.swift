//
//  ModiStream.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/24.
//

import Foundation


class ModiStream {
    
    enum STREAM_TYPE : Int {
        case INTERPRETER = 3
    }
    
    enum STREAM_RESPONSE : Int {
        case SUCCESS = 0
        case DUPLICATE = 3
        case UNDEFINED = 4
        case TIMEOUT = 5
    }
    
    var moduleId : Int = 0
    var streamId : UInt8 = 0
    var streamType : STREAM_TYPE = STREAM_TYPE.INTERPRETER
    var streamBody : Array<UInt8> = []
        
    
    func makeStream(moduleId : Int, streamId : Int, streamType : STREAM_TYPE, streamBody : Array<UInt8>) -> Self {
        
        self.moduleId = moduleId
        self.streamId = UInt8(streamId)
        self.streamType = streamType
        self.streamBody = streamBody
        
        return self
    }
}
