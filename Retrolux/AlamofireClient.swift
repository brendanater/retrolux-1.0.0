//
//  AlamofireClient.swift
//  Retrolux
//
//  Created by Brendan Henderson on 12/23/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

//import Alamofire
//
//extension Request: Task {
//    public var state: URLSessionTask.State {
//        return self.task?.state ?? .suspended
//    }
//}
//
//public class AlamofireClient: Client {
//    public func createTask(_ taskType: TaskType, with request: URLRequest, delegate: SingleTaskDelegate?, completionHandler: @escaping (Response<AnyData>) -> Void) -> Task {
//        
//        let task: Request
//        
//        switch taskType {
//            
//        case .dataTask:
//            task = Alamofire.request(request).response(completionHandler: { completionHandler(Response.init($0.metrics, request, $0.data.map { .data($0) }, $0.response, $0.error)) })
//        
//        case .downloadTask:
//            task = Alamofire.download(request).response(completionHandler: { completionHandler(Response.init($0.metrics, request, $0.re, <#T##urlResponse: URLResponse?##URLResponse?#>, <#T##error: Error?##Error?#>)) })
//        }
//        
//    }
//}

