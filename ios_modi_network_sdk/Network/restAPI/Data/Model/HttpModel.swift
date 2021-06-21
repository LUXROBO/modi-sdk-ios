//
//  HttpModel.swift
//  modiNetworkSDK
//
//  Created by steave_mac on 2021/04/26.
//

import Foundation

// MARK: - HttpbinModel

struct HttpModel: Codable {
    let args: Args
    let data: String
    let files, form: Args
    let headers: Headers
    let httpbinModelJSON: JSONNull?
    let method, origin: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case args, data, files, form, headers
        case httpbinModelJSON = "json"
        case method, origin, url
    }
}

// MARK: - Args

struct Args: Codable {}

// MARK: - Headers

struct Headers: Codable {
    let accept, acceptEncoding, acceptLanguage, host: String
    let secChUa, secChUaMobile, secFetchDest, secFetchMode: String
    let secFetchSite, secFetchUser, upgradeInsecureRequests, userAgent: String
    let xAmznTraceID: String

    enum CodingKeys: String, CodingKey {
        case accept = "Accept"
        case acceptEncoding = "Accept-Encoding"
        case acceptLanguage = "Accept-Language"
        case host = "Host"
        case secChUa = "Sec-Ch-Ua"
        case secChUaMobile = "Sec-Ch-Ua-Mobile"
        case secFetchDest = "Sec-Fetch-Dest"
        case secFetchMode = "Sec-Fetch-Mode"
        case secFetchSite = "Sec-Fetch-Site"
        case secFetchUser = "Sec-Fetch-User"
        case upgradeInsecureRequests = "Upgrade-Insecure-Requests"
        case userAgent = "User-Agent"
        case xAmznTraceID = "X-Amzn-Trace-Id"
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    public static func == (_: JSONNull, _: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
