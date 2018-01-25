//
//  Utils.swift
//  ActionPackageDescription
//
//  Created by Oleksandr Stepanov on 07/01/2018.
//

import Foundation

public func log(_ str: String) {
    print(str)
    #if os(Linux)
        fputs(str, stderr)
    #endif
}


