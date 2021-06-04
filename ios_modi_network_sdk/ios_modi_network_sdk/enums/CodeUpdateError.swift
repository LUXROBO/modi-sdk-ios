//
//  CodeUpdateError.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/18.
//

import Foundation

public enum CodeUpdateError : Error {
    
    public typealias RawValue = String
    
    case SUCCESS
    case MODULE_TIMEOUT
    case CONNECTION_ERROR
    case CODE_NOW_UPDATING
    case CODE_NOT_UPDATE_MODE
    case CODE_NOT_UPDATE_READY
    case FLASH_ERASE_ERROR
    case STREAM_COMMAND_RESPONSE_FAILED
    
    
    public var rawValue: RawValue {
      switch self {
        case .SUCCESS: return "SUCCESS"
        case .MODULE_TIMEOUT: return "MODULE_TIMEOUT"
        case .CONNECTION_ERROR: return "CONNECTION_ERROR"
        case .CODE_NOW_UPDATING: return "CODE_NOW_UPDATING"
        case .CODE_NOT_UPDATE_MODE: return "module is not update mode"
        case .CODE_NOT_UPDATE_READY: return "module is not update ready"
        case .FLASH_ERASE_ERROR: return "flash erase error"
        case .STREAM_COMMAND_RESPONSE_FAILED: return "Modi Stream Command response failed"
       
      }
    }
    
}
