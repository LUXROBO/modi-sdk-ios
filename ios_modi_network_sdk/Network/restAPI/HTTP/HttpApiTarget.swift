//
//  HttpApiTarget.swift
//  modiNetworkSDK
//
//  Created by steave_mac on 2021/04/26.
//

import Foundation
import Moya

enum HttpApiTarget {
   
    case update(file:Data)
    
}

extension HttpApiTarget: TargetType {
    var baseURL: URL {
        guard let url = URL(string: "http://192.168.4.1:8080/") else { fatalError() }
        return url
    }

    var path: String {
        switch self {
      
        case .update:
            return "update"
        }
        
        
    
    }

    var method: Moya.Method {
        return .post
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        
        case let .update(file):
            let formData: [MultipartFormData] = [MultipartFormData(
                provider: .data(file as! Data),
                name: "update",
                fileName: "esp32.bin",
                mimeType: "application/octet-stream"
            )]
            
            return .uploadMultipart(formData)
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "multipart/form-data"]
    }
}
