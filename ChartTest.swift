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
    
    var sut: [Double] = [3.5, 4.5, 10, 7.5, 3.5]
    var state: RenderState!
    var frame: Frame = .init(count: 5, height: Dimensions.height, width: Dimensions.width, padding: 0.1 * Dimensions.width)
    var mmr: MMR = .init(max: 10, min: 3.5)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        state = LineState(data: sut, frame: frame, mmr: .init(max: sut.max()!, min: sut.min()!), setKeyPath: \Double.self)
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func reverse(y: CGFloat) -> CGFloat {
        let share = y / frame.height
        let deviation = share * mmr.range
        let point = mmr.max - deviation
        return point
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var y = Y.get(point: 10, mmr: mmr, frame: frame)
        XCTAssertEqual(y, 0)
        y = Y.get(point: 3.5, mmr: mmr, frame: frame)
        XCTAssertEqual(y, Dimensions.height)
        XCTAssertEqual(reverse(y: y), 3.5)
        
        let y1 = Y.get(point: 4.5, mmr: mmr, frame: frame)
        let y2 = Y.get(point: 7.5, mmr: mmr, frame: frame)
        XCTAssert(y1 > y2)
    }
    
    func testAllNegative() throws {
        mmr = .init(max: , min: )
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
