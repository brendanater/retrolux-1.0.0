//
//  Task.swift
//  Retrolux
//
//  Created by Brendan Henderson on 10/25/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public protocol Task: AnyObject {
    
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

//open class CancellableTask<T>: Task {
//
//    private var result: T?
//
//    public let completionHandler: (T) -> Void
//    public let beginTask: (@escaping (T)->Void) -> Void
//
//    public private(set) var didStartTask: Bool = false
//
//    public private(set) var state: URLSessionTask.State = .suspended
//
//    public init(_ completionHandler: @escaping (T) -> Void, beginTask: @escaping (@escaping (T)->Void)->Void) {
//
//        self.completionHandler = completionHandler
//        self.beginTask = beginTask
//    }
//
//    /// sets self.state to .canceling.  The task will continue, but will not call the completionHandler.
//    public func cancel() {
//        self.state = .canceling
//    }
//
//    public func resume() {
//
//        if self.state == .suspended {
//
//            if let result = self.result {
//                self.result = nil
//                self.state = .completed
//                self.completionHandler(result)
//                return
//            }
//
//            self.state = .running
//
//            guard self.didStartTask else {
//                self.didStartTask = true
//
//                self.beginTask({ [weak self] in
//
//                    switch self?.state ?? .completed {
//
//                    case .running:
//                        self?.state = .completed
//                        self?.completionHandler($0)
//
//                    case .suspended:
//                        self?.result = $0
//
//                    case .canceling:
//                        return
//
//                    case .completed:
//                        return
//                    }
//                })
//
//                return
//            }
//        }
//    }
//
//    public func suspend() {
//
//        if self.state == .running {
//            self.state = .suspended
//        }
//    }
//}




















