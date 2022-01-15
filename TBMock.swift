import Foundation
struct Mock {
    
    static func account() -> Account {
        return Account(budget: 5000, cash: 5000, accumulatedShares: 0)
    }
    
    static func tb() -> TradeBot {
        return TradeBot(account: account(), conditions: [condition()])!
    }
    
    static func condition() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, enterOrExit: .enter, andCondition: [])!
    }
    
    static func ticker() -> OHLCCloudElement {
        return OHLCCloudElement(stamp: "", open: 1.1, high: 0, low: 0, close: 0, volume: 0, percentageChange: nil, RSI: [:], movingAverage: [200 : 1], standardDeviation: nil, upperBollingerBand: nil, lowerBollingerBand: nil)
    }
    
    static func context() -> ContextObject {
        let o = ContextObject(account: account(), tb: tb())
            .updateTickers(previous: ticker(), mostRecent: ticker())
        return o
    }
    
}
