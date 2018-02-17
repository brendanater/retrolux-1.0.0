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

    open func createTask(_ taskType: TaskType, with request: URLRequest, delegate: SingleTaskDelegate?, completionHandler: @escaping (Response<DataBody>) -> Void) -> Task {
        
        var task: URLSessionTask!
        
        func response(_ body: Any?, _ urlResponse: URLResponse?, _ error: Error?) {
            
            completionHandler(
                Response(
                    body: (body as? Data).map { .data($0) } ?? (body as? URL).map { .url($0, temporaryFile: true) },
                    urlResponse: urlResponse,
                    error: error,
                    originalRequest: task.originalRequest ?? request,
                    metrics: delegate?.metrics,
                    resumeData: (error as NSError?)?.userInfo[NSURLSessionDownloadTaskResumeData] as? Data,
                    isValid: error == nil && (200..<300).contains((urlResponse as? HTTPURLResponse)?.statusCode ?? 0)
                )
            )
        }
        
        switch taskType {

        case .dataTask:
            task = self.dataTask(with: request) { response($0, $1, $2) }

        case .downloadTask:
            task = self.downloadTask(with: request) { response($0, $1, $2) }

        case .downloadTaskWithResumeData(let data):
            task = self.downloadTask(withResumeData: data) { response($0, $1, $2) }

        case .uploadTaskFromData(let data):
            task = self.uploadTask(with: request, from: data)

//            switch data {
//
//            case .url(let url, let isTemporary):
//
//            case .data(let data):
//            }
            
        case .uploadTaskFromFile(let url):
            task = self.uploadTask(with: request, fromFile: url) { response($0, $1, $2) }
            
        case .uploadTaskWithStream(let inputStream):
            // FIXME: add inputStream handling to URLSession 'Client'
            fatalError()
        }
        
        delegate?.task = task

        if let masterDelegate = self.delegate as? URLSessionMasterDelegate {
            masterDelegate[self][task] = delegate
        }

        return task
    }
}

public protocol SingleURLSessionDelegate: AnyObject {
    func didBecomeInvalid(error: Error?)
    func didReceive(_ challenge: URLAuthenticationChallenge, _ completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    func didFinishEvents()
}

extension SingleURLSessionDelegate {
    public func didBecomeInvalid(error: Error?) {}
    public func didReceive(_ challenge: URLAuthenticationChallenge, _ completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) { completionHandler(.performDefaultHandling, nil) }
    public func didFinishEvents() {}
}

open class URLSessionDelegateManager {

    open weak var delegate: SingleURLSessionDelegate?

    // cannot cast a swift value to an AnyObject and then to a protocol without casting to the original swift type

    /// The delegates for each task.  Values should be SingleTaskDelegate (couldn't store protocol weakly).
    open var taskDelegates = ReferenceDictionary<URLSessionTask, AnyObject>(key: .weak, value: .weak)

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

    // manager should be strong because no outside references hold them, deinitializes when urlSession is deinitialized
    open var sessions = ReferenceDictionary<URLSession, URLSessionDelegateManager>(key: .weak, value: .strong)

    open static let shared = URLSessionMasterDelegate()

    open subscript(session: URLSession) -> URLSessionDelegateManager {
        get {
            return self.sessions.object(forKey: session) ?? { let manager = URLSessionDelegateManager(); self[session] = manager; return manager }()
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
        self.delegate(for: session)?.didReceive(challenge, completionHandler)
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
        let delegate = self.delegate(for: task, in: session)
        delegate?.metrics = metrics
        delegate?.didFinishCollecting(metrics)
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        self.delegate(for: task, in: session)?.didSendBodyData(bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, needNewBodyStream completionHandler: @escaping (InputStream?) -> Void) {
        self.delegate(for: task, in: session)?.needNewBodyStream(completionHandler)
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest request: URLRequest, completionHandler: @escaping (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        self.delegate(for: task, in: session)?.willBegin(request, completionHandler)
    }

    open func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.delegate(for: task, in: session)?.willPerformHTTPRedirection(response, newRequest: request, completionHandler)
    }

    //
    //// DataDelegate: TaskDelegate
    //dataDelegate.urlSession(<#T##session: URLSession##URLSession#>, dataTask: <#T##URLSessionDataTask#>, didBecome: <#T##URLSessionDownloadTask#>)
    //dataDelegate.urlSession(<#T##session: URLSession##URLSession#>, dataTask: <#T##URLSessionDataTask#>, didBecome: <#T##URLSessionStreamTask#>)
    
    private func _urlSession(_ session: URLSession, originalTask: URLSessionTask, didBecome task: URLSessionTask) {
        let manager = self[session]
        let delegate = manager[originalTask]
        manager[task] = delegate
        manager[originalTask] = nil
        delegate?.task = task
        delegate?.taskDidBecome(task)
    }

    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        self._urlSession(session, originalTask: dataTask, didBecome: downloadTask)
    }

    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        self._urlSession(session, originalTask: dataTask, didBecome: streamTask)
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
        self.delegate(for: streamTask, in: session)?.stream(didBecome: inputStream, outputStream: outputStream)
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

