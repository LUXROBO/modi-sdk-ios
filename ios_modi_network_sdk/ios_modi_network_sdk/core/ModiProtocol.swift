//
//  ModiProtocol.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/04/28.
//

import Foundation


class ModiProtocol  {
    
    enum FLASH_CMD : Int {
        case CHECK_CRC = 0x101
        case ERASE = 0x201
    }
    
    enum MODULE_STATE : Int {
        case RUN = 0
        case STOP = 3
        case UPDATE = 4
        case UPDATE_READY = 5
        case RESET = 6
    }
    
    enum MODULE_WARNING : Int{
        case NO = 0
        case FIRMWARE = 1
        case FIRMWARE_READY = 2
        case EXCEPTION = 3
        case ERROR = 4
        case BUS = 5
        case SRAM = 6
        case FAULT = 7
    }
        
    
    func streamCommand(stream : ModiStream) -> [UInt8] {
        
        var streamCommandData = [UInt8](repeating: 0, count: 8)
        let streamBodySize = stream.streamBody.count


        streamCommandData[0] = stream.streamId
        streamCommandData[1] = 3

        let dataArray = withUnsafeBytes(of: streamBodySize, Array.init)
        
        for i in 0...3 {

            streamCommandData[i + 2] = dataArray[i]

        }
        
        print(streamCommandData)
        
        return ModiFrame().makeFrame(cmd: 0x12, sid: 0, did : stream.moduleId, binary : streamCommandData)
    }
    
    func streamDataList(stream : ModiStream) -> Array<[UInt8]> {
        
        var dataList = Array<[UInt8]>()
        
        for i in stride(from : 0, to : stream.streamBody.count - 1, by: 7)  {

           let begin = i
           var end = i + 7
           
            if (end > stream.streamBody.count) {
                end = stream.streamBody.count
            }
           
            let slice : [UInt8] =  Array(stream.streamBody[begin...end])
            var streamSlice = [UInt8]()
            streamSlice.reserveCapacity(slice.count + 1)
            streamSlice[0] = stream.streamId
            
            for j in 0...slice.count - 1 {
                streamSlice[j+1] = slice[j]
            }
            
            dataList.append(ModiFrame().makeFrame(cmd: 0x10, sid: 0, did : stream.moduleId, binary : streamSlice))
        }
        
        return dataList
    }
    
    func discoverModule(module_uuid : Int64, flag : UInt8) -> [UInt8] {
        
        var data = [UInt8](repeating: 0, count: 8)
        var uuid = module_uuid
        
        for i in 0...6 {
           data[i] = (UInt8)(uuid & 0xFF)
           uuid = uuid >> 8
        }

       data[7] = flag
    
       return ModiFrame().makeFrame(cmd: 0x08, sid: 0, did : 0xFFF , binary : data)
    }
    
    func firmwareCommand(moduleKey : Int , flashCmd : FLASH_CMD, address : Int , crc : Int ) -> [UInt8] {
        
        var data = [UInt8](repeating: 0, count: 8)
        
        let address_buffer = withUnsafeBytes(of: address, Array.init)
        let crc_buffer = withUnsafeBytes(of: crc, Array.init)
        
        for i in 0...3 {
           data[i] = crc_buffer[i]
           data[i + 4] = address_buffer[i]
        }
        
        return ModiFrame().makeFrame(cmd: 0x0D, sid: flashCmd.rawValue, did : moduleKey , binary : data)
    }
    
    func firmwareData(moduleKey : Int , segment : Int , data : [UInt8] ) -> [UInt8] {
        
        return ModiFrame().makeFrame(cmd: 0x0B, sid: segment, did : moduleKey , binary : data)
    }
    
    func setModuleState(moduleKey : Int, state : MODULE_STATE) -> [UInt8] {
        
        var data = [UInt8](repeating: 0, count: 8)
        data[0] = UInt8(state.rawValue)
        
        return ModiFrame().makeFrame(cmd: 0x09, sid: 0, did : moduleKey , binary : data)
    }
    
    func setBootToFactory(moduleKey : Int) -> [UInt8] {
        
        var data = [UInt8](repeating: 0, count: 8)
        
        for i in 0...6 {
            data[i] = 0x00
        }
        
        return ModiFrame().makeFrame(cmd: 0xAD, sid: 0, did : moduleKey , binary : data)
    }
    
    func setBootToApp(moduleKey : Int) -> [UInt8] {
        
        var data = [UInt8](repeating: 0, count: 8)
        
        for i in 0...6 {
            data[i] = 0x00
        }
        
        return ModiFrame().makeFrame(cmd: 0xAE, sid: 0, did : moduleKey , binary : data)
    }
    
    func setVersion(moduleKey : Int , data : [UInt8] ) -> [UInt8] {
        ModiFrame().makeFrame(cmd: 0xA0, sid : 24, did : moduleKey , binary : data)
    }
    
    func getVersion(moduleKey : Int) -> [UInt8] {
        
        var data = [UInt8](repeating: 0, count: 8)
        
        for i in 0...6 {
            data[i] = 0x00
        }
        
        return ModiFrame().makeFrame(cmd: 0xA0, sid : 25, did : moduleKey , binary : data)
    }
}
