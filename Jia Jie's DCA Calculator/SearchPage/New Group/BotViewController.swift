//
//  BotViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/12/21.
//

import Foundation
import UIKit

class BotCoordinator: NSObject, Coordinator {
    
    let sorted: [OHLC]
    
    var bot: TradeBot? { didSet {
        let todaysDate = Date(timeIntervalSinceNow: 0)
        if sorted.last?.stamp != todaysDate {
            
        } else {
            
        }
    }
}

class BotViewController: UIViewController {
    
    var viewModel: BotViewModel
    var coordinator: BotCoordinator
    
    override func viewDidLoad() {
        viewModel.createBotButtonTapped = { [unowned self] in
            coordinator.bot = viewModel.createBot()
        }
    }
    
    
    
}
