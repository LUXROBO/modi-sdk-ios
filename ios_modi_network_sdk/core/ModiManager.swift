//
//  ModiManager.swift
//  Modisdk
//
//  Created by steave_mac on 2020/02/25.
//  Copyright © 2020 solter. All rights reserved.
//

import Foundation
import RxBluetoothKit
import RxCocoa
import RxSwift
import CoreBluetooth

open class ModiManager  {
   
    private var bluetoothService: RxBluetoothKitService
    private var modiConnected:Bool = false;
    private var managerDelegate:ModiManagerDelegate?
    private var modiModuleManager : ModiModuleManager?
    private var modiCodeUpdater : ModiCodeUpdater?
    private var connectedDeviceAddress:String?
//    private var scanningOutput: Observable<Result<ScannedPeripheral, Error>>
    
    private var isScanning: Bool = false
    private var peripheralList:Dictionary = [String: Peripheral]()
    private var periperal : Peripheral?
    private var bluetoothState: Bool = false
    private var disconnectPermanently:Bool = true   //
    private var service : Service?
    private var characteristic : Characteristic?
    private var characteristicUUID : CBUUID?
    private var varcharacteristicUuidStreamUpload : CBUUID?
   

    
    private var MODI_ID:[UInt8] = [0x00,0x00, 0x00, 0x00]
    private var macString : String
    
//    private let discoveredServicesSubject = PublishSubject<Result<Service, Error>>()

    private var disposeBag = DisposeBag()

    private var isReconnect = false
    private var reConnectCount = 0
    
    
    
    
    public init(managerDelegate:ModiManagerDelegate) {
        
        self.bluetoothService = RxBluetoothKitService()
        self.managerDelegate = managerDelegate
        self.modiConnected = false
        self.macString = ""
        self.modiModuleManager = ModiModuleManager(modiManager: self)
        self.modiCodeUpdater = ModiCodeUpdater(modiManager: self)
//        self.scanningOutput = bluetoothService.scanningOutput
    
        
    }
    
    open func scan() {
        
        ModiLog.i("scan", messages: "scan start")
//        self.disposeBag = DisposeBag()
        
        self.bluetoothService.stopScanning()
        self.peripheralList.removeAll()
        
        self.bluetoothService.startScanning()
        self.bluetoothService.scanningOutput.subscribe(onNext: { result in
            switch result {
            case .success(let value):
                
 
                if(value.peripheral.name == nil) {
                    return
                }
                
                if ((value.peripheral.name ?? "").uppercased()).contains(ModiConstants.BROADCAST_NAME.uppercased()) {
                    
                    
                  if !self.searchPeripheral(value.peripheral) {
                                      
                    self.putPeripheral(peripheral: value.peripheral)
                    let macAddress = ""
                    
                    
                    ModiLog.i("scan", messages: "============================================")
                    ModiLog.i("scan", messages: "value : \(String(describing:value.peripheral.peripheral.name))")
                    ModiLog.i("scan", messages: "value : \(String(describing: value.peripheral.peripheral.identifier.uuidString))")
                    ModiLog.i("scan", messages: "============================================")
                    
                    let name = value.peripheral.peripheral.name!
                    let address  = value.peripheral.peripheral.identifier.uuidString
                    
                    
                   
                    if(self.managerDelegate != nil) {
                        
                        if(self.isReconnect) {
                            
                            self.connect(periperal: self.periperal)
                           self.isReconnect = false
                           return
                        }
                        self.managerDelegate!.onFoundDevice(deviceName: name, deviceAddress: address, macAddress: macAddress)
                    }
                 }
                    
                }
                
                
                case .error(let error):
                 ModiLog.i("scan", messages: "error : \(error)")
//                 self.bluetoothService.stopScanning()
                    self.scanFail(error: error)
                
            }
            }).disposed(by: disposeBag)
    
    }
    
    open func stopScan() {
        bluetoothService.stopScanning()
    }
    
    
    
    open func connect(uuid: String!)  {
        
        self.periperal = getPeripheral(uuid: uuid)
        
         ModiLog.i("modiManager connect", messages: "connect uuid : \(String(describing:uuid))")
         ModiLog.i("modiManager connect", messages: "connect periperal : \(String(describing:periperal))")
        self.connect(periperal: periperal)
          
    }
    
    private func connect(periperal: Peripheral!)  {
       print("modiManager connect periperal ")
       bluetoothService.discoverServices(for: periperal)
       bluetoothService.discoveredServicesOutput
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: { result in
            switch result {
            case .success(let services):
                
                if(self.modiConnected) {
                    ModiLog.i("connect", messages: "modiConnected true")
                    return
                }
                
                self.macString = ModiString.subString(periperal.peripheral.name, start: 5, length: periperal.peripheral.name!.count - 5)
                ModiLog.i("connect", messages: "============================================")
                ModiLog.i("connect", messages: "peripheral.name : \(String(describing:periperal.peripheral.name))")
                ModiLog.i("connect", messages: "uuid value : \(self.macString)")
                ModiLog.i("connect", messages: "uuidString value : \(String(describing: periperal.peripheral.identifier.uuidString))")
                ModiLog.i("connect", messages: "============================================")
                
               
                self.stopScan()
                
                
                services.forEach { service in

                    ModiLog.i("connect", messages: "============================================")
                    ModiLog.i("connect", messages: "uuid : \(String(describing:service.uuid))")
                    ModiLog.i("connect", messages: "services.count : \(String(describing:services.count))")
                    ModiLog.i("connect", messages: "============================================")
                    
                    self.discoverCharacteristics(service: service)
                    
                }
                
               
                
            case .error(let error):
               ModiLog.i("connect", messages: "error : \(error)")
            
                self.connectFail(error : error)
                
            }
        }).disposed(by: disposeBag)
    }
    
    private func discoverCharacteristics(service : Service) {
        
       self.bluetoothService.discoverCharacteristics(for: service)
       
       self.bluetoothService.discoveredCharacteristicsOutput
        .observeOn(MainScheduler.instance)
        .subscribe(onNext: {[unowned self] (success) in
            switch success {
                
                case .success(let characteristics):
                    
                    let item = characteristics[0]
                    
                    if(self.characteristic == item) {
                        ModiLog.i("discoveredServices", messages: "characteristic == item")
                        return
                    }
                    
                     if(ModiGattArributes.isUUIDExist(item.uuid)) {
                                                        
                        self.service = service
                        self.characteristic = item
                        
                        if item.properties.contains(.notify) {
                        
                           self.characteristicUUID = item.uuid
                           self.setupNotification(characteristic: item)
                           ModiLog.i("discoveredServices", messages: "notify")
                       }

                       if item.properties.contains(.read) {
                        
                           self.bluetoothService.readValueFrom(item)
                           self.setupRead()
                        
                            ModiLog.i("discoveredServices", messages: "read")
                       }

                        if item.properties.contains(.write) || item.properties.contains(.writeWithoutResponse) {
                           self.varcharacteristicUuidStreamUpload = item.uuid
                           ModiLog.i("discoveredServices", messages: "write")
                        
                       }
                        
                        ModiLog.i("discoveredServices", messages: "============================================")
                        ModiLog.i("discoveredServices", messages: "characteristics.count : \(String(describing:characteristics.count))")
                        ModiLog.i("discoveredServices", messages: "value2 : \(String(describing:item.uuid))")
                        ModiLog.i("discoveredServices", messages: "============================================")
                        
                        

                    }
                    
                
                var buff: [UInt8]=[0x00,0x00,0x00,0x00,0x00,0x00,0x08,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00]
                let MODI:Data = Data(bytes: &buff, count: buff.count)
                self.sendData(MODI)
                    
                case .error(let error):
                    ModiLog.i("discoveredServices", messages: "error : \(error)")
                    self.disconnect()
                    
            }
        }).disposed(by: self.disposeBag)
        
        
    }
    
    func setupRead() {
        
        ModiLog.d("setModi_ID", messages: "setupRead start")
        
        self.bluetoothService.readValueOutput.subscribe(onNext: {[unowned self] (result) in
            
            switch result {
                case .success(let data) :
                    
                    
                     let lenth = self.macString.count
                     let macString0 = ModiString.subString(self.macString, start : lenth - 2, length: 2)
                     let macString1 = ModiString.subString(self.macString, start : lenth - 4, length: 2)


                     ModiLog.d("setModi_ID1", messages: "\(String(describing: ModiString.convertHexString(data.value)))")
                    

//                     ModiLog.d("setModi_ID1-1", messages: "\(String(describing: macString0))")
//                     ModiLog.d("setModi_ID1-2", messages: "\(String(describing: macString1))")
//                     ModiLog.d("setModi_ID1-3", messages: "\(String(describing: self.stringToBytes(macString0)![0]))")
//                     ModiLog.d("setModi_ID1-4", messages: "\(String(describing: self.stringToBytes(macString1)![0]&0x0f))")
                
                     self.MODI_ID[0] = data.value![0]
                     self.MODI_ID[1] = data.value![1]
                     self.MODI_ID[2] = data.value![2]
                     self.MODI_ID[3] = data.value![3]
                
                     self.modiConnected = true
                     self.managerDelegate?.onConnected()
                     self.reConnectCount = 0
                    
                    
                    ModiLog.d("setupRead", messages: "\(MODI_ID)")
                    ModiLog.d("setupRead", messages: "\(getConnectedModiUuid())")
                    
                    
                    modiModuleManager!.setRootModule(uuid: self.getConnectedModiUuid())
                    modiModuleManager!.discoverModules()
                    self.managerDelegate?.onDiscoveredAllCharacteristics()
                
                  
                case .error(let error) :
                     ModiLog.i("setupRead", messages: "error : \(error)")
                    self.modiConnected = false
                   
                     self.disconnect()
                    
            }
            
        }).disposed(by: disposeBag)
    }
    
    func setupNotification(characteristic : Characteristic) {

        print("setupNotification start \(characteristic)");
        
        self.bluetoothService.observeValueUpdateAndSetNotification(for: characteristic)
        self.bluetoothService.updatedValueAndNotificationOutput
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {[unowned self] (result) in

            switch result {
                case .success(let characteristics) :
                    
                   var i = 0
                   var str:String = ""
                   while(i < characteristic.value!.count) {

                       if i == 0 { str.append(contentsOf: String(format: "%02X", characteristic.value![i])) }
                       else { str.append(contentsOf: String(format: " %02X", characteristic.value![i])) }

                       i += 1
                   }
                   
                   let UUID16bit:String = ModiGattArributes.convert16UUID(characteristic.uuid)

                   switch UUID16bit {
                        case ModiGattArributes.DEVICE_CHAR_TX_RX:
                          if(characteristics.value?.count == 10 || characteristics.value?.count == 16) {

                            if (characteristic.value![0] != 0) {
                                ModiLog.d("setupNotification DEVICE_CHAR_TX_RX", messages: "\(ModiString.convertHexString(characteristics.value)))")
                            }
                            
                            self.managerDelegate?.onReceived(str, bytes: characteristics.value!)
                            let modiFrame = ModiFrame()
                            modiFrame.setFrame(data: characteristics.value!)
                            ModiSingleton.shared.notifyModiFrame(frame: modiFrame.getFrame())
                            
                            if(characteristics.value![0] == 0x28) {
                                
                                self.setModi_ID(value: characteristics.value!)
                              
                            }
                            
                      }

                       case ModiGattArributes.DEVICE_TX_DESC:
                           print("ModiGattArributes.DEVICE_TX_DESC")
                           break

                       default:
                           print("default");
                    
                }
                case .error(let error) :
                    
                   ModiLog.i("setupNotification", messages: "error : \(error)")
                   self.disconnect()
            }

        }).disposed(by: disposeBag)
        
    }


    private func scanFail(error : Error) {
        stopScan()
        
        managerDelegate?.onScanFail(error: error)
    }
    
    private func connectFail(error : Error) {
        
        self.disconnect()
    
        managerDelegate?.onConnectFail(error: error)
    }
    
    open func disconnect() {
        
        self.modiConnected = false
        if let periperal = self.periperal {
            self.bluetoothService.disconnect(periperal)
        }
        self.periperal = nil
        self.stopNotification()
        self.managerDelegate?.onDisconnected()
        
        self.reConnectCount = 0
       
    }
    
    private func reConnect() {
        
        self.reConnectCount = self.reConnectCount+1
        
        
        self.modiConnected = false
        self.bluetoothService.disconnect(self.periperal!)
        self.stopNotification()

        if(reConnectCount > 10) {
            self.reConnectCount = 0
            self.managerDelegate?.onNoServiceFound()
            return
        }
        
        self.isReconnect = true
        self.scan()
    }
    
    
   func searchPeripheral(_ peripheral: Peripheral) -> Bool {
        
        var isExist = false
        for item in self.peripheralList.keys {
            if item == peripheral.identifier.uuidString {
                isExist = true
            }
        }
        
        return isExist
    }
    
    open func putPeripheral(peripheral: Peripheral) {
        
        self.peripheralList[peripheral.identifier.uuidString] = peripheral
    }
    
    open func getPeripheral(uuid: String) -> Peripheral? {
        
        return self.peripheralList[uuid]
    }
    
    open func isConnected() -> Bool {
        ModiLog.d("isConnected", messages: "\(String(describing: self.modiConnected))")
        return self.modiConnected
    }
    
       
    open func stopNotification() {
       
        if(self.characteristic != nil && self.service != nil) {
            
            self.bluetoothService.disposeNotification(for: self.characteristic!)
            self.characteristic = nil
            self.service = nil
//            self.discoverService(service: self.service!)
        }
        
    }
    
    //--------------------------------------------------
    // DATA SENDER
    //--------------------------------------------------
   open func sendData(_ bytes:Data!) {
       
//       let characteristic = self.characteristicsList[ModiGattArributes.DEVICE_CHAR_TX_RX]
        ModiLog.d("sendData", messages: "\(String(describing: ModiString.convertHexString(bytes)))")
    
        self.bluetoothService.writeValueTo(characteristic: self.characteristic!, data: bytes)

   }
    
    func setModi_ID(value : Data) {
        
       //모디 ID를 입력받음
        
        self.MODI_ID[0] = value[0]
        self.MODI_ID[1] = value[1]
        self.MODI_ID[2] = value[2]
        self.MODI_ID[3] = value[3]
  
        self.modiConnected = true
        self.managerDelegate?.onConnected()
        self.reConnectCount = 0
      
        ModiLog.d("setModi_ID value1 : ", messages: "\(String(describing: stringToBytes(value.hexEncodedString())![0]))")
        ModiLog.d("setModi_ID value2 : ", messages: "\(String(describing: stringToBytes(value.hexEncodedString())![1]&0x0f))")
        ModiLog.d("setModi_ID value3 : ", messages: "\(String(describing: self.MODI_ID))")
       
      
    }
    
    
   
   open func getMODI_ID() -> [UInt8]
   {
    return self.MODI_ID
   }
    
    private func stringToBytes(_ string: String) -> [UInt8]? {
        // omit error checking: remove '0x', make sure even, valid chars
        let pairs = toPairsOfChars(pairs: [], string: string)
        return pairs.map { UInt8($0, radix: 16)! }
    }
    
    private func toPairsOfChars(pairs: [String], string: String) -> [String] {
       if string.count == 0 {
           return pairs
       }
       var pairsMod = pairs
       pairsMod.append(String(string.prefix(2)))
       return toPairsOfChars(pairs: pairsMod, string: String(string.dropFirst(2)))
    }

    
   open func checkBluetoothState() -> Bool{
    
     let cm = self.bluetoothService.getCentralManager()
    
    
    switch cm.manager.state {
                                 
         case .poweredOn:
           
            ModiLog.i("discoverServices", messages: "poweredOn")
           
           
             self.bluetoothState = true
             break
         
         case .poweredOff:
            self.bluetoothState = false
            break
         
         case .resetting:
             self.bluetoothState = false
             break
         case .unauthorized:
             self.bluetoothState = false
         
         case .unknown:
             self.bluetoothState = false
         
         case .unsupported :
             self.bluetoothState = false

          @unknown default:
          self.bluetoothState = false
       }

     return self.bluetoothState
    
   }
        
    
    open func findID() {
        var buff: [UInt8]=[
            0x28,0x00,
            0x00,0x00,
            0x00,0x00,
            0x00,0x00,
            0x00, 0x00 ,0x00,0x00,0x00,0x00,0x00,0x00]
        let MODI:Data = Data(bytes: &buff, count: buff.count)
        self.sendData(MODI)
    }
    
    open func getConnectedModiUuid() -> Int {
        
        let littleEndianValue = getMODI_ID().withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: Int.self, capacity: 2) { $0 })
        }.pointee.littleEndian
        
        return littleEndianValue.littleEndian
    }
    
    open func getModuleManager() -> ModiModuleManager {
        
        return self.modiModuleManager!
    }
    
    open func getCodeUpdater() -> ModiCodeUpdater {
        
        return self.modiCodeUpdater!
    }
    
    open func getVersion(){
        let data = ModiProtocol().getVersion(moduleKey: 0)
        sendData(Data(data))
    }
   
}


extension Data {
    /// A hexadecimal string representation of the bytes.
    func hexEncodedString() -> String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(count * 2)
        
        for byte in self {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.append(hexDigits[index1])
            hexChars.append(hexDigits[index2])
        }
        
        return String(utf16CodeUnits: hexChars, count: hexChars.count)
    }
}
