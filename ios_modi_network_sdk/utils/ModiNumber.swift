/*
 * Developement Part, SOLTER INC., SEOUL, KOREA
 * Copyright(c) 2014 by Solter Inc.
 *
 * All rights reserved. No part of this work may be reproduced, stored in a
 * retrieval system, or transmitted by any means without prior written
 * Permission of Solter Inc.
 */

import Foundation


class ModiNumber {
    
    
    /**
     Data to Int8 변환
    */
    static func convertNSDataToInt8(_ data:Data?, offset:Int) -> Int8? {
        
        if(data != nil) {
            
            var buffer = [Int8](repeating: 0, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            if offset <= buffer.count {
                return buffer[offset]
            }
        }
        
        return nil
    }
    
    static func convertNSDataToInt8(_ data:Data?, offset:Int, defaultVal:Int8) -> Int8! {
        
        return convertNSDataToInt8(ModiData.subData(data, offset: offset, length: 1), offset: 0) ?? defaultVal
    }
    
    
    /**
     Data to UInt8 변환
     */
    static func convertNSDataToUInt8(_ data: Data?, offset: Int) -> UInt8? {
        
        if(data != nil) {
            
            var buffer = [UInt8](repeating: 0x00, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            if offset <= buffer.count {
                return buffer[offset]
            }
        }
        
        return nil
        
    }
    
    static func convertNSDataToUInt8(_ data: Data?) -> UInt8? {
        
        return convertNSDataToUInt8(data, offset: 0)
    }
    
    static func convertNSDataToUInt8(_ data: Data?, defaultVal:UInt8) -> UInt8! {
        
        return convertNSDataToUInt8(data, offset: 0) ?? defaultVal
    }
    
    static func convertNSDataToUInt8(_ data: Data?, offset: Int, defaultVal:UInt8) -> UInt8! {
        
        return convertNSDataToUInt8(ModiData.subData(data, offset: offset, length: 1), offset: 0) ?? defaultVal
    }
    
    /**
     Data to UInt16 변환
    */
    
    static func convertNSDataToUInt16(_ data: Data?, offset: Int) -> UInt16? {
        
        if(data != nil) {
            
            var buffer = [UInt16](repeating: 0x00, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            if offset <= buffer.count {
                return buffer[offset]
            }
        }
        return nil
    }
    
    static func convertNSDataToUInt16(_ data: Data?) -> UInt16? {
        
        return convertNSDataToUInt16(data, offset: 0)
    }
    
    static func convertNSDataToUInt16(_ data: Data?, defaultVal:UInt16) -> UInt16! {
        
        return convertNSDataToUInt16(data, offset: 0) ?? defaultVal
    }
    
    
    static func convertNSDataToUInt16(_ data: Data?, offset: Int, defaultVal:UInt16) -> UInt16! {
        
        return convertNSDataToUInt16(ModiData.subData(data, offset: offset, length: 2), offset: 0) ?? defaultVal
    }
    
    /**
     Data to UInt32 변환
     */
    static func convertNSDataToUInt32(_ data: Data?, offset: Int) -> UInt32? {
        
        if(data != nil) {
            
            var buffer = [UInt32](repeating: 0x00, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            if offset <= buffer.count {
                
                return buffer[offset]
            }
        }
        return nil
    }
    
    
    static func convertNSDataToUInt32(_ data: Data?) -> UInt32? {
        
        return convertNSDataToUInt32(data, offset: 0)
    }
    
    static func convertNSDataToUInt32(_ data: Data?, defaultVal:UInt32) -> UInt32! {
        
        return convertNSDataToUInt32(data, offset: 0) ?? defaultVal
    }
    
    static func convertNSDataToUInt32(_ data: Data?, offset: Int, defaultVal:UInt32) -> UInt32! {
        
        return convertNSDataToUInt32(ModiData.subData(data, offset: offset, length: 4), offset: 0) ?? defaultVal
    }
    
    
    /**
    Data to UInt64 변환
    */
    static func convertNSDataToUInt64(_ data: Data?, offset: Int) -> UInt64? {
        
        if(data != nil) {
            
            var buffer = [UInt64](repeating: 0x00, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            if offset <= buffer.count {
                
                return buffer[offset]
            }
        }
        return nil
    }
    
    static func convertNSDataToUInt64(_ data: Data?) -> UInt64? {
        
        return convertNSDataToUInt64(data, offset: 0)
    }
    
    static func convertNSDataToUInt64(_ data: Data?, defaultVal:UInt64) -> UInt64! {
        
        return convertNSDataToUInt64(data, offset: 0) ?? defaultVal
    }
    
    static func convertNSDataToUInt64(_ data: Data?, offset: Int, defaultVal:UInt64) -> UInt64! {
        
        return convertNSDataToUInt64(ModiData.subData(data, offset: offset, length: 8), offset: 0) ?? defaultVal
    }
}
