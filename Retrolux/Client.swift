//
//  Client.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/25/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol Client {
    
    func createTask(_ taskType: TaskType, with request: URLRequest, delegate: SingleTaskDelegate?, completionHandler: @escaping (Response<DataBody>) -> Void) -> Task
}

