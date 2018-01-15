//
//  TaskDelegate.swift
//  Retrolux
//
//  Created by Brendan Henderson on 12/11/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

/// a delegate for a single URLSessionTask's actions
public protocol SingleTaskDelegate: AnyObject {
    
    /// the weak reference to the task being delegated
    var task: Task! {get set}
    var metrics: URLSessionTaskMetrics? {get set}
    
    func didComplete(error: Error?)
    func didFinishCollecting(_ metrics: URLSessionTaskMetrics)
    func didSendBodyData(_ bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    func needNewBodyStream(_ completionHandler: @escaping (InputStream?) -> Void)
    func willBegin(_ delayedRequest: URLRequest, _ completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void)
    func willPerformHTTPRedirection(_ response: HTTPURLResponse, newRequest: URLRequest, _ completionHandler: @escaping (URLRequest?) -> Void)
    
    func taskDidBecome(_ newTask: Task)
    
    func betterRouteDiscovered()
    func readClosed()
    func stream(didBecome inputStream: InputStream, outputStream: OutputStream)
    func writeClosed()
    
    func didFinishDownloading(to location: URL)
    func didResume(atOffset fileOffset: Int64, expectedTotalBytes: Int64)
    func didWriteData(_ byteCount: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
 }

extension SingleTaskDelegate {
    
    public func didComplete(error: Error?) {}
    public func didFinishCollecting(_ metrics: URLSessionTaskMetrics) {}
    public func didSendBodyData(_ bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {}
    public func needNewBodyStream(_ completionHandler: @escaping (InputStream?) -> Void) { completionHandler(nil) }
    public func willBegin(_ delayedRequest: URLRequest, _ completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) { completionHandler(.continueLoading, nil) }
    public func willPerformHTTPRedirection(_ response: HTTPURLResponse, newRequest: URLRequest, _ completionHandler: @escaping (URLRequest?) -> Void) { completionHandler(nil) }
    
    public func taskDidBecome(_ newTask: Task) {}
    
    public func betterRouteDiscovered() {}
    public func readClosed() {}
    public func stream(didBecome inputStream: InputStream, outputStream: OutputStream) {}
    public func writeClosed() {}
    
    public func didFinishDownloading(to location: URL) {}
    public func didResume(atOffset fileOffset: Int64, expectedTotalBytes: Int64) {}
    public func didWriteData(_ byteCount: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {}
}
