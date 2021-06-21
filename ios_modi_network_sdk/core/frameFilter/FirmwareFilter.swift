//
//  FirmwareFilter.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/05/26.
//

import Foundation

class FirmwareFilter: ModiFrameFilter {
    
    private let moduleKey : Int
    
    init(moduleKey : Int) {
        
        self.moduleKey = moduleKey & 0xFF
        
    }
    
    override func filter(frame: ModiFrame) -> Bool {
        
        if frame.cmd() == 0x0C && frame.sid() == moduleKey {
            
            return true
        }
        
        return false
    }
}
