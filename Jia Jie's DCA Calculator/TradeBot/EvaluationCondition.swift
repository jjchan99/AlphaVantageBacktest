//
//  EvaluationCondition.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 21/12/21.
//

import Foundation
import CloudKit

struct EvaluationCondition: CloudKitInterchangeable, CustomStringConvertible, CloudChild {
    
    init?(record: CKRecord) {
        let technicalIndicatorRawValue = record["technicalIndicator"] as! Double
        let aboveOrBelowRawValue = record["aboveOrBelow"] as! Int
        let buyOrSellRawValue = record["buyOrSell"] as! Int
        
        self.technicalIndicator = TechnicalIndicators.build(rawValue: technicalIndicatorRawValue)
        self.aboveOrBelow = AboveOrBelow(rawValue: aboveOrBelowRawValue)!
        self.buyOrSell = BuyOrSell(rawValue: buyOrSellRawValue)!
        self.record = record
    }
    
    init?(technicalIndicator: TechnicalIndicators, aboveOrBelow: AboveOrBelow, buyOrSell: BuyOrSell, andCondition: [EvaluationCondition]) {
        let record = CKRecord(recordType: "EvaluationCondition")
                record.setValuesForKeys([
                    "technicalIndicator": technicalIndicator.rawValue,
                    "aboveOrBelow": aboveOrBelow.rawValue,
                    "buyOrSell": buyOrSell.rawValue,
                ])
        self.init(record: record)
        self.andCondition = andCondition
    }
    
    var record: CKRecord
    
    func update(newCondition: EvaluationCondition) -> EvaluationCondition {
        let record = self.record
        //DO STUFF WITH THE RECORD
        record.setValuesForKeys([
            "technicalIndicator" : newCondition.technicalIndicator.rawValue,
            "aboveOrBelow" : newCondition.aboveOrBelow.rawValue,
            "buyOrSell" : newCondition.buyOrSell.rawValue
        ])
        //MARK: Needs to append new and conditions to local instance without need to re-fetch
        return EvaluationCondition(record: record)!
    }
    
    var technicalIndicator: TechnicalIndicators
    let aboveOrBelow: AboveOrBelow
    let buyOrSell: BuyOrSell
    var andCondition: [EvaluationCondition] = []
    
    var description: String {
        "Evaluation conditions: check whether the close price is \(aboveOrBelow) the \(technicalIndicator) ___ (which will be fed in). Then \(buyOrSell)"
    }
}
