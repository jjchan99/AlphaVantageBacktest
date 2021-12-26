//
//  DescriptionManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/12/21.
//

import Foundation
import CloudKit

class LedgerManager {
    var entries: [LedgerRecord] = []
    
    func upload(tb: TradeBot, completion: @escaping (Bool) -> Void) {
        CloudKitUtility.saveArray(array: entries, for: tb) { success in
            completion(success)
        }
    }
    
    func append(entry: LedgerRecord) {
        entries.append(entry)
    }
}

struct LedgerRecord: CloudKitInterchangeable, CloudChild {
    init?(record: CKRecord) {
        let description = record["description"] as! String
        let stamp = record["stamp"] as! String
        let deltaCash = record["deltaCash"] as! Double
        let deltaShares = record["deltaShares"] as! Double
        
        self.record = record
        
        self.description = description
        self.stamp = stamp
        self.deltaShares = deltaShares
        self.deltaCash = deltaCash
    }
    
    init?(description: String, stamp: String, deltaCash: Double, deltaShares: Double) {
        let record = CKRecord(recordType: "Description")
        record.setValuesForKeys([
            "description" : description,
            "stamp" : stamp,
            "deltaCash" : deltaCash,
            "deltaShares" : deltaShares
        ])
        self.init(record: record)
    }
    
    var record: CKRecord
     
    let description: String
    let stamp: String
    let deltaCash: Double
    let deltaShares: Double
}
