//
//  ModiProtocol_Test.swift
//  ios_modi_network_sdkTests
//
//  Created by steave_mac on 2021/05/07.
//

import XCTest

import ios_modi_network_sdk


class ModiProtocol_Test: XCTestCase {

    class Stream {
        var moduleId : Int = 0
        var streamId : UInt8 = 0
        var streamType : STREAM_TYPE = STREAM_TYPE.INTERPRETER
        var streamBody : Array<UInt8> = []
    }
    
    enum STREAM_TYPE : Int {
        case INTERPRETER = 3
    }
    
    enum STREAM_RESPONSE : Int {
        case SUCCESS = 0
        case DUPLICATE = 3
        case UNDEFINED = 4
        case TIMEOUT = 5
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        testStreamCommand()
    }
    
    
    func testStreamDataList() {
        
        let stream = Stream()
        stream.streamBody = [0x00, 0x00,0x00,0x00,0x00,0x00,0x00, 0x01]
        stream.streamId = 10
        
        for i in stride(from : 0, to : stream.streamBody.count - 1, by: 7)  {

           let begin = i
           var end = i + 7
           
            if (end > stream.streamBody.count) {
                end = stream.streamBody.count
            }
           
            let slice : [UInt8] =  Array(stream.streamBody[begin...end])
            var streamSlice = [UInt8](repeating: 0, count: slice.count + 1)
            
            
            print("streamSlice : \(streamSlice.count)")
            print("slice.count : \(slice.count)")
            
            
            streamSlice[0] = stream.streamId
            
            for j in 0...slice.count - 1 {
                
                print("slice.count : \(j)")
                
                streamSlice[j+1] = slice[j]
            }
            
            print("streamSlice : \(streamSlice)")
            
        }
        
    }

    func testStreamCommand() {
        
        let stream = Stream()
        stream.streamBody = [0x00, 0x01]
    
        var streamCommandData = [UInt8](repeating: 0, count: 8)
        let streamBodySize = stream.streamBody.count


        streamCommandData[0] = stream.streamId
        streamCommandData[1] = 3

        let dataArray = withUnsafeBytes(of: streamBodySize, Array.init)
        
        for i in 0...3 {

            streamCommandData[i + 2] = dataArray[i]

        }
        
        print(streamCommandData)

        
    }
    
    func testDiscoverModule(module_uuid : Int64, flag : UInt8) {
        
        var data = [UInt8](repeating: 0, count: 8)
        var uuid = module_uuid
        
        for i in 0...5 {
           data[i] = (UInt8)(uuid & 0xFF)
           uuid = uuid >> 8
       }

       data[7] = flag;
    
//        print(ModiFrame().makeFrame(cmd: 0x08, sid: 0, did : 0xFFF , binary : data))
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
