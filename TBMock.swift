import Foundation
struct Mock {
    
    static func account() -> Account {
        return Account(budget: 5000, cash: 5000, accumulatedShares: 0)
    }
    
    static func tb() -> TradeBot {
        return TradeBot(account: account(), conditions: [])!
    }
    
    static func MA() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, enterOrExit: .enter, andCondition: [])!
    }
    
    static func MAOperation() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .movingAverageOperation(period1: 200, period2: 50), aboveOrBelow: .priceAbove, enterOrExit: .enter, andCondition: [])!
    }
    
    static func BB() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .bollingerBands(percentage: 0.69), aboveOrBelow: .priceBelow, enterOrExit: .enter, andCondition: [])!
    }
    
    static func RSI() -> EvaluationCondition {
        return EvaluationCondition(technicalIndicator: .RSI(period: 14, value: 0.69), aboveOrBelow: .priceBelow, enterOrExit: .enter, andCondition: [])!
    }
    
    static func ticker() -> OHLCCloudElement {
        return OHLCCloudElement(stamp: "", open: 1.1, high: 0, low: 0, close: 0, volume: 0, percentageChange: nil, RSI: [14: 0.70], movingAverage: [
            200 : 1 ,
            50 : 0.9
        ], standardDeviation: nil, upperBollingerBand: 100, lowerBollingerBand: 0)
    }
    
    static func context() -> ContextObject {
        let o = ContextObject(account: account(), tb: tb())
            .updateTickers(previous: ticker(), mostRecent: ticker())
        return o
    }
    
}
