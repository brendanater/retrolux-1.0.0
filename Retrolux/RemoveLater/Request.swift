//
//  Request.swift
//  Retrolux
//
//  Created by Christopher Bryan Henderson on 8/21/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation


//open class Request: NSMutableURLRequest {
//
//    open var responseValidators: [(ClientResponse)throws->Bool] = []
//    open var statusValidation: ((Int) -> Bool)?
//
//    /// use this method to check the request. Throw to deny the request
//    open var requestInterceptor: ((inout URLRequest)throws->())?
//    /// use this method to check the response.
//    open var responseInterceptor: ((inout ClientResponse)throws->())?
//
//    open var testResponse: ClientResponse?
//
//    open var client: Client = URLSession(configuration: .default)
//
//    public override init(url: URL, cachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy, timeoutInterval: TimeInterval = 60) {
//        super.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    public func validateStatus(in range: Range<Int>) {
//
//        self.statusValidation = { range.contains($0) }
//    }
//
//    public func validateStatus(in codes: [Int]) {
//
//        self.statusValidation = { codes.contains($0) }
//    }
//
//    public func validateStatus(is code: Int) {
//
//        self.statusValidation = { $0 == code }
//    }
//
////    // FIXME: remove when methods from extensions can be overridden
////    open func set(restful: RestfulHTTPMethod) {
////        self.httpMethod = restful.httpMethod
////        self.statusValidation = restful.statusConfirmation
////    }
//
//    open func createTask(_ taskType: TaskType, with urlRequest: URLRequest, completionHandler: @escaping (ClientResponse)->()) throws -> Task {
//        var urlRequest = urlRequest
//
//        try self.requestInterceptor?(&urlRequest)
//
//        let completionHandler = {
//            [capturedValidation = (self.responseInterceptor, self.statusValidation, self.responseValidators)] in
//            completionHandler(Request.validate($0, with: capturedValidation))
//        }
//
//        let task = try Request.testTask(forTestResponse: self.testResponse, completionHandler: completionHandler) ?? self.client.createTask(taskType, with: urlRequest, completionHandler: completionHandler)
//
//        if !task.isSuspended {
//            task.suspend()
//        }
//
//        return task
//    }
//
//    open func createTask(_ taskType: TaskType, completionHandler: @escaping (ClientResponse)->()) throws -> Task {
//        return try self.createTask(taskType, with: self as URLRequest, completionHandler: completionHandler)
//    }
//
//    /// creates and resumes a dataTask with self then locks the current queue until it is finished (useful if on a background thread for a quick request)
//    open func execute(_ taskType: TaskType, with urlRequest: URLRequest) throws -> ClientResponse {
//
//        return try DispatchSemaphore.retrieve() { semaphore in try self.createTask(taskType, with: urlRequest, completionHandler: { semaphore.response = $0 }).resume() }
//            ?? ClientResponse.empty(urlRequest)
//    }
//
//    /// execute task with self as URLRequest
//    open func execute(_ taskType: TaskType) throws -> ClientResponse {
//
//        return try self.execute(taskType, with: self as URLRequest)
//    }
//
//    /// calls responseInterceptor, responseValidators, and statusValidation with the response
//    open class func validate(_ response: ClientResponse, with capture: (responseInterceptor: ((inout ClientResponse)throws->())?, statusValidation:  ((Int) -> Bool)?, responseValidators: [(ClientResponse)throws->Bool])) -> ClientResponse {
//
//        var response = response
//
//        do {
//            try capture.responseInterceptor?(&response)
//
//            for validator in capture.responseValidators {
//
//                guard response.isValid else {
//                    return response
//                }
//
//                response.isValid = try validator(response)
//            }
//
//            if response.isValid,
//                let status = response.statusCode,
//                let statusValidation = capture.statusValidation {
//
//                response.isValid = statusValidation(status)
//            }
//
//        } catch {
//
//            response.error = response.error ?? error
//            response.isValid = false
//        }
//
//        return response
//    }
//}

