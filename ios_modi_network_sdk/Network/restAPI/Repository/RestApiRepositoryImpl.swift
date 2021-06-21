//
//  RestApiRepositoryImpl.swift
//  modiNetworkSDK
//
//  Created by steave_mac on 2021/04/26.
//

import Foundation
import RxSwift
import Moya

class RestApiRepositoryImpl: RestApiRepository {
   
    
    private let restApiDataSource: RestApiRemoteDataSource

    init(dataSource: RestApiRemoteDataSource) {
        print("Rest Api Test RestApiRepositoryImpl init")
        restApiDataSource = dataSource
    }

    func updateFirmware(
        file: Data,
        success: @escaping (HttpModel) -> Void,
        failed: @escaping (Error) -> Void) -> Disposable {
        
        print("Rest Api Test RestApiRepositoryImpl updateFirmware")

        return restApiDataSource.updateFirmware(file: file, success: success, failed: failed)
    }
}
