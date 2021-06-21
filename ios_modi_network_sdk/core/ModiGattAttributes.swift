/*
 * Developement Part, SOLTER INC., SEOUL, KOREA
 * Copyright(c) 2014 by Solter Inc.
 *
 * All rights reserved. No part of this work may be reproduced, stored in a
 * retrieval system, or transmitted by any means without prior written
 * Permission of Solter Inc.
 */

import Foundation
import CoreBluetooth


class ModiGattArributes {
    
    static let DEFAULT_96BIT_LEFT:String = "0000XXXX-0000-1000-8000-00805f9b34fb"
    static let DEVICE_CHAR_SERVICE = "00FF";
    static let DEVICE_CHAR_TX_RX = "8421";
    static let DEVICE_TX_DESC = "2902";
    
    static let attrbutes:Dictionary<String, String> = [
        DEVICE_CHAR_SERVICE: "MODI SERVICE",
        DEVICE_CHAR_TX_RX: "DATA TX/RX",
        DEVICE_TX_DESC: "TX DESC"
    ]
    
    static func convert16UUID(_ origin: CBUUID) -> String {
        return convert16UUID(origin.uuidString)
    }
    
    static func convert16UUID(_ origin: String) -> String {
        var UUID16bit:String = ""
        
        if ModiString.getLength(origin) > 4 {
            UUID16bit = ModiString.subString(origin, start: 4, length:4)
        } else {
            UUID16bit = origin
        }
        
        // ModiLog.d("Convert Characteristic UUID origin \(origin):", messages: "UUID16bit: \(UUID16bit)")
        return UUID16bit
    }
    
    static func lookup(_ uuid: String, defaultName: String) -> String {
        
        /*
        for (key, value) in attrbutes {
            
            ModiLog.d("\(key)", messages:"\(value)")
        }
        */
        
        return attrbutes[uuid] ?? defaultName
    }
    
    static func lookup(_ uuid: CBUUID, defaultName: String?) -> String {
        
        let uuid16 = convert16UUID(uuid)
        return attrbutes[convert16UUID(uuid16)] ?? (defaultName ?? uuid16)
    }
    
    static func isUUIDExist(_ uuid: CBUUID) -> Bool {
        var exist:Bool = false
        
        for key in attrbutes.keys {
            if key == convert16UUID(uuid)  {
                exist = true
                break;
            }
        }
        
        return exist
    }
}
