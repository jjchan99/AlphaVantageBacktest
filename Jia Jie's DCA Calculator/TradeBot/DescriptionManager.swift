//
//  DescriptionManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/12/21.
//

import Foundation
import CloudKit

class DescriptionManager {
    var descriptions: [DescriptionRecord] = []
    
    func upload(tb: TradeBot, completion: @escaping (Bool) -> Void) {
        CloudKitUtility.saveArray(array: descriptions, for: tb) { success in
            completion(success)
        }
    }
    
    func append(description: String) {
        let description: DescriptionRecord = .init(description: description)!
        descriptions.append(description)
    }
}

struct DescriptionRecord: CloudKitInterchangeable, CloudChild {
    init?(record: CKRecord) {
        let description = record["description"] as! String
        self.description = description
        self.record = record
    }
    
    init?(description: String) {
        let record = CKRecord(recordType: "Description")
        record["description"] = description
        self.init(record: record)
    }
    
    var record: CKRecord
     
    let description: String

}
