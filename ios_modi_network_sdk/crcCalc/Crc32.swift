//
//  Crc32.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/05/28.
//

import Foundation


class Crc32 {
//    let Crc32 = AlgoParams(name: "CRC-32", hashSize: 32, poly: 0x04C11DB7, initial: 0xFFFFFFFF, refIn: true, refOut: true, xorOut: 0xFFFFFFFF, check: 0xCBF43926)
//    let Crc32Bzip2 = AlgoParams(name: "CRC-32/BZIP2", hashSize: 32, poly: 0x04C11DB7, initial: 0xFFFFFFFF, refIn: false, refOut: false, xorOut: 0xFFFFFFFF, check: 0xFC891918)
//    let Crc32C = AlgoParams(name: "CRC-32C", hashSize: 32, poly: 0x1EDC6F41, initial: 0xFFFFFFFF, refIn: true, refOut: true, xorOut: 0xFFFFFFFF, check: 0xE3069283)
    
    let Crc32Mpeg2 = AlgoParams(name: "CRC-32/MPEG-2", hashSize: 32, poly: 0x04C11DB7, initial: 0x00000000, refIn: false, refOut: false, xorOut: 0x00000000, check: 0x0376E6E7)
}
