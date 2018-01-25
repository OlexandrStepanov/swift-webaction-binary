//
//  TimeAction.swift
//  ActionPackageDescription
//
//  Created by Oleksandr Stepanov on 19/01/2018.
//

import Foundation

public class TimeAction : ApiAction {
    
    override public func action() {
        log("requestArgs: \(requestArgs)")
        
        guard checkClientId() else {
            return
        }

        makeSuccessResponse(["unixtime" : String(UInt64(Date().timeIntervalSince1970))])
    }
}
