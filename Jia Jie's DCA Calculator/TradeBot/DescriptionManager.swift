//
//  DescriptionManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/12/21.
//

import Foundation
class DescriptionManager {
    var descriptions: [String] = []
    
    func upload(tb: TradeBot, completion: @escaping (Bool) -> Void) {
        CloudKitUtility.saveArray(array: descriptions, for: tb) { success in
            completion(success)
        }
    }
}
