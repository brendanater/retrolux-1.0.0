//
//  OldBuilder.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation












// MARK: private functions

//extension Builder {
//
//    enum ParseArgumentError: Error {
//        case mismatchTypes(creation: Any.Type, starting: Any.Type)
//        case valueNotBuilderArg(Any.Type)
//        case startingCannotBeNil(Any.Type)
//        case nilArgInCreation
//    }
//
//    internal func parseArguments<A>(creation: A, starting: A) throws -> [(BuilderArg, BuilderArg?)] {
//
//        var array = [(BuilderArg, BuilderArg?)]()
//        try _parseArguments(creation, starting, to: &array)
//        return array
//    }
//
//    private func _parseArguments(_ creation: Any, _ starting: Any?, to array: inout [(BuilderArg, BuilderArg?)]) throws {
//
//        if let creation = creation as? BuilderArg {
//
//            guard let starting = starting as? BuilderArg else {
//                array.append((creation, nil))
//                return
//            }
//
//            guard type(of: creation) == type(of: starting) else {
//                throw ParseArgumentError.mismatchTypes(creation: type(of: creation), starting: type(of: starting))
//            }
//
//            array.append((creation, starting))
//
//        } else if creation is Void {
//            return
//
//        } else if isNil(creation) {
//            throw ParseArgumentError.nilArgInCreation
//
//        } else if let creation = creation as? [AnyHashable : Any], let starting = starting as? [AnyHashable : Any] {
//
//            for (key, creation) in creation {
//                try _parseArguments(creation, starting[key], to: &array)
//            }
//
//        } else if let creation = creation as? [Any], var starting = starting as? [Any] {
//            starting = starting.reversed()
//
//            for creation in creation {
//                try _parseArguments(creation, starting.popLast(), to: &array)
//            }
//
//        } else {
//
//            let creationMirror = Mirror(reflecting: creation).children
//            var startingMirror = Mirror(reflecting: starting ?? ()).children.reversed()
//
//            guard creationMirror.count != 0 else {
//                throw ParseArgumentError.valueNotBuilderArg(type(of: creation))
//            }
//
//            for (_, creation) in creationMirror {
//                try _parseArguments(creation, startingMirror.popLast()?.value, to: &array)
//            }
//        }
//    }
//}


//open func make<Args, Body, Return, T: FactoryRequestProtocol>(_: T.Type, _ path: String, _ method: URLRequest.HTTPMethod, _ creationArgs: Args, body: Body.Type, response: Return.Type) -> T where T.Args == (startingArgs: Args, body: Body), T.Return == Return {
//
//    return T(self.request(path, method), factory: { request, args in
//        // request is done setting values and factory was called
//
//        var request = request.data
//
//        try self._apply(body: args.body, to: &request)
//        try self._apply(args: (creationArgs, args.startingArgs), to: &request)
//
//        return FactoryResponse(request, self.client, self._factoryReturn())
//    })
//}
//
//open func make<Args, Return, T: FactoryRequestProtocol>(_: T.Type, _ path: String, _ method: URLRequest.HTTPMethod, _ creationArgs: Args, response: Return.Type) -> T where T.Args == Args, T.Return == Return {
//
//    return T(self.request(path, method)) { request, startingArgs in
//        // request is done setting values and factory was called
//
//        var request = request.data
//
//        try self._apply(args: (creationArgs, startingArgs), to: &request)
//
//        return FactoryResponse(request, self.client, self._factoryReturn())
//    }
//}
//
//open func make<Body, Return, T: FactoryRequestProtocol>(_: T.Type, _ path: String, _ method: URLRequest.HTTPMethod, body: Body.Type, response: Return.Type) -> T where T.Args == Body, T.Return == Return {
//
//    return T(self.request(path, method)) { request, body in
//        // request is done setting values and factory was called
//
//        var request = request.data
//
//        try self._apply(body: body, to: &request)
//
//        return FactoryResponse(request, self.client, self._factoryReturn())
//    }
//}
//
//open func make<Return, T: FactoryRequestProtocol>(_: T.Type, _ path: String, _ method: URLRequest.HTTPMethod, response: Return.Type) -> T where T.Args == (), T.Return == Return {
//
//    return T(self.request(path, method)) { request, _ in
//        // request is done setting values and factory was called
//
//        return FactoryResponse(request.data, self.client, self._factoryReturn())
//    }
//}
//
//open func makeRequest<Args, Body, Return>(_ path: String, _ method: URLRequest.HTTPMethod, _ creationArgs: Args, body: Body.Type, response: Return.Type) -> FactoryRequest<(startingArgs: Args, body: Body), Return> {
//
//    return self.make(FactoryRequest.self, path, method, creationArgs, body: body, response: response)
//}
//
//open func makeRequest<Args, Return>(_ path: String, _ method: URLRequest.HTTPMethod, _ creationArgs: Args, response: Return.Type) -> FactoryRequest<Args, Return> {
//
//    return self.make(FactoryRequest.self, path, method, creationArgs, response: response)
//}
//
//open func makeRequest<Body, Return>(_ path: String, _ method: URLRequest.HTTPMethod, body: Body.Type, response: Return.Type) -> FactoryRequest<Body, Return> {
//
//    return self.make(FactoryRequest.self, path, method, body: body, response: response)
//}
//
//open func makeRequest<Return>(_ path: String, _ method: URLRequest.HTTPMethod, response: Return.Type) -> FactoryRequest<(), Return> {
//
//    return self.make(FactoryRequest.self, path, method, response: response)
//}


//    open func test() {
//        class User {}
//
//        struct EncoderHint<Type, Encoder> {
//            static func getType() -> Any.Type {
//                return Type.self
//            }
//
//            static func getEncoderType() -> Any.Type {
//                return Encoder.self
//            }
//        }
//
//        typealias JSON<T> = EncoderHint<T, JSONEncoder>
//
////        let request = make(.get("users/{id}/"), args: Path("id"), body: Void.self, response: Int.self)
//        let request = make(.get, "users/{id}/", Path("id"), response: Int.self)
//        _ = request.enqueue(Path("id")) { (response) in
//
//        }
//    }

//    internal func decode(from data: Data) throws -> Void {
//        return ()
//    }
//
//    internal func decode<R>(from data: Data) throws -> R {
//        if R.self == Void.self {
//            return () as! R
//        }
//
//        guard let decoder = decoders.first(where: { $0.supports(type: R.self) }) else {
//            fatalError() // TODO: Error message or throw exception.
//        }
//
//        return try decoder.decode(data)
//    }
//
//    internal func encode(using body: Void) throws -> (contentType: String, body: Data)? {
//        return nil
//    }
//
//    internal func encode<B>(using body: B) throws -> (contentType: String, body: Data)? {
//        if B.self == Void.self {
//            return nil
//        }
//
//        guard let encoder = encoders.first(where: { $0.supports(type: B.self) }) else {
//            throw BuilderCreationError.unsupportedBodyType
//        }
//
//        return try encoder.encode(body: body)
//    }

//    internal func applyArguments<A, B, Q>(creationArgs: A, body: B.Type, requestArgs: Q, to request: inout URLRequest) throws
//    {
//        let startingArgs: A
//        let body: B
//
//        if Q.self == Void.self {
//            startingArgs = () as! A
//            body = () as! B
//        } else if A.self == Void.self && B.self == Q.self {
//            startingArgs = () as! A
//            body = requestArgs as! B
//        } else if A.self == Q.self && B.self == Void.self {
//            startingArgs = requestArgs as! A
//            body = () as! B
//        } else {
//            (startingArgs, body) = requestArgs as! (A, B)
//        }
//
//        // Process HTTP body first, so that arguments may override the Content-Type header if they so wish.
//        let encoded = try self.encode(using: body)
//        request.httpBody = encoded?.body
//        request.setValue(encoded?.contentType, forHTTPHeaderField: "Content-Type")
//
//        // Process non-HTTP body arguments
//
//        for (creation, starting) in try self.parseArguments(creation: creationArgs, starting: startingArgs) {
//
//            try creation.apply(starting: starting, to: &request)
//        }
//    }
//
//    enum ProcessResponseError: Error {
//        case missingBody
//    }
//
//    internal func process<R>(_ d: ResponseData, request: URLRequest) throws -> Response<R> {
//        if R.self == Void.self {
//            return Response(status: d.status, body: () as? R, headers: d.headers, error: d.error, request: request)
//        } else if let body = d.body {
//            let body: R = try self.decode(from: body)
//            return Response(status: d.status, body: body, headers: d.headers, error: d.error, request: request)
//        } else {
//            throw ProcessResponseError.missingBody
//        }
//    }
//
//    internal func _make<A, R, Q>(_ method: URLRequest.HTTPMethod, _ path: String, _ creationArgs: A, body: TopLevelEncoder?, response: R.Type, requestArgs: Q.Type) -> Request<Q, Response<R>, Call> {
//
//
//        // factory == request is done setting values and enqueue was called
//        let factory: (Request<Q, Response<R>, Call>, Q, ResponseData?, @escaping (Response<R>) -> Void) -> Call = { (r, q, s, c) -> Call in
//            var request = r.data
//            try! self.applyArguments(creationArgs: creationArgs, body: type(of: body), requestArgs: q, to: &request)
//            let client = s.map { DryClient($0) } ?? self.client
//            return client.start(request, { (responseData) in
//                let processed: Response<R>
//                do {
//                    processed = try self.process(responseData, request: request)
//                } catch {
//                    processed = Response(
//                        status: responseData.status,
//                        body: nil,
//                        headers: responseData.headers,
//                        error: responseData.error ?? error,
//                        request: request
//                    )
//                }
//                c(processed)
//            })
//        }
//
////        let url = base.appendingPathComponent(method.path)
//        let url = base.appendingPathComponent(path)
//        var request = URLRequest(url: url)
//        request.set(method: method)
////        request.httpMethod = method.method
//        return Request(data: request, simulatedResponse: nil, factory: factory)
//    }


//    class HackEncoder: Encodable {
//        var encoder: Encoder!
//        func encode(to encoder: Encoder) throws {
//            self.encoder = encoder
//        }
//    }
//
//    struct HackDecoder: Decodable {
//        let decoder: Decoder
//        init(from decoder: Decoder) throws {
//            self.decoder = decoder
//        }
//    }
//
//    open class JSONEncoder: Foundation.JSONEncoder, BuilderEncoder {
//        open func supports<T>(type: T.Type) -> Bool {
//            return type is Encodable.Type
//        }
//
//        public func encode<T>(body: T) throws -> (contentType: String, body: Data) {
//            guard let encodable = body as? Encodable else {
//                throw BuilderCreationError.unsupportedBodyType
//            }
//
//            return (
//                contentType: "application/json",
//                body: try encodable.encode()
//            )
//        }
//    }
//
//    open class JSONDecoder: Foundation.JSONDecoder, BuilderDecoder {
//        open func supports<T>(type: T.Type) -> Bool {
//            return type is Decodable.Type
//        }
//
//        open func decode<T>(_ data: Data) throws -> T {
//            guard let decodableType = T.self as? Decodable.Type else {
//                throw BuilderCreationError.unsupportedBodyType // TODO: Throw different error.
//            }
//
//            return try decodableType.decode(from: data) as! T
//        }
//    }





//fileprivate protocol _HasUnderlyingValue {
//    var _underlyingValue: Any {get}
//}
//
//extension Optional: _HasUnderlyingValue {
//
//    var _underlyingValue: Any {
//        if case .some(let wrapped) = self {
//
//            if let wrapped = wrapped as? _HasUnderlyingValue {
//                return wrapped._underlyingValue
//            } else {
//                return wrapped
//            }
//
//        } else {
//
//            return nil as Any? as Any
//        }
//    }
//}
//
//func underlyingValue(_ value: Any?) -> Any {
//    return value._underlyingValue
//}
