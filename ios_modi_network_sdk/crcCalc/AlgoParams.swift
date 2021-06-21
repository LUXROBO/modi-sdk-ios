//
//  AlgoParams.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/05/28.
//

import Foundation

class AlgoParams {
    
    let name : String
    let hashSize : Int
    let poly : UInt64
    let initial : UInt64
    let refIn : Bool
    let refOut : Bool
    let xorOut : Int
    let check : Int
    
    init(name : String, hashSize : Int, poly : UInt64, initial : UInt64, refIn : Bool, refOut : Bool, xorOut : Int, check : Int) {
        self.name = name
        self.hashSize = hashSize
        self.poly = poly
        self.initial = initial
        self.refIn = refIn
        self.refOut = refOut
        self.xorOut = xorOut
        self.check = check
    }
}
