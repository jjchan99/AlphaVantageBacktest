//
//  TBTests.swift
//  Jia Jie's DCA CalculatorTests
//
//  Created by Jia Jie Chan on 13/1/22.
//

import XCTest
@testable import Jia_Jie_s_DCA_Calculator

class TBTests: XCTestCase {
    
    var sut: ContextObject!
    var mockTimeSeries: [String: TimeSeriesDaily] = [
        "2022-01-01" : .init(open: "25", high: "30", low: "20", close: "22", volume: "44")
    ]

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let account: Account = .init(budget: 5000, cash: 5000, accumulatedShares: 0)
        let tb: TradeBot = BotAccountCoordinator.specimen()
        sut = ContextObject(account: account, tb: tb)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let test = Backtest.from(date: "", daily: .init(meta: nil, timeSeries: mockTimeSeries, note: nil, sorted: nil), bot: sut.tb)
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

class EVTests: XCTestCase {
    
    var sut: EvaluationState!
    let account: Account = .init(budget: 5000, cash: 5000, accumulatedShares: 0)
    lazy var tb: TradeBot = .init(account: account, conditions: [.init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, enterOrExit: .enter, andCondition: [])!])!
    lazy var context: ContextObject = .init(account: account, tb: tb)
    let ticker1: OHLCCloudElement = .init(stamp: "", open: 0, high: 0, low: 0, close: 0, volume: 0, percentageChange: nil, RSI: [:], movingAverage: [200 : 1], standardDeviation: nil, upperBollingerBand: nil, lowerBollingerBand: nil)
    let ticker2: OHLCCloudElement = .init(stamp: "", open: 0, high: 0, low: 0, close: 0, volume: 0, percentageChange: nil, RSI: [:], movingAverage: [200 : 1.1], standardDeviation: nil, upperBollingerBand: nil, lowerBollingerBand: nil)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        context.updateTickers(previous: ticker1, mostRecent: ticker2)
        let state: EvaluationState = MA_EVState(context: context, condition: .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, enterOrExit: .enter, andCondition: [])!)
        sut = state
        sut.setContext(context: context)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(sut.perform(), true)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
