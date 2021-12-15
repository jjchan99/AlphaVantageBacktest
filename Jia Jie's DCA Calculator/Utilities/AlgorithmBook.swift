//
//  AlgorithmBook.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 20/11/21.
//

import Foundation

struct AlgorithmBook {
    var closestIndex: Int?
    mutating func binarySearch(_ a: [(String, TimeSeriesDaily)], key: String, range: Range<Int>) -> Int? {
        if range.lowerBound >= range.upperBound {
            // If we get here, then the search key is not present in the array.
            return closestIndex ?? nil
        } else {
            // Calculate where to split the array.
            let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2
            closestIndex = midIndex

            // Is the search key in the left half?
            if a[midIndex].0 < key {
//                print("comparing \(a[midIndex].0) > \(key)")
                return binarySearch(a, key: key, range: range.lowerBound ..< midIndex)

            // Is the search key in the right half?
            } else if a[midIndex].0 > key {
//                print("comparing \(a[midIndex].0) < \(key)")
                return binarySearch(a, key: key, range: midIndex + 1 ..< range.upperBound)

            // If we get here, then we've found the search key!
            } else {
                return midIndex
            }
        }
    }
    
    mutating func resetIndex() {
        closestIndex = nil
    }
}
