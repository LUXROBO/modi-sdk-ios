//
//  HttpNetworkManager.swift
//  modiNetworkSDK
//
//  Created by steave_mac on 2021/04/26.
//

import Foundation
import Moya
import RxCocoa
import RxSwift

class HttpNetworkManager {
    var provider = MoyaProvider<HttpApiTarget>(plugins: [NetworkLoggerPlugin()])

    init() {
        print("Rest Api Test HttpbinNetworkManager init")
    }
    
    
    func updateFirmware(
        file: Data
    ) -> Single<HttpModel> {
        print("Rest Api Test HttpbinNetworkManager updateFirmware")

        return request(
            target: .update(file: file)
        )
    }
}

private extension HttpNetworkManager {
    private func request(
        target: HttpApiTarget
    ) -> Single<HttpModel> {
        print("Rest Api Test HttpbinNetworkManager extension")

        return provider.rx.request(target).map(HttpModel.self)
    }
}
