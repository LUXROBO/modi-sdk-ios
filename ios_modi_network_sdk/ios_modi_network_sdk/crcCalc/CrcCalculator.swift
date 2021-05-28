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
    private var mask : Int = 0xFFFFFFFFFFFFFFF
    private var table = [Int]()
    
    init(params : AlgoParams) {
        self.params = params
        hashSize = params.hashSize
        
        if hashSize < 64 {
            mask = (1 << hashSize) - 1
        }
        
        createTable()
    }
    
    private func createTable() {
        
        for i in 0...table.count {
            table[i] = createTableEntry(index : i)
        }
    }
    
    private func createTableEntry(index : Int) -> Int {
        
        var r = index
        
        if params.refIn {
            r = reverseBits(index: r, valueLength: hashSize)
        }
        
        else if hashSize > 8 {
            r <<= hashSize - 8
        }
        
        let lastBit = 1 << hashSize - 1
        
        for i in 0...7 {
            
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
    
    private func reverseBits(index : Int, valueLength : Int) -> Int {
        
        var newValue = 0
        var ul = index
        
        for i in (0...valueLength - 1).reversed() {
            
            newValue |= (ul & 1) << i
            ul >>= 1
        }
        
        return newValue
    }
    
    
    private func computeCalc(initial : Int, data : [UInt8], offset : Int, length : Int) -> Int {
        
        var crc = initial
        
        if params.refOut {
            
            for i in offset...offset + length {
                crc = (table[(crc ^ Int(data[i])) & 0xFF] ^ crc & 0xFFFF) >> 8
                crc &= mask
            }
            
            return crc
        }
        
        var toRight = hashSize - 8
        toRight = toRight < 0 ? 0 : toRight
        
        for i in offset...offset + length {
            crc = (table[((crc >> toRight) ^ Int(data[i])) & 0xFF] ^ crc << 8)
            crc &= mask
        }
        
        return crc
    }
    
    func calc(data : [UInt8], offset : Int, length : Int) -> Int {
        let initial = params.refOut ? reverseBits(index: params.initial, valueLength: hashSize) : params.initial
        let hash = computeCalc(initial: initial, data: data, offset: offset, length: length)
        
        return (hash ^ params.xorOut) & mask
        
    }
}
