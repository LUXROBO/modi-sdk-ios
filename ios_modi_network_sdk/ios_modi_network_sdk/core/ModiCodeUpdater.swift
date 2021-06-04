import Foundation
import RxSwift
import RxCocoa

open class ModiCodeUpdater : ModiFrameObserver{
    
    private let MODULE_PROGRESS_COUNT_UNIT = 5;
    private let PROGRESS_NOTIFY_PERIOD = 150;
    private let RetryMaxCount = 5
    
    private var modiManager : ModiManager
    private var mRecieveQueue : Array<ModiFrame>? = nil
    private var modiStream : ModiStream? = nil
    private var modiCodeUpdaterCallback : ModiCodeUpdaterCallback? = nil
    private var mUpdateTargets : Array<ModiModule>? = nil
    private var mRunningFlag = false
    private var mDone = false
    
    private var timer : Timer? = nil
    
    private var mToTal = 0
    private var mCount = 0
    
    private var mUserEnable = false
    private var mPnpEnable = false
    
    private var startUpdateDisposable : Disposable!
    private var startResetDisposable : Disposable!
    
    init(modiManager : ModiManager) {
        
        self.modiManager = modiManager
        
    }
    
    open func startReset(callback : ModiCodeUpdaterCallback) {
    
        if mRunningFlag == true {
           
            mRunningFlag = false
            mDone = false
            
            callback.onUpdateFailed(error: CodeUpdateError.CODE_NOW_UPDATING, reason: "Code Update Task is running")
            
            return
        }
        
        self.mCount = 0
        self.mUserEnable = false
        self.mPnpEnable = true
        
        self.modiCodeUpdaterCallback = callback
        let uuid = modiManager.getConnectedModiUuid() & 0xFFF
        let data : Array<UInt8> = []
        self.modiStream = ModiStream().makeStream(moduleId: uuid,streamId: 0,streamType: ModiStream.STREAM_TYPE.INTERPRETER, streamBody: data)
        
        mUpdateTargets = modiManager.getModuleManager().getModules()
        
        mRunningFlag = true
        
        runUpdateTask()
    
        
    }
    

    
    open func startUpdate(stream : ModiStream, callback : ModiCodeUpdaterCallback) {
        
        if mRunningFlag == true {
            
            mRunningFlag = false
            mDone = false
            
            callback.onUpdateFailed(error: CodeUpdateError.CODE_NOW_UPDATING, reason: CodeUpdateError.CODE_NOW_UPDATING.rawValue)
            return
        }
        
        mCount = 0
        mUserEnable = false
        mPnpEnable = false
        mRunningFlag = true
        modiStream = stream
        mUpdateTargets = modiManager.getModuleManager().getModules()
        modiCodeUpdaterCallback = callback
        
        runUpdateTask()
        
    }
    
    func getTotal() throws -> Int {

        
        let total = mUpdateTargets!.count * MODULE_PROGRESS_COUNT_UNIT + modiStream!.streamBody.count
        
        if total == 0 {
            throw CodeUpdateError.CONNECTION_ERROR
        }
        
        return total
        
    }
    
    func runUpdateTask()  {
        
        do  {
            mToTal = try getTotal()
            
            progressNotifierStart()
            var bytes = ModiProtocol().setModuleState(moduleKey : 0xFFF, state : ModiProtocol.MODULE_STATE.STOP)
            self.sendData(bytes: bytes)
            requestResetStream()
            
            
            for module in mUpdateTargets! {
                
                if module.type == ModiModule().typeCodeToString(typeCode : 0) {
                    
                    progressNotifierAddCount(count: MODULE_PROGRESS_COUNT_UNIT)
                    
                    continue
                }
                
                for retry in 0...RetryMaxCount {
                    
                    do {
                        try requestChangeUpdateMode(module : module)
                    }
                    
                    catch CodeUpdateError.CODE_NOT_UPDATE_MODE {
                        
                        if retry == RetryMaxCount - 1 {
                            updateFail(error : CodeUpdateError.CODE_NOT_UPDATE_MODE)
                        }
                    }
                    
                    catch {
                        
                        if retry == RetryMaxCount - 1 {
                            updateFail(error : CodeUpdateError.CODE_NOT_UPDATE_READY)
                        }
                    }
                }
                
                for retry in 0...RetryMaxCount {
                    
                    do {
                        try setPlugAndPlayModule(module : module, pnpEnable: mPnpEnable, userEnable: mUserEnable)
                    }
                    
                    catch CodeUpdateError.FLASH_ERASE_ERROR {
                        if retry == RetryMaxCount - 1 {
                            updateFail(error : CodeUpdateError.FLASH_ERASE_ERROR)
                        }
                    }
                    
                    catch {
                        
                        if retry == RetryMaxCount - 1 {
                            updateFail(error : CodeUpdateError.CODE_NOT_UPDATE_MODE)
                        }
                    }
                }
                
                progressNotifierAddCount(count: MODULE_PROGRESS_COUNT_UNIT)
                
            }
            
            try requestStream()
        
            bytes = ModiProtocol().setModuleState(moduleKey : 0xFFF, state : ModiProtocol.MODULE_STATE.RESET)
            sendData(bytes: bytes)
            
            Observable.just(0).delay(RxTimeInterval.milliseconds(200), scheduler: MainScheduler.instance).subscribe { (result) in
                self.progressNotifierComplete()
                if self.modiCodeUpdaterCallback != nil {
                    self.modiCodeUpdaterCallback?.onUpdateSuccess()
                }
                
            }
           
        }

        catch CodeUpdateError.CONNECTION_ERROR  {
            print("\(CodeUpdateError.CONNECTION_ERROR.rawValue)")
            notifyUpdateFail(reson: CodeUpdateError.CONNECTION_ERROR.rawValue)
        }
        
        catch  {
            print("\(CodeUpdateError.MODULE_TIMEOUT.rawValue)")
            notifyUpdateFail(reson: CodeUpdateError.MODULE_TIMEOUT.rawValue)
        }
        
        progressNotifierComplete()
        mRunningFlag = false
        
    }
    
    func requestStream() throws {
        
        if modiStream!.streamBody.count  > 0 {
            
            mRecieveQueue?.removeAll()
            
            let bytes = ModiProtocol().streamCommand(stream: modiStream!)
            self.sendData(bytes: bytes)
            
            do {
                var response = try waitForModiFrame(timeout: 5000, frameFilter: getStreamFilter(moduleKey: modiStream!.moduleId, streamId: Int(modiStream!.streamId)))
                
                if response.data()[1] != ModiStream.STREAM_RESPONSE.SUCCESS.rawValue {
                    throw CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED
                }
                
                let frames : Array<[UInt8]> = ModiProtocol().streamDataList(stream: modiStream!)
                
                for frame in frames {
                    
                    mRecieveQueue?.removeAll()
                    sendData(bytes: frame)
                    progressNotifierAddCount(count: Int(frame[6]) - 1)
                }
                
                response = try waitForModiFrame(timeout: 5000, frameFilter: getStreamFilter(moduleKey: modiStream!.moduleId, streamId: Int(modiStream!.streamId)))
                
                if response.data()[1] != 0x00 {
                    throw CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED
                }
                
            }
            
            catch CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED {
                print("\(CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED.rawValue)")
                notifyUpdateFail(reson: CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED.rawValue)
            }
           
            
        }
    }
    
    
    func setPlugAndPlayModule(module : ModiModule, pnpEnable : Bool, userEnable : Bool) throws {
        
        let targetModuleKey = module.uuid & 0xFFF
        mRecieveQueue?.removeAll()
        
        var bytes = ModiProtocol().firmwareCommand(moduleKey: targetModuleKey, flashCmd: ModiProtocol.FLASH_CMD.ERASE, address: 0x0801F800, crc: 0)
        sendData(bytes: bytes)
        
        var res = try waitForModiFrame(timeout: 5000, frameFilter: getFirmwareFilter(moduleKey: targetModuleKey))
        
        if res.data()[4] != 0x07 {
            throw CodeUpdateError.FLASH_ERASE_ERROR
        }
        
        var pnpData = Array<UInt8>()
        
        pnpData[0] = 0xAA
        pnpData[1] = mPnpEnable ? 0 : 1
        pnpData[2] = mUserEnable ? 1 : 0
        pnpData[3] = 0x00
        
        let idBuffer = withUnsafeBytes(of: module.uuid & 0xFFF, Array.init)
        let versionBuffer = withUnsafeBytes(of:  module.version, Array.init)
        
        pnpData[4] = idBuffer[0]
        pnpData[5] = idBuffer[1]
        pnpData[6] = versionBuffer[0]
        pnpData[7] = versionBuffer[1]
        
        bytes = ModiProtocol().firmwareData(moduleKey: targetModuleKey, segment: 0, data: pnpData)
        sendData(bytes: bytes)
        
        let reverseData = reverseBlock(source : pnpData)
        
        let crcValue = calculateCrc32(data : reverseData)
        
        mRecieveQueue?.removeAll()
        
        bytes = ModiProtocol().firmwareCommand(moduleKey: targetModuleKey, flashCmd: ModiProtocol.FLASH_CMD.CHECK_CRC, address: 0x0801F800, crc: crcValue)
        sendData(bytes: bytes)
        
    }
    
    func calculateCrc32(data : [UInt8])-> Int {
        let crcCalc = CrcCalculator(params: Crc32().Crc32Mpeg2)

        return crcCalc.calc(data: data, offset: 0, length: data.count)
    }
    
    func reverseBlock(source : [UInt8]) -> [UInt8] {
        
        var buffer = [UInt8](repeating: 0, count: 8)
        
        var old = 0
        var j = 3
        
        for i in 0...7 {
            buffer[i] = source[j]
            j -= 1
            
            if j == old {
                
                j = i + 5
                old = i + 1
            }
        }
        
        return buffer
        
    }
    
    func updateFail(error : CodeUpdateError) {
        
        let bytes = ModiProtocol().setModuleState(moduleKey: 0xFFF, state: ModiProtocol.MODULE_STATE.RESET)
        sendData(bytes: bytes)
        
        notifyUpdateFail(reson: error.rawValue)
        
    }
    
    func requestChangeUpdateMode(module : ModiModule) throws {
        
        let targetModuleKey = module.uuid & 0xFFF
        
        mRecieveQueue?.removeAll()
        
        var bytes = ModiProtocol().setModuleState(moduleKey: targetModuleKey, state: ModiProtocol.MODULE_STATE.UPDATE)
        sendData(bytes: bytes)
        
        var res = try waitForModiFrame(timeout: 1200, frameFilter: getModuleStateFilter(moduleKey: targetModuleKey))
        
        if res.data()[6] != ModiProtocol.MODULE_WARNING.FIRMWARE.rawValue {
            throw CodeUpdateError.CODE_NOT_UPDATE_MODE
        }
        
        mRecieveQueue?.removeAll()
        
        bytes = ModiProtocol().setModuleState(moduleKey: targetModuleKey, state: ModiProtocol.MODULE_STATE.UPDATE_READY)
        sendData(bytes: bytes)
        
        res = try waitForModiFrame(timeout: 1200, frameFilter: ChageUpdateFilter(moduleKey: targetModuleKey))
        
        if res.data()[6] != ModiProtocol.MODULE_WARNING.FIRMWARE_READY.rawValue {
            throw CodeUpdateError.CODE_NOT_UPDATE_READY
        }
        
    }
    
    func requestResetStream() {
        
        let resetStream = ModiStream()
        resetStream.streamType = modiStream!.streamType
        resetStream.moduleId = modiStream!.moduleId
        resetStream.streamId = modiStream!.streamId
        resetStream.streamBody = Array<UInt8>()
        
        var responseCode = ModiStream.STREAM_RESPONSE.SUCCESS.rawValue
        
        for i in 0...RetryMaxCount {
            
            do {
                mRecieveQueue?.removeAll()
                
                let bytes = ModiProtocol().streamCommand(stream: resetStream)
                sendData(bytes: bytes)
                let response = try waitForModiFrame(timeout: 5000, frameFilter: getStreamFilter(moduleKey : resetStream.moduleId, streamId : Int(resetStream.streamId)))
                
                responseCode = Int(response.data()[1])
                
                if responseCode != ModiStream.STREAM_RESPONSE.SUCCESS.rawValue {
                    print("Stream Reset Error. (\(responseCode)  retry : \(i)")
                    continue
                }
                
                return
                
            }
            
            catch {
                print("Stream Reset Response Timeout.")
                notifyUpdateFail(reson: "Modi Stream Command response failed : \(responseCode)")
            }
        }
        
    }
    
    func waitForModiFrame(timeout : Int , frameFilter : ModiFrameFilter) throws -> ModiFrame {
        
        let startTime = Date().timeIntervalSinceNow
        var curTime = startTime
        
        while (Int(curTime - startTime) < timeout) {

            if mRecieveQueue?.isEmpty != true {

                let frame = mRecieveQueue?.first

                mRecieveQueue?.remove(at: 0)

                if frameFilter.filter(frame: frame!) {
                    return frame!
                }
            }

            else {
                Observable.just(0).delay(RxTimeInterval.milliseconds(100), scheduler: MainScheduler.instance)
            }
            
            curTime = Date().timeIntervalSinceNow
        }

        throw CodeUpdateError.MODULE_TIMEOUT
    }
    
    func getStreamFilter(moduleKey : Int, streamId : Int) -> ModiFrameFilter {
        return StreamFilter(moduleKey: moduleKey, streamId: streamId)
    }
    
    func getFirmwareFilter(moduleKey : Int) -> ModiFrameFilter {
        return FirmwareFilter(moduleKey: moduleKey)
    }
    
    func getModuleStateFilter(moduleKey : Int) -> ModiFrameFilter {
        return ModuleStateFilter(moduleKey: moduleKey)
    }
    
    func getChageUpdateFilter(moduleKey : Int) -> ModiFrameFilter {
        return ChageUpdateFilter(moduleKey: moduleKey)
    }
    
    func onModiFrame(frame: ModiFrame) {
        
        if frame.cmd() != 0x00 {
            
            mRecieveQueue?.append(frame)
        }
        
        while mRecieveQueue!.count > 64 {
            mRecieveQueue!.popLast()
        }
    }
    
    private func progressNotifierStart() {
        
    
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            
            if self.mDone {
        
                timer.invalidate()
                return
            }
            self.notifyProgressEvent()
        
        }
        
        timer!.fire()
    
    }
    
    func notifyProgressEvent() {
        print("notifyProgressEvent \(self.mCount) / \(self.mToTal)")
        self.modiCodeUpdaterCallback?.onUpdateProgress(progressCount: self.mCount, total: self.mToTal)
    }

    func progressNotifierComplete() {
        
        mDone = true
        mRunningFlag = false
    }
    
    func progressNotifierAddCount(count : Int) {
        
        self.mCount += count
        
        if(self.mCount >= self.mToTal) {
            self.mDone = true
        }
        
        self.notifyProgressEvent()
    }
    
    func sendData(bytes : Array<UInt8>) {
        let data = Data(bytes : bytes, count: bytes.count)
        modiManager.sendData(data)
    }
    
    func notifyUpdateFail(reson : String) {
        
        progressNotifierComplete()
        let bytes = ModiProtocol().setModuleState(moduleKey : 0xFFF, state : ModiProtocol.MODULE_STATE.RESET)
        self.sendData(bytes: bytes)
        
        if modiManager.isConnected() != true {
            
            modiCodeUpdaterCallback?.onUpdateFailed(error: CodeUpdateError.CONNECTION_ERROR, reason: "check ble connection.")
            return
        }
        
        modiCodeUpdaterCallback?.onUpdateFailed(error: CodeUpdateError.MODULE_TIMEOUT, reason: reson)
        
    }

    
}
