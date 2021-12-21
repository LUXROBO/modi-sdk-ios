//
//  ModiKind.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/09/10.
//

import Foundation

public enum ModiKind {
    
    public typealias RawValue = Int
    public typealias FromInteager = ModiKind
    
    case MODI
    case MODI_PLUS

    
    
    public var rawValue: RawValue {
      switch self {
        case .MODI: return 0
        case .MODI_PLUS: return 1

      }
    }

}
