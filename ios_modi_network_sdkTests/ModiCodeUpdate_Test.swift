//
//  ModiCodeUpdate_Test.swift
//  ios_modi_network_sdkTests
//
//  Created by steave_mac on 2021/05/12.
//

import XCTest

import ios_modi_network_sdk


protocol ModiCodeUpdaterCallback {
    
    func onUpdateSuccess()
    func onUpdateFailed(error : String, reason : String);
    func onUpdateProgress(progressCount : Int , total :Int);
}

class ModiCodeUpdate_Test: XCTestCase {

    private var mDone = false
    private var mToTal = 0
    private var mCount = 0
    
    private var callback : ModiCodeUpdaterCallback? = nil

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        self.callback = ModiCodeUpdaterCallback.self as? ModiCodeUpdaterCallback
        progressNotifierStart(total : 100)
        
        while (self.mDone != true) {
            progressNotifierAddCount(count : 1)
            
        }
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func progressNotifierStart(total : Int) {
        
        self.mToTal = total
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            
            if self.mDone {
        
                timer.invalidate()
                return
            }
            self.notifyProgressEvent()
        
        }
        timer.fire()
    
    }
    
    func notifyProgressEvent() {
        print("notifyProgressEvent \(self.mCount) / \(self.mToTal)")
        self.callback?.onUpdateProgress(progressCount: self.mCount, total: self.mToTal)
    }
    
    func progressNotifierAddCount(count : Int) {
        
        self.mCount += count
        
        if(self.mCount >= self.mToTal) {
            self.mDone = true
        }
        
        self.notifyProgressEvent()
    }
    
    func progressNotifierComplete() {
        
        self.mDone = true
        callback?.onUpdateSuccess()
    
    }
}
