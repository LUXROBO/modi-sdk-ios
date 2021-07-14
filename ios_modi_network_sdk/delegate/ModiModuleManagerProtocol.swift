//
//  ModiModuleManagerDelegate.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/04/27.
//

import Foundation

protocol ModiModuleManagerProtocol {
    
    func onConnectModule(manager : ModiModuleManager, module:ModiModule)
    func onExpiredModule(manager : ModiModuleManager, module:ModiModule)
    func onUpdateModule(manager : ModiModuleManager, module:ModiModule)
}
