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
    case JOYSTICK_DIRECTION
    case DIAL_POSITION
    case SLIDER_POSITION
    case TIMER
    case IMU_ANGLE_ROLL
    case IMU_ANGLE_PITCH
    case IMU_ANGLE_YAW
    case IMU_DIRECTION
    case IMU_ROTATION
    
    public var rawValue: RawValue {
      switch self {
        case .RECEIVE_DATA: return 0x02
        case .BUTTON_PRESS_STATUS: return 0x00
        case .BUTTON_CLICK: return 0x02
        case .BUTTON_DOUBLE_CLICK: return 0x04
        case .TOGGLE: return 0x00
        case .JOYSTICK_DIRECTION: return 0x00
        case .DIAL_POSITION: return 0x00
        case .SLIDER_POSITION: return 0x00
        case .TIMER: return 0x00
        case .IMU_ANGLE_ROLL: return 0x00
        case .IMU_ANGLE_PITCH : return 0x02
        case .IMU_ANGLE_YAW : return 0x04
        case .IMU_DIRECTION : return 0x00
        case .IMU_ROTATION : return 0x00
       
      }
    }
    
}
