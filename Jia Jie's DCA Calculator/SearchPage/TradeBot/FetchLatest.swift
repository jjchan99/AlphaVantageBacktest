//
//  FetchLatest.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 8/12/21.
//

import Foundation
import Combine

class FetchLatest {
    static var subscribers = Set<AnyCancellable>()
    
    
    static func update(completion: @escaping (TradeBot) -> Void) {
        let technicalManager = OHLCTechnicalManager(window: 200)
        let group = DispatchGroup()
        var value: Daily!
        var bot: TradeBot!
        
        group.enter()
        get { stonks in
            value = stonks
            group.leave()
        }
        
        group.enter()
        getBot { tb in
            bot = tb
            group.leave()
        }
        
        group.notify(queue: .global()) {
            let sorted = value.sorted!
            var previous: OHLCCloudElement?
            
            for idx in 0..<sorted.count - 1 {
                let OHLC = technicalManager.addOHLCCloudElement(key: sorted[idx].key, value: sorted[idx].value)
                
                if previous != nil {
                    bot.evaluate(latest: OHLC, previous: previous!)
                }
                
                previous = OHLC
            }
            DispatchQueue.main.async {
            completion(bot)
            }
        }
    }
    
    private static func get(completion: @escaping (Daily) -> Void) {
        CandleAPI.fetchDaily("TSLA")
            .sink { _ in
                
            } receiveValue: { value in
                completion(value)
                }
            .store(in: &subscribers)
   }
    
   private static func getBot(completion: @escaping (TradeBot) -> Void) {
        BotAccountCoordinator.fetchBot()
            .sink { _ in
                
            } receiveValue: { value in
                completion(value)
            }
            .store(in: &subscribers)
        }
    }
