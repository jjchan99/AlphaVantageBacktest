//
//  CandleRenderer.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import SwiftUI

struct Candle<T: ChartPointSpecified> {
    let data: T
    let body: Path
    let stick: Path
}



