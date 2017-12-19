//
//  URLSessionClient.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/20/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

//
//// SessionDelegate
//sessionDelegate.urlSession(<#T##session: URLSession##URLSession#>, didBecomeInvalidWithError: <#T##Error?#>)
//sessionDelegate.urlSession(<#T##session: URLSession##URLSession#>, didReceive: <#T##URLAuthenticationChallenge#>, completionHandler: <#T##(URLSession.AuthChallengeDisposition, URLCredential?) -> Void#>)
//sessionDelegate.urlSessionDidFinishEvents(forBackgroundURLSession: <#T##URLSession#>)
//
//// TaskDelegate: SessionDelegate
//taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, didCompleteWithError: <#T##Error?#>)
//taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, didFinishCollecting: <#T##URLSessionTaskMetrics#>)
//taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, didSendBodyData: <#T##Int64#>, totalBytesSent: <#T##Int64#>, totalBytesExpectedToSend: <#T##Int64#>)
//taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, needNewBodyStream: <#T##(InputStream?) -> Void#>)
//taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, willBeginDelayedRequest: <#T##URLRequest#>, completionHandler: <#T##(URLSession.DelayedRequestDisposition, URLRequest?) -> Void#>)
//taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, willPerformHTTPRedirection: <#T##HTTPURLResponse#>, newRequest: <#T##URLRequest#>, completionHandler: <#T##(URLRequest?) -> Void#>)
//
//// DataDelegate: TaskDelegate
//dataDelegate.urlSession(<#T##session: URLSession##URLSession#>, dataTask: <#T##URLSessionDataTask#>, didBecome: <#T##URLSessionDownloadTask#>)
//dataDelegate.urlSession(<#T##session: URLSession##URLSession#>, dataTask: <#T##URLSessionDataTask#>, didBecome: <#T##URLSessionStreamTask#>)
//
//// StreamDelegate: TaskDelegate
//streamDelegate.urlSession(<#T##session: URLSession##URLSession#>, betterRouteDiscoveredFor: <#T##URLSessionStreamTask#>)
//streamDelegate.urlSession(<#T##session: URLSession##URLSession#>, readClosedFor: <#T##URLSessionStreamTask#>)
//streamDelegate.urlSession(<#T##session: URLSession##URLSession#>, streamTask: <#T##URLSessionStreamTask#>, didBecome: <#T##InputStream#>, outputStream: <#T##OutputStream#>)
//streamDelegate.urlSession(<#T##session: URLSession##URLSession#>, writeClosedFor: <#T##URLSessionStreamTask#>)
//
//// DownloadDelegate: TaskDelegate
//downloadDelegate.urlSession(<#T##session: URLSession##URLSession#>, downloadTask: <#T##URLSessionDownloadTask#>, didFinishDownloadingTo: <#T##URL#>)
//downloadDelegate.urlSession(<#T##session: URLSession##URLSession#>, downloadTask: <#T##URLSessionDownloadTask#>, didResumeAtOffset: <#T##Int64#>, expectedTotalBytes: <#T##Int64#>)
//downloadDelegate.urlSession(<#T##session: URLSession##URLSession#>, downloadTask: <#T##URLSessionDownloadTask#>, didWriteData: <#T##Int64#>, totalBytesWritten: <#T##Int64#>, totalBytesExpectedToWrite: <#T##Int64#>)

extension URLSession: Client {

    open func createTask(_ taskType: TaskType, with request: URLRequest, delegate: SingleTaskDelegate?, completionHandler: @escaping (Response<AnyData>) -> Void) -> Task {

        let task: URLSessionTask

        switch taskType {

        case .dataTask:
            task = self.dataTask(with: request) { completionHandler(Response(request, $0.map { .data($0) }, $1, $2)) }

        case .downloadTask:
            task = self.downloadTask(with: request)

        case .downloadTaskWithResumeData(let data):
            task = self.downloadTask(withResumeData: data) { completionHandler(Response(request, $0.map { .url($0, temporary: false) }, $1, $2)) }

        case .uploadTask(let data):

            switch data {

            case .url(let url, let isTemporary):
                task = self.uploadTask(with: request, fromFile: url) {
                    completionHandler(Response(request, $0.map { .data($0) }, $1, $2))
                    try? url.removeFile(ifTemporary: isTemporary)
                }

            case .data(let data):
                task = self.uploadTask(with: request, from: data) { completionHandler(Response(request, $0.map { .data($0) }, $1, $2)) }
            }
        }

        if let masterDelegate = self.delegate as? URLSessionMasterDelegate {
            masterDelegate[self][task] = delegate
        }

        return task
    }
}

public protocol SingleURLSessionDelegate: AnyObject {
    func didBecomeInvalid(error: Error?)
    func didReceive(_ challenge: URLAuthenticationChallenge) -> (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?)
    func didFinishEvents()
}

extension SingleURLSessionDelegate {
    public func didBecomeInvalid(error: Error?) {}
    public func didReceive(_ challenge: URLAuthenticationChallenge) -> (disposition: URLSession.AuthChallengeDisposition, credential: URLCredential?) { return (.performDefaultHandling, nil) }
    public func didFinishEvents() {}
}

open class URLSessionDelegateManager {

    open weak var delegate: SingleURLSessionDelegate?

    // cannot cast a swift value to an AnyObject and then to a protocol without casting to the original swift type

    /// The delegates for each task.  Values should be SingleTaskDelegate
    open var taskDelegates = NSMapTable<URLSessionTask, AnyObject>(keyOptions: .weakMemory, valueOptions: .weakMemory)

    open subscript(task: URLSessionTask) -> SingleTaskDelegate? {
        get {
            return self.taskDelegates.object(forKey: task) as? SingleTaskDelegate
        }
        set {
            self.taskDelegates.setObject(newValue, forKey: task)
        }
    }
}

open class URLSessionMasterDelegate: NSObject, URLSessionDataDelegate, URLSessionStreamDelegate, URLSessionDownloadDelegate {

    open var sessions = NSMapTable<URLSession, URLSessionDelegateManager>(keyOptions: .weakMemory, valueOptions: .strongMemory)

    open static let shared = URLSessionMasterDelegate()

    open subscript(session: URLSession) -> URLSessionDelegateManager {
        get {
            return self.sessions.object(forKey: session) ?? URLSessionDelegateManager()
        }
        set {
            self.sessions.setObject(newValue, forKey: session)
        }
    }

    open func delegate(for task: URLSessionTask, in session: URLSession) -> SingleTaskDelegate? {
        return self[session][task]
    }

    open func delegate(for session: URLSession) -> SingleURLSessionDelegate? {
        return self[session].delegate
    }

    //// SessionDelegate
    //sessionDelegate.urlSession(<#T##session: URLSession##URLSession#>, didBecomeInvalidWithError: <#T##Error?#>)
    //sessionDelegate.urlSession(<#T##session: URLSession##URLSession#>, didReceive: <#T##URLAuthenticationChallenge#>, completionHandler: <#T##(URLSession.AuthChallengeDisposition, URLCredential?) -> Void#>)
    //sessionDelegate.urlSessionDidFinishEvents(forBackgroundURLSession: <#T##URLSession#>)

    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.delegate(for: session)?.didBecomeInvalid(error: error)
    }

    open func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let (disposition, credential) = self.delegate(for: session)?.didReceive(challenge) {
            completionHandler(disposition, credential)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }

    open func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        self.delegate(for: session)?.didFinishEvents()
    }

    //
    //// TaskDelegate: SessionDelegate
    //taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, didCompleteWithError: <#T##Error?#>)
    //taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, didFinishCollecting: <#T##URLSessionTaskMetrics#>)
    //taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, didSendBodyData: <#T##Int64#>, totalBytesSent: <#T##Int64#>, totalBytesExpectedToSend: <#T##Int64#>)
    //taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, needNewBodyStream: <#T##(InputStream?) -> Void#>)
    //taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, willBeginDelayedRequest: <#T##URLRequest#>, completionHandler: <#T##(URLSession.DelayedRequestDisposition, URLRequest?) -> Void#>)
    //taskDelegate.urlSession(<#T##session: URLSession##URLSession#>, task: <#T##URLSessionTask#>, willPerformHTTPRedirection: <#T##HTTPURLResponse#>, newRequest: <#T##URLRequest#>, completionHandler: <#T##(URLRequest?) -> Void#>)

    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.delegate(for: task, in: session)?.didComplete(error: error)
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        self.delegate(for: task, in: session)?.didFinishCollecting(metrics)
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.delegate(for: task, in: session)?.didSendBodyData(bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        completionHandler(self.delegate(for: task, in: session)?.needNewBodyStream())
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        if let (disposition, request) = self.delegate(for: task, in: session)?.willBegin(request) {
            completionHandler(disposition, request)
        } else {
            completionHandler(.continueLoading, nil)
        }
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(self.delegate(for: task, in: session)?.willPerformHTTPRedirection(response, newRequest: request))
    }

    //
    //// DataDelegate: TaskDelegate
    //dataDelegate.urlSession(<#T##session: URLSession##URLSession#>, dataTask: <#T##URLSessionDataTask#>, didBecome: <#T##URLSessionDownloadTask#>)
    //dataDelegate.urlSession(<#T##session: URLSession##URLSession#>, dataTask: <#T##URLSessionDataTask#>, didBecome: <#T##URLSessionStreamTask#>)

    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        self[session][downloadTask] = self[session][dataTask]
        self[session][dataTask] = nil
        self[session][downloadTask]?.didBecome(downloadTask)
    }

    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        self[session][streamTask] = self[session][dataTask]
        self[session][dataTask] = nil
        self[session][streamTask]?.didBecome(streamTask)
    }

    //
    //// StreamDelegate: TaskDelegate
    //streamDelegate.urlSession(<#T##session: URLSession##URLSession#>, betterRouteDiscoveredFor: <#T##URLSessionStreamTask#>)
    //streamDelegate.urlSession(<#T##session: URLSession##URLSession#>, readClosedFor: <#T##URLSessionStreamTask#>)
    //streamDelegate.urlSession(<#T##session: URLSession##URLSession#>, streamTask: <#T##URLSessionStreamTask#>, didBecome: <#T##InputStream#>, outputStream: <#T##OutputStream#>)
    //streamDelegate.urlSession(<#T##session: URLSession##URLSession#>, writeClosedFor: <#T##URLSessionStreamTask#>)

    open func urlSession(_ session: URLSession, betterRouteDiscoveredFor streamTask: URLSessionStreamTask) {
        self.delegate(for: streamTask, in: session)?.betterRouteDiscovered()
    }

    open func urlSession(_ session: URLSession, readClosedFor streamTask: URLSessionStreamTask) {
        self.delegate(for: streamTask, in: session)?.readClosed()
    }

    open func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream) {
        self.delegate(for: streamTask, in: session)?.didBecome(inputStream, outputStream: outputStream)
    }

    open func urlSession(_ session: URLSession, writeClosedFor streamTask: URLSessionStreamTask) {
        self.delegate(for: streamTask, in: session)?.writeClosed()
    }
    
    //
    //// DownloadDelegate: TaskDelegate
    //downloadDelegate.urlSession(<#T##session: URLSession##URLSession#>, downloadTask: <#T##URLSessionDownloadTask#>, didFinishDownloadingTo: <#T##URL#>)
    //downloadDelegate.urlSession(<#T##session: URLSession##URLSession#>, downloadTask: <#T##URLSessionDownloadTask#>, didResumeAtOffset: <#T##Int64#>, expectedTotalBytes: <#T##Int64#>)
    //downloadDelegate.urlSession(<#T##session: URLSession##URLSession#>, downloadTask: <#T##URLSessionDownloadTask#>, didWriteData: <#T##Int64#>, totalBytesWritten: <#T##Int64#>, totalBytesExpectedToWrite: <#T##Int64#>)

    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        self.delegate(for: downloadTask, in: session)?.didFinishDownloading(to: location)
    }

    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        self.delegate(for: downloadTask, in: session)?.didResume(atOffset: fileOffset, expectedTotalBytes: expectedTotalBytes)
    }

    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.delegate(for: downloadTask, in: session)?.didWriteData(bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
    }
}

