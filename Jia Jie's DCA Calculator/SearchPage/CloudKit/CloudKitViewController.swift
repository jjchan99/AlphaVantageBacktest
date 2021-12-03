//
//  CloudKit.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/12/21.
//

import Foundation
import CloudKit
import UIKit

class CloudKitViewController: UIViewController {
    
    var isSignedInToiCloud: Bool = false
    var error: String = ""
    var userName: String = ""
    var permission: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getiCloudStatus()
        requestPermission()
        fetchiCloudUserRecordID()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func requestPermission() {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { [unowned self] status, error in
            DispatchQueue.main.async {
                if status == .granted {
                    self.permission = true
                }
            }
        }
    }
    
    private func getiCloudStatus() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    break
                case .noAccount:
                    break
                case .couldNotDetermine:
                    break
                case .restricted:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func fetchiCloudUserRecordID() {
        CKContainer.default().fetchUserRecordID { [unowned self] id, error in
            if let id = id {
                discoveriCloudUser(id: id)
            }
        }
    }
    
    func discoveriCloudUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { [unowned self] id, error in
            DispatchQueue.main.async {
                if let name = id?.nameComponents?.givenName {
                    self.userName = name
                }
            }
            
        }
    }
}
