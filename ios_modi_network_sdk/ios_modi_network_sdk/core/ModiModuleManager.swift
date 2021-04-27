//
//  ModiModuleManager.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/25.
//

import Foundation

class ModiModuleManager: ModiFrameObserver {
    
    private let MODULE_STATE_UNKNOWN = 0xFF
    private let MODULE_TIMEOUT_PERIOD = 2000
    private let MODULE_CHECK_PERIOD = 500

    private var mModuleMap : Dictionary<Int, ModiModule> = Dictionary()
    private var mDisabledModuleMap : Dictionary<Int, ModiModule> = Dictionary()

    private var mListener : ModiModuleManagerProtocol? = nil
    private var mModiMananger : ModiManager? = nil
    private var mRootmodule : ModiModule? = nil
    
    func onModiFrame(frame :ModiFrame) {
        
    }
    
}
