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
                let idx = sorted.count - 1 - idx
                let OHLC = technicalManager.addOHLCCloudElement(key: sorted[idx].key, value: sorted[idx].value)
                
                if previous != nil && sorted[idx].key > bot.effectiveAfter {
                    bot.evaluate(previous: previous!, latest: OHLC) { success in

                    }
                }
                
                previous = OHLC
            }
            
            //MARK: UPDATE EFFECTIVE AFTER
            let record = bot.update(effectiveAfter: sorted.first!.key, cash: bot.account.cash, accumulatedShares: bot.account.accumulatedShares)
            CloudKitUtility.update(item: record) { success in
                DispatchQueue.main.async {
                completion(bot)
                }
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
