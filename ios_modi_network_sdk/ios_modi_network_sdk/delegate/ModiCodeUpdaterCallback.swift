//
//  ModiCodeUpdaterCallback.swift
//  Code-Sketch
//
//  Created by steave_mac on 2021/03/18.
//

import Foundation

public protocol ModiCodeUpdaterCallback : NSObjectProtocol {
    
    func onUpdateSuccess()
    func onUpdateFailed(error : CodeUpdateError, reason : String);
    func onUpdateProgress(progressCount : Int , total :Int);
}
