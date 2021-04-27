//
//  ModiModule.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/25.
//

import Foundation

class ModiModule {
    
    private let TYPE_NETWORK = "Network";
    private let TYPE_ENVIRONMENT = "Environment";
    private let TYPE_GYRO = "Gyro"
    private let TYPE_MIC = "Mic";
    private let TYPE_BUTTON = "Button";
    private let TYPE_DIAL = "Dial";
    private let TYPE_ULTRASONIC = "Ultrasonic";
    private let TYPE_IR = "Ir";
    private let TYPE_DISPLAY = "Display";
    private let TYPE_MOTOR = "Motor";
    private let TYPE_LED = "Led";
    private let TYPE_SPEAKER = "Speaker";
    
    private var version = 0
    private var typeCode = 0
    private var uuid = 0
    private var state = 0
    private var type = "null"
    private var lastUpdate : Int64 = 0
    
    func makeModule(type : Int , uuid : Int , version : Int , state : Int , time : Date ) -> Self {
        
        self.typeCode = type
        self.type = typeCodeToString(typeCode: type)
        self.uuid = uuid
        self.version = version
        self.state = state
        self.lastUpdate = Int64(time.timeIntervalSince1970 * 1000)
        
        return self
        
    }
    
    func typeCodeToString(typeCode : Int) -> String {
        
        switch typeCode {
            case 0x0000: return TYPE_NETWORK
            case 0x2000: return TYPE_ENVIRONMENT
            case 0x2010: return TYPE_GYRO
            case 0x2020: return TYPE_MIC
            case 0x2030: return TYPE_BUTTON
            case 0x2040: return TYPE_DIAL
            case 0x2050: return TYPE_ULTRASONIC
            case 0x2060: return TYPE_IR
            case 0x4000: return TYPE_DISPLAY
            case 0x4010: return TYPE_MOTOR
            case 0x4020: return TYPE_LED
            case 0x4030: return TYPE_SPEAKER
            default: return "unKnown"
                
        }
        
    }
    
    func getString() -> String {
        
        let name = self.type.lowercased()+"0"
        return String(format: "%s %s(0x%04X%08X);\n", name)
    }
    
}