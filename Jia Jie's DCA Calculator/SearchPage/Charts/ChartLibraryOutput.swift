//
//  ChartLibraryOutput.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 12/12/21.
//

import Foundation
import SwiftUI

struct ChartLibraryOutput<T: CandlePointSpecified> {
    var bars: [String: Path] = [:]
    var candles: [String: [Candle<T>]] = [:]
    var lines: [String: (path: Path, area: Path)] = [:]
}
