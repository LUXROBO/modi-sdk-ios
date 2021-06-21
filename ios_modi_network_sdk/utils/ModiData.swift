/*
 * Developement Part, SOLTER INC., SEOUL, KOREA
 * Copyright(c) 2014 by Solter Inc.
 *
 * All rights reserved. No part of this work may be reproduced, stored in a
 * retrieval system, or transmitted by any means without prior written
 * Permission of Solter Inc.
 */

import Foundation


class ModiData {
    
    static func subData(_ data:Data?, offset:Int, length:Int) -> Data? {
        
        if data != nil {
            
            if data!.count >= offset+length {
                
                let subData = data!.subdata(in: offset..<offset+length)
                return subData
            }
        }
        
        return nil
    }
    
    static func subData(_ data:Data?, offset:Int) -> Data? {
        
        if data != nil {
            
            if data!.count > offset {
                
                let subData = data!.subdata(in: offset..<data!.count)
                return subData
            }
        }
        
        return nil
    }
}
