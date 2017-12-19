//
//  RequestCreation.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/25/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

public struct ExampleInterface {
    
    public typealias User = String
    
    /*
     
     It was very restricted, I was aiming for something like this:
     
     // builder needs access to on init to create closures
     private let builder: RequestBuilder
     
     // method needs to be able to be get only
     // method needs to be short as possible
     public let getUser = get("users/%@/").build(Int.self) { try! $0.path($1).build(Call<User>.self) }
     
     
     // haven't found an easy way to privately add multiple methods from an imported framework
     private func get(_ endpoint: String) -> RequestBuilder {
         return self.builder.make(.get, endpoint)
     }
     
     public private(set) getUser = ...
     
     */
    
    public let getUser: (Int) -> Call<User>
    
    public init(_ builder: RequestBuilder = RequestBuilder(base: URL(string: "test.com/")!)) {
        // first build converts to a closure type, second build returns the Call<User>
        self.getUser = builder.make(.get, "users/%@/").build(Int.self) { try! $0.path($1).build(Call<User>.self) }
    }
    
//    @GET("users/{id}")
//    Call<User> getUser(@Path("id") Int id)
    
}


open class RequestBuilder: Copyable {

    open var url: URL
    open var method: HTTPMethod
    open var headers: HTTPHeaders
    open var queryItems: [URLQueryItem]
    open var queryDestination: QueryDestination
    open var body: Body?
    open var factoryEncoders: [FactoryEncoder]
    open var factoryDecoders: [FactoryDecoder]
    open var client: Client
    open var statusConfirmation: ((Int) -> Bool)?
    open var download: (willDownload: Bool, resumeData: Data?)
    open var upload: Bool
    open var autoResume: Bool
    /// whether to capture self or a copy on build
    open var capturesCopy: Bool
    
    open var path: String {
        get {
            return self.url.path
        }
        set {
            guard var components = self.url.components else {
                fatalError("failed to get components of url: \(self.url)")
            }
            
            components.path = newValue
            
            self.url = components.url!
        }
    }
    
    public init(base: URL) {
        self.url = base
        self.method = .get
        self.headers = [:]
        self.queryItems = []
        self.queryDestination = .methodDependentUTF8
        self.body = nil
        self.factoryEncoders = []
        self.factoryDecoders = []
        self.client = URLSession(configuration: .default, delegate: URLSessionMasterDelegate.shared, delegateQueue: nil)
        self.statusConfirmation = nil
        self.download = (false, nil)
        self.upload = false
        self.autoResume = true
        self.capturesCopy = false
    }
    
    public convenience init?(base: String) {
        if let url = URL(string: base) {
            self.init(base: url)
        } else {
            return nil
        }
    }

    public required init(copy: RequestBuilder) {
        self.url = copy.url
        self.method = copy.method
        self.headers = copy.headers
        self.queryItems = copy.queryItems
        self.queryDestination = copy.queryDestination
        self.body = copy.body
        self.factoryEncoders = copy.factoryEncoders
        self.factoryDecoders = copy.factoryDecoders
        self.client = copy.client
        self.statusConfirmation = copy.statusConfirmation
        self.download = copy.download
        self.upload = copy.upload
        self.autoResume = copy.autoResume
        self.capturesCopy = copy.capturesCopy
    }
    
    public enum BuilderError: Error {
        
        case invalidValue(Any, debugDescription: String, underlyingError: Error?)
        case buildFailed(debugDescription: String, underlyingError: Error?)
    }

    // MARK: prefix method: modify or get the method

    open func method(_ method: HTTPMethod) -> Self {
        self.method = method
        return self
    }
    
    open func method(restful: RestfulHTTPMethod) -> Self {
        self.method = HTTPMethod(restful.httpMethod)!
        self.statusConfirmation = restful.statusConfirmation
        return self
    }
    
    // MARK: prefix url: modify the url
    
    open func url(_ url: URL) -> Self {
        self.url = url
        return self
    }

    // MARK: prefix path: modify the path on the url
    
    // note: path sets all the path args at once
    
    open func path(_ args: CustomStringConvertible...) -> Self {
        return self.path(args)
    }
    
    open func path(_ args: [CustomStringConvertible]) -> Self {
        self.path = String(format: self.path, args.map { $0.description.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! })
        return self
    }

    // MARK: prefix query: add one or more to self.query or modify self.url.query

    open func query(_ name: String, _ value: String?) -> Self {
        self.queryItems.append(URLQueryItem(name, value))
        return self
    }

    open func query(_ queryItems: [URLQueryItem]) -> Self {
        self.queryItems += queryItems
        return self
    }
    
    open func query(destination: QueryDestination) -> Self {
        // doesn't throw "body already set here", because, .methodDependent is variable
        self.queryDestination = destination
        return self
    }

    // MARK: prefix body: set or modify the body

    open func body(_ body: Body) throws -> Self {
        guard self.body == nil else {
            throw BuilderError.invalidValue(body, debugDescription: "Builder already has a body", underlyingError: nil)
        }
        self.body = body
        return self
    }

    open func body<T>(_ value: T) throws -> Self {

        for encoder in self.factoryEncoders {
            if encoder.supports(value) {
                return try self.body(encoder.encode(value))
            }
        }
        
        if let value = value as? RequestBody {
            return try self.body(value.requestBody())
        }
        
        throw BuilderError.invalidValue(value, debugDescription: "No FactoryEncoders support value in \(self)", underlyingError: nil)
    }

    // MARK: prefix header: replace or add a header

    open func header(_ field: HTTPHeaders.Field, _ value: String) -> Self {
        self.headers[field] = value
        return self
    }

    // MARK: prefix headers: replace or add multiple headers

    open func headers(_ headers: HTTPHeaders) -> Self {
        for (field, value) in headers {
            _ = self.header(field, value)
        }
        return self
    }

    // MARK: prefix make: copy or make a new self with default values

    open func make(_ method: HTTPMethod, _ endpoint: String, _ args: CustomStringConvertible...) -> Self {
        return self.make(method, endpoint, args)
    }
    
    open func make(_ method: HTTPMethod, _ endpoint: String, _ args: [CustomStringConvertible] = []) -> Self {
        return self.copy().method(method).url(self.url.appendingPathComponent(String(format: endpoint, args.map { $0.description.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)! })))
    }

    // MARK: prefix apply: apply part of self to an object
    // NOTE: apply always returns Self and is always @discardableResult
    
    @discardableResult
    open func applyQuery(to request: inout URLRequest) throws -> Self {
        
        func setQueryItems() throws {
            
            guard (request.urlComponents?.queryItems = self.queryItems) != nil else {
                
                if self.queryItems.isEmpty {
                    return
                } else {
                    throw BuilderError.invalidValue(
                        request,
                        debugDescription: "Cannot set queryItems to a request with no urlComponents. Make sure that the request has a URL and urlComponents can be initialized from it",
                        underlyingError: nil
                    )
                }
            }
        }
        
        func setHTTPBody(_ encoding: String.Encoding) throws {
            
            var components = URLComponents(string: "?")!
            
            components.queryItems = self.queryItems
            
            guard let data = components.url?.query?.data(using: encoding) else {
                if self.queryItems.isEmpty {
                    return
                } else {
                    throw BuilderError.invalidValue(self.queryItems, debugDescription: "Failed to get query data", underlyingError: nil)
                }
            }
            
            guard !request.isHTTPBodySet && self.body == nil else {
                
                if self.queryItems.isEmpty {
                    return
                } else {
                    throw BuilderError.invalidValue(
                        self.queryItems,
                        debugDescription: "Cannot set a form url encoded body when there is already a body set.  Set .queryDestination to QueryDestination.queryString or remove all queryItems",
                        underlyingError: nil
                    )
                }
            }
            
            request.httpBody = data
            request.httpHeaders[.contentType] = "application/x-www-form-urlencoded" + (encoding.charset.map { "; charset=\($0)" } ?? "")
            request.httpHeaders[.contentLength] = data.count.description
        }
        
        switch self.queryDestination {
            
        case .methodDependent(let encoding):
            
            switch request.httpMethod_enum ?? .get {
            
            case .get, .head, .delete:
                try setQueryItems()
            
            default:
                try setHTTPBody(encoding)
            }
            
        case .queryString:
            try setQueryItems()
            
        case .httpBody(let encoding):
            try setHTTPBody(encoding)
        }
        
        return self
    }
    
    @discardableResult
    open func applyBody(_ urlRequest: inout URLRequest, taskType: inout TaskType) throws -> Self {
        
        if let body = self.body {
            
            switch body.data {
                
            case .data(let data):
                
                func setBody() throws {
                    guard !urlRequest.isHTTPBodySet else {
                        throw BuilderError.invalidValue(urlRequest, debugDescription: "Cannot set body to a request that already has an httpBody", underlyingError: nil)
                    }
                    urlRequest.httpBody = data
                }
                
                if self.upload {
                    if case .downloadTaskWithResumeData(_) = taskType {
                        try setBody()
                    } else {
                        taskType = .uploadTask(body.data)
                    }
                } else {
                    try setBody()
                }
                
            case .url(_, _):
                if case .downloadTaskWithResumeData(_) = taskType {
                    throw BuilderError.invalidValue(
                        body,
                        debugDescription: "Cannot overwrite taskType: .downloadTaskWithResumeData(_) with .uploadTask(URL). Remove .body or .download.resumeData",
                        underlyingError: nil
                    )
                } else {
                    taskType = .uploadTask(body.data)
                }
            }
            
            for (field, value) in body.httpHeaders {
                urlRequest.httpHeaders[field] = value
            }
        }
        
        return self
    }
    
    // Note: only the build and get prefixes are allowed to have a different return type other than Self
    
    // MARK: prefix get: get a value by using multiple values or by adapting a value
    
    open func getValue<T>(_ value: T.Type = T.self, from response: Response<AnyData>) throws -> T {
        
        var errors: [Error] = []
        
        for decoder in self.factoryDecoders {
            if let supports = decoder.supports(value) {
                
                if supports {
                    return try decoder.decode(response)
                } else {
                    continue
                }
            } else {
                do {
                    return try decoder.decode(response)
                } catch {
                    errors.append(error)
                    continue
                }
            }
        }
        
        if let valueMetaType = T.self as? ResponseBody.Type {
            return try valueMetaType.init(from: response) as! T
        }
        
        if errors.isEmpty {
            throw BuilderError.invalidValue(value, debugDescription: "No FactoryDecoders support value", underlyingError: nil)
        } else {
            throw BuilderError.invalidValue(value, debugDescription: "No FactoryDecoders could decode value", underlyingError: nil)
        }
    }
    
    open func getCaptureBuilder() -> Self {
        return self.capturesCopy ? self.copy() : self
    }

    // MARK: prefix build: finalize self by converting to a different format

    open func buildRequest() throws -> (urlRequest: URLRequest, taskType: TaskType) {
        
        var taskType: TaskType = {
            
            if self.download.willDownload {
                
                return self.download.resumeData.map {
                    .downloadTaskWithResumeData($0)
                } ?? .downloadTask
                
            } else {
                return .dataTask
            }
        }()

        var urlRequest = URLRequest(url: self.url)
        
        urlRequest.httpHeaders = self.headers
        urlRequest.httpMethod_enum = self.method
        
        try self
        .applyBody(&urlRequest, taskType: &taskType)
        .applyQuery(to: &urlRequest)
        
        return (urlRequest, taskType)
    }
    
    open func build<T, U>(_ args: T.Type, _ applyArgs: @escaping (RequestBuilder, T) -> U) -> (T) -> U {
        
        return { [builder = self.getCaptureBuilder()] in
            applyArgs(builder, $0)
        }
    }
    
    open func build<T, U>(_ args: T.Type, _ applyArgs: @escaping (RequestBuilder, T) throws -> U) -> (T) throws -> U {
        
        return { [builder = self.getCaptureBuilder()] in
            try applyArgs(builder, $0)
        }
    }

    open func build<T: CallAdaptable>(_: T.Type) throws -> T {

        let (urlRequest, taskType) = try self.buildRequest()
        
        return T(Call<T.Return>(urlRequest, autoResume: self.autoResume) { [builder = self.getCaptureBuilder()] in
            let (urlRequest, delegate, callback) = $0
            return builder.client.createTask(taskType, with: urlRequest, delegate: delegate) {
                
                var response = $0
                
                if response.isValid,
                    let statusCode = response.statusCode,
                    let statusConfirmation = builder.statusConfirmation {
                    
                    response.isValid = statusConfirmation(statusCode)
                }
                
                callback(response.convert {
                    return try builder.getValue(from: $0)
                })
            }
        })
    }
}

