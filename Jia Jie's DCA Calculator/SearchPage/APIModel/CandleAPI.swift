//
//  CandleAPI.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import Combine

struct CandleAPI {
    
    static var keyIdx: Int = 0
    
    private enum APIError: Error {
        case percentEncoding
        case failedRequest
        case invalidUrl
    }
    
    private enum type {
        case intraday
        case daily
    }
    
    private func fetchURL(type: type, query: String) -> URL? {
        switch type {
        case .intraday:
            return URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_INTRADAY&symbol=\(query)&interval=5min&apikey=\(key0)")
        case .daily:
            return URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=\(query)&outputsize=full&apikey=\(key1)")
        }
    }
    
    var key0: String {
        if CandleAPI.keyIdx == 5 { CandleAPI.keyIdx = 0 } else { CandleAPI.keyIdx += 1 }
        return keys0[CandleAPI.keyIdx]
    }
    
    var key1: String {
        return keys1[CandleAPI.keyIdx]
    }
    
    let keys0 = ["GKCZHS0SQNP50WDS", "9GA1F0JY13Z0DWC4", "1BRTTJRUMG63EUSO", "5BR25V35UQTEUCCW", "43GM9MU0FXBGBB6Z", "355URCWX6U1VOGCY"]
    let keys1 = ["HEZNTAZ4HWL4TZBL", "OCTMFHTVCH8VTQK0", "HENHM5ZQK1QNX4NS", "P3IK9KTI2JHVLA5J", "YENDQZHUMT4O24WF", "03L502FSYT02IOLN"]
    
    
    func fetchIntraday(_ symbolQuery: String) -> AnyPublisher<Intraday, Error> {
        
        guard symbolQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) != nil else {
            return Fail(error: APIError.percentEncoding).eraseToAnyPublisher()
        }
    
        let url = fetchURL(type: .intraday, query: symbolQuery)
        
        if let url = url {
            
            let publisher = URLSession.shared.dataTaskPublisher(for: url)
                return publisher
                    .tryMap { value in
                        return value.0
                    }
                    .decode(type: Intraday.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.invalidUrl)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchDaily(_ symbolQuery: String) -> AnyPublisher<Daily, Error> {
        
        guard let symbolQuery = symbolQuery.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return Fail(error: APIError.percentEncoding).eraseToAnyPublisher()
        }
    
        let url = fetchURL(type: .daily, query: symbolQuery)
        
        if let url = url {
            
            let publisher = URLSession.shared.dataTaskPublisher(for: url)
                return publisher
                    .tryMap { value in
                        return value.0
                    }
                    .decode(type: Daily.self, decoder: JSONDecoder())
                    .receive(on: RunLoop.main)
                    .eraseToAnyPublisher()
        } else {
            return Fail(error: APIError.invalidUrl)
                .eraseToAnyPublisher()
        }
    }
    
    
    
    
}
