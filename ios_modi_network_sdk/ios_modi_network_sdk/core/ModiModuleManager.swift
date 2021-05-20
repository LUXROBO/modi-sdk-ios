//
//  ModiModuleManager.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/25.
//

import Foundation
import RxSwift

class ModiModuleManager: ModiFrameObserver {
    
    private let MODULE_STATE_UNKNOWN = 0xFF
    private let MODULE_TIMEOUT_PERIOD = 2000
    private let MODULE_CHECK_PERIOD = 500

    private var mModuleMap : Dictionary<Int, ModiModule> = Dictionary()
    private var mDisabledModuleMap : Dictionary<Int, ModiModule> = Dictionary()

    private var mListener : ModiModuleManagerProtocol? = nil
    private var mModiMananger : ModiManager? = nil
    private var mRootmodule : ModiModule? = nil
//    private var runningKey : Stream
    
    
    public init (modiManager : ModiManager) {
        self.mModiMananger = modiManager
    }
    
    func setListener(listener : ModiModuleManagerProtocol) {
        self.mListener = listener
    }
    
    func discoverModules() {
        
        var buff = ModiProtocal().discoverModule(module_uuid : 0xFFF, flag : 0x0)
        
        let data = Data(bytes: &buff, count: buff.count)
        
        self.mModiMananger?.sendData(data)
    }
    
    
    func getModules() -> Array<ModiModule> {
        
        var modules = Array<ModiModule>()
        
        self.mModuleMap.keys.forEach { (module) in
            modules.append(self.mModuleMap[module]!)
        }
        
        return modules
    }
    
    func setRootModule(uuid : Int) {
        
        if self.mRootmodule != nil {
            
            self.resetAllModules()
        }
    
        self.mRootmodule = ModiModule().makeModule(type: 0x0000, uuid: uuid, version: 0, state: 0, time: Date())
        
        updateRootModule(uuid : uuid & 0xFFF)
        
        observeFrame()
        
    }
    
    func resetAllModules() {
        
        if self.mRootmodule != nil {
            expireAllModules()
            self.mRootmodule = nil
        }
    }
    
    func updateRootModule(uuid : Int) {
        
        if self.mModuleMap.keys.contains(uuid) != false {
            self.mModuleMap[uuid] = self.mRootmodule
        }
        
        if self.mListener != nil {
            self.mListener?.onConnectModule(manager: self, module: self.mRootmodule!)
        }
    }
    
    func expireAllModules() {
        var expireList = Array<Int>()
        
        self.mModuleMap.keys.forEach { (key) in
            expireList.append(key)
        }
        
        expireList.forEach { (key) in
            expireModule(key : key)
        }
        
        self.mModuleMap.removeAll()
    }
    
    func expireModule(key : Int) {
        
        if self.mModuleMap.keys.contains(key) {
            let module = self.mModuleMap[key]
            self.mModuleMap.removeValue(forKey: key)
            self.mDisabledModuleMap[key] = module
            
            if self.mListener != nil {
                self.mListener?.onExpiredModule(manager: self, module: module!)
            }
        }
    }
    
    func observeFrame() {
        
    }
    
    func onModiFrame(frame :ModiFrame) {
        
        let cmd = frame.cmd()
    }
    
}
