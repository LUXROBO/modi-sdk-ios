import Foundation
import RxSwift
import RxCocoa

class ModiCodeUpdater : ModiFrameObserver{
    
    
    
    private let _MODULE_PROGRESS_COUNT_UNIT = 5;
    private let _PROGRESS_NOTIFY_PERIOD = 150;
    private let RetryMaxCount = 5
    
    private var modiManager : ModiManager? = nil
    private var mRecieveQueue : Array<ModiFrame>? = nil
    private var modiStream : ModiStream? = nil
    private var modiCodeUpdaterCallback : ModiCodeUpdaterCallback? = nil
    private var mUpdateTargets : Array<ModiModuleManager>? = nil
    
    private var startUpdateDisposable : Disposable!
    private var startResetDisposable : Disposable!
    
    init(modiManager : ModiManager?) {
        
        self.modiManager = modiManager
        
    }
    
    func startReset(stream : ModiStream, callback : ModiCodeUpdaterCallback) {
        self.modiStream = stream
        self.modiCodeUpdaterCallback = callback
        
        
    }
    
    func startUpdate() {
        
    }
    
    func runUpdateTask() {
        
    }
    
    func onModiFrame(frame: ModiFrame) {
        
    }


    
}
