//
//  ModuleStateFilter.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/05/26.
//

import Foundation

class ModuleStateFilter: ModiFrameFilter {
    
    private let moduleKey : Int
    
    init(moduleKey : Int) {
        
        self.moduleKey = moduleKey & 0xFF
        
    }
    
    override func filter(frame: ModiFrame) -> Bool {
        
        if frame.cmd() == 0x0A && frame.sid() == moduleKey {
            
            return true
        }
        
        return false
    }
}
