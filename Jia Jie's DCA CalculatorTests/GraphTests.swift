//
//  GraphTests.swift
//  Jia Jie's DCA CalculatorTests
//
//  Created by Jia Jie Chan on 18/10/21.
//

//MARK: TESTS PASSED
//MARK: ALL TESTS PASSED. UPDATED SAT 23 OCT. SIGNING OFF JJ. DONE 

import Foundation
import XCTest
import Combine
import CoreGraphics
@testable import Jia_Jie_s_DCA_Calculator

class GraphTests: XCTestCase {
    
    var sut: DCACalculator!
    let mode: Mode = .gain
    let height: CGFloat = 300
    let width: CGFloat = 390
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let mockSubject = createMockSubject()
        sut = DCACalculator(subject: mockSubject, initialInvestment: 5000, monthlyInvestment: 1500, sortedData: mockSubject.sortedData(), monthIndex: 9)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    private func createMockSubject() -> TimeSeriesMonthlyAdjusted {
        let meta = TimeSeriesMonthlyAdjusted.Meta(information: "Mock Company", symbol: "Mock", lastRefreshed: "Not Important", timeZone: "Not Important")
        var data: [String: TimeSeriesMonthlyAdjusted.Data] = [:]
        let datesArray: [String] = ["2021-10-08", "2021-09-30", "2021-08-31", "2021-07-30", "2021-06-30", "2021-05-28", "2021-04-30", "2021-03-31", "2021-02-26", "2021-01-29"]
    
        for dates in datesArray {
            data[dates] = TimeSeriesMonthlyAdjusted.Data(open: "\(Int.random(in: 100...200))", high: "\(Int.random(in: 100...200))", low: "\(Int.random(in: 100...200))", close: "\(Int.random(in: 100...200))", adjustedClose: "\(Int.random(in: 100...200))", volume: "\(Int.random(in: 100...200))", dividendAmount: "\(Int.random(in: 100...200))")
        }
        let subject = TimeSeriesMonthlyAdjusted(metaData: meta, data: data)
        return subject
    }
    
    //MARK: TEST SATISFIED - BY JIA JIE ON THU 21 OCT
    
    func testGraphPlot() {
        let data = sut.calculate()
        let render = GraphRenderer(width: width, height: height, data: data.result, meta: data.meta, mode: mode).render()
        let points = render.points
        for idx in 0..<points.count {
            let ySourceOfTruth = data.result[idx].mode(mode: mode)
            let ySourceOfTruthScaledToGraph = yScaleToGraph(element: ySourceOfTruth)
            let xSourceOfTruthScaledToGraph = xScaleToGraph(idx: idx)
            let pointOfTruth = CGPoint(x: xSourceOfTruthScaledToGraph, y: ySourceOfTruthScaledToGraph)
            let pointToTest: CGPoint = points[idx]
            print("Data for index \(idx): \(data.result[idx])")
            print("meta: \(data.meta)")
            XCTAssertEqual(pointOfTruth.x, pointToTest.x, accuracy: 0.001)
            XCTAssertEqual(pointOfTruth.y, pointToTest.y, accuracy: 0.001)
        }
        testIndicator()
    }
    
    func yScaleToGraph(element: Double) -> CGFloat {
        let meta = sut.calculate().meta
        let maxY = meta.mode(mode: mode, min: false)
        let minY = meta.mode(mode: mode, min: true)
        
        var range: Double!
        let allNegative: Bool = maxY < 0 && minY < 0
        let negativePostive: Bool = minY < 0 && maxY >= 0
        
        if allNegative {
            range = abs(minY)
        } else if negativePostive {
            range = maxY - minY
        } else {
            range = maxY
        }
        
        let deviationFromMin = minY < 0 ? abs(element - minY) : element
        if allNegative {
            if element == minY {
                let point = (1 - CGFloat(deviationFromMin / range)) * height
                print("should be 300 (all negative): \(point)")
                XCTAssertEqual(point, height)
            }
        } else {
        if element == maxY {
            let point = (1 - CGFloat(deviationFromMin / range)) * height
            print("should be zero: \(point)")
            XCTAssertEqual(0, point)
        }
        }
        return (1 - CGFloat(deviationFromMin / range)) * height
    }
    
    func xScaleToGraph(idx: Int) -> CGFloat {
        let data = sut.calculate()
        return (width / CGFloat(data.result.count - 1)) * CGFloat(idx)
    }
    
    func yDescale(point: CGFloat) -> Double {
        //MARK: TEST PASSED
        let meta = sut.calculate().meta
        let maxY = meta.mode(mode: mode, min: false)
        let minY = meta.mode(mode: mode, min: true)
        var range: Double!
        if maxY < 0 && minY < 0 {
            range = abs(minY)
        } else if minY < 0 && maxY >= 0 {
            range = maxY - minY
        } else {
            range = maxY
        }
        
        let deviationFromMin = ((CGFloat((point/height)) - CGFloat(1)) * CGFloat(range)) * -1
        let element = minY < 0 ? deviationFromMin + CGFloat(minY) : deviationFromMin
        return Double(element)
    }
    
    func testIndicator() {
        let data = sut.calculate()
        let meta = data.meta
        print("meta: \(meta)")
        let render = GraphRenderer(width: width, height: height, data: data.result, meta: data.meta, mode: mode).render()
        let points = render.points
        
        let indicator = Indicator(graphPoints: points, height: height, width: width, meta: meta, mode: mode)
        let startX: CGFloat = 0
        let endX: CGFloat = width
        
        var result = indicator.updateIndicator(xPos: startX)
        XCTAssertEqual(result.selectedYPos, yScaleToGraph(element: data.result[0].mode(mode: mode)), accuracy: 0.001)
        
        result = indicator.updateIndicator(xPos: endX)
        XCTAssertEqual(result.selectedYPos, yScaleToGraph(element: data.result.last!.mode(mode: mode)), accuracy: 0.001)
        
        //MARK: Test of Points along results indices
        
        for idx in 0..<data.result.count {
            result = indicator.updateIndicator(xPos: xScaleToGraph(idx: idx))
            let element: Double = data.result[idx].gain
            XCTAssertEqual(result.selectedYPos, yScaleToGraph(element: element), accuracy: 0.001)
            XCTAssertEqual(result.selectedYPos, points[idx].y, accuracy: 0.001)
            
            //MARK: Test of Descaling of y Point
            XCTAssertEqual(yDescale(point: result.selectedYPos), data.result[idx].gain, accuracy: 0.001)
        }
    }
    
    
}
