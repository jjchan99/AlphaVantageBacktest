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
import SwiftUI

class CloudKitViewController: UIViewController {

    var subscribers = Set<AnyCancellable>()
    var hostingController: UIHostingController<AnyView>?
    var viewModel = CloudViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hostingController = UIHostingController(rootView: AnyView(CloudView().environmentObject(viewModel)))
        view.addSubview(hostingController!.view)
        hostingController!.view.activateConstraints(reference: view, constraints: [.top(), .leading()], identifier: "cloudView")
        view.backgroundColor = .white
        Log.queue(action: "Cloud view did load")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
            .sink { value in
                switch value {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                viewModel.permission = value
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
                    viewModel.error = error.localizedDescription
                }
            } receiveValue: { [unowned self] value in
                viewModel.isSignedInToiCloud = value
            }.store(in: &subscribers)
    }

    func getCurrentUserName() {
        CloudKitUtility.discoverUserIdentity()
            .receive(on: DispatchQueue.main)
            .sink { value in
                switch value {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                viewModel.userName = value
            }.store(in: &subscribers)
    }
    
    var bot: [TradeBot] = []
    
    func fetchItems() {
        let predicate = NSPredicate(value: true)
        let recordType = "TradeBot"
        CloudKitUtility.fetch(predicate: predicate, recordType: recordType)
            .receive(on: DispatchQueue.main)
            .sink { value in
                switch value {
                case .failure(let error):
                    print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] items in
                self.bot = items
            }
            .store(in: &subscribers)
    }
}
