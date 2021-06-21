//
//  CrcCalculator.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/05/28.
//

import Foundation

class CrcCalculator {
    
    private var params : AlgoParams
    private var hashSize = 8
    private var mask : UInt64 = 0xFFFFFFFFFFFFFFFF
    private var table = [UInt64](repeating: 0, count: 256)
    
    init(params : AlgoParams) {
        self.params = params
        hashSize = params.hashSize
        
        if hashSize < 64 {
            mask = (1 << hashSize) - 1
        }
        
        createTable()
    }
    
    private func createTable() {
        
        for i in 0...table.count - 1 {
            table[i] = createTableEntry(index : i)
            
        }
    }
    
    private func createTableEntry(index : Int) -> UInt64 {
        
        var r = UInt64(index)
      
        if params.refIn {
            r = reverseBits(index: r, valueLength: hashSize)
        }
        
        else if hashSize > 8 {
            r <<= hashSize - 8
        }
        
        let lastBit : UInt64 = 1 << UInt64(hashSize - 1)
    
        for _ in 0...7 {
            
            if (r & lastBit) != 0 {
                r =  (r << 1) ^ params.poly
            }
            
            else {
                r <<= 1
            }
        }
    
        
        if params.refOut {
            r = reverseBits(index: r, valueLength: hashSize)
        }
        
        
        return r & mask
    }
    
    private func reverseBits(index : UInt64, valueLength : Int) -> UInt64 {
        
        var newValue : UInt64 = 0
        var ul = index
        
        for i in (0...valueLength - 1).reversed() {
            
            newValue |= (ul & 1) << i
            ul >>= 1
        }
        
        return newValue
    }
    
    
    private func computeCalc(initial : UInt64, data : [UInt8], offset : Int, length : Int) -> Int {
        
        var crc = initial
        
        if params.refOut {
            
            for i in offset ..< offset + length {
                crc = table[Int(crc) ^ Int(data[i]) & 0xFF] ^ (crc & 0xFFFF) >> 8
                crc &= mask
            }
            
            return Int(crc)
        }
        
        var toRight = hashSize - 8
        toRight = toRight < 0 ? 0 : toRight
        
        for i in offset ..< offset + length {
            crc = table[Int(crc >> toRight) ^ Int(data[i]) & 0xFF] ^ crc << 8

            crc &= mask
    
            
        }
      
        return Int(crc)
    }
    
    func calc(data : [UInt8], offset : Int, length : Int) -> Int {
        let initial : UInt64 = params.refOut ? reverseBits(index: params.initial, valueLength: hashSize) : params.initial
        let hash = computeCalc(initial: initial, data: data, offset: offset, length: length)
        

        return (hash ^ params.xorOut) & Int(mask)
        
    }
}
