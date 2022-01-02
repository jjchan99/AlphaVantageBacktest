//
//  Double+Extensiosn.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 5/10/21.
//

import Foundation

extension Double {
    
    var stringValue: String {
        return String(describing: self)
    }
    
    var twoDecimalPlaceString: String {
        return String(format: "%.2f", self)
    }
    
    var zeroDecimalPlaceString: String {
        return String(format: "%.0f", self)
    }
    
    var currencyFormat: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString
    }
    
    var percentageFormat: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self/100 as NSNumber) ?? twoDecimalPlaceString
    }
    
    func toCurrencyFormat(hasDollarSymbol: Bool = true, hasDecimalPlaces: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        if hasDollarSymbol == false {
            formatter.currencySymbol = ""
        }
        if hasDecimalPlaces == false {
            formatter.maximumFractionDigits = 0
        }
        return formatter.string(from: self as NSNumber) ?? twoDecimalPlaceString

    }

}

extension Double {
    var roundedWithAbbreviations: String {
        let number = self
        let thousand = number / 1000
        let million = number / 1000000
        if number >= 0 {
        if million >= 1.0 {
            return "\((self/1000000).round(to: 2))M"
        }
        else if thousand >= 1.0 {
            return "\((self/1000).round(to: 2))K"
        }
        else {
            return "\(self.round(to: 2))"
        }
        } else {
            if million <= -1.0 {
                return "\((self/1000000).round(to: 2))M"
            }
            else if thousand <= -1.0 {
                return "\((self/1000).round(to: 2))K"
            }
            else {
                return "\(self.round(to: 2))"
            }
        }
    }
    
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}



