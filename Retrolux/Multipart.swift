//
//  Part.swift
//  Retrolux
//
//  Created by Brendan Henderson on 11/13/17.
//
//
//  MultipartFormData.swift
//
//  Copyright (c) 2014-2017 Alamofire Software Foundation (http://alamofire.org/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/**
 Content-Type: multipart/#{subType}; boundary=simple boundary
 Content-Length: 123768
 
 This is the preamble.  It is to be ignored, though it
 is a handy place for mail composers to include an
 explanatory note to non-MIME compliant readers.
 --simple boundary
 
 This is implicitly typed plain ASCII text.
 It does NOT end with a linebreak.
 --simple boundary
 Content-type: text/plain; charset=us-ascii
 
 This is explicitly typed plain ASCII text.
 It DOES end with a linebreak.
 
 --simple boundary--
 This is the epilogue.  It is also to be ignored.
 */
public struct Multipart {
    
    /// the headers to add to the Content-Type, Content-Length,
    public var defaultHTTPHeaders: HTTPHeaders = [:]
    
    public var boundary: String = Multipart.randomBoundary()
    
    public var preamble: Data?
    public var epilogue: Data?
    
    public var parts: [Part]
    
    /// the max size to load to memory before moving data to a temporary file, default = just under 40MB
    public var maxMemorySize: Int64 = 40_000_000
    
    public func estimatedContentLength() throws -> Int64 {
        
        let boundaryCount = try Int64(self.getAndValidateBoundary().data(using: .utf8)?.count ?? 0)
        
        let count1 = Int64(self.preamble?.count ?? 0)
        let count2 = Int64(self.epilogue?.count ?? 0)
        
        return try self.parts.reduce(count1 + count2, { try $0 + $1.body.data.contentLength() + boundaryCount + Int64(Multipart.headerData(for: $1.body.httpHeaders).count) })
    }
    
    public init() {
        self.parts = []
    }
    
    public init<S>(_ elements: S) where S : Sequence, S.Element == Part {
        self.parts = elements.map {$0}
    }
    
    public init(_ parts: Part...) {
        self.init(parts)
    }
    
    public init(_ parts: [Part]) {
        self.parts = parts
    }
    
    // MARK: Part
    
    public struct Part {
        
        public var name: String
        public var body: Body
        public var filename: String?
        
        public init(name: String, _ body: Body, filename: String? = nil) {
            
            self.name = name
            self.body = body
            self.filename = filename
        }
        
        /// sets the content disposition header with self.body.httpHeaders
        public func formDataHeaders() -> HTTPHeaders {
            
            var httpHeaders = self.body.httpHeaders
            
            httpHeaders[.contentDisposition] = "form-data; name=\(self.name.quoted)" + (self.filename.map { "; filename=\($0.quoted)" } ?? "")
            
            return httpHeaders
        }
    }
    
    // MARK: apply
    
    public func formData() throws -> Body {
        
        var data = Data()
        let temporaryURL = URL.temporaryFileURL()
        var contentLength: Int = 0
        var writtenToURL = false
        
        let crlfData = Multipart.crlf.data(using: .utf8)!
        
        let boundary = try self.getAndValidateBoundary()
        
        let encapsulatedBoundary = ("--\(boundary)").data(using: .utf8)! + crlfData
        let finalBoundary = ("--\(boundary)--").data(using: .utf8)!
        
        if let preamble = self.preamble {
            data.append(preamble + crlfData)
        }
        
        for part in self.parts {
            
            data.append(encapsulatedBoundary)
            
            try data.append(Multipart.headerData(for: part.formDataHeaders()))
            
            switch part.body.data {
                
            case .data(let d):
                data.append(d)
                
            case .url(let url, temporary: let isTemporary):
                guard let stream = InputStream(url: url) else {
                    throw MultipartError.failedToGetStream(forPart: part)
                }
                
                try data.append(stream.data(maxMemorySize: self.maxMemorySize - Int64(data.count), willReset: {
                    
                    data.append($0)
                    $0.removeAll()
                    
                    try data.write(to: temporaryURL)
                    
                    contentLength += data.count
                    data.removeAll()
                    
                    writtenToURL = true
                    
                    return self.maxMemorySize
                }))
                
                try? url.removeFile(ifTemporary: isTemporary)
            }
            
            data.append(crlfData)
        }
        
        data.append(finalBoundary)
        
        if let epilogue = self.epilogue {
            data.append(crlfData + epilogue)
        }
        
        contentLength += data.count
        
        if writtenToURL {
            try data.write(to: temporaryURL)
            data.removeAll()
        }
        
        var headers: HTTPHeaders = self.defaultHTTPHeaders
        
        headers[.contentLength] = contentLength.description
        headers[.contentType] = "multipart/form-data; boundary=\(boundary)"
        
        if writtenToURL {
            return Body(.url(temporaryURL, temporary: true), headers)
        } else {
            return Body(.data(data), headers)
        }
    }
    
    public enum MultipartError: Error {
        
        case failedToGetHeaderData(from: HTTPHeaders)
        case invalidBoundary(String)
        case failedToGetStream(forPart: Part)
    }
    
    /**
     header data in format:
     field ": " value
     joined(separator: crlf)
     + crlf + crlf
     .data(using: .utf8, allowLossyConversion: false) ?? throw
     */
    public static func headerData(for httpHeaders: HTTPHeaders) throws -> Data {
        
        guard let data = (
            httpHeaders.allFields
            .map({ "\($0.key): \($0.value)" })
            .joined(separator: Multipart.crlf)
            + Multipart.crlf
            + Multipart.crlf
            ).data(using: .utf8, allowLossyConversion: false)
        else {
            throw MultipartError.failedToGetHeaderData(from: httpHeaders)
        }
        
        return data
    }
    
    public func getAndValidateBoundary() throws -> String {
        
        if  self.boundary.isEmpty
         || self.boundary.contains(where: { !Multipart.boundaryAllowedCharacters.contains($0) })
         || self.boundary.count > 70 {
            
            throw MultipartError.invalidBoundary(self.boundary)
        } else {
            return self.boundary
        }
    }
    
    public static var boundaryAllowedCharacters: [Character] {
        
        return ((30...39).map {$0} // digits
                + (65...90).map {$0} // uppercase Alpha
                + (61...122).map {$0} // lowercase Alpha
            ).map { UnicodeScalar($0)!.description.first! }
            + ["'", "(", ")", "+", "_", ",", "-", ".", "/", ":", "=", "?"]
    }
    
    /// basically a newLine, but in a way that other parsers can interpret
    public static let crlf = "\r\n"
    
    public static func randomBoundary() -> String {
        return String(format: "alamofire.retrolux.boundary.%08x%08x", arc4random(), arc4random())
    }
}



