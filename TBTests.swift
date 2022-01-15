//
//  TBTests.swift
//  Jia Jie's DCA CalculatorTests
//
//  Created by Jia Jie Chan on 13/1/22.
//

import XCTest
@testable import Jia_Jie_s_DCA_Calculator

class TBTests: XCTestCase {
    var sut: TradeBot!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = AlgoMock.tb()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }
    
    func testHoldingPeriod() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        sut.conditions = ExitTriggerManager.orUpload(tb: AlgoMock.tb(), context: AlgoMock.context())
        XCTAssertEqual(sut.conditions.first!.technicalIndicator.rawValue, 20220111)
        sut.conditions = ExitTriggerManager.resetOrExitTrigger(tb: sut)
        XCTAssertEqual(sut.conditions.first!.technicalIndicator.rawValue, 99999999)
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
    

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = Empty_EVState(context: Mock.context())
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        sut = sut.transition(condition: Mock.MA())
        XCTAssertTrue(sut.perform())
        sut = sut.transition(condition: Mock.MAOperation())
        XCTAssertTrue(sut.perform())
        sut = sut.transition(condition: Mock.BB())
        XCTAssertTrue(sut.perform())
        sut = sut.transition(condition: Mock.RSI())
        XCTAssertTrue(sut.perform())
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
