//
//  Builder.swift
//  Retrolux
//
//  Created by Christopher Bryan Henderson on 8/21/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation
















open class Builder {
    
    open var base: URL
    
    open var client: Client = URLSession(configuration: .default)
    
    open lazy var encoders: [FactoryEncoder] = []
    open lazy var decoders: [FactoryDecoder] = []
    
    open var requestInterceptor: ((_ request: inout URLRequest) throws -> ())?
    open var responseInterceptor: ((_ response: inout Response<AnyData>) throws -> ())?
    
    /// queue for thread safety adding and removing values
    open let safetyQueue: DispatchQueue = DispatchQueue(label: "Retrolux.Builder.safetyQueue")
    
    public init(base: URL) {
        self.base = base
    }
    
    /// access the values of Builder on it's safety queue
    open func sync<T>(execute: (Builder)throws->T) rethrows -> T {
        return try self.safetyQueue.sync(execute: { try execute(self) })
    }
    
    /// sync with the Builder's safety queue
    open func sync(execute: ()throws->()) rethrows {
        try self.safetyQueue.sync(execute: execute)
    }
    
    // content type would have to be exact
    
    public enum BuilderError: Error {
        case failedToEncodeWithEncoders(Any, errors: [Error], encoders: [FactoryEncoder])
        case failedToDecodeWithDecoders(Any.Type, errors: [Error], decoders: [FactoryDecoder])
    }

    /// loops over the encoders and returns the first success or throws
    open class func encode<T>(_ value: T, using encoders: [FactoryEncoder]) throws -> Body {

        var errors: [Error] = []

        for encoder in encoders {
            do {
                return try encoder.encode(value)
            } catch {
                errors.append(error)
            }
        }

        throw BuilderError.failedToEncodeWithEncoders(value, errors: errors, encoders: encoders)
    }

    /// returns a closure that loops over the decoders and returns the first success or throws
    open class func decodeHandler<T>(for: T.Type = T.self, using decoders: [FactoryDecoder]) -> (Response<AnyData>) throws -> T {

        return {
            var errors: [Error] = []

            for decoder in decoders {
                do {
                    return try decoder.decode($0)
                } catch {
                    errors.append(error)
                }
            }

            throw BuilderError.failedToDecodeWithDecoders(T.self, errors: errors, decoders: decoders)
        }
    }
    
    public func create<T>(_ withClosure: (Builder) throws -> T) rethrows -> T {
        return try withClosure(self)
    }
    
    open func makeRequest<Args, Return>(
        _ method: URLRequest.HTTPMethod,
        _ path: String,
        args: Args.Type,
        response: @escaping (Response<AnyData>)throws->Return,
        applyArgs: @escaping (inout URLRequest, Args)throws->TaskType
        ) -> Call<Args, Return> {
        
        var request = URLRequest(url: self.base.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        
        return Call(request, factory: {[client = self.client, requestInterceptor = self.requestInterceptor, responseInterceptor = self.responseInterceptor] (request, args, callback) in
            
            var request = request
            
            try requestInterceptor?(&request)
            
            let taskType = try applyArgs(&request, args)
            
            return try client.createTask(taskType, with: request, completionHandler: {
                
                var dataResponse = $0
                
                do {
                    try responseInterceptor?(&dataResponse)
                    
                    callback(dataResponse.convert { try response($0) })
                    
                } catch {
                    callback(dataResponse.convert { _ in throw error })
                }
            })
        })
    }
}

//public typealias User = Void
//
//public protocol GetUserInterface {
//
//    func getUser(_ name: String, _ callback: @escaping (User)->())
//}
//
//let interface: GetUserInterface = Builder(base: URL(string: "randomsite.org/")!).create() { builder in
//
//    struct RandomSiteGetUserInterface: GetUserInterface {
//
//        let builder: Builder
//
//        func getUser(_ name: String, _ callback: @escaping (User) -> ()) {
//            let request = builder.makeRequest(.get, "users/", args: String.self, response: <#T##(Response<AnyData>) throws -> Return#>, applyArgs: <#T##(inout URLRequest, Args) throws -> TaskType#>)
//        }
//    }
//
//    return RandomSiteGetUserInterface(builder: builder)
//}
//
//func t() {
//
//    interface.getUser("Bob", { user in
//        print(user) // == ()
//    })
//}
//
//class BuilderInterface: Builder {
//
//
//
//}
//
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






