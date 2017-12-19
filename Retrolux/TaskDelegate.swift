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
    
    func didComplete(error: Error?)
    func didFinishCollecting(_ metrics: URLSessionTaskMetrics)
    func didSendBodyData(_ bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    func needNewBodyStream() -> InputStream?
    func willBegin(_ delayedRequest: URLRequest) -> (disposition: URLSession.DelayedRequestDisposition, returnRequest: URLRequest?)
    func willPerformHTTPRedirection(_ response: HTTPURLResponse, newRequest: URLRequest) -> URLRequest?
    
    func didBecome(_ task: Task)
    
    func betterRouteDiscovered()
    func readClosed()
    func didBecome(_ inputStream: InputStream, outputStream: OutputStream)
    func writeClosed()
    
    func didFinishDownloading(to url: URL)
    func didResume(atOffset fileOffset: Int64, expectedTotalBytes: Int64)
    func didWriteData(_ byteCount: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
}

extension SingleTaskDelegate {
    
    public func didComplete(error: Error?) {}
    public func didFinishCollecting(_ metrics: URLSessionTaskMetrics) {}
    public func didSendBodyData(_ bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {}
    public func needNewBodyStream() -> InputStream? { return nil }
    public func willBegin(_ delayedRequest: URLRequest) -> (disposition: URLSession.DelayedRequestDisposition, returnRequest: URLRequest?) { return (.continueLoading, nil) }
    public func willPerformHTTPRedirection(_ response: HTTPURLResponse, newRequest: URLRequest) -> URLRequest? { return nil }
    
    public func didBecome(_ task: Task) {}
    
    public func betterRouteDiscovered() {}
    public func readClosed() {}
    public func didBecome(_ inputStream: InputStream, outputStream: OutputStream) {}
    public func writeClosed() {}
    
    public func didFinishDownloading(to location: URL) {}
    public func didResume(atOffset fileOffset: Int64, expectedTotalBytes: Int64) {}
    public func didWriteData( byteCount: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {}
}
