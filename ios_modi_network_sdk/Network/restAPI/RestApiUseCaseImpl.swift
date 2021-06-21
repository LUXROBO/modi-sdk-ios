//
//  RestApiUseCaseImpl.swift
//  modiNetworkSDK
//
//  Created by steave_mac on 2021/04/26.
//

import Foundation
import RxCocoa
import RxSwift
import Moya


protocol RestApiUseCase {
  
    func updateFirmware(
        file : Data,
        success: @escaping (HttpModel) -> Void,
        failed: @escaping (Error) -> Void) -> Disposable?
}

final class RestApiUseCaseImpl: RestApiUseCase {
    private let restApiRepository: RestApiRepository

    init(restApiRepository: RestApiRepository) {
        print("Rest Api Test RestApiUseCaseImpl init")
        self.restApiRepository = restApiRepository
    }

    
    func updateFirmware(
        file : Data,
        success: @escaping (HttpModel) -> Void,
        failed: @escaping (Error) -> Void
    ) -> Disposable? {
        print("Rest Api Test RestApiUseCaseImpl updateFirmware")
        return restApiRepository.updateFirmware(file: file, success: success, failed: failed)
    }
}
