//
//  Builder.swift
//  Retrolux
//
//  Created by Christopher Bryan Henderson on 8/21/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

//protocol BuilderProtocol {
//    func encode<T>(_ value: T) throws -> Body
//    
//    func decode<T>(_ value: T.Type) -> (Response<AnyData>) throws -> T
//}



//
//
//public struct Response<T> {
//
//    public let originalRequest: URLRequest
//
//    public var body: T?
//    public let urlResponse: URLResponse?
//    public var error: Error?
//    public var isValid: Bool
//
//    public init(_ originalRequest: URLRequest, _ body: T?, _  urlResponse: URLResponse?, _ error: Error?) {
//
//        self.originalRequest = originalRequest
//
//        self.body = body
//        self.error = error
//        self.urlResponse = urlResponse
//
//        self.isValid = body != nil
//    }
//
//    // MARK: Interpret
//
//    public enum Interpreted {
//        case body(T)
//        case error(Error?)
//    }
//
//    public func interpreted() -> Interpreted {
//        return self.body.map { .body($0) } ?? .error(self.error)
//    }
//
//    public enum NoError: Error {
//        case noBodyOrErrorInInterpretedResponse
//    }
//
//    public func interpret() throws -> T {
//
//        switch self.interpreted() {
//        case .body(let body): return body
//        case .error(let error): throw error ?? NoError.noBodyOrErrorInInterpretedResponse
//        }
//    }
//
//    // map
//
//    public func convert<U>(_ f: (Response<T>)throws->U?) -> Response<U> {
//
//        var body: U? = nil
//        var error: Error? = nil
//
//        do {
//            body = try f(self)
//        } catch let _error {
//            error = _error
//        }
//
//        return Response<U>(self.originalRequest, body, self.urlResponse, self.error ?? error)
//    }
//
//    // convenience
//
//    public var httpURLResponse: HTTPURLResponse? {
//        return self.urlResponse as? HTTPURLResponse
//    }
//
//    public var statusCode: Int? {
//        return self.httpURLResponse?.statusCode
//    }
//
//    public var mimeType: String? {
//        return self.urlResponse?.mimeType
//    }
//
//    public var allHeaderFields: [String: String]? {
//        return self.httpURLResponse?.allHeaderFields as? [String: String]
//    }
//
//    public var expectedContentLength: Int64? {
//        return self.urlResponse?.expectedContentLength
//    }
//
//    public var textEncodingName: String? {
//        return self.urlResponse?.textEncodingName
//    }
//
//    public var suggestedFilename: String? {
//        return self.urlResponse?.suggestedFilename
//    }
//}
//
//extension Response where T: Equatable {
//
//    public static func ==(lhs: Response, rhs: Response) -> Bool {
//
//        return lhs.body == rhs.body
//            && (lhs.error == nil) == (rhs.error == nil)
//            && lhs.isValid == rhs.isValid
//            && lhs.originalRequest == rhs.originalRequest
//            && lhs.urlResponse == rhs.urlResponse
//    }
//}
//
//// Task
//
//// URLSession = URLSessionTask URLSessionDataTask || URLSessionDownloadTask || URLSessionUploadTask
//// Alamofire = Request -> DataRequest || DownloadRequest || UploadRequest
//
//public protocol Task {
//
//    mutating func cancel()
//    mutating func resume()
//    mutating func suspend()
//
//    var state: URLSessionTask.State {get}
//}
//
//extension Task {
//
//    public var isSuspended: Bool {
//        return self.state == .suspended
//    }
//
//    public var isCancelled: Bool {
//        return self.state == .canceling
//    }
//
//    public var isRunning: Bool {
//        return self.state == .running
//    }
//
//    public var isCompleted: Bool {
//        return self.state == .completed
//    }
//}
//
//// an extension to help with sync retrieval of response
//
//extension DispatchSemaphore {
//    open class SemaphoreRetrieve<T> {
//
//        fileprivate let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
//
//        public init() {}
//
//        open var response: T? {
//            didSet {
//                self.semaphore.signal()
//            }
//        }
//
//        open func wait(timeout: DispatchTime) -> T? {
//            _ = self.semaphore.wait(timeout: timeout)
//            return self.response
//        }
//
//        open func wait() -> T {
//            self.semaphore.wait()
//            return self.response!
//        }
//    }
//
//    public static func retrieve<T>(_ value: T.Type = T.self, timeout: DispatchTime, execute: (SemaphoreRetrieve<T>)throws->()) rethrows -> T? {
//        let s = SemaphoreRetrieve<T>()
//        try execute(s)
//        return s.wait(timeout: timeout)
//    }
//
//    public static func retrieve<T>(_ value: T.Type = T.self, execute: (SemaphoreRetrieve<T>)throws->()) rethrows -> T {
//        let s = SemaphoreRetrieve<T>()
//        try execute(s)
//        return s.wait()
//    }
//}
//
//typealias User = (username: String, Void)
//
//typealias HTTPMethod = (rawValue: String, Void)
//
//public enum AnyData {
//    case url(URL, temporary: Bool)
//    case data(Data)
//}
//
//public enum TaskType {
//    case dataTask
//    case downloadTask
//    case uploadTask(AnyData)
//}
//
//public protocol Client {
//    func createTask(_ taskType: TaskType, with request: URLRequest, callback: @escaping (Response<AnyData>) -> Void) -> Task
//}
//
//// I was thinking for the builder:
//// (protocol or class,
//// struct has to create a new object
//// to override a method)
//public protocol BuilderProtocol {
//    var base: URL {get}
//    var client: Client {get}
//    func make(_ method: HTTPMethod, _ endpoint: String, _ formatEndpoint: String...) -> RequestBuilder
//    func encode<T>(_ value: T) throws -> Body
//    // handler so that they can capture self or capture the decoders
//    func decodeHandler<T>(_ value: T.Type) -> (Response<AnyData>) throws -> T
//}
//
//open class Builder: BuilderProtocol {
//
//    open var base: URL
//    open var client: Client = URLSession(configuration: .default)
//    open var encoders: [FactoryEncoder] = []
//    open var decoders: [FactoryDecoder] = []
//
//    public init(_ base: URL) {
//        self.base = base
//    }
//
//    public func make(_ method: HTTPMethod, _ endpoint: String, _ formatEndpoint: String...) -> RequestBuilder {
//
//        var urlRequest = URLRequest.init(url: self.base.appendingPathComponent(String(format: endpoint, formatEndpoint)))
//        urlRequest.httpMethod = method.rawValue
//
//        return ImpartialRequest(urlRequest, self)
//    }
//}

//// and then in the usage the user can hide the builder in the interface:
//
//public protocol RequestInterface {
//    init(_ builder: BuilderProtocol)
//}
//
//struct GetUserService: RequestInterface {
//    private let builder: BuilderProtocol
//    public init(_ builder: BuilderProtocol) {
//        self.builder = builder
//    }
//
//    // self.builder would have to be added,
//    // but there will only be the functions in the interface
//    // Retrofit creates the interface, but Retrofit doesn't show
//    // in the interface
//
//    func updateUser(_ user: User, _ callback: @escaping (Response<User>)->()) {
//        self.builder.make(.head, "users/%@/", user.username).build().enqueue({
//            // if fail or false:
//            // (callback fail)
//            // if need update:
//            self.builder.get("users/%@/", user.username).build().enqueue(callback)
//        })
//
//    }
//
//}
//
//
//
//public struct Test {
//
//}
//
///*public*/ extension Test: Encoder {
//    public var codingPath: [CodingKey] {
//        fatalError()
//    }
//
//    public var userInfo: [CodingUserInfoKey : Any] {
//        fatalError()
//    }
//
//    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
//        fatalError()
//    }
//
//    public func unkeyedContainer() -> UnkeyedEncodingContainer {
//        fatalError()
//    }
//
//    public func singleValueContainer() -> SingleValueEncodingContainer {
//        fatalError()
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//import Alamofire
//
//
//class Builder {
//
//    var base: URL
//    var client: Client = URLSession(configuration: .default)
//
//    init(_ base: URL) {
//        self.base = base
//    }
//
//    func make(_ method: HTTPMethod, _ endpoint: String, _ pathArgs: (identifier: String, value: String)...) -> RequestCreator {
//
//        var endpoint = endpoint
//
//        for (identifier, value) in pathArgs {
//            endpoint = endpoint.replacingOccurrences(of: "{\(identifier)}", with: value)
//        }
//
//        return self.make(method, String(format: endpoint, pathArgs))
//    }
//
//    func processResponse<T>(_ response: Response<AnyData>) -> T {
//
//        // TODO: encode using encoders
//
//        fatalError()
//        // return ?
//    }
//}
//
//
//class RequestCreator {
//
//    var builder: Builder
//    var urlRequest: URLRequest
//    var body: AnyData?
//
//    var hasSetBody: Bool = false
//
//    init(_ urlRequest: URLRequest, builder: Builder) {
//        self.urlRequest = urlRequest
//        self.builder = builder
//    }
//
//    func path(_ id: String, _ value: String) -> Self {
//        // {modify self}
//        return self
//    }
//
//    func query(_ name: String, _ value: String?) -> Self {
//        // {modify Self}
//        return self
//    }
//
//    func body<T>(_ value: T) -> Self {
//
//        if hasSetBody {
//            fatalError()
//        }
//        self.hasSetBody = true
//
//        return self
//    }
//
//    func response<T>(_ value: T.Type) -> Call<T> {
//
//        fatalError()
//    }
//
//}

//extension Alamofire.Request: Task {
//    public var state: URLSessionTask.State {
//        return self.task?.state ?? .suspended
//    }
//}








//extension URLRequest {
//
//    /// httpBody is set last
//    public init(_ url: URL, _ method: URLRequest.HTTPMethod = .get, timeoutInterval: TimeInterval = 60, _ args: [RequestArg] = []) throws {
//
//        self.init(url: url, timeoutInterval: timeoutInterval)
//
//        self.httpMethod = method.rawValue
//
//        for arg in args {
//            try arg.apply(to: &self)
//        }
//    }
//
//    public init(_ base: URL, _ path: String, _ method: HTTPMethod = .get, timeoutInterval: TimeInterval = 60, query: [URLQueryItem]? = nil, headers: [String: String]? = nil, httpBody: Data? = nil) {
//
//        self.init(url: base.appendingPathComponent(path), timeoutInterval: timeoutInterval)
//        self.httpMethod = method.rawValue
//        self.allHTTPHeaderFields = headers
//        self.urlComponents?.queryItems = query
//        self.httpBody = httpBody
//    }
//}





//
//public protocol BuilderProtocol {
//
//    var base: URL {get}
//
//    associatedtype BuilderClient
//
//    var client: BuilderClient {get}
//
//    var encoders: [FactoryEncoder] {get}
//    var decoders: [FactoryDecoder] {get}
//
//    func requestInterceptor(_ request: inout URLRequest) throws
//    func responseInterceptor(_ response: inout Response<AnyData>) throws
//
//    func make<Return>(_ method: URLRequest.HTTPMethod, _ path: String, timeoutInterval: TimeInterval, _ args: [RequestArg]) throws -> Call<Return>
//}
//
//extension BuilderProtocol {
//
//    public var dispatchQueue: DispatchQueue { return DispatchQueue(label: "Retrolux.Builder.dispatchQueue") }
//
//    /// access self after sync
//    public func sync<T>(execute: (Self) throws -> T) rethrows -> T {
//        return try self.dispatchQueue.sync(execute: { try execute(self) })
//    }
//
//    /// sync with self.dispatchQueue
//    public func sync(execute: () throws -> Void) rethrows {
//        try self.dispatchQueue.sync(execute: execute)
//    }
//
//    /// async with self.dispatchQueue
//    public func async(execute: @escaping () -> Void) {
//        self.dispatchQueue.async(execute: execute)
//    }
//
//    public var encoders: [FactoryEncoder] { return [] }
//    public var decoders: [FactoryDecoder] { return [] }
//
//    public func requestInterceptor(_ request: inout URLRequest) throws {}
//    public func responseInterceptor(_ response: inout Response<AnyData>) throws {}
//
//    public func makeRequest(_ method: URLRequest.HTTPMethod = .get, _ path: String, timeoutInterval: TimeInterval = 60, _ args: [RequestArg] = []) throws -> URLRequest {
//
//    }
//}
//
//extension BuilderProtocol where BuilderClient == URLSession {
//
//    public var client: URLSession { return URLSession(configuration: .default) }
//
//}





//
//open class Builder {
//
//    open var base: URL
//
//    open var client: Client = URLSession(configuration: .default)
//
//    open lazy var encoders: [FactoryEncoder] = []
//    open lazy var decoders: [FactoryDecoder] = []
//
//    open var requestInterceptor: ((_ request: inout URLRequest) throws -> ())?
//    open var responseInterceptor: ((_ response: inout Response<AnyData>) throws -> ())?
//
//    /// queue for thread safety adding and removing values
//    open let safetyQueue: DispatchQueue = DispatchQueue(label: "Retrolux.Builder.safetyQueue")
//
//    public init(base: URL) {
//        self.base = base
//    }
//
//    /// access the values of Builder on it's safety queue
//    open func sync<T>(execute: (Builder)throws->T) rethrows -> T {
//        return try self.safetyQueue.sync(execute: { try execute(self) })
//    }
//
//    /// sync with the Builder's safety queue
//    open func sync(execute: ()throws->()) rethrows {
//        try self.safetyQueue.sync(execute: execute)
//    }
//
//    // content type would have to be exact
//
//    public enum BuilderError: Error {
//        case failedToEncodeWithEncoders(Any, errors: [Error], encoders: [FactoryEncoder])
//        case failedToDecodeWithDecoders(Any.Type, errors: [Error], decoders: [FactoryDecoder])
//    }
//
//    /// loops over the encoders and returns the first success or throws
//    open class func encode<T>(_ value: T, using encoders: [FactoryEncoder]) throws -> Body {
//
//        var errors: [Error] = []
//
//        for encoder in encoders {
//            do {
//                return try encoder.encode(value)
//            } catch {
//                errors.append(error)
//            }
//        }
//
//        throw BuilderError.failedToEncodeWithEncoders(value, errors: errors, encoders: encoders)
//    }
//
//    /// returns a closure that loops over the decoders and returns the first success or throws
//    open class func decodeHandler<T>(for: T.Type = T.self, using decoders: [FactoryDecoder]) -> (Response<AnyData>) throws -> T {
//
//        return {
//            var errors: [Error] = []
//
//            for decoder in decoders {
//                do {
//                    return try decoder.decode($0)
//                } catch {
//                    errors.append(error)
//                }
//            }
//
//            throw BuilderError.failedToDecodeWithDecoders(T.self, errors: errors, decoders: decoders)
//        }
//    }
//
//    /// body sets to httpBodyStream
//    open func makeRequest(method: URLRequest.HTTPMethod, path: String, httpHeaders: HTTPHeaders?, query: Query?, body: AnyData?) -> URLRequest {
//        var urlRequest = URLRequest(url: self.base.appendingPathComponent(path))
//        urlRequest.httpMethod = method.rawValue
//        urlRequest.urlComponents?.queryItems = query?.items
//        urlRequest.httpHeaders = httpHeaders ?? [:]
//        urlRequest.httpBodyStream = body.flatMap { try? $0.stream() }
//        return urlRequest
//    }
//
//
//    open func makeRequest<Args, Return>(
//        _ method: URLRequest.HTTPMethod,
//        _ path: String,
//        args: Args.Type,
//        response: @escaping (Response<AnyData>)throws->Return,
//        applyArgs: @escaping (inout URLRequest, Args)throws->TaskType
//        ) -> Call<Args, Return> {
//
//        var request = URLRequest(url: self.base.appendingPathComponent(path))
//        request.httpMethod = method.rawValue
//
//        return Call(request, factory: {[client = self.client, requestInterceptor = self.requestInterceptor, responseInterceptor = self.responseInterceptor] (request, args, callback) in
//
//            var request = request
//
//            try requestInterceptor?(&request)
//
//            let taskType = try applyArgs(&request, args)
//
//            return try client.createTask(taskType, with: request, completionHandler: {
//
//                var dataResponse = $0
//
//                do {
//                    try responseInterceptor?(&dataResponse)
//
//                    callback(dataResponse.convert { try response($0) })
//
//                } catch {
//                    callback(dataResponse.convert { _ in throw error })
//                }
//            })
//        })
//    }
//}

//public typealias User = Void
//
//public protocol GetUserInterface {
//
//    func getUser(_ name: String, _ callback: @escaping (User)->())
//}
//
//let interface: GetUserInterface = Builder(base: URL(string: "randomsite.org/")!).create() { builder in
//
//    struct RandomSiteGetUserInterface: GetUserInterface {
//
//        let builder: Builder
//
//        func getUser(_ name: String, _ callback: @escaping (User) -> ()) {
//            let request = builder.makeRequest(.get, "users/", args: String.self, response: <#T##(Response<AnyData>) throws -> Return#>, applyArgs: <#T##(inout URLRequest, Args) throws -> TaskType#>)
//        }
//    }
//
//    return RandomSiteGetUserInterface(builder: builder)
//}
//
//func t() {
//
//    interface.getUser("Bob", { user in
//        print(user) // == ()
//    })
//}
//
//class BuilderInterface: Builder {
//
//
//
//}
//
//public struct Call2<Return> {
//
//    public struct CallTask {
//        public func cancel() {}
//    }
//
//    public init(_ request: URLRequest, _ action: @escaping ((request: URLRequest, callback: (Return)->()))->CallTask) {
//        self.request = request
//        self.action = action
//    }
//
//    var request: URLRequest
//    var action: ((request: URLRequest, callback: (Return)->()))->CallTask
//
//    public func enqueue(_ callback: @escaping (Return)->()) -> CallTask {
//
//        return self.action((request: self.request, callback: callback))
//    }
//
//    public func perform() -> Return? {
//
//        return DispatchSemaphore.retrieve() { s in
//            _ = self.enqueue { s.response = $0 }
//        }
//    }
//}






