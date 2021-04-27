//
//  RestApiRemoteDataSourceImpl.swift
//  modiNetworkSDK
//
//  Created by steave_mac on 2021/04/26.
//

import Foundation
import RxCocoa
import RxSwift
import Moya

class RestApiRemoteDataSourceImpl: RestApiRemoteDataSource {
   

    private let httpApi: HttpNetworkManager

    init(httpApi: HttpNetworkManager) {
     
        self.httpApi = httpApi
    }

    func updateFirmware(
        file: Data,
        success: @escaping (HttpModel) -> Void,
        failed: @escaping (Error) -> Void) -> Disposable {
        
        print("Rest Api Test RestApiRemoteDataSourceImpl updateFirmware")

        return httpApi.updateFirmware(
            file: file
        ).subscribe(
            onSuccess: {
                result in success(result)
            },
            onError: {
                result in failed(result)
            }
        )
        
    }
}
