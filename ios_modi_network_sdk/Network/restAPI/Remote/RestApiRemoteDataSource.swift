//
//  RestApiRemoteDataSource.swift
//  modiNetworkSDK
//
//  Created by steave_mac on 2021/04/26.
//

import Foundation
import RxSwift
import Moya

protocol RestApiRemoteDataSource {
   
    func updateFirmware(
        file: Data,
        success: @escaping (HttpModel) -> Void,
        failed: @escaping (Error) -> Void
    ) -> Disposable
}
