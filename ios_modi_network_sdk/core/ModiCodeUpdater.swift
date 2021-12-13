import Foundation
import RxSwift
import RxCocoa

open class ModiCodeUpdater : ModiFrameObserver{
    
    private let MODULE_PROGRESS_COUNT_UNIT = 5;
    private let PROGRESS_NOTIFY_PERIOD = 150;
    private let RetryMaxCount = 5
    
    private var modiManager : ModiManager
    private var mRecieveQueue : Array<ModiFrame> = Array()
    private var mRecieveQueueSubject = PublishSubject<ModiFrame>()
    private var modiStream : ModiStream? = nil
    private var modiCodeUpdaterCallback : ModiCodeUpdaterCallback? = nil
    private var mUpdateTargets : Array<ModiModule>? = nil
    private var mRunningFlag = false
    private var mDone = false
    
    private var timer : Timer? = nil
    
    private var mToTal = 0
    private var mCount = 0
    private var mModuleUpdateCount = 0

    private var mUserEnable = false
    private var mPnpEnable = false
    
    private var startUpdateDisposable : Disposable!
    private var startResetDisposable : Disposable!
    
    private var modiFrame : ModiFrame? = nil
    
    private var disposeBag : DisposeBag?
    
    private let background = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
    
    private var frameFilter = FRAME_FILTER.RESET_STREAM
    private var modiKind = ModiKind.MODI_PLUS
    
//    private var modiFrameTimerCheck = Date().timeIntervalSince1970 * 1000
    
    enum FRAME_FILTER {
        
        typealias RawValue = Int
        
        case RESET_STREAM
        case MODULE_STATE_UPDATE
        case MODULE_STATE_UPDATE_READY
        case FLASH_CMD_ERASE
        case FLASH_CMD_CHECK_CRC
        case UPLOAD_STREAM
        case UPLOAD_STREAM_DATA
        
        var rawValue: RawValue {
          switch self {
            case .RESET_STREAM:                 return 0
            case .MODULE_STATE_UPDATE:          return 1
            case .MODULE_STATE_UPDATE_READY:    return 2
            case .FLASH_CMD_ERASE:              return 3
            case .FLASH_CMD_CHECK_CRC:          return 4
            case .UPLOAD_STREAM:                return 5
            case .UPLOAD_STREAM_DATA:           return 6
          }
        }
    }
    
    
    init(modiManager : ModiManager) {
        
        self.modiManager = modiManager
        self.disposeBag = DisposeBag()
    
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
        modiCodeUpdaterCallback = callback
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
        
        if mUpdateTargets!.count == 0 {
            throw CodeUpdateError.CONNECTION_ERROR
        }
        print("getTotal \(total)")
        return total
        
    }
    
    func runUpdateTask()  {
        
        do  {
            
           
//            let backgroundScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
            self.disposeBag = DisposeBag()
            mModuleUpdateCount  = 0
            self.frameFilter = FRAME_FILTER.RESET_STREAM
            self.sendData(bytes: ModiProtocol().discoverModule(module_uuid : 0xFFF, flag : 0x0))
            
            ModiSingleton.shared.getModiFrameObserver()
//                .observeOn(MainScheduler.instance)
//                .observeOn(background)
//                .subscribeOn(MainScheduler.instance)
                .subscribe { frame in
                    
                self.onModiFrame(frame: frame)
                }.disposed(by: disposeBag!)
            
            mToTal = try getTotal()
            
            progressNotifierStart()
            
            let bytes = ModiProtocol().setModuleState(moduleKey : 0xFFF, state : ModiProtocol.MODULE_STATE.STOP)
            self.sendData(bytes: bytes)
            
            self.requestResetStream()
            
           
        }

        catch CodeUpdateError.CONNECTION_ERROR  {
            print("\(CodeUpdateError.CONNECTION_ERROR.rawValue)")
            notifyUpdateFail(error : CodeUpdateError.CONNECTION_ERROR, reson: CodeUpdateError.CONNECTION_ERROR.rawValue)
        }
        
        catch  {
            print("\(CodeUpdateError.MODULE_TIMEOUT.rawValue)")
            notifyUpdateFail(error : CodeUpdateError.CONNECTION_ERROR, reson: CodeUpdateError.MODULE_TIMEOUT.rawValue)
        }
        
        print("runUpdateTask end")
        
    }
    
    func updateModule() {
        

        let module = mUpdateTargets![mModuleUpdateCount]
        
        print("steave updateModule \(module.type) mModuleUpdateCount \(mModuleUpdateCount)")
        
        if module.type == ModiModule().typeCodeToString(typeCode : 0) {

            if (mModuleUpdateCount < mUpdateTargets!.count - 1) {
                mModuleUpdateCount += 1
                progressNotifierAddCount(count: MODULE_PROGRESS_COUNT_UNIT)
                updateModule()
                return
            }
            progressNotifierAddCount(count: MODULE_PROGRESS_COUNT_UNIT)
            updateEnd()
            return
           
        }

        do {
           
            try requestChangeUpdateMode(module : module)
           
            
        }

        catch CodeUpdateError.CODE_NOT_UPDATE_MODE {

            updateFail(error : CodeUpdateError.CODE_NOT_UPDATE_MODE)
        }

        catch {

            updateFail(error : CodeUpdateError.CODE_NOT_UPDATE_READY)
        }
        
        
        if mModuleUpdateCount == mUpdateTargets!.count {
            
            updateEnd()
            
        }
        
    }
    
    func updateEnd() {
        
        self.requestStream()
    
    }
    
    func requestStream() {
        
        print("steave requestStream ")
        
        if modiStream!.streamBody.count  > 0 {
            
            mRecieveQueue.removeAll()
            self.frameFilter = FRAME_FILTER.UPLOAD_STREAM
           
            var checkTime = Date().timeIntervalSince1970 * 1000
            do {
                
                let bytes = ModiProtocol().streamCommand(stream: self.modiStream!)
                self.sendData(bytes: bytes)
                
                mRecieveQueueSubject
                    .subscribeOn(MainScheduler.instance)
                    .subscribe { event in
                    
                        
                        self.timerCheck(checkTime: checkTime, timeout: 1000 * 10)
                        
                    if self.getStreamFilter(moduleKey: self.modiStream!.moduleId, streamId: Int(self.modiStream!.streamId)).filter(frame: event.element!) == true {
                        
                        let  responseCode = Int(event.element!.data()[1])
                        
//                        print("steave requestStream UPLOAD_STREAM \(responseCode)")
                        
                        if responseCode != ModiStream.STREAM_RESPONSE.SUCCESS.rawValue {
                            self.updateFail(error: CodeUpdateError.MODULE_TIMEOUT)
                            return
                        }
                        
                        let frames : Array<[UInt8]> = ModiProtocol().streamDataList(stream: self.modiStream!)
                        
                        self.frameFilter = FRAME_FILTER.UPLOAD_STREAM_DATA
                        for frame in frames {
                            
                            self.mRecieveQueue.removeAll()
                            self.sendData(bytes: frame)
                            self.progressNotifierAddCount(count: Int(frame[6]) - 1)
                            
                        }
                        checkTime = Date().timeIntervalSince1970 * 1000
                    }
                
                    
                    else if self.getStreamFilter(moduleKey: self.modiStream!.moduleId, streamId: Int(self.modiStream!.streamId)).filter(frame: event.element!) == true &&
                                self.frameFilter == FRAME_FILTER.UPLOAD_STREAM_DATA {
                        
                        
                    
                        let responseCode = Int(event.element!.data()[1])
                        
//                        print("steave requestStream UPLOAD_STREAM_DATA \(responseCode)")
                        
                        if responseCode != ModiStream.STREAM_RESPONSE.SUCCESS.rawValue {
                            self.updateFail(error: CodeUpdateError.MODULE_TIMEOUT)
                            return
                        }
                        
                        let bytes = ModiProtocol().setModuleState(moduleKey : 0xFFF, state : ModiProtocol.MODULE_STATE.RESET)
                        self.sendData(bytes: bytes)
                        self.sendData(bytes: ModiProtocol().setStartInterpreter())
                        
                        
                        self.progressNotifierComplete()
                        if self.modiCodeUpdaterCallback != nil {
                            self.modiCodeUpdaterCallback?.onUpdateSuccess()
                        }
                        
                    }
                    
                }.disposed(by: disposeBag!)
                
            }
            
            catch CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED {
                print("\(CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED.rawValue)")
                notifyUpdateFail(error: CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED, reson: CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED.rawValue)
            }
           
            
        }
        
        else {
            
            let bytes = ModiProtocol().setModuleState(moduleKey : 0xFFF, state : ModiProtocol.MODULE_STATE.RESET)
            self.sendData(bytes: bytes)
            self.sendData(bytes: ModiProtocol().setStartInterpreter())
            
            
            self.progressNotifierComplete()
            if self.modiCodeUpdaterCallback != nil {
                self.modiCodeUpdaterCallback?.onUpdateSuccess()
            }
            
        }
        
       
        
    }
    
    
    func setPlugAndPlayModule(module : ModiModule, pnpEnable : Bool, userEnable : Bool) {
        
        print("steave setPlugAndPlayModule type \(module.type) \(module.uuid)")
        
        let targetModuleKey = module.uuid & 0xFFF
        mRecieveQueue.removeAll()
        
        
        var address = 0x0800F800
        var moduleCase = 1
        

        self.frameFilter = FRAME_FILTER.FLASH_CMD_ERASE
        
        if modiKind == .MODI_PLUS {
            
            if (module.type == "Network" || module.type == "Display" || module.type == "Environment" || module.type == "Speaker") {
               address = 0x0801F800;
               moduleCase = 0;
           }
        }
        
         
        var bytes = ModiProtocol().firmwareCommand(moduleKey: targetModuleKey, flashCmd: ModiProtocol.FLASH_CMD.ERASE, address: address, crc: 1)
        sendData(bytes: bytes)
        
        var checkTime = Date().timeIntervalSince1970 * 1000
       
        mRecieveQueueSubject
            .subscribe(onNext: { event in
           
                        
            if(self.frameFilter.rawValue < FRAME_FILTER.FLASH_CMD_ERASE.rawValue ||
                self.frameFilter.rawValue > FRAME_FILTER.FLASH_CMD_CHECK_CRC.rawValue) {
                return
            }
                        
            self.timerCheck(checkTime: checkTime, timeout:1000 * 10 * self.mUpdateTargets!.count)
                        
            if self.getFirmwareFilter(moduleKey: targetModuleKey).filter(frame: event) == true && self.frameFilter == FRAME_FILTER.FLASH_CMD_ERASE {
                
                let frame = self.mRecieveQueue.last
                self.mRecieveQueue.removeLast()
                
                let responseCode = Int(frame!.data()[4])
                
                print("steave setPlugAndPlayModule responseCode \(responseCode)")

                if responseCode != 0x07 {
                    self.updateFail(error: CodeUpdateError.FLASH_ERASE_ERROR)
                }

                else {
                    var pnpData = [UInt8](repeating: 0, count: 8)
                    
                    pnpData[0] = 0xAA
                    pnpData[1] = self.mPnpEnable ? 0 : 1
                    pnpData[2] = self.mUserEnable ? 1 : 0
                    pnpData[3] = 0x00
                    
                    let idBuffer = withUnsafeBytes(of: module.uuid & 0xFFF, Array.init)
                    let versionBuffer = withUnsafeBytes(of:  module.version, Array.init)
                    
                    pnpData[4] = idBuffer[0]
                    pnpData[5] = idBuffer[1]
                    pnpData[6] = versionBuffer[0]
                    pnpData[7] = versionBuffer[1]
                    
                    
                    bytes = ModiProtocol().firmwareData(moduleKey: targetModuleKey, segment: 0, data: pnpData)
                    self.sendData(bytes: bytes)
                    
                    var reverseData = self.reverseBlock(source : pnpData)
                    var crcValue = self.calculateCrc32(data : reverseData)
                    
//                    print("steave setPlugAndPlayModule crcValue \(crcValue)")
                    //0x3BF0B6D
                    //0xf084a0dc
                    self.mRecieveQueue.removeAll()
                    
                    self.frameFilter = FRAME_FILTER.FLASH_CMD_CHECK_CRC
                    
                    if self.modiKind == .MODI {
                        
                        bytes = ModiProtocol().firmwareCommand(moduleKey: targetModuleKey, flashCmd: ModiProtocol.FLASH_CMD.CHECK_CRC, address: 0x0801F800, crc: crcValue)
                        self.sendData(bytes: bytes)
                    
                    }
                    
                    else if self.modiKind == .MODI_PLUS {
                        
                        var bootingAddress = [UInt8](repeating: 0, count: 8)
                        
                        for i in 0 ..< 6 {
                            
                            bootingAddress[i] = 0x00
                        }
                        
                        bootingAddress[7] = 0x08
                        
                        if(moduleCase == 0) {

                            bootingAddress[5] = 0x90

                        } else {

                            bootingAddress[5] = 0x50

                        }
                        
                    
                        bytes = ModiProtocol().firmwareData(moduleKey: targetModuleKey, segment: 1, data: bootingAddress)
                        self.sendData(bytes: bytes)
                        
                        reverseData = self.reverseBlock(source : bootingAddress)
                        
                        crcValue = self.calculateCrc32(data : reverseData, crc: crcValue)
                        
                        
                        bytes = ModiProtocol().firmwareCommand(moduleKey: targetModuleKey, flashCmd: ModiProtocol.FLASH_CMD.CHECK_CRC, address: address, crc: crcValue)
                        self.sendData(bytes: bytes)
                        
                        checkTime = Date().timeIntervalSince1970 * 1000
        
                    }
                   
                    
                }
            }
            
            else if self.getFirmwareFilter(moduleKey: targetModuleKey).filter(frame:event) == true  && self.frameFilter == FRAME_FILTER.FLASH_CMD_CHECK_CRC{
                
               
                if (self.mRecieveQueue.isEmpty) {
                    return
                }
                let frame = self.mRecieveQueue.last
                self.mRecieveQueue.removeLast()
                
                let responseCode = Int(frame!.data()[4])
                
                print("steave setPlugAndPlayModule FLASH_CMD_CHECK_CRC \(responseCode)")
                

                if responseCode != 0x05 {
                    self.updateFail(error: CodeUpdateError.FLASH_ERASE_ERROR)
                    return
                }
                
                self.progressNotifierAddCount(count: self.MODULE_PROGRESS_COUNT_UNIT)
                
                if (self.mModuleUpdateCount < self.mUpdateTargets!.count - 1) {
                    
                    self.mModuleUpdateCount += 1
//                    print("steave setPlugAndPlayModule Fself.mModuleUpdateCount < self.mUpdateTargets!.count - 1")
                    self.updateModule()
                    return
                }
             
                self.requestStream()
                
            }},onError: { _ in
                
                if(self.frameFilter.rawValue >= FRAME_FILTER.UPLOAD_STREAM.rawValue) {
                    return
                }
                
                self.updateFail(error: CodeUpdateError.FLASH_ERASE_ERROR)
            
            
            }).disposed(by: self.disposeBag!)
        
        
      
        
    }
    
    func calculateCrc32(data : [UInt8])-> Int {
        let crcCalc = CrcCalculator(params: Crc32().Crc32Mpeg2)

        return crcCalc.calc(data: data, offset: 0, length: data.count)
    }
    
    func calculateCrc32(data : [UInt8], crc : Int )-> Int {
        let crcCalc = CrcCalculator(params: Crc32().Crc32Mpeg2)

        return crcCalc.calc(data: data, offset: 0, length: data.count, crc : crc)
    }
    
    
    func reverseBlock(source : [UInt8]) -> [UInt8] {
        
        var buffer = [UInt8](repeating: 0, count: 8)
        
        var old = 0
        var j = 3
        var i = 0
        
        while i < 8 {
            
            buffer[i] = source[j]
        
            if j == old {
                
                j = i + 5
                old = i + 1
            }
            
            i += 1
            j -= 1
           
        }
        
        return buffer
        
    }
    
    func updateFail(error : CodeUpdateError) {
        
        notifyUpdateFail(error : error ,reson: error.rawValue)
        
    }
    
    func requestChangeUpdateMode(module : ModiModule) throws {
        
        let targetModuleKey = module.uuid & 0xFFF
        
        mRecieveQueue.removeAll()
        
        self.frameFilter = FRAME_FILTER.MODULE_STATE_UPDATE
        var bytes = ModiProtocol().setModuleState(moduleKey: targetModuleKey, state: ModiProtocol.MODULE_STATE.UPDATE)
        sendData(bytes: bytes)
       
        var checkTime = Date().timeIntervalSince1970 * 1000
        
        mRecieveQueueSubject
            .subscribeOn(MainScheduler.instance)
            .subscribe (onNext : { event in
               
                if(self.frameFilter.rawValue < FRAME_FILTER.MODULE_STATE_UPDATE.rawValue ||
                    self.frameFilter.rawValue > FRAME_FILTER.MODULE_STATE_UPDATE_READY.rawValue) {
                    return
                }
                
                print("steave requestChangeUpdateMode subscribe \(event.cmd())")
                
                self.timerCheck(checkTime: checkTime, timeout: 1000 * 10 * self.mUpdateTargets!.count)
            
                
            if self.getModuleStateFilter(moduleKey: targetModuleKey).filter(frame: event) == true &&
                self.frameFilter == FRAME_FILTER.MODULE_STATE_UPDATE {
                
                let frame = self.mRecieveQueue.last
                self.mRecieveQueue.removeLast()
                
                let responseCode = Int(frame!.data()[6])
                
                print("steave requestChangeUpdateMode UPDATE \(responseCode)")
                
                if responseCode != ModiProtocol.MODULE_WARNING.FIRMWARE.rawValue {
               
                    self.updateFail(error: CodeUpdateError.CODE_NOT_UPDATE_MODE)
                    return
                }
                
                self.frameFilter = FRAME_FILTER.MODULE_STATE_UPDATE_READY

                bytes = ModiProtocol().setModuleState(moduleKey: targetModuleKey, state: ModiProtocol.MODULE_STATE.UPDATE_READY)
                self.sendData(bytes: bytes)
                
                checkTime = Date().timeIntervalSince1970 * 1000
            }
            
            else if self.getChageUpdateFilter(moduleKey: targetModuleKey).filter(frame: event) == true &&
                        self.frameFilter == FRAME_FILTER.MODULE_STATE_UPDATE_READY {
                        
                        let frame = self.mRecieveQueue.last
                        self.mRecieveQueue.removeLast()
                        
                        let responseCode = Int(frame!.data()[6])
                        
                        print("steave requestChangeUpdateMode MODULE_STATE_UPDATE_READY \(responseCode)")
                        
                        if responseCode != ModiProtocol.MODULE_WARNING.FIRMWARE_READY.rawValue {
                       
                            self.updateFail(error: CodeUpdateError.CODE_NOT_UPDATE_MODE)
                            return
                        }
                
                        self.setPlugAndPlayModule(module: module, pnpEnable: self.mPnpEnable, userEnable: self.mUserEnable)
                    }
            
            },
            onError: { _ in
                    
                    print("steave requestChangeUpdateMode onError \(self.frameFilter.rawValue)")
                    
                self.updateFail(error: CodeUpdateError.CODE_NOT_UPDATE_READY)
                    
                    
            
        }).disposed(by: self.disposeBag!)
        
        
       
       
        
    }
    
    func requestResetStream() {
        
        let resetStream = ModiStream()
        resetStream.streamType = modiStream!.streamType
        resetStream.moduleId = modiStream!.moduleId
        resetStream.streamId = modiStream!.streamId
        resetStream.streamBody = Array<UInt8>()
    
        mRecieveQueue.removeAll()
        let bytes = ModiProtocol().streamCommand(stream: resetStream)
        sendData(bytes: bytes)
        
        let checkTime = Date().timeIntervalSince1970 * 1000
    
        
        mRecieveQueueSubject
//            .subscribeOn(background)
        
            .subscribeOn(MainScheduler.instance)
            .subscribe(
                onNext:{
                    event in
                    
                    if(self.frameFilter.rawValue > FRAME_FILTER.RESET_STREAM.rawValue) {
                        return
                    }
                    
                    print("steave requestResetStream subscribe \(event.cmd())")
                    
                    self.timerCheck(checkTime: checkTime, timeout: 1000 * 5)
                
                    if self.getStreamFilter(moduleKey : resetStream.moduleId, streamId : Int(resetStream.streamId)).filter(frame: event) == true {
                        
                        let frame = self.mRecieveQueue.last
                        self.mRecieveQueue.removeLast()
                        
                        let responseCode = Int(frame!.data()[1])
                        
                        print("steave requestResetStream RESET_STREAM \(responseCode)")
                        
                        if responseCode != ModiStream.STREAM_RESPONSE.SUCCESS.rawValue {
                       
                            self.updateFail(error: CodeUpdateError.MODULE_TIMEOUT)
                        }

                        else {
                            self.modiManager.getModuleManager().enableUpdateMode()
                            self.updateModule()
                            
                        }
                    }
            },
                onError: {_ in
                    
                    print("steave requestResetStream onError \(self.frameFilter.rawValue)")
                    
                    if(self.frameFilter.rawValue > FRAME_FILTER.RESET_STREAM.rawValue) {
                        return
                    }
                    
                    self.updateFail(error: CodeUpdateError.STREAM_COMMAND_RESPONSE_FAILED)
                }
        
        ).disposed(by: disposeBag!)
       
       
        
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
        
        ModiLog.d("onModiFrame", messages: "frame : \(frame.cmd())")
    
        
        if frame.cmd() != 0x00 {
            
            mRecieveQueue.append(frame)
            mRecieveQueueSubject.onNext(frame)
        }
        
        while mRecieveQueue.count > 64 {
            mRecieveQueue.removeLast()
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
        mModuleUpdateCount = 0
        disposeBag = nil
        self.frameFilter = FRAME_FILTER.RESET_STREAM
        
        self.mToTal = 0
        self.mCount = 0
        self.modiManager.getModuleManager().disableUpdateMode()
        self.modiManager.getModuleManager().discoverModules()
        
//        disposeBag = DisposeBag()
        
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
        sleep(1)
    }
    
    func notifyUpdateFail(error: CodeUpdateError, reson : String) {
        
        progressNotifierComplete()
        let bytes = ModiProtocol().setModuleState(moduleKey : 0xFFF, state : ModiProtocol.MODULE_STATE.RESET)
        self.sendData(bytes: bytes)
        
        if modiManager.isConnected() != true {
            
            modiCodeUpdaterCallback?.onUpdateFailed(error: CodeUpdateError.CONNECTION_ERROR, reason: "check ble connection.")
            return
        }
        
        modiCodeUpdaterCallback?.onUpdateFailed(error: CodeUpdateError.MODULE_TIMEOUT, reason: reson)
        
    }
    
    
    func timerCheck(checkTime : TimeInterval ,timeout : Int) {
        
        let currentTime = Date().timeIntervalSince1970 * 1000
        
      
        let duration = Int(currentTime - checkTime)
        
        if (duration > timeout) {
            
            print("timerCheck MODULE_TIMEOUT duration \(duration)")
            updateFail(error: CodeUpdateError.MODULE_TIMEOUT)
            
        }
    }

    
}
