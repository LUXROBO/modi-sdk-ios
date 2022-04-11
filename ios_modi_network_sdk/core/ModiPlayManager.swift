//
//  ModiPlayManager.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/06/22.
//

import Foundation

open class ModiPlayManager {
    
    private var modiManager : ModiManager
    private var delegate : ModiPlayManagerProtocol
    
    public init(modiManager:ModiManager, delegate : ModiPlayManagerProtocol) {
        
        self.modiManager = modiManager
        self.delegate = delegate

        ModiSingleton.shared.getModiFrameObserver().subscribe { frame in
            if let frame = frame.element {
                self.onModiFrame(frame: frame)

            }

            
        }.dispose()
        
    }
    
    
    public func fireEvent(index : Int, property : Int, command : PlayCommand, commandDataValue : Int, option : Int) {
        let target = modiManager.getConnectedModiUuid() & 0xFFF

        var data = getEventData(command: command, commandData: commandDataValue)
        data[7] = UInt8(option)
        
        let did = property + (index * 100);
        
        sendData(bytes: ModiFrame().makeFrame(cmd:0x1F, sid: target, did: did, binary : data))
    }
    
    
    private func getEventData(command : PlayCommand,commandData : Int) -> [UInt8]{
        var data = [UInt8](repeating: 0, count: 8)
        switch command {
                
        case .RECEIVE_DATA:
            data[2] = UInt8(commandData) & 0xFF
                
        case . BUTTON_CLICK:
            data[2] = UInt8(commandData) & 0xFF
                
        case . IMU_ANGLE_PITCH:
            data[2] = UInt8(commandData) & 0xFF
                
        case . BUTTON_DOUBLE_CLICK :
            data[4] = UInt8(commandData) & 0xFF
        case . IMU_ANGLE_YAW :
                
            data[4] = UInt8(commandData) & 0xFF
                
        default:
            data[0] = UInt8(commandData) & 0xFF
        }
        return data
    }
    
    public func sendValue(value : Int,did:Int) {
        let target = modiManager.getConnectedModiUuid() & 0xFFF
    
        var data = [UInt8](repeating: 0, count: 8)
        data[0] = UInt8(value & 0xFF)
        data[7] = 0
        
        sendData(bytes: ModiFrame().makeFrame(cmd:0x1F, sid: target, did: did, binary : data))
    }
    
    private func sendData(bytes : [UInt8]) {
        
        let data = Data(bytes : bytes, count: bytes.count)
        modiManager.sendData(data)
    }
    
    private func onModiFrame(frame : ModiFrame) {
        if frame.cmd() == 0x04 {
            
            let moduleKey = modiManager.getConnectedModiUuid() & 0xFF
            
            if frame.did() == moduleKey {
                
                switch fromInteager(val : frame.sid()) {
                    
                    case .DATA:
                        delegate.onEventData(data: frame.data())
        
                    case .BUZZER:
                        
                        let buzzerData = ModiFrame().getInt(data: frame.data())
                        let enable = buzzerData != 0
                        
                        delegate.onEventBuzzer(enable: enable)
                    case .CAMERA:
                        delegate.onEventCamera(enable: true)
                        
                    case .INVALID:
                        print("Invalid Mobile Event code : ")
                }
            }
        }
    }
    
    private func fromInteager (val : Int) -> PlayEvent {
        
      switch val {
        case 0x0002: return .DATA
        case 0x0100: return .BUZZER
        case 0x0101: return .CAMERA
     
        default:
            return .INVALID
      }
    }
}
