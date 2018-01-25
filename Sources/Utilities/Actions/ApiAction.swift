//
//  ApiAction.swift
//  Utilities
//
//  Created by Oleksandr Stepanov on 23/01/2018.
//

import Foundation

public protocol ApiError: Error, CustomStringConvertible  {
    var code: UInt { get }
}

public class ApiAction {
    public static let ClientId = "SOME_CLIENT_ID"
    
    enum Error: ApiError {
        case clientIdMissing
        case unknown(Swift.Error)
        
        public var description: String {
            switch self {
            case .clientIdMissing:
                return "Client Id is missing or wrong"
            case .unknown(let error):
                return error.localizedDescription
            }
        }
        
        public var code: UInt {
            switch self {
            case .clientIdMissing:
                return 401
            case .unknown:
                return 500
            }
        }
    }
    
    
    enum HTTPMethod: String {
        case get, post, put, delete
        case unknown
    }
    
    let requestArgs: [String : Any]
    let requestMethod: HTTPMethod
    let requestHeaders: [String : String]
    
    var responseJSON: [String : Any]
    var responseCode: UInt
    var responseHeaders: [String : String]
    
    public init?() {
        let env = ProcessInfo.processInfo.environment
        guard let inputStr: String = env["WHISK_INPUT"] else {
            log("'WHISK_INPUT' environment variable is missing")
            return nil
        }
        guard let args = JSONUtils.jsonStringToDictionary(jsonString: inputStr) else {
            log("Can't parse WHISK_INPUT: \(inputStr)")
            return nil
        }
        
        requestArgs = args
        
        if let method = args["__ow_method"] as? String {
            requestMethod = HTTPMethod(rawValue: method) ?? .unknown
        }
        else {
            log("__ow_method is not set")
            requestMethod = .unknown
        }
        requestHeaders = args["__ow_headers"] as? [String : String] ?? [:]
        
        //  Default response is success with empty JSON
        responseJSON = [:]
        responseCode = 200
        responseHeaders = ["Content-Type" : "application/json"]
    }
    
    public func main() {
        //  First, call an action to make a response
        action()
        
        //  Then, form and print the result
        guard let base64_body = ApiAction.makeBody(responseJSON) else {
            log("Can't serialize to JSON response: \(responseJSON)")
            return
        }
        
        let result: [String : Any] = [ "body": base64_body, "statusCode": responseCode, "headers": responseHeaders ]
        if let respString = JSONUtils.dictionaryToJsonString(jsonDict: result) {
            print("\(respString)")
        } else {
            log("Error converting \(result) to JSON string")
        }
    }
    
    // MARK: Override in subclasses
    
    public func action() {
        //  To be overridden
    }
    
    // MARK: Making response methods
    
    public func makeSuccessResponse(_ payload: [String : Any]) {
        responseCode = 200
        responseJSON = payload
    }
    
    public func makeErrorResponse(_ error: ApiError) {
        responseCode = error.code
        responseJSON = ["error" : error.description]
    }
    
    public func makeErrorResponse(_ errors: [ApiError]) {
        responseCode = 400
        responseJSON = ["errors" : errors.map({ $0.description })]
    }
}

public extension ApiAction {
    
    /// Makes API key check, and form error response if check failed
    ///
    /// - Returns: true if check passed, and false otherwise
    public func checkClientId() -> Bool {
        guard let cliendId = requestHeaders["x-client-id"],
            cliendId == ApiAction.ClientId else {
            makeErrorResponse(ApiAction.Error.clientIdMissing)
            return false
        }
        return true
    }
    
    /// Makes Base64 string from args in JSON format
    ///
    /// - Parameter args: JSON
    /// - Returns: base64 string
    public static func makeBody(_ args: [String : Any]) -> String? {
        guard let json_body = JSONUtils.dictionaryToJsonString(jsonDict: args) else {
            return nil
        }
        return Data(json_body.utf8).base64EncodedString()
    }
}

