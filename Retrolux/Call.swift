//
//  Call.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol CallAdaptable {
    associatedtype Return
    init(_ call: Call<Return>)
}

public struct Call<Return>: CallAdaptable {
    
    // can access urlRequest from call
    public let urlRequest: URLRequest
    public var callbackQueue: DispatchQueue?
    /// if true, task.resume() is called before being returned from enqueue
    public var autoResume: Bool
    // pass back urlRequest to allow inline calls and avoid storing the request twice
    private let enqueue: ((urlRequest: URLRequest, delegate: SingleTaskDelegate?, callback: (Response<Return>)->()))->Task
    
    public init(_ urlRequest: URLRequest, callbackQueue: DispatchQueue? = nil, autoResume: Bool = true, _ enqueue: @escaping ((urlRequest: URLRequest, delegate: SingleTaskDelegate?, callback: (Response<Return>)->()))->Task) {
        
        self.urlRequest = urlRequest
        self.callbackQueue = callbackQueue
        self.autoResume = autoResume
        self.enqueue = enqueue
    }
    
    /// self = call to conform to CallAdaptable
    public init(_ call: Call<Return>) {
        self = call
    }
    
    @discardableResult
    public func enqueue(_ callback: @escaping (Response<Return>) -> ()) -> Task {
        return self.enqueue(delegate: nil, callback)
    }
    
    @discardableResult
    public func enqueue(delegate: SingleTaskDelegate?, _ callback: @escaping (Response<Return>) -> ()) -> Task {
        
        let task = self.enqueue((self.urlRequest, delegate, callback))
        
        if self.autoResume && task.isSuspended {
            task.resume()
        } else if !task.isSuspended {
            task.suspend()
        }
        
        return task
    }
    
    public func perform() -> Response<Return>? {
        return DispatchSemaphore.retrieve() { s in self.enqueue { s.response = $0 }.resume() }
    }
}

//public struct Call2<Return> {
//
//    public struct CallTask {
//        public func cancel() {}
//    }
//
//    public init(_ request: URLRequest, _ action: @escaping ((request: URLRequest, callback: (Return)->()))->CallTask) {
//        self.request = request
//        self.action = action
//    }
//
//    var request: URLRequest
//    var action: ((request: URLRequest, callback: (Return)->()))->CallTask
//
//    public func enqueue(_ callback: @escaping (Return)->()) -> CallTask {
//
//        return self.action((request: self.request, callback: callback))
//    }
//
//    public func perform() -> Return? {
//
//        return DispatchSemaphore.retrieve() { s in
//            _ = self.enqueue { s.response = $0 }
//        }
//    }
//}


//public struct Call<Args, Return> {
//
//    public typealias Factory<Args, Return> = ((urlRequest: URLRequest, args: Args, callback: (Response<Return>) -> Void))throws->Task
//
//    public var storedRequest: URLRequest
//    public let factory: Factory<Args, Return>
//
//    public var statusValidation: ((Int) -> Bool)?
//
//    public var subResponseInterceptor: ((inout Response<Return>) throws -> ())?
//
//    public var testResponse: Response<Return>?
//
//    public init(_ storedRequest: URLRequest, factory: @escaping Factory<Args, Return>) {
//        self.storedRequest = storedRequest
//        self.factory = factory
//    }
//
//    public mutating func validateStatus(in range: Range<Int>) -> Call {
//
//        self.statusValidation = { range.contains($0) }
//        return self
//    }
//
//    public mutating func validateStatus(in codes: [Int]) -> Call {
//
//        self.statusValidation = { codes.contains($0) }
//        return self
//    }
//
//    public mutating func validateStatus(is code: Int) -> Call {
//
//        self.statusValidation = { $0 == code }
//        return self
//    }
//
//    public mutating func validateStatusOK() -> Call {
//
//        return self.validateStatus(in: 200..<300)
//    }
//
//    public func enqueue(_ args: Args, _ callback: @escaping (Response<Return>)->Void) throws -> Task {
//
//        let completionHandler: (Response<Return>)->Void = {
//
//            // validate
//            var response = $0
//
//            do {
//                try self.subResponseInterceptor?(&response)
//            } catch {
//                callback(response.convert { _ in throw error })
//            }
//
//            if response.isValid,
//                let status = response.statusCode,
//                let statusValidation = self.statusValidation {
//
//                response.isValid = statusValidation(status)
//            }
//
//            // return
//            callback(response)
//        }
//
//        let task = try TestTask(self.testResponse, completionHandler)
//            ?? self.factory((self.storedRequest, args, completionHandler))
//
//        if !task.isSuspended {
//            task.suspend()
//        }
//
//        return task
//    }
//
//    /// resumes the enqueue task then locks the current queue until finished
//    public func perform(_ args: Args) throws -> Response<Return>? {
//
//        return try DispatchSemaphore.retrieve() { semaphore in try self.enqueue(args, { semaphore.response = $0 }).resume() }
//    }
//}
//
//extension Call where Args == Void {
//
//    public func enqueue(_ callback: @escaping (Response<Return>)->Void) throws -> Task {
//
//        return try self.enqueue((), callback)
//    }
//
//    /// resumes the enqueue task then locks the current queue until finished
//    public func perform() throws -> Response<Return>? {
//
//        return try self.perform(())
//    }
//}
//
//public class TestTask<Return>: Task {
//
//    public var completionHandler: (Response<Return>) -> Void
//    public var testResponse: Response<Return>
//    public private(set) var state: URLSessionTask.State = .suspended
//
//    public init?(_ testResponse: Response<Return>?, _ completionHandler: @escaping (Response<Return>) -> Void) {
//
//        guard let testResponse = testResponse else {
//            return nil
//        }
//
//        self.completionHandler = completionHandler
//        self.testResponse = testResponse
//    }
//
//    public func cancel() {
//        self.state = .suspended
//    }
//
//    public func resume() {
//        self.state = .completed
//        self.completionHandler(self.testResponse)
//    }
//
//    public func suspend() {
//        self.state = .suspended
//    }
//}

