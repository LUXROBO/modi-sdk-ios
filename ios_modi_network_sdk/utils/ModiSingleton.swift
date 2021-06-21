//
//  ModiSingleton.swift
//  ios_modi_network_sdk
//
//  Created by steave_mac on 2021/05/20.
//

import Foundation
import RxSwift
import RxCocoa


class ModiSingleton {
    
    static let shared = ModiSingleton()
    
    var modiFrameSubject = PublishSubject<ModiFrame>()
    
    private init() {
        
    }
    
    func getModiFrameObserver() -> Observable<ModiFrame> {
        
        return modiFrameSubject.asObservable()
    }
    
    func notifyModiFrame(frame : ModiFrame) {
        
        modiFrameSubject.onNext(frame)
    }
}
