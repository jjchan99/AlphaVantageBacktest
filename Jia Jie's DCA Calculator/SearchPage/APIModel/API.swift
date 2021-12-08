//
//  Monthly.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 12/9/21.
//

import Combine
import Foundation

struct API {
    
    private enum APIError: Error {
        case percentEncoding
        case failedRequest
        case invalidUrl
    }
    
    static var key: String {
        return keys.randomElement() ?? ""
    }
    
    static let keys = ["N483IC64XUG8M4VQ", "HXMUNDJIX81H2UDJ", "6DUG1TOBABY1SOPG"]
    
    static func fetchMonthlySeriesPublisher(_ symbolQuery: String) -> AnyPublisher<TimeSeriesMonthlyAdjusted, Error> {
        
        guard let symbolQuery = symbolQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIError.percentEncoding).eraseToAnyPublisher()
        }
        
        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_MONTHLY_ADJUSTED&symbol=\(symbolQuery)&apikey=\(key)")
        
        if let url = url {
            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { value in
                    return value.0
                }
                .decode(type: TimeSeriesMonthlyAdjusted.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.invalidUrl)
                .eraseToAnyPublisher()
        }
    }
    
    static func fetchSearchResultsPublisher(_ query: String) -> AnyPublisher<SearchResults, Error> {
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIError.percentEncoding).eraseToAnyPublisher()
        }
        
        let url = URL(string: "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=\(query)&apikey=\(key)")
        
        if let url = url {
            return URLSession.shared.dataTaskPublisher(for: url)
                .tryMap { value in
                    return value.0
                }
                .decode(type: SearchResults.self, decoder: JSONDecoder())
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.invalidUrl)
                .eraseToAnyPublisher()
        }
    }
}
