//
//  RESTBatchCommand.swift
//  Parse (iOS)
//
//  Created by Florent Vilmart on 17-08-19.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation

typealias ParseObjectBatchCommand<T> = BatchCommand<T, T> where T: ObjectType
typealias ParseObjectBatchResponse<T> = [(T, ParseError?)]
typealias RESTBatchCommandType<T> = RESTCommand<ParseObjectBatchCommand<T>, ParseObjectBatchResponse<T>> where T: ObjectType

public struct BatchCommand<T, U>: Encodable where T: Encodable {
    let requests: [RESTCommand<T, U>]
}

public struct BatchResponseItem<T>: Decodable where T: Decodable {
    let success: T?
    let error: ParseError?
}

public class RESTBatchCommand<T>: RESTBatchCommandType<T> where T: ObjectType {
    typealias ParseObjectCommand = RESTCommand<T, T>
    typealias ParseObjectBatchCommand = BatchCommand<T, T>

    init(commands: [ParseObjectCommand]) {
        let commands = commands.flatMap { (command) -> RESTCommand<T, T>? in
            let path = _mountPath + command.path
            guard let body = command.body else {
                return nil
            }
            return RESTCommand<T, T>(method: command.method, path: path, body: body, mapper: command.mapper)
        }
        let bodies = commands.flatMap { (command) -> T? in
            return command.body
        }
        let mapper = { (data: Data) -> [(T, ParseError?)] in
            let responses = try getDecoder().decode([BatchResponseItem<SaveOrUpdateResponse>].self, from: data)
            return bodies.enumerated().map({ (object) -> (T, ParseError?) in
                let response = responses[object.0]
                if let success = response.success {
                    return (success.apply(object.1), nil)
                } else {
                    return (object.1, response.error)
                }
            })
        }
        super.init(method: .POST, path: "/batch", body: BatchCommand(requests: commands), mapper: mapper)
    }
}