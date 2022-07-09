//
//  File.swift
//  
//
//  Created by kevinzhow on 2022/7/10.
//

import Foundation

struct Environment {
    static func get(_ key: String) -> String? {
        return ProcessInfo.processInfo.environment[key]
    }
}
