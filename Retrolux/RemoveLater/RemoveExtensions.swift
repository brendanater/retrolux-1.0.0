//
//  RemoveExtensions.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/17/17.
//  Copyright © 2017 Christopher Bryan Henderson. All rights reserved.
//

import Foundation


/// An enum for the default REST httpMethods and statusConfirmations ( (Int)->Bool )
//public enum RestfulHTTPMethod {
//    /// defines httpMethod: "GET"    and statusConfirmation: 200.
//    case list
//    /// defines httpMethod: "POST"   and statusConfirmation: 201.
//    case create
//    /// defines httpMethod: "GET"    and statusConfirmation: 200.
//    case retrieve
//    /// defines httpMethod: "PUT"    and statusConfirmation: 200
//    case update
//    /// defines httpMethod: "PATCH"  and statusConfirmation: 200
//    case partialUpdate
//    /// defines httpMethod: "DELETE" and statusConfirmation: 204.
//    case destroy
//
//    public var httpMethod: String {
//        switch self {
//        case .list, .retrieve: return "GET"
//        case .create: return "POST"
//        case .update: return "PUT"
//        case .partialUpdate: return "PATCH"
//        case .destroy: return "DELETE"
//        }
//    }
//
//    public var statusConfirmation: (Int)->Bool {
//        switch self {
//        case .list, .retrieve, .update, .partialUpdate: return { $0 == 200 }
//        case .create: return { $0 == 201 }
//        case .destroy: return { $0 == 204 }
//        }
//    }
//}
//
//extension NSMutableURLRequest {
//    // TODO: uncomment when methods from extensions can be overridden
//    //    /// Sets the httpMethod of the REST method
//    //    open func set(restful: RestfulHTTPMethod) {
//    //        self.httpMethod = restful.httpMethod
//    //    }
//}
//
//extension URLRequest {
//
//    /// Sets the httpMethod of the REST method
//    //    public mutating func set(restful: RestfulHTTPMethod) {
//    //        self.httpMethod = restful.httpMethod
//    //    }
//}

