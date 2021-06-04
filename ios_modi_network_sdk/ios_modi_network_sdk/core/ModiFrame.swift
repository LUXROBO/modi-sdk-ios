//
//  ModiFrame.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/18.
//

import Foundation

class ModiFrame  {
    
    private var mFrame = [UInt8](repeating: 0, count: 16)
    private var frame = [UInt8](repeating: 0, count: 16)

    func cmd() -> Int {

        var cmd = Array<UInt8>()
        cmd[0] = mFrame[0]
        
        return getInt(data : cmd)
    
    }
    
    func sid() -> Int {
        
        var sid = Array<UInt8>()
        sid[0] = mFrame[1]
        
        return getInt(data:  sid)
    }
    
    func did() -> Int {
        
        var did = Array<UInt8>()
        did[0] = mFrame[4]
        
        return getInt(data:  did)
        
    }
    
    func len() -> Int {
        
        var len = Array<UInt8>()
        len[0] = mFrame[6]
        
        return getInt(data:  len)
        
    }
    
    func data() -> Array<UInt8> {
        
        var data = [UInt8](repeating: 0, count: 8)
        
        for i in 8 ... frame.count {
            
            data[i - 8] = frame[i]
        }
        
        return data
    }
    
    func setFrame(frame : Array<UInt8>) {
        self.frame = frame
    }
    
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
    
    func getInt(data : Array<UInt8>) -> Int {
        
        let littleEndianValue = data.withUnsafeBufferPointer {
                 ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 2) { $0 })
        }.pointee
        let value = UInt32(littleEndianValue)
        
        return Int(value)
        
    }
    
}
