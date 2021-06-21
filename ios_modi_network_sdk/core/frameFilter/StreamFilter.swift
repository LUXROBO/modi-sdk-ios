//
//  StreamFilter.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/05/25.
//

import Foundation

class StreamFilter: ModiFrameFilter {
    
    var targetStreamKey = 0
    
    init(moduleKey : Int, streamId : Int) {
        
        let temp = moduleKey & 0xFF
        targetStreamKey = temp << 8 | streamId
    }
    
    override func filter(frame: ModiFrame) -> Bool {
        
        if frame.cmd() == 0x11 {
            
            let tempData = Int(frame.data()[0])
            let streamKey = frame.sid() << 8 | tempData
            if streamKey  == targetStreamKey {
               
                return true
            }
        }
       
        return false
    }
}
