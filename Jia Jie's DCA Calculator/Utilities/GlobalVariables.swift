//
//  GlobalVariables.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 14/9/21.
//

import Foundation
import UIKit

let formatter: DateFormatter = {
    let format = DateFormatter()
    format.dateFormat = "yyyy-MM-dd"
    return format
}()


let formatter_MMMM_yyyy: DateFormatter = {
    let format = DateFormatter()
    format.dateFormat = "MMMM yyyy"
    return format
}()

enum conversionError: Error {
    case toAdjustedOpen
    case dateConversion
    case emptyDataSet
}


