//
//  Task.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/25/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

/// an object that encompasses a data task
public protocol Task: class { // class because we're monitoring the task and cannot be referenced by copy.
    
    func cancel()
    func resume()
    func suspend()
    
    var state: URLSessionTask.State {get}
}

extension Task {
    
    public var isSuspended: Bool {
        return self.state == .suspended
    }
    
    public var isCancelled: Bool {
        return self.state == .canceling
    }
    
    public var isRunning: Bool {
        return self.state == .running
    }
    
    public var isCompleted: Bool {
        return self.state == .completed
    }
}

public protocol SchedulableTask: Task {
    
    /// The earliest date at which the network load should begin.
    var earliestBeginDate: Date? {get set}
    /// A best-guess upper bound on the number of bytes the client expects to send.
    var countOfBytesClientExpectsToSend: Int64 {get set}
    /// A best-guess upper bound on the number of bytes the client expects to receive.
    var countOfBytesClientExpectsToReceive: Int64 {get set}
}

extension URLSessionTask: SchedulableTask {}





















