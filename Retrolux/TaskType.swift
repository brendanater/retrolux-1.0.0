//
//  TaskType.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/16/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public enum TaskType {
    case dataTask
    case downloadTask
    case resumeTask(Data)
    case uploadTask(AnyData)
}
