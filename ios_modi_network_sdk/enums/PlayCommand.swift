//
//  PlayCommand.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/06/23.
//

import Foundation

public enum PlayCommand  {
    
    public typealias RawValue = Int
    
    case RECEIVE_DATA
    case BUTTON_PRESS_STATUS
    case BUTTON_CLICK
    case BUTTON_DOUBLE_CLICK
    case TOGGLE
    case JOYSTICK
    case DIAL
    case LEFT_SLIDER
    case RIGHT_SLIDER
    case TIMER
    
    
    public var rawValue: RawValue {
      switch self {
        case .RECEIVE_DATA: return 0x0002
        case .BUTTON_PRESS_STATUS: return 0x0003
        case .BUTTON_CLICK: return 0x0102
        case .BUTTON_DOUBLE_CLICK: return 0x0103
        case .TOGGLE: return 0x0104
        case .JOYSTICK: return 0x0003
        case .DIAL: return 0x0004
        case .LEFT_SLIDER: return 0x0005
        case .RIGHT_SLIDER: return 0x0006
        case .TIMER: return 0x0007
       
      }
    }
    
}
