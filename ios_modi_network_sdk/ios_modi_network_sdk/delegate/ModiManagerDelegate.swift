/*
 * Developement Part, SOLTER INC., SEOUL, KOREA
 * Copyright(c) 2014 by Solter Inc.
 *
 * All rights reserved. No part of this work may be reproduced, stored in a
 * retrieval system, or transmitted by any means without prior written
 * Permission of Solter Inc.
 */

import Foundation


@objc public protocol ModiManagerDelegate : NSObjectProtocol {
    
    // SCAN
    func onFoundDevice(deviceName name:String, deviceAddress address:String, macAddress:String)
    func onConnected()
    func onDisconnected()
    func onDiscoveredAllCharacteristics()
    func onScan(_ scanable:Bool)
    
    // BLUETOOTH
    func onBluetoothEnabled(_ enabled:Bool)
    func onBluetoothStateOn(_ connected:Bool)
    func onBluetoothStateError()
    func onBluetoothStateUnknown()
    func onNoServiceFound()
    
    func onReceived(_ data:String, bytes:Data!)
}