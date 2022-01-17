//
//  ChartTest.swift
//  Jia Jie's DCA CalculatorTests
//
//  Created by Jia Jie Chan on 17/1/22.
//

import XCTest
@testable import Jia_Jie_s_DCA_Calculator

extension Double: Plottable {
    public typealias T = Self
}

class ChartTest: XCTestCase {
    
    var sut: [Double] = [3.5, 7.5, 10, 7.5, 3.5]
    var state: RenderState!
    let frame: Frame = .init(count: 5, height: Dimensions.height, width: Dimensions.width, padding: 0.1 * Dimensions.width)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        state = LineState(data: sut, frame: frame, mmr: .init(max: sut.max()!, min: sut.min()!), setKeyPath: \Double.self)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
