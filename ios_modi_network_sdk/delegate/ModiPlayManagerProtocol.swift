//
//  ModiPlayManagerProtocol.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/06/22.
//

import Foundation

public protocol ModiPlayManagerProtocol {
    
    func onEventData(data : [UInt8])
    func onEventBuzzer(enable : Bool)
    func onEventCamera(enable : Bool)
}
