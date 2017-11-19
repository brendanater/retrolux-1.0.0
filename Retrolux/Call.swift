//
//  Call.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation


public struct Call<Args, Return> {
    
    public typealias Factory<Args, Return> = ((urlRequest: URLRequest, args: Args, callback: (Response<Return>) -> Void))throws->Task
    
    public var storedRequest: URLRequest
    public let factory: Factory<Args, Return>
    
    public var statusValidation: ((Int) -> Bool)?
    
    public var subResponseInterceptor: ((inout Response<Return>) throws -> ())?
    
    public var testResponse: Response<Return>?
    
    public init(_ storedRequest: URLRequest, factory: @escaping Factory<Args, Return>) {
        self.storedRequest = storedRequest
        self.factory = factory
    }
    
    public mutating func validateStatus(in range: Range<Int>) -> Call {
        
        self.statusValidation = { range.contains($0) }
        return self
    }
    
    public mutating func validateStatus(in codes: [Int]) -> Call {
        
        self.statusValidation = { codes.contains($0) }
        return self
    }
    
    public mutating func validateStatus(is code: Int) -> Call {
        
        self.statusValidation = { $0 == code }
        return self
    }
    
    public mutating func validateStatusOK() -> Call {
        
        return self.validateStatus(in: 200..<300)
    }
    
    public func enqueue(_ args: Args, _ callback: @escaping (Response<Return>)->Void) throws -> Task {
        
        let completionHandler: (Response<Return>)->Void = {
            
            // validate
            var response = $0
            
            do {
                try self.subResponseInterceptor?(&response)
            } catch {
                callback(response.convert { _ in throw error })
            }
            
            if response.isValid,
                let status = response.statusCode,
                let statusValidation = self.statusValidation {
                
                response.isValid = statusValidation(status)
            }
            
            // return
            callback(response)
        }
        
        let task = try TestTask(self.testResponse, completionHandler)
            ?? self.factory((self.storedRequest, args, completionHandler))
        
        if !task.isSuspended {
            task.suspend()
        }
        
        return task
    }
    
    /// resumes the enqueue task then locks the current queue until finished
    public func perform(_ args: Args) throws -> Response<Return>? {
        
        return try DispatchSemaphore.retrieve() { semaphore in try self.enqueue(args, { semaphore.response = $0 }).resume() }
    }
}

extension Call where Args == Void {
    
    public func enqueue(_ callback: @escaping (Response<Return>)->Void) throws -> Task {
        
        return try self.enqueue((), callback)
    }
    
    /// resumes the enqueue task then locks the current queue until finished
    public func perform() throws -> Response<Return>? {
        
        return try self.perform(())
    }
}

public class TestTask<Return>: Task {
    
    public var completionHandler: (Response<Return>) -> Void
    public var testResponse: Response<Return>
    public private(set) var state: URLSessionTask.State = .suspended
    
    public init?(_ testResponse: Response<Return>?, _ completionHandler: @escaping (Response<Return>) -> Void) {
        
        guard let testResponse = testResponse else {
            return nil
        }
        
        self.completionHandler = completionHandler
        self.testResponse = testResponse
    }
    
    public func cancel() {
        self.state = .suspended
    }
    
    public func resume() {
        self.state = .completed
        self.completionHandler(self.testResponse)
    }
    
    public func suspend() {
        self.state = .suspended
    }
}
