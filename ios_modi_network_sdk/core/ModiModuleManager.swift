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
        
        var buff = ModiProtocol().discoverModule(module_uuid : 0xFFF, flag : 0x0)
        
        let data = Data(bytes: &buff, count: buff.count)
        
        self.mModiMananger?.sendData(data)
    }
    
    
    func getModules() -> Array<ModiModule> {
        
        var modules = Array<ModiModule>()
        
        print("getModules \(mModuleMap.count)")
        
        self.mModuleMap.keys.forEach { (module) in
            modules.append(self.mModuleMap[module]!)
        }
        
        return modules
    }
    
    func setRootModule(uuid : Int) {
        
        if self.mRootmodule != nil {
            
            self.resetAllModules()
        }
    
        self.mRootmodule = ModiModule().makeModule(type: 0x0000, uuid: uuid & 0xFFF, version: 0, state: 0, time: Date())
        
        updateRootModule(uuid : uuid & 0xFFF)
        
        observeFrame()
        
       Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { timer in
           
            self.run()
        })
        
       
        
    }
    
    func resetAllModules() {
        
        if self.mRootmodule != nil {
            expireAllModules()
            self.mRootmodule = nil
        }
    }
    
    func updateRootModule(uuid : Int) {
        
        print("updateRootModule1 uuid \(uuid)")
        
        if self.mModuleMap.keys.contains(uuid) != true {
            self.mModuleMap[uuid] = self.mRootmodule
            
            print("updateRootModule2 uuid \(uuid) mModuleMap : \(mModuleMap.count)")
            
        }
        
        if self.mListener != nil {
            self.mListener?.onConnectModule(manager: self, module: self.mRootmodule!)
        }
    }
    
    func updateModuleTime(id : Int) {
        
        let module = self.mModuleMap[id]
        
        if(module != nil) {
            
            module?.lastUpdate = Date().timeIntervalSince1970 * 1000
        }
        
        else {
            let data = ModiProtocol().discoverModule(module_uuid: Int64(id), flag: 0x0)

            mModiMananger?.sendData(Data(bytes: data, count: data.count))
        }
        
        
    }
    
    func updateModuleState(id : Int, moduleData : Array<UInt8>) {
        
        if(self.mModuleMap.keys.contains(id) != true) {
            
            let uuid = ModiFrame().getInt(data : Array(moduleData[0...1])) & 0xFFFF
            let typeCode = ModiFrame().getInt(data : Array(moduleData[4...5])) & 0xFFFF
            var version = ModiFrame().getInt(data : Array(moduleData[6...7])) & 0xFFFF
            let state = Int(moduleData[6]) & 0xFFFF
            let time = Date()
            
            if version == 10 || version == 0 {
                version = 16690
            }
            
            let module = ModiModule().makeModule(type : typeCode, uuid : uuid, version : version, state : state, time : time)
            
            self.mModuleMap[id] = module
        
            
            self.removeDisableMapModule(id : id)
            
            if(mListener != nil) {
                mListener?.onConnectModule(manager: self, module: module)
            }
        }
        
        else {
            
            let module = self.mModuleMap[id]
            module!.state = Int(moduleData[6])
            module?.lastUpdate = Date().timeIntervalSince1970 * 1000
            
            if(mListener != nil) {
                mListener?.onUpdateModule (manager: self, module: module!)
            }
            
        }
    }
    
    func isRootModule(key : Int) -> Bool {
        
        if mRootmodule == nil {
            return false
        }
        
        let rootModuleKey = mRootmodule!.uuid & 0xFFF
        if rootModuleKey == key {
            return true
        }
        
        return false
    }
    
    func run() {
        
        if mRootmodule != nil {
            
            let currentTime = Date().timeIntervalSince1970 * 1000
            
            var expireList = Array<Int>()
            
            for key in mModuleMap.keys {
                
                if isRootModule(key: key) {
                    continue
                }
                
                let module = mModuleMap[key]
                let duration = Int(currentTime - module!.lastUpdate)
                
                print("run module duration \(duration))")
                
                if duration > MODULE_TIMEOUT_PERIOD {
                    expireList.append(key)
                }
            }
            
            for key in expireList {
                expireModule(key: key)
            }
        }
    }
    
    func getModuleVersion(uuid : Int) -> Int {
        
        let key = uuid & 0xFFF
        
        if mModuleMap.keys.contains(key) {
            
            let module = mModuleMap[key]
            
            return module!.version
        }
        
        else if mDisabledModuleMap.keys.contains(key) {
            
            let module = mDisabledModuleMap[key]
            
            return module!.version
        }
        
        return 16690
    }
    
    func removeDisableMapModule(id : Int) {
        
        if mDisabledModuleMap.keys.contains(id) == true {
            mDisabledModuleMap.removeValue(forKey: id)
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
        
        print("updateModuleData expireModule : \(key & 0xFFF)")
        
        if self.mModuleMap.keys.contains(key) {
            let module = self.mModuleMap[key]
            self.mModuleMap.removeValue(forKey: key)
            self.mDisabledModuleMap[key] = module
            
            print("updateModuleData onExpiredModule : \(module!.getString())")
            
            
            if self.mListener != nil {
                self.mListener?.onExpiredModule(manager: self, module: module!)
            }
        }
    }
    
    func updateModuleData(moduleKey : Int , moduleData : Array<UInt8>) {
        
        let data = Data(bytes : moduleData, count: moduleData.count)
    
        if mModuleMap.keys.contains(moduleKey) != true {
            
            let uuid = ModiFrame().getInt(data : Array(moduleData[0...1])) & 0xFFFF
            let typeCode = ModiFrame().getInt(data : Array(moduleData[4...5])) & 0xFFFF
            var version = ModiFrame().getInt(data : Array(moduleData[6...7])) & 0xFFFF
            let state = Int(moduleData[6]) & 0xFFFF
            let time = Date()
            
            if version == 10 || version == 0 {
                version = 16690
            }
            
            
            let module = ModiModule().makeModule(type : typeCode, uuid : uuid, version : version, state : state, time : time)
            
            self.mModuleMap[moduleKey] = module
            
          
            
            self.removeDisableMapModule(id : moduleKey)
            
            if(mListener != nil) {
                mListener?.onConnectModule(manager: self, module: module)
            }
            
            return
        }
    
        updateModuleTime(id: moduleKey)
    }
    
    func observeFrame() {
        ModiSingleton.shared.getModiFrameObserver().subscribe { modiFrame in
            
        
            self.onModiFrame(frame: modiFrame)
        }
    }
    
    
    func onModiFrame(frame :ModiFrame) {
        
        let cmd = frame.cmd()
       
        
        switch cmd {
        
            case 0x07, 0x00:
                
                updateModuleTime(id: frame.sid())
                
                break
                
            case 0x05:
                
                updateModuleData(moduleKey: frame.sid(), moduleData: frame.data())
                break
            case 0x0A:
                
                updateModuleState(id: frame.sid(), moduleData: frame.data())
                break
        
            default:
                break
        }
    }
    
}
