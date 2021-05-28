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
    let poly : Int
    let initial : Int
    let refIn : Bool
    let refOut : Bool
    let xorOut : Int
    let check : Int
    
    init(name : String, hashSize : Int, poly : Int, initial : Int, refIn : Bool, refOut : Bool, xorOut : Int, check : Int) {
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
