//
//  firmwareUpdater.swift
//  modiNetworkSDK
//
//  Created by steave_mac on 2021/04/26.
//

import Foundation
import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork
import NetworkExtension
import CoreLocation
import Moya


public class FirmwareUpldater {
    
    private var restApiUseCase: RestApiUseCaseImpl! = nil
    
    
    public init() {
        let httpManager = HttpNetworkManager()
        let dataSource = RestApiRemoteDataSourceImpl(httpApi: httpManager)
        let restApiRepository = RestApiRepositoryImpl(dataSource: dataSource)
        restApiUseCase = RestApiUseCaseImpl.init(restApiRepository: restApiRepository)
    }
    
    public func startUpdate(deviceName : String, filePath : String) -> Bool {
        
        if(checkWifi(deviceName: deviceName) == false) {
            return false
        }
        
        do {
            let url = URL(fileURLWithPath: filePath)
            let data = try Data(contentsOf: url)
            updateFirmware(file: data)
            return true
        }
        
        catch {
            return false
        }
      
    }
    
    private func checkWifi(deviceName : String) -> Bool {
        var ssid: String?
        
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                
                print("get Wifi SSid interface = \(interface)")
                
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    if ssid == deviceName {
                        return true
                    }
                    break
                }
            }
        }
        
        if(ssid == nil || ssid != deviceName) {
            return false
        }
        
        return true
    }
    
    private func updateFirmware(file : Data) {
        
        restApiUseCase.updateFirmware(
            file: file,
            success: {
                result in
                print("Rest Api Test RestApiViewModel sendFile success => ", result)
            },
            failed: {
                result in
                print("Rest Api Test RestApiViewModel sendFile failed => ", result)
            }
        )
    }
}
