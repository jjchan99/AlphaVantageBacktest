//
//  CloudKit.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/12/21.
//

import Foundation
import UIKit
import Combine
import CloudKit

class CloudKitViewController: UIViewController {

    var isSignedInToiCloud: Bool = false
    var error: String = ""
    var userName: String = ""
    var permission: Bool = false
    var subscribers = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getiCloudStatus()
        requestPermission()
        getCurrentUserName()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func requestPermission() {
        CloudKitUtility.requestApplicationPermission()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [unowned self] value in
                self.permission = value
            }.store(in: &subscribers)
    }

    private func getiCloudStatus() {
        CloudKitUtility.getiCloudStatus()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self.error = error.localizedDescription
                }
            } receiveValue: { [unowned self] value in
                self.isSignedInToiCloud = value
            }.store(in: &subscribers)
    }

    func getCurrentUserName() {
        CloudKitUtility.discoverUserIdentity()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [unowned self] value in
                self.userName = value
            }.store(in: &subscribers)
    }
    
    func fetchItems() {
        let predicate = NSPredicate(value: true)
        
        CloudKitUtility.fetch(predicate: predicate, recordType: "TradeBot") { [unowned self] (items: [TradeBot]) in
            DispatchQueue.main.async {
                
            }
        }
    }
}
