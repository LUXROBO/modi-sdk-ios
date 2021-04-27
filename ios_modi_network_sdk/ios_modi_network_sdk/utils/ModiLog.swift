/*
 * Developement Part, SOLTER INC., SEOUL, KOREA
 * Copyright(c) 2014 by Solter Inc.
 *
 * All rights reserved. No part of this work may be reproduced, stored in a
 * retrieval system, or transmitted by any means without prior written
 * Permission of Solter Inc.
 */

import Foundation


@objc open class ModiLog : NSObject {
    
    fileprivate static let LABEL: String = "MODI-SDK"
    fileprivate static var DEBUG: Bool = true
    
    public static func showLog(_ show: Bool) {
        
        ModiLog.DEBUG = show
    }
    
    public static func e(_ Tag: String, error: NSError) {
        
        if DEBUG {
            //print(NSString(format:"[%@ Error on %@] %@", MAIN_LABEL, Tag, error.localizedDescription))
            eLog(Tag, error: error)
        }
    }
    
    public static func e(_ Tag: String, messages: String) {
        
        if DEBUG {
            //print(NSString(format:"[%@ Error on %@] %@", MAIN_LABEL, Tag, messages))
            eLog(Tag, messages: messages)
        }
    }
    
    public static func i(_ Tag: String, messages: String) {
        
        if DEBUG {
            //print(NSString(format:"[%@ Info From %@] %@", MAIN_LABEL, Tag, messages))
            iLog(Tag, messages: messages)
            
        }
    }
    
    public static func d(_ Tag: String, messages: String) {
        
        if DEBUG {
            //print(NSString(format:"[%@ Debug From %@] %@", MAIN_LABEL, Tag, messages))
            dLog(Tag, messages: messages)
        }
    }
    
    
    public static func eLog(_ Tag: String, error: NSError) {
        
        if DEBUG {
            NSLog("[%@ Error on %@] %@", LABEL, Tag, error.localizedDescription)
        }
    }
    
    public static func eLog(_ Tag: String, messages: String) {
        
        if DEBUG {
            NSLog("[%@ Error %@] %@", LABEL, Tag, messages)
            
        }
    }
    
    public static func iLog(_ Tag: String, messages: String) {
        
        if DEBUG {
            NSLog("[%@ Info %@] %@", LABEL, Tag, messages)
        }
    }
    
    public static func dLog(_ Tag: String, messages: String) {
        
        if DEBUG {
            NSLog("[%@ Debug %@] %@", LABEL, Tag, messages)
        }
    }
}
