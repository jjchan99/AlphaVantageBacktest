//
//  SymbolsModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 16/9/21.
//

import Foundation

struct SearchResults: Codable {
    var bestMatches: [Symbol]
    
    internal struct Symbol: Codable {
        var symbol: String
        var name: String
        var type: String
        var region: String
        var marketOpen: String
        var marketClose: String
        var timezone: String
        var currency: String
        var matchScore: String
        
        private enum CodingKeys: String, CodingKey {
            case symbol = "1. symbol"
            case name = "2. name"
            case type = "3. type"
            case region = "4. region"
            case marketOpen = "5. marketOpen"
            case marketClose = "6. marketClose"
            case timezone = "7. timezone"
            case currency = "8. currency"
            case matchScore = "9. matchScore"
        }
    }
}
