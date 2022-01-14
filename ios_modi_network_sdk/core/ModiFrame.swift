//
//  ModiFrame.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/18.
//

import Foundation

open class ModiFrame  {
    
    private var mFrame = [UInt8](repeating: 0, count: 16)
    private var frame = [UInt8](repeating: 0, count: 16)

    public init() {}
    
    open func cmd() -> Int {

        return Int(mFrame[0])
    
    }
    
    func sid() -> Int {
        
        return Int(mFrame[2])
    }
    
    func did() -> Int {
        
        return Int(mFrame[4])
        
    }
    
    func len() -> Int {
        
        return Int(mFrame[6])
        
    }
    
    open func data() -> [UInt8] {
        
        var data = [UInt8](repeating: 0, count: 8)
        
        for i in 8 ... mFrame.count - 1 {
            
            data[i - 8] = mFrame[i]
        }
        
        return data
    }
    
    open func setFrame(data : Data) {
        
        for i in 0...data.count - 1 {
            
            frame[i] = data[i]
        }
        
        mFrame = frame
        
    }
    
    func getFrame() -> ModiFrame {
        
        return self
    }
    
    open func makeFrame(cmd : Int, sid : Int, did : Int, binary : [UInt8]) -> [UInt8] {
        
    
        stuffFrameHeader(cmd:cmd, sid : sid, did : did)
        stuffFrameData(data : binary)
        
        return mFrame
    }
    
    
    private func stuffFrameHeader(cmd : Int, sid : Int, did : Int) {
        
        mFrame[0] = UInt8(cmd & 0xFF)
        mFrame[1] = UInt8(cmd >> 8 & 0xFF)
        mFrame[2] = UInt8(sid & 0xFF)
        mFrame[3] = UInt8(sid >> 8 & 0xFF)
        mFrame[4] = UInt8(did & 0xFF)
        mFrame[5] = UInt8(did >> 8 & 0xFF)
        
    }
    
    private func stuffFrameData(data : [UInt8] ) {
    
        mFrame[6] = UInt8( data.count & 0xFF)
        mFrame[7] = UInt8( data.count >> 8 & 0xFF)
        
        for i in 0 ..< data.count {
            
            mFrame[i+8] = data[i]
        
        }
        
    }
    
    open func getInt(data : Array<UInt8>) -> Int {
                
        let littleEndianValue = data.withUnsafeBufferPointer {
                 ($0.baseAddress!.withMemoryRebound(to: Int.self, capacity: 8) { $0 })
        }.pointee.littleEndian
    
        return littleEndianValue
        
    }
    
}
