/*
 * Developement Part, SOLTER INC., SEOUL, KOREA
 * Copyright(c) 2014 by Solter Inc.
 *
 * All rights reserved. No part of this work may be reproduced, stored in a
 * retrieval system, or transmitted by any means without prior written
 * Permission of Solter Inc.
 */

import Foundation


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ModiString {
    
    static func convertHexString(_ data: Data?) -> String {
        var returnStr:String = ""
        
        if  data != nil && data?.count > 0{
            var buffer = [UInt8](repeating: 0x00, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            for i in 0...buffer.count-1 {
                
                returnStr = returnStr + (NSString(format: " %X" ,UInt8(buffer[i])) as String)
                // returnStr = returnStr + " \(strValue)"
            }
        }
        
        return returnStr;
    }
    
    static func convertHexString(_ data: Data?, defaultString: String?) -> String {
        var returnStr:String = ""
        
        if  data != nil && data?.count > 0{
            var buffer = [UInt8](repeating: 0x00, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            for i in 0...buffer.count-1 {
                
                returnStr = returnStr + (NSString(format: " %X" ,UInt8(buffer[i])) as String)
                // returnStr = returnStr + " \(strValue)"
            }
        } else {
            returnStr = defaultString ?? ""
        }
        
        
        return returnStr;
    }
    
    static func convertOctString(_ data: Data?) -> String {
        var returnStr:String = ""
        
        if  data != nil && data?.count > 0{
            var buffer = [UInt8](repeating: 0x00, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            for i in 0...buffer.count-1 {
                var strValue:UInt8?
                strValue = UInt8(buffer[i])
                
                returnStr = returnStr + (NSString(format: " %2o" , strValue!) as String)
                //  returnStr = returnStr + " \(strValue)"
            }
        }
        
        return returnStr;
    }

    
    static func convertOctString(_ data: Data?, defaultString: String?) -> String {
        var returnStr:String = ""
        
        if  data != nil && data?.count > 0{
            var buffer = [UInt8](repeating: 0x00, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            for i in 0...buffer.count-1 {
                var strValue:UInt8?
                strValue = UInt8(buffer[i])
                
                returnStr = returnStr + (NSString(format: " %2o" , strValue!) as String)
                //  returnStr = returnStr + " \(strValue)"
            }
        } else {
            returnStr = defaultString ?? ""
        }
        
        
        return returnStr;
    }
    
    
    static func convertDecimalString(_ data: Data?, defaultString: String?) -> String {
        var returnStr:String = ""
        
        if  data != nil && data?.count > 0{
            var buffer = [UInt16](repeating: 0x00, count: data!.count)
            (data! as NSData).getBytes(&buffer, length: buffer.count)
            
            for i in 0...buffer.count-1 {
                returnStr = returnStr + (NSString(format: " %d" ,UInt16(buffer[i])) as String)
            }
        } else {
            returnStr = defaultString ?? ""
        }
        
        
        
        return returnStr;
    }
    
    
    static func getLength(_ data: Data?, offset: Int) -> Int {
        if data != nil {
            let count = data!.count
            
            for i in offset...count-1 {
                if data![i] == 0x00 {
                    return i - offset
                }
            }
            
            return count - offset
        }
        
        return 0
    }
    
    static func getLength(_ data: Data?) -> Int {
        return getLength(data, offset: 0)
    }
    
    static func convertNSDataToUTFString(_ data: Data?) -> String? {
        if data != nil {
            return String(data: data!, encoding: String.Encoding.utf8) ?? nil
        }
        
        return nil
    }
    
    static func convertNSDataToUTFString(_ data: Data?, defaultString: String) -> String {
        return convertNSDataToUTFString(data) ?? defaultString
    }
    
    static func convertNSDataToUTFString(_ data: Data?, offset: Int) -> String? {
        return convertNSDataToUTFString(ModiData.subData(data, offset:offset))
    }
    
    static func convertNSDataToUTFString(_ data: Data?, offset: Int, defaultString: String) -> String {
        return convertNSDataToUTFString(ModiData.subData(data, offset:offset), defaultString: defaultString)
    }
    
   
    static func convertNSDataToUTFString(_ data: Data?, offset: Int, length: Int, defaultString: String) -> String {
        return convertNSDataToUTFString(ModiData.subData(data, offset:offset, length:length), defaultString: defaultString)
    }
    
    
    static func convertNSDataToASCIIString(_ data: Data?) -> String {
        if data != nil {
            return String(data: data!, encoding: String.Encoding.ascii) ?? ""
            
        }
        
        return ""
    }
    
    static func convertNSDataToASCIIString(_ data: Data?, defaultString: String) -> String {
        if data != nil {
            return String(data: data!, encoding: String.Encoding.ascii) ?? ""
            
        }
        
        return defaultString
    }
    
    static func convertUTF8StringToNSData(_ string: String!) -> Data {
        
        var buff:[UInt8] = [UInt8](string.utf8)
        let data = Data(bytes: &buff, count:buff.count)
        
        return data;
    }
    
    static func getLength(_ string: String!) -> Int {
        
        if string == nil { return 0 }
        return string.count;
    }
    
    static func subString(_ string: String!, start: Int, end: Int) -> String {
        if start < 0 || end <= start {
            return ""
        }
        let startIndex = string.index(string.startIndex, offsetBy: start)
        let endIndex = string.index(string.endIndex, offsetBy: end - getLength(string))
        let range = startIndex..<endIndex
        
        return String(string[range])
    }

    static func subString(_ string: String!, start: Int, length: Int) -> String {
       
        return subString(string, start: start, end: start+length)
    }
    
    static func subString(_ string: String!, length: Int) -> String {
        
        return subString(string, start: 0, end: length)
    }
}
