//
//  ModiFrame.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/18.
//

import Foundation

class ModiFrame  {
    
    private var mFrame : Array<UInt8> = []

    
    func makeFrame(cmd : Int, sid : Int, did : Int, binary : Array<UInt8>) -> Array<UInt8> {
        
    
        stuffFrameHeader(cmd:cmd, sid : sid, did : did)
        stuffFrameData(data : binary)
        
        return mFrame
    }
    
    
    private func stuffFrameHeader(cmd : Int, sid : Int, did : Int) {
        
        mFrame[0] = UInt8(cmd & 0xFF)
        mFrame[1] = UInt8(cmd >> 8 & 0xFF)
        mFrame[2] = UInt8(sid & 0xFF)
        mFrame[3] = UInt8(sid >> 8 & 0xFF)
        mFrame[4] = UInt8(cmd & 0xFF)
        mFrame[5] = UInt8(did >> 8 & 0xFF)
        
    }
    
    private func stuffFrameData(data : Array<UInt8>) {
    
        mFrame[6] = UInt8( data.count & 0xFF)
        mFrame[7] = UInt8( data.count >> 8 & 0xFF)
        
        for i in 0 ..< data.count {
            
            mFrame[i+8] = data[i]
        }
    }
    
}
