//
//  ZeroPositionModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 22/10/21.
//

import Foundation
import CoreGraphics

struct ZeroPosition {
    let meta: DCAResultMeta
    let mode: Mode
    let metaAnalysis: MetaAnalysis
    
    let height: CGFloat
    
    init(meta: DCAResultMeta, mode: Mode, height: CGFloat) {
        self.meta = meta
        self.mode = mode
        self.height = height
        self.metaAnalysis = .init(meta: meta, mode: mode)
    }
    
    func getZeroPosition() -> CGFloat {
        let metaType = metaAnalysis.getMetaType
        let range = metaAnalysis.getRange()
        let minY = meta.mode(mode: mode, min: true)
        switch metaType {
        case .allNegative:
            return 0
        case .allPositive:
            return height
        case .negativePositive:
            return ( CGFloat((range + minY)/range) * height )
        }
    }
    
}
