//
//  Builder.swift
//  Retrolux
//
//  Created by Christopher Bryan Henderson on 8/21/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation

typealias User = String

///*
// interface Interface {
// @GET("users/{id}/")
// Call<User> getUser(@Path("id") id Int)
//
// // Retrulox can carry logic inside and around each request where Retrofit cannot.
// @GET("users/{id}/")
// Call<User> getNextUser(@Path("id") id Int)
// }
// */
//
//// method 1: (store on init)
///*
// pros:
// 1. Not mutating
// 2. requests are all built at once
// 3. builder is not captured
//
// cons:
// 1. each request must predefine its type (probably good for the frontend)
// 2. each request must be created inside init
// */
//
//struct InterfaceInit {
//    let getUser: (_ id: Int) -> Call<User>
//    let getNextUser: (_ id: Int) -> Call<User>
//    init(_ builder: RequestBuilder) {
//        self.getUser     = builder.get("users/{id}/").wait { try! $0.path("id", $1).build() }
//        self.getNextUser = builder.get("users/{id}/").wait { try! $0.path("id", $1 + 1).build() }
//    }
//}
//let interfaceInit = InterfaceInit(RequestBuilder(base: URL(string: "users.com/")!))
//let callInit    : Call<User> = interfaceInit.getUser(1)
//let callNextInit: Call<User> = interfaceInit.getNextUser(1)
//
//class InterfaceClassInit {
//    let getUser: (_ id: Int) -> Call<User>
//    let getNextUser: (_ id: Int) -> Call<User>
//    init(_ builder: RequestBuilder) {
//        self.getUser     = builder.get("users/{id}/").wait { try! $0.path("id", $1).build() }
//        self.getNextUser = builder.get("users/{id}/").wait { try! $0.path("id", $1 + 1).build() }
//    }
//}
//let interfaceClassInit = InterfaceClassInit(RequestBuilder(base: URL(string: "users.com/")!))
//let callClassInit    : Call<User> = interfaceInit.getUser(1)
//let callNextClassInit: Call<User> = interfaceInit.getNextUser(1)
//
//// method 2: (create lazily)
///*
// pros:
// 1. each request is built lazily
// 2. builder can define variable's type
// 3. can define and store the request on a single line
//
// cons:
// 1. builder is captured
// 2. requests are mutating on get (not a problem if a class)
// 3. more modifiers needed
// */
//
//struct InterfaceLazy {
//    private let builder: RequestBuilder
//    init(_ builder: RequestBuilder) {
//        self.builder = builder.copy()
//    }
//    lazy private(set) var getUser: (_ id: Int) -> Call<User> = self.builder.get("users/{id}/").wait { try! $0.path("id", $1).build() }
//    lazy private(set) var getNextUser = self.builder.get("users/{id}/").wait(for: Int.self, { try! $0.path("id", $1 + 1).build(Call<User>.self) })
//}
//private(set) var interfaceLazy = InterfaceLazy(RequestBuilder(base: URL(string: "users.com/")!))
//let callLazy    : Call<User> = interfaceLazy.getUser(1)
//let callNextLazy: Call<User> = interfaceLazy.getNextUser(1)
//
//class InterfaceClassLazy {
//    private let builder: RequestBuilder
//    init(_ builder: RequestBuilder) {
//        self.builder = builder.copy()
//    }
//    lazy private(set) var getUser: (_ id: Int) -> Call<User> = self.builder.get("users/{id}/").wait { try! $0.path("id", $1).build() }
//    lazy private(set) var getNextUser = self.builder.get("users/{id}/").wait(for: Int.self, { try! $0.path("id", $1 + 1).build(Call<User>.self) })
//}
//let interfaceClassLazy = InterfaceClassLazy(RequestBuilder(base: URL(string: "users.com/")!))
//let callClassLazy    : Call<User> = interfaceClassLazy.getUser(1)
//let callNextClassLazy: Call<User> = interfaceClassLazy.getNextUser(1)
//
////

extension Errors {
    public struct RequestBuilder_ {
        private init() {}
        
        open class UnsupportedEncodeValue: RetypedError<(value: Any, encoders: [FactoryEncoder])> {}
        open class UnsupportedDecodeValue: RetypedError<(value: Any.Type, decoders: [FactoryDecoder])> {}
        
        open class MultipleBodies: RetypedError<MBErrorCase> {}
        public enum MBErrorCase {
            case multipleBodiesSetToBuilder(bodies: [Body])
            case cannotSetFieldBody(Body, presetBody: Body)
            case cannotSetMultipartBody(Body, presetBody: Body)
        }
        
        open class FailedToEncodeFields: RetypedError<(fields: [URLQueryItem], query: String, encoding: String.Encoding)> {}
        
        open class FailedToBuildQuery: RetypedError<(item: URLQueryItem, query: [URLQueryItem])> {}
        
        open class BuildPathFailed: RetypedError<BPFErrorCase> {}
        public enum BPFErrorCase {
            case identifierContainsIdentifier(identifier: String, containsIdentifier: String)
            case emptyIdentifierForValuesCannotFindRanges(values: [CustomStringConvertible])
            case identifierNotFoundInPath(path: String, identifier: String)
            case tooManyIdentifiersFoundInPath(path: String, identifier: String, found: Int, expected: Int)
            case notEnoughIdentifiersFoundInPath(path: String, identifier: String, found: Int, expected: Int)
            case anIdentifierLikelyContainsPartOfAnother(identifiers: [String])
        }
    }
}

open class RequestBuilder: Copyable {
    
    open var base: URL
    open var endpoint: String
    open var method: HTTPMethod
    
    open var paths: [(identifier: String?, value: CustomStringConvertible)]
    open var defaultPathIdentifier: String
    open var headers: HTTPHeaders
    open var queryDestination: QueryDestination?
    /// the query of the request.  (Does not contain the query already in the url).  Might add to fields on build if queryDestination is set
    open var query: [URLQueryItem]
    /// the query to set to as httpBody. Might add to query if queryDestination is set
    open var fields: [URLQueryItem]
    open var multipart: Multipart
    open var multipartFormat: (Multipart) throws -> Body
    open var bodies: [Body]
    
    // request and response building
    open var encoders: [FactoryEncoder]
    open var decoders: [FactoryDecoder]
    open var client: Client
    open var statusConfirmation: ((Int) -> Bool)?
    
    // taskType
    open var download: Bool
    open var resumeData: Data?
    /// if there is data to send, lets the builder know to send it as an upload task
    open var upload: Bool
    
    // handlers
    /// tasks created from this builder should call .resume() before being returned.
    open var autoResume: Bool
    /// for intercepting the request before being sent to the client.
    open var requestInterceptor: ((inout URLRequest) throws -> Void)?
    /// for intercepting the response after callback from the client
    open var responseInterceptor: ((inout Response<AnyData>) throws -> Void)?
    
    /// init builder with a base URL and optional default values.
    public init(
        base: URL,
        endpoint: String = "",
        method: HTTPMethod = .get,
        
        paths: [(identifier: String?, value: CustomStringConvertible)] = [],
        defaultPathIdentifier: String = "%@",
        headers: HTTPHeaders = [:],
        queryDestination: QueryDestination? = nil,
        query: [URLQueryItem] = [],
        fields: [URLQueryItem] = [],
        multipart: Multipart = [],
        multipartFormat: @escaping (Multipart) throws -> Body = { try $0.formData() },
        bodies: [Body] = [],
        
        encoders: [FactoryEncoder] = [JSONEncoder(), JSONSerialization()],
        decoders: [FactoryDecoder] = [JSONDecoder(), JSONSerialization()],
        client: Client = URLSession(configuration: .default, delegate: URLSessionMasterDelegate.shared, delegateQueue: nil),
        statusConfirmation: ((Int) -> Bool)? = nil,
        
        download: Bool = false,
        resumeData: Data? = nil,
        upload: Bool = false,
        
        autoResume: Bool = true,
        requestInterceptor: ((inout URLRequest) throws -> Void)? = nil,
        responseInterceptor: ((inout Response<AnyData>) throws -> Void)? = nil
        ) {
        
        self.base = base
        self.endpoint = endpoint
        self.method = method
        
        self.paths = paths
        self.defaultPathIdentifier = defaultPathIdentifier
        self.headers = headers
        self.queryDestination = queryDestination
        self.query = query
        self.fields = fields
        self.multipart = multipart
        self.multipartFormat = multipartFormat
        self.bodies = bodies
        
        self.encoders = encoders
        self.decoders = decoders
        self.client = client
        self.statusConfirmation = statusConfirmation
        
        self.download = download
        self.resumeData = resumeData
        self.upload = upload
        
        self.autoResume = autoResume
        self.requestInterceptor = requestInterceptor
        self.responseInterceptor = responseInterceptor
    }
    
    public convenience init!(baseURL: String) {
        if let url = URL(string: baseURL) {
            self.init(base: url)
        } else {
            return nil
        }
    }
    
    public required init(copy: RequestBuilder) {
        self.base = copy.base
        self.endpoint = copy.endpoint
        self.method = copy.method
        
        self.paths = copy.paths
        self.defaultPathIdentifier = copy.defaultPathIdentifier
        self.headers = copy.headers
        self.query = copy.query
        self.fields = copy.fields
        self.multipart = copy.multipart
        self.multipartFormat = copy.multipartFormat
        self.bodies = copy.bodies
        
        self.encoders = copy.encoders
        self.decoders = copy.decoders
        self.client = copy.client
        self.statusConfirmation = copy.statusConfirmation
        
        self.download = copy.download
        self.resumeData = copy.resumeData
        self.upload = copy.upload
        
        self.autoResume = copy.autoResume
        self.requestInterceptor = copy.requestInterceptor
        self.responseInterceptor = copy.responseInterceptor
    }
    
    // MARK: starting a request
    // returns a new builder, auto-setting values
    
    /// return a new builder with the method and endpoint
    open func make(_ method: HTTPMethod, _ endpoint: String) -> Self {
        
        return self.copy()
            .method(method)
            .endpoint(endpoint)
    }
    
    /// return a new builder with the restful method and endpoint
    open func make(restful: RestfulHTTPMethod, _ endpoint: String) -> Self {
        
        return self.copy()
            .method(restful: restful)
            .endpoint(endpoint)
    }
    
    // make with default methods
    
    open func get(_ endpoint: String) -> Self {
        return self.make(.get, endpoint)
    }
    
    open func post(_ endpoint: String) -> Self {
        return self.make(.post, endpoint)
    }
    
    open func head(_ endpoint: String) -> Self {
        return self.make(.head, endpoint)
    }
    
    open func put(_ endpoint: String) -> Self {
        return self.make(.put, endpoint)
    }
    
    open func patch(_ endpoint: String) -> Self {
        return self.make(.patch, endpoint)
    }
    
    open func delete(_ endpoint: String) -> Self {
        return self.make(.delete, endpoint)
    }
    
    // make with default restful methods
    
    open func list(_ endpoint: String) -> Self {
        return self.make(restful: .list, endpoint)
    }
    
    open func create(_ endpoint: String) -> Self {
        return self.make(restful: .create, endpoint)
    }
    
    open func retrieve(_ endpoint: String) -> Self {
        return self.make(restful: .retrieve, endpoint)
    }
    
    open func update(_ endpoint: String) -> Self {
        return self.make(restful: .update, endpoint)
    }
    
    open func partialUpdate(_ endpoint: String) -> Self {
        return self.make(restful: .partialUpdate, endpoint)
    }
    
    open func destroy(_ endpoint: String) -> Self {
        return self.make(restful: .destroy, endpoint)
    }
    
    // MARK: method
    
    open func method(_ method: HTTPMethod) -> Self {
        
        self.method = method
        
        return self
    }
    
    open func method(restful: RestfulHTTPMethod) -> Self {
        
        return self
            .method(restful.httpMethod)
            .statusConfirmation(restful.statusConfirmation)
    }
    
    // MARK: statusConfirmation
    
    open func statusConfirmation(_ statusConfirmation: @escaping (Int) -> Bool) -> Self {
        
        self.statusConfirmation = statusConfirmation
        
        return self
    }
    
    // MARK: endpoint
    
    open func endpoint(_ newEndpoint: String) -> Self {
        
        self.endpoint = newEndpoint
        
        return self
    }
    
    // MARK: path
    
    open func path(exactly identifier: String? = nil, _ formatWith: CustomStringConvertible) -> Self {
        
        self.paths.append((identifier, formatWith))
        
        return self
    }
    
    open func path(_ identifier: String, _ formatWith: CustomStringConvertible) -> Self {
        
        self.paths.append(("{\(identifier)}", formatWith))
        
        return self
    }
    
    open func path(_ formatWith: [CustomStringConvertible]) -> Self {
        
        for formatWith in formatWith {
            _ = self.path(formatWith)
        }
        
        return self
    }
    
    // TODO: add other path functions
    
    // MARK: query
    
    open func queryDestination(_ destination: QueryDestination) -> Self {
        
        self.queryDestination = destination
        
        return self
    }
    
    open func query(_ name: String, value: String?) -> Self {
        
        self.query.append(URLQueryItem(name, value))
        
        return self
    }
    
    // TODO: add more query methods
    
    // MARK: field
    
    open func field(_ name: String, value: String?) -> Self {
        
        self.fields.append(URLQueryItem(name, value))
        
        return self
    }
    
    // TODO: add more field methods
    
    // MARK: body
    
    open func body(_ body: Body) -> Self {
        
        self.bodies.append(body)
        
        return self
    }
    
    open func body<T>(_ value: T) throws -> Self {
        
        return try self.body(self.buildEncodedBody(value))
    }
    
    // MARK: part
    
    
    open func part(_ part: Part) -> Self {
        self.multipart.parts.append(part)
        return self
    }
    
    open func part(_ name: String, _ body: Body, fileName: String? = nil) -> Self {
        return self.part(Part(name: name, body, filename: fileName))
    }
    
    open func parts(_ parts: [Part]) -> Self {
        
        for part in parts {
            _ = self.part(part)
        }
        
        return self
    }
    
    // MARK: header
    
    open func header(_ field: HTTPHeaders.Field, _ value: String) -> Self {
        
        self.headers[field] = value
        
        return self
    }
    
    open func headers(_ httpHeaders: HTTPHeaders) -> Self {
        
        for (field, value) in httpHeaders {
            _ = self.header(field, value)
        }
        
        return self
    }

    // MARK: wait

    open func wait<U>(_ didWait: @escaping (RequestBuilder) -> U) -> () -> U {
        return { [builder = self.copy()] in
            didWait(builder.copy())
        }
    }

    open func wait<U>(_ didWait: @escaping (RequestBuilder) throws -> U) -> () throws -> U {
        return { [builder = self.copy()] in
            try didWait(builder.copy())
        }
    }

    open func wait<T, U>(for args: T.Type = T.self, _ apply: @escaping (RequestBuilder, T) -> U) -> (T) -> U {

        return { [builder = self.copy()] in
            apply(builder.copy(), $0)
        }
    }

    open func wait<T, U>(for args: T.Type = T.self, _ apply: @escaping (RequestBuilder, T) throws -> U) -> (T) throws -> U {

        return { [builder = self.copy()] in
            try apply(builder.copy(), $0)
        }
    }
    
    // MARK: build
    
    //
    
    open func buildEncodedBody<T>(_ value: T) throws -> Body {
        
        for encoder in self.encoders {
            if encoder.supports(value) {
                return try encoder.encode(value)
            }
        }
        
        if value is RequestBody {
            return try (value as! RequestBody).requestBody()
        }
        
        throw Errors.RequestBuilder_.UnsupportedEncodeValue("No encoders could support/encode \(type(of: value)).", (value: value, encoders: self.encoders))
    }
    
    open func buildDecodeHandler<T>(for value: T.Type) -> (Response<AnyData>) throws -> T {
        
        // because the decode happens an indeterminate time later, it has to capture the decoders
        
        return { [decoders = self.decoders] in
            
            for decoder in decoders {
                if decoder.supports(value) {
                    return try decoder.decode($0)
                }
            }
            
            if T.self is ResponseBody.Type, T.self != ResponseBody.self {
                return try (T.self as! ResponseBody.Type).init(from: $0) as! T
            }
            
            throw Errors.RequestBuilder_.UnsupportedDecodeValue("No decoders could support/decode \(value)", (value: value, decoders: decoders))
        }
    }
    
    //
    
    open func buildTaskType(with data: AnyData? = nil) -> TaskType {
        
        // .dataTask has lowest priority
        var taskType: TaskType = .dataTask
        
        // .downloadTask has second
        if self.download {
            taskType = .downloadTask
        }
        
        // .uploadTask has third
        if let data = data, self.upload || data.isURL {
            taskType = .uploadTask(data)
        }
        
        // .resumeData has highest priority
        if let resumeData = self.resumeData {
            taskType = .resumeTask(resumeData)
        }
        
        return taskType
    }
    
    //
    
    open func buildBody() throws -> Body? {
        
        var body = self.bodies.first
        
        if self.bodies.count > 1 {
            throw Errors.RequestBuilder_.MultipleBodies(
                "Multiple bodies set to \(type(of: self)).",
                .multipleBodiesSetToBuilder(bodies: self.bodies),
                recovery: "Set only one body."
            )
        }
        
        if let fieldBody = try self.buildFieldBody() {
            
            if let body = body {
                throw Errors.RequestBuilder_.MultipleBodies(
                    "Cannot set a field body when there is already a body set.",
                    .cannotSetFieldBody(fieldBody, presetBody: body),
                    recovery: "Remove fields or remove body.  Remember that, by default, queryDestination might be merging query with fields; Make sure queryDestination is set to nil or .queryString."
                )
            }
            
            body = fieldBody
        }
        
        if let multipartBody = try self.buildMultipartBody() {
            
            if let body = body {
                throw Errors.RequestBuilder_.MultipleBodies(
                    "Cannot set a multipart body when there is already a body set.",
                    .cannotSetMultipartBody(multipartBody, presetBody: body),
                    recovery: "Remove multipart parts or remove body."
                )
            }
            
            body = multipartBody
        }
        
        return body
    }
    
    //
    
    open func buildMultipartBody() throws -> Body? {
        return try self.multipart.isEmpty ? nil : self.multipartFormat(self.multipart)
    }
    
    //
    
    open func buildFieldBody() throws -> Body? {
        
        let fields = self.queryDestination.map { $0.shouldSetToBody(withMethod: self.method) ? self.fields + self.query : [] } ?? self.fields
        
        return try self.buildQuery(fields).map { query in
            
            let encoding = self.queryDestination?.encoding ?? .utf8
            
            guard let data = query.data(using: encoding, allowLossyConversion: false) else {
                
                throw Errors.RequestBuilder_.FailedToEncodeFields("Failed to encode field query to data", (fields, query, encoding))
            }
            
            return Body(data, [.contentType : "application/x-www-form-urlencoded" + (encoding.charset.map { "; charset=\($0)" } ?? ""), .contentLength : data.count.description])
        }
    }
    
    //
    
    public static let queryUnescapedCharacterSet: CharacterSet = {
        
        var unescapedCharacters = CharacterSet.urlQueryAllowed
        unescapedCharacters.remove(charactersIn: ":#[]@" + "!$&'()*+,;=")
        
        return unescapedCharacters
    }()
    
    open func buildQuery(_ queryItems: [URLQueryItem]? = nil, addTo presetQuery: String? = nil) throws -> String? {
        
        func _result(_ query: String?) -> String? {
            
            switch (presetQuery, query) {
                
            case (.some(let presetQuery), .some(let query)):
                return presetQuery + "&" + query
                
            case (.some(let presetQuery), .none):
                return presetQuery
                
            case (.none, .some(let query)):
                return query
                
            case (.none, .none):
                return nil
            }
        }
        
        let queryItems = queryItems ?? self.queryDestination.map { $0.shouldSetToQuery(withMethod: self.method) ? self.fields + self.query : [] } ?? self.query
        
        if queryItems.isEmpty {
            return _result(nil)
        }
        
        let query = try queryItems.map {
            
            guard
                let name = $0.name.addingPercentEncoding(withAllowedCharacters: type(of: self).queryUnescapedCharacterSet),
                let value = ($0.value ?? "").addingPercentEncoding(withAllowedCharacters: type(of: self).queryUnescapedCharacterSet)
            else {
                throw Errors.RequestBuilder_.FailedToBuildQuery("Failed to add percent encoding to query item", ($0, queryItems))
            }
            
            return "\(name)=\(value)"
            
        }.joined(separator: "&")
        
        return _result(query)
    }
    
    //
    
    /// RequestBuilder: Formats the path, adding values for each identifier (defaulting to the defaultPathIdentifier) in the same order that they appear on the path.  Path must have equal amount of identifiers on path to values and not contain part or all of another identifier.
    open func buildPath(formatting originalPath: String) throws -> String {
        
        if self.paths.isEmpty {
            return originalPath
        }
        
        var path = originalPath
        
        var valuesForIdentifier: [String: [CustomStringConvertible]] = [:]
        
        for (identifier, value) in self.paths {
            valuesForIdentifier.appendElement(value, forKey: identifier ?? self.defaultPathIdentifier)
        }
        
        var replacementIdentifier: String! = nil
        var sortableValues: [(offset: Int, value: CustomStringConvertible)] = []
        
        for (identifier, values) in valuesForIdentifier {
            
            // remove identifier to keep from checking if it contains itself
            valuesForIdentifier.removeValue(forKey: identifier)
            
            try valuesForIdentifier.forEach({
                if $0.key.contains(identifier) {
                    throw Errors.RequestBuilder_.BuildPathFailed("A path identifier contains another identifier.", .identifierContainsIdentifier(identifier: $0.key, containsIdentifier: identifier))
                }
            })
            
            if identifier.isEmpty {
                throw Errors.RequestBuilder_.BuildPathFailed("Cannot find ranges of empty identifier in path", .emptyIdentifierForValuesCannotFindRanges(values: values))
            }
            
            let ranges = originalPath.ranges(of: identifier)
            
            guard ranges.count == values.count else {
                if ranges.count == 0 {
                    throw Errors.RequestBuilder_.BuildPathFailed(
                        "Identifier (\(identifier.debugDescription)) not found in path: \(originalPath)",
                        .identifierNotFoundInPath(path: originalPath, identifier: identifier)
                    )
                } else if ranges.count > values.count {
                    throw Errors.RequestBuilder_.BuildPathFailed(
                        "Too many identifiers (\(identifier.debugDescription)) found in path: \(originalPath).  Expected: \(values.count)",
                        .tooManyIdentifiersFoundInPath(path: originalPath, identifier: identifier, found: ranges.count, expected: values.count)
                    )
                } else {
                    throw Errors.RequestBuilder_.BuildPathFailed(
                        "Not enough identifiers (\(identifier.debugDescription)) found in path: \(originalPath).  Expected: \(values.count)",
                        .notEnoughIdentifiersFoundInPath(path: originalPath, identifier: identifier, found: ranges.count, expected: values.count)
                    )
                }
            }
            
            // if an identifier contains part of another, it is not caught. ( "test%@" technically has "test%" and "%@", but neither contains the other. )
            
            // set all identifiers to a central identifier
            path = path.replacingOccurrences(of: identifier, with: replacementIdentifier ?? { replacementIdentifier = identifier ; return identifier }())
            
            // the encoded offset will be the sortable for which values to replace
            sortableValues.append(contentsOf: zip(ranges, values).map { ($0.0.lowerBound.encodedOffset, $0.1) } as [(offset: Int, value: CustomStringConvertible)])
            
            // put identifier back to check if it contains the next identifiers
            valuesForIdentifier[identifier] = []
        }
        
        var components = path.components(separatedBy: replacementIdentifier)
        
        let values = sortableValues.sorted(by: { $0.offset < $1.offset }).map { $0.value }
        
        guard values.count == components.count - 1 else {
            throw Errors.RequestBuilder_.BuildPathFailed(
                "Uneven identifiers to values. One or more path identifiers likely contains part of another identifier.",
                .anIdentifierLikelyContainsPartOfAnother(identifiers: valuesForIdentifier.map { $0.key }),
                recovery: "Check for identifiers that may conflict and check the path for spots where identifiers overlap.  Example: 'id%' conflicts with '%@' and the path contains 'id%@'."
            )
        }
        
        path.removeAll()
        
        for value in values {
            path.append(components.removeFirst() + value.description)
        }
        
        path.append(components.removeLast())
        
        return path
    }
    
    //
    
    open func buildURL() throws -> URL {
        
        var components = self.base.appendingPathComponent(self.endpoint).components!
        
        components.path = try self.buildPath(formatting: components.path)
        
        components.query = try self.buildQuery(addTo: components.query)
        
        return components.url!
    }
    
    //
    
    open func buildRequest() throws -> (urlRequest: URLRequest, taskType: TaskType) {
        
        var urlRequest = try URLRequest(url: self.buildURL())
        
        urlRequest.set(httpMethod: self.method)
        
        let body = try self.buildBody()
        
        var headers = self.headers
        for (field, value) in body?.httpHeaders ?? [:] {
            headers[field] = value
        }
        
        urlRequest.httpHeaders = headers
        
        let taskType = self.buildTaskType(with: body?.data)
        
        if case .dataTask = taskType {
            urlRequest.httpBody = body?.data.dataValue
        }
        
        try self.requestInterceptor?(&urlRequest)
        
        return (urlRequest, taskType)
    }

    open func buildConfirmation() -> (inout Response<AnyData>) throws -> Void {

        return { [statusConfirmation = self.statusConfirmation] in

            try self.responseInterceptor?(&$0)

            if $0.isValid,
                let statusCode = $0.statusCode,
                let statusConfirmation = statusConfirmation {

                $0.isValid = statusConfirmation(statusCode)
            }
        }
    }

    open func build<T: CallAdaptable>(_ call: T.Type = T.self) throws -> T {

        let value = T.Return.self
        let (urlRequest, taskType) = try self.buildRequest()
        
        return T(
            Call<T.Return>(urlRequest, autoResume: self.autoResume) { [client = self.client, confirmation = self.buildConfirmation(), decodeHandler = self.buildDecodeHandler(for: value)] in
                
                let callback = $0.callback
                
                return client.createTask(taskType, with: $0.urlRequest, delegate: $0.delegate) {

                    var response = $0

                    do {
                        try confirmation(&response)
                    } catch {
                        response.error = response.error ?? error
                        response.isValid = false
                    }

                    callback(response.convert(decodeHandler))
                }
            }
        )
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//open class RequestBuilder: Copyable {
//
//    open var base: URL
//    open var endpoint: String
//    /// adds endpoint to base using appendingPathComponent(_:)
//    open var url: URL {
//        return self.base.appendingPathComponent(self.endpoint)
//    }
//    open var method: HTTPMethod
//    open var headers: HTTPHeaders
//    open var queryItems: [URLQueryItem]
//    open var queryDestination: QueryDestination
//    open var body: Body?
//    open var factoryEncoders: [FactoryEncoder]
//    open var factoryDecoders: [FactoryDecoder]
//    open var client: Client
//    open var statusConfirmation: ((Int) -> Bool)?
//    open var download: (willDownload: Bool, resumeData: Data?)
//    open var upload: Bool
//    open var autoResume: Bool
//    open var requestInterceptor: ((inout URLRequest) throws -> Void)?
//    open var responseInterceptor: ((inout Response<AnyData>) throws -> Void)?
//
//    public init(base: URL) {
//        self.base = base
//        self.endpoint = ""
//        self.method = .get
//        self.headers = [:]
//        self.queryItems = []
//        self.queryDestination = .methodDependentUTF8
//        self.body = nil
//        self.factoryEncoders = [JSONEncoder(), JSONSerialization()]
//        self.factoryDecoders = [JSONDecoder(), JSONSerialization()]
//        self.client = URLSession(configuration: .default, delegate: URLSessionMasterDelegate.shared, delegateQueue: nil)
//        self.statusConfirmation = nil
//        self.download = (false, nil)
//        self.upload = false
//        self.autoResume = true
//        self.requestInterceptor = nil
//        self.responseInterceptor = nil
//    }
//
//    public convenience init?(base: String) {
//        if let url = URL(string: base) {
//            self.init(base: url)
//        } else {
//            return nil
//        }
//    }
//
//    public required init(copy: RequestBuilder) {
//        self.base = copy.base
//        self.endpoint = copy.endpoint
//        self.method = copy.method
//        self.headers = copy.headers
//        self.queryItems = copy.queryItems
//        self.queryDestination = copy.queryDestination
//        self.body = copy.body
//        self.factoryEncoders = copy.factoryEncoders
//        self.factoryDecoders = copy.factoryDecoders
//        self.client = copy.client
//        self.statusConfirmation = copy.statusConfirmation
//        self.download = copy.download
//        self.upload = copy.upload
//        self.autoResume = copy.autoResume
//        self.requestInterceptor = copy.requestInterceptor
//        self.responseInterceptor = copy.responseInterceptor
//    }
//
//    public enum BuilderError: Error {
//
//        case invalidValue(Any, debugDescription: String, underlyingError: Error?)
//        case buildFailed(debugDescription: String, underlyingError: Error?)
//    }
//
//    // MARK: prefix method: modify or get the method
//
//    open func method(_ method: HTTPMethod) -> Self {
//        self.method = method
//        return self
//    }
//
//    open func method(restful: RestfulHTTPMethod) -> Self {
//        self.method = HTTPMethod(restful.httpMethod)!
//        self.statusConfirmation = restful.statusConfirmation
//        return self
//    }
//
//    // MARK: prefix path: modify the path on the url
//
//    // Note: path sets all path args at once, because, it doesn't know about all path args
//
//    /// format endpoint the Swift CVarArg way
//    open func path(_ args: CustomStringConvertible...) -> Self {
//        return self.path(args)
//    }
//
//    /// format endpoint the Swift CVarArg way
//    open func path(_ args: [CustomStringConvertible]) -> Self {
//        self.endpoint.format(args.map { $0.description.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? { fatalError("Failed to percent encode path arg: '\($0)'")}($0) })
//        return self
//    }
//
//    /// format endpoint the Retrofit way
//    open func path(_ args: (identifier: String, value: String)...) -> Self {
//        // TODO: Find out how Retrofit does this
//        fatalError("split value for each identifier and join again at the same time without using .replacingOccurrences(of: , with: ), because each value may have the identifer of the other args in it.")
//    }
//
//    /// format endpoint the Retrofit way with one arg
//    open func path(_ identifier: String, _ value: String) -> Self {
//        return self.path((identifier, value))
//    }
//
//    // MARK: prefix query: add one or more to self.query or modify self.url.query
//
//    open func query(_ name: String, _ value: String?) -> Self {
//        self.queryItems.append(URLQueryItem(name, value))
//        return self
//    }
//
//    open func query(_ queryItems: [URLQueryItem]) -> Self {
//        self.queryItems += queryItems
//        return self
//    }
//
//    open func query(destination: QueryDestination) -> Self {
//        // doesn't throw "body already set here", because, .methodDependent is variable
//        self.queryDestination = destination
//        return self
//    }
//
//    // MARK: prefix body: set or modify the body
//
//    open func body(_ body: Body) throws -> Self {
//        guard self.body == nil else {
//            throw BuilderError.invalidValue(body, debugDescription: "Builder already has a body", underlyingError: nil)
//        }
//        self.body = body
//        return self
//    }
//
//    open func body<T>(_ value: T) throws -> Self {
//
//        for encoder in self.factoryEncoders {
//            if encoder.supports(value) {
//                return try self.body(encoder.encode(value))
//            }
//        }
//
//        if let value = value as? RequestBody {
//            return try self.body(value.requestBody())
//        }
//
//        throw BuilderError.invalidValue(value, debugDescription: "No FactoryEncoders support value in \(self)", underlyingError: nil)
//    }
//
//    // MARK: prefix header: replace or add a header
//
//    open func header(_ field: HTTPHeaders.Field, _ value: String) -> Self {
//        self.headers[field] = value
//        return self
//    }
//
//    // MARK: prefix headers: replace or add multiple headers
//
//    open func headers(_ headers: HTTPHeaders) -> Self {
//        for (field, value) in headers {
//            _ = self.header(field, value)
//        }
//        return self
//    }
//
//    // MARK: prefix make: copy or make a new self with default values
//
//    open func make(_ method: HTTPMethod, _ endpoint: String, _ args: CustomStringConvertible...) -> Self {
//        return self.make(method, endpoint, args)
//    }
//
//    open func make(_ method: HTTPMethod, _ endpoint: String, _ args: [CustomStringConvertible]) -> Self {
//
//        let builder = self.copy()
//        builder.endpoint = endpoint
//        return builder.method(method).path(args)
//    }
//
//    open func make(_ method: HTTPMethod, _ newBase: URL) -> Self {
//
//        let builder = self.copy()
//        builder.base = newBase
//        return builder.method(method)
//    }
//
//    // MARK: prefix apply: apply part of self to an object
//    // Note: apply should return Self and be @discardableResult to follow pattern
//
//    @discardableResult
//    open func applyWillDownload(to taskType: inout TaskType) -> Self {
//
//        if self.download.willDownload {
//            if let resumeData = self.download.resumeData {
//                taskType = .resumeTask(resumeData)
//
//                // shouldn't override .uploadTask with .downloadTask
//            } else if case .uploadTask(_) = taskType {
//            } else {
//                taskType = .downloadTask
//            }
//        }
//
//        return self
//    }
//
//    @discardableResult
//    open func applyQuery(to request: inout URLRequest) throws -> Self {
//
//        if self.queryItems.isEmpty {
//            return self
//        }
//
//        func setQueryItems() throws {
//
//            guard (request.urlComponents?.queryItems = self.queryItems) != nil else {
//                throw BuilderError.invalidValue(
//                    request,
//                    debugDescription: "Cannot set queryItems to a request with no urlComponents. Make sure that the request has a URL and urlComponents can be initialized from it",
//                    underlyingError: nil
//                )
//            }
//        }
//
//        func setHTTPBody(_ encoding: String.Encoding) throws {
//
//            var components = URLComponents(string: "?")!
//
//            components.queryItems = self.queryItems
//
//            guard let data = components.url?.query?.data(using: encoding) else {
//                throw BuilderError.invalidValue(self.queryItems, debugDescription: "Failed to convert query to data", underlyingError: nil)
//            }
//
//            guard !request.isHTTPBodySet && self.body == nil else {
//                throw BuilderError.invalidValue(
//                    self.queryItems,
//                    debugDescription: "Cannot set a form url encoded body when there is already a body set.  Set .queryDestination to QueryDestination.queryString or remove .queryItems",
//                    underlyingError: nil
//                )
//            }
//
//            request.httpBody = data
//            request.httpHeaders[.contentType] = "application/x-www-form-urlencoded" + (encoding.charset.map { "; charset=\($0)" } ?? "")
//            request.httpHeaders[.contentLength] = data.count.description
//        }
//
//        switch self.queryDestination {
//
//        case .methodDependent(let encoding):
//
//            switch request.httpMethod_enum ?? .get {
//
//            case .get, .head, .delete:
//                try setQueryItems()
//
//            default:
//                try setHTTPBody(encoding)
//            }
//
//        case .queryString:
//            try setQueryItems()
//
//        case .httpBody(let encoding):
//            try setHTTPBody(encoding)
//        }
//
//        return self
//    }
//
//    @discardableResult
//    open func applyBody(to urlRequest: inout URLRequest, taskType: inout TaskType) throws -> Self {
//
//        if let body = self.body {
//
//            switch body.data {
//
//            case .data(let data):
//
//                func setBody() throws {
//
//                    // TODO: find out if upload from data overrides the URLRequest's .httpBody or if it adds the upload on top of it
//
//                    guard !urlRequest.isHTTPBodySet else {
//                        throw BuilderError.invalidValue(urlRequest, debugDescription: "Cannot set httpBody to a request that already has an httpBody", underlyingError: nil)
//                    }
//                    urlRequest.httpBody = data
//                }
//
//                if self.upload {
//                    if case .resumeTask(_) = taskType {
//                        try setBody()
//                    } else {
//                        taskType = .uploadTask(body.data)
//                    }
//                } else {
//                    try setBody()
//                }
//
//            case .url(_, _):
//                if case .resumeTask(_) = taskType {
//                    throw BuilderError.invalidValue(
//                        body,
//                        debugDescription: "Cannot overwrite taskType: .downloadTaskWithResumeData(_) with .uploadTask(URL). Remove .body or .download.resumeData",
//                        underlyingError: nil
//                    )
//                } else {
//                    taskType = .uploadTask(body.data)
//                }
//            }
//
//            for (field, value) in body.httpHeaders {
//                urlRequest.httpHeaders[field] = value
//            }
//        }
//
//        return self
//    }
//
//    // MARK: prefix wait: convert to something else to break and wait for something or just wait til later
//
//    open func wait<U>(_ didWait: @escaping (RequestBuilder) -> U) -> () -> U {
//        return { [builder = self.copy()] in
//            didWait(builder.copy())
//        }
//    }
//
//    open func wait<U>(_ didWait: @escaping (RequestBuilder) throws -> U) -> () throws -> U {
//        return { [builder = self.copy()] in
//            try didWait(builder.copy())
//        }
//    }
//
//    open func wait<T, U>(for args: T.Type, _ apply: @escaping (RequestBuilder, T) -> U) -> (T) -> U {
//
//        return { [builder = self.copy()] in
//            apply(builder.copy(), $0)
//        }
//    }
//
//    open func wait<T, U>(for args: T.Type, _ apply: @escaping (RequestBuilder, T) throws -> U) -> (T) throws -> U {
//
//        return { [builder = self.copy()] in
//            try apply(builder.copy(), $0)
//        }
//    }
//
//    // MARK: prefix build: build a value from self
//
//    open func buildConfirmation() -> (inout Response<AnyData>) throws -> Void {
//
//        return { [statusConfirmation = self.statusConfirmation] in
//
//            try self.responseInterceptor?(&$0)
//
//            if $0.isValid,
//                let statusCode = $0.statusCode,
//                let statusConfirmation = statusConfirmation {
//
//                $0.isValid = statusConfirmation(statusCode)
//            }
//        }
//    }
//
//    open func buildResponseConversion<T>(for value: T.Type) -> (Response<AnyData>) throws -> T? {
//
//        return { [decoders = self.factoryDecoders] in
//
//            var errors: [Error] = []
//
//            for decoder in decoders {
//                if let supports = decoder.supports(value) {
//
//                    if supports {
//                        return try decoder.decode($0)
//                    } else {
//                        continue
//                    }
//                } else {
//                    do {
//                        return try decoder.decode($0)
//                    } catch {
//                        errors.append(error)
//                        continue
//                    }
//                }
//            }
//
//            if let valueMetaType = T.self as? ResponseBody.Type, T.self != ResponseBody.self {
//                return try valueMetaType.init(from: $0) as? T
//            }
//
//            if errors.isEmpty {
//                throw BuilderError.invalidValue(value, debugDescription: "No FactoryDecoders support value", underlyingError: nil)
//            } else {
//                throw BuilderError.invalidValue(value, debugDescription: "No FactoryDecoders could decode value", underlyingError: nil)
//            }
//        }
//    }
//
//    open func buildRequest() throws -> (urlRequest: URLRequest, taskType: TaskType) {
//
//        var taskType: TaskType = .dataTask
//
//        var urlRequest = URLRequest(url: self.url)
//
//        urlRequest.httpHeaders = self.headers
//        urlRequest.httpMethod_enum = self.method
//
//        try self
//            .applyWillDownload(to: &taskType)
//            .applyBody(to: &urlRequest, taskType: &taskType)
//            .applyQuery(to: &urlRequest)
//            .requestInterceptor?(&urlRequest)
//
//        return (urlRequest, taskType)
//    }
//
//    open func buildCall<T: CallAdaptable>(_: T.Type = T.self) throws -> T {
//
//        // TODO: find a way to keep self.client from deinitializing when call is created, so that delegate methods continue to be called
//
//        let value = T.Return.self
//
//        let (urlRequest, taskType) = try self.buildRequest()
//        return T(Call<T.Return>(urlRequest, autoResume: self.autoResume) { [client = self.client, confirmation = self.buildConfirmation(), responseConversion = self.buildResponseConversion(for: value)] in
//            let (urlRequest, delegate, callback) = $0
//            return client.createTask(taskType, with: urlRequest, delegate: delegate) {
//                // reference to client will keep it from deinitializing until call.enqueue is used and call is not stored
//
//                var response = $0
//
//                do {
//                    try confirmation(&response)
//                } catch {
//                    response.error = response.error ?? error
//                    response.isValid = false
//                }
//
//                callback(response.convert(responseConversion))
//            }
//        })
//    }
//}

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






