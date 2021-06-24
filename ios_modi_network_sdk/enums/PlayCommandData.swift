//
//  PlayCommandData.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/06/23.
//

import Foundation

public enum PlayCommandData  {
    
    public typealias RawValue = UInt8
    
    case PRESSED
    case UNPRESSED
    case JOYSTICK_UNPRESSED
    case JOYSTICK_UP
    case JOYSTICK_DOWN
    case JOYSTICK_LEFT
    case JOYSTICK_RIGHT

    
    public var rawValue: RawValue {
      switch self {
        case .PRESSED: return 100 & 0xFF
        case .UNPRESSED: return 0 & 0xFF
        case .JOYSTICK_UNPRESSED: return 0 & 0xFF
        case .JOYSTICK_UP: return 0 & 0xFF
        case .JOYSTICK_DOWN: return 0 & 0xFF
        case .JOYSTICK_LEFT: return 0 & 0xFF
        case .JOYSTICK_RIGHT: return 0 & 0xFF
       
      }
    }
    
}
