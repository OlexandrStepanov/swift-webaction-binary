//
//  JSONUtils.swift
//  Utilities
//
//  Created by Oleksandr Stepanov on 23/01/2018.
//  Credits to James Thomas: https://github.com/jthomas/OpenWhiskAction/

import Foundation


class JSONUtils {
    
    class func jsonStringToDictionary(jsonString: String) -> [String:Any]? {
        guard let jsonData = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
            return nil
        }
        
        do {
            let dic = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return dic as? [String:Any]
        } catch {
            log("Error converting JSON data to dictionary \(error)")
            return nil
        }
    }
    
    class func dictionaryToJsonString(jsonDict: [String:Any]) -> String? {
        if JSONSerialization.isValidJSONObject(jsonDict) {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
                if let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8) {
                    return jsonStr
                } else {
                    log("Error serializing data to JSON, data conversion returns nil string")
                }
            } catch {
                log(("\(error)"))
            }
        } else {
            log("Error serializing JSON, data does not appear to be valid JSON")
        }
        return nil
    }
}
