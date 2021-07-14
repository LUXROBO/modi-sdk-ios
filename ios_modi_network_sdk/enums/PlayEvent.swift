//
//  PlayEvent.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/06/23.
//

import Foundation

public enum PlayEvent {
    
    public typealias RawValue = Int
    public typealias FromInteager = PlayEvent
    
    case INVALID
    case DATA
    case BUZZER
    case CAMERA
    
    
    public var rawValue: RawValue {
      switch self {
        case .INVALID: return 0x0000 & 0xFF
        case .DATA: return 0x0002 & 0xFF
        case .BUZZER: return 0x100 & 0xFF
        case .CAMERA: return 0x101 & 0xFF
    
      }
    }

}
