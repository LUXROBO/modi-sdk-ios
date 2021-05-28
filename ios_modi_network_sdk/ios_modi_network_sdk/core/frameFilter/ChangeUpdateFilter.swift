//
//  ChangeUpdateFilter.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/05/26.
//

import Foundation


class ChageUpdateFilter: ModiFrameFilter {
    private let moduleKey : Int
    
    init(moduleKey : Int) {
        
        self.moduleKey = moduleKey
        
    }
    
    override func filter(frame: ModiFrame) -> Bool {
        
        if frame.cmd() == 0x0A && frame.sid() == moduleKey && frame.data()[6] != 1 {
            
            return true
        }
        
        return false
    }
}
