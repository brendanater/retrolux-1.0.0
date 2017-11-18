//
//  FactoryRequest.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/15/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation
//
//
//// MARK: FactoryRequest
//
//public typealias FactoryResponse<Return> = (urlRequest: URLRequest, responseHandler: (ClientResponse)throws->Return, taskType: TaskType)
//public typealias Factory<Args, Return> = ((urlRequest: URLRequest, args: Args))throws->FactoryResponse<Return>
//
//
//
//open class FactoryRequest<Args, Return>: Request {
//
//    open var factory: Factory<Args, Return>
//
//    public init(url: URL, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 60, factory: @escaping Factory<Args, Return>) {
//
//        self.factory = factory
//        super.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
//    }
//
//    /// returns nil. self.factory cannot be decoded and is neccessary for operation
//    public required init?(coder aDecoder: NSCoder) {
//        return nil
//    }
//
//    public enum FactoryRequestError: Error {
//        case triedToCreateTaskWithoutArgs
//    }
//
//    open override func createTask(_ taskType: TaskType, completionHandler: @escaping (ClientResponse) -> ()) throws -> Task {
//        if Args.self == Void.self {
//            return try super.createTask(taskType, completionHandler: completionHandler)
//        } else {
//            throw FactoryRequestError.triedToCreateTaskWithoutArgs
//        }
//    }
//
//    open override func execute(_ taskType: TaskType) throws -> ClientResponse {
//        if Args.self == Void.self {
//            return try super.execute(taskType)
//        } else {
//            throw FactoryRequestError.triedToCreateTaskWithoutArgs
//        }
//    }
//
//    open func enqueue(_ args: Args, _ callback: @escaping (Response<Return>)->Void) throws -> Task {
//
//        let (urlRequest, responseHandler, taskType) = try self.factory((self as URLRequest, args))
//
//        return try self.createTask(taskType, with: urlRequest, completionHandler: { callback(Response($0, responseHandler)) })
//    }
//
//    /// resumes the enqueue task then locks the current queue until finished
//    open func perform(_ args: Args) throws -> Response<Return> {
//
//        let (urlRequest, responseHandler, taskType) = try self.factory((self as URLRequest, args))
//
//        return try Response(self.execute(taskType, with: urlRequest), responseHandler)
//    }
//}
//
//extension FactoryRequest where Args == Void {
//
//    open func enqueue(_ callback: @escaping (Response<Return>)->Void) throws -> Task {
//
//        return try self.enqueue((), callback)
//    }
//
//    /// resumes the enqueue task then locks the current queue until finished
//    open func perform() throws -> Response<Return> {
//
//        return try self.perform(())
//    }
//}

