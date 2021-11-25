//
//  Logger.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 13/9/21.
//

import Foundation

enum Log {
    static func queue(action: String) {
        DispatchQueue.log(action: action)
    }
    
    static func location(fileName: String, functionName: String = #function, lineNumber: Int = #line) {
        print("Called by \(fileName.components(separatedBy: "/").last ?? fileName) - \(functionName) at line \(lineNumber)")
    }
}

extension DispatchQueue {
    static func log(action: String) {
        print("""
            
            \(action): 👨‍👩‍👦 \(String(validatingUTF8: __dispatch_queue_get_label(nil))!) 🧵 \(Thread.current)
            
            """)
    }
}
