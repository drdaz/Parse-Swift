//
//  API.swift
//  ParseSwift
//
//  Created by Florent Vilmart on 17-08-19.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation

public struct API {

    internal enum Method: String, Encodable {
        case GET, POST, PUT, DELETE
    }

    internal enum Endpoint: Encodable {
        case batch
        case objects(className: String)
        case object(className: String, objectId: String)
        case login
        case signup
        case logout
        case any(String)

        var urlComponent: String {
            switch self {
            case .batch:
                return "/batch"
            case .objects(let className):
                return "/classes/\(className)"
            case .object(let className, let objectId):
                return "/classes/\(className)/\(objectId)"
            case .login:
                return "/login"
            case .signup:
                return "/users"
            case .logout:
                return "/users/logout"
            case .any(let path):
                return path
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(urlComponent)
        }
    }

    public typealias Options = Set<API.Option>

    public enum Option: Hashable {
        case useMasterKey
        case sessionToken(String)
        case installationId(String)

        public static func == (lhs: API.Option, rhs: API.Option) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }
    }

    internal static func getHeaders(options: API.Options) -> [String: String] {
        var headers: [String: String] = ["X-Parse-Application-Id": ParseConfiguration.applicationId,
                                         "Content-Type": "application/json"]
        if let clientKey = ParseConfiguration.clientKey {
            headers["X-Parse-Client-Key"] = clientKey
        }

        if let token = CurrentUserInfo.currentSessionToken {
            headers["X-Parse-Session-Token"] = token
        }

        options.forEach { (option) in
            switch option {
            case .useMasterKey:
                headers["X-Parse-Master-Key"] = ParseConfiguration.masterKey
            case .sessionToken(let sessionToken):
                 headers["X-Parse-Session-Token"] = sessionToken
            case .installationId(let installationId):
                headers["X-Parse-Installation-Id"] = installationId
            }
        }

        return headers
    }
}

internal extension Dictionary where Key == String, Value == String? {
    func getQueryItems() -> [URLQueryItem] {
        return map { (key, value) -> URLQueryItem in
            return URLQueryItem(name: key, value: value)
        }
    }
}
