//
//  MetaAnalysisModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 23/10/21.
// MARK: SEEMS TO WORK

import Foundation

struct MetaAnalysis {
    let meta: DCAResultMeta
    let mode: Mode
    
    init(meta: DCAResultMeta, mode: Mode) {
        self.meta = meta
        self.mode = mode
    }
    
    enum metaType {
        case allNegative
        case allPositive
        case negativePositive
    }
    
    var maxY: Double {
        meta.mode(mode: mode, min: false)
    }
    
    var minY: Double {
        meta.mode(mode: mode, min: true)
    }
    
    var getMetaType: metaType {
        let allNegativeOrAllPositive: metaType = minY < 0 && maxY < 0 ? .allNegative : .allPositive
        let metaType: metaType = minY < 0 && maxY >= 0 ? .negativePositive : allNegativeOrAllPositive
        return metaType
    }
    
    func getRange() -> Double {
        switch getMetaType {
        case .allNegative:
            return abs(minY)
        case .allPositive:
            return maxY
        case .negativePositive:
            return maxY - minY
        }
    }
}
