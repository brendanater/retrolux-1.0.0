//
//  Client.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/25/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation



public protocol Client {
    
    func createTask(_ taskType: TaskType, with request: URLRequest, completionHandler: @escaping (ClientResponse) -> Void) throws -> Task
}

public enum ClientTaskCreationError: Error {
    case clientCannotCreateTaskWithRequest(Client, TaskType, with: URLRequest)
}

extension Client {
    
    public func cannotCreate(_ taskType: TaskType, with request: URLRequest) -> ClientTaskCreationError {
        return ClientTaskCreationError.clientCannotCreateTaskWithRequest(self, taskType, with: request)
    }
}

extension URLSession: Client {
    
    public func createTask(_ taskType: TaskType, with request: URLRequest, completionHandler: @escaping (ClientResponse) -> Void) throws -> Task {
        
        switch taskType {
        case .dataTask                      : return self.dataTask      (with: request,                 completionHandler: { completionHandler(ClientResponse(request, $0, $1, $2)) })
        case .downloadTask                  : return self.downloadTask  (with: request,                 completionHandler: { completionHandler(ClientResponse(request, $0, $1, $2)) })
        case .uploadTask(let data):
            switch data {
            case .atURL(let url): return self.uploadTask(with: request, fromFile: url, completionHandler: { completionHandler(ClientResponse(request, $0, $1, $2)) })
            case .data(let data): return self.uploadTask(with: request, from: data   , completionHandler: { completionHandler(ClientResponse(request, $0, $1, $2)) })
            }
            
        // default: throw self.cannotCreate(taskType, with: request)
        }
    }
}

//open class URLSessionClient: Client {
//    open func start(dataTask request: URLRequest, _ callback: @escaping (AnyResponse) -> Void) -> Call {
//        let session = URLSession(configuration: .default)
//
//        let task = session.dataTask(with: request) { (data: Data?, urlResponse: URLResponse?, error: Error?) in
//            let httpResponse = urlResponse as? HTTPURLResponse
//            let headers = httpResponse?.allHeaderFields as? [String: String]
//            let responseData = ResponseData(body: data, status: httpResponse?.statusCode, headers: headers, error: error)
//            callback(responseData)
//        }
//
//        session.
//
//        return task
//    }
//}

