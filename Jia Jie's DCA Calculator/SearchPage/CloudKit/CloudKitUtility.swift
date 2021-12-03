//
//  CloudKitUtility.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/12/21.
//

import Foundation
import CloudKit
import Combine

class CloudKitUtility {
    static private func getiCloudStatus(completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().accountStatus { status, error in
                switch status {
                case .available:
                    completion(.success(true))
                case .noAccount:
                    completion(.failure(CloudKitError.iCloudAccountNotFound))
                case .couldNotDetermine:
                    completion(.failure(CloudKitError.iCloudAccountNotDetermined))
                case .restricted:
                    completion(.failure(CloudKitError.iCloudAccountRestricted))
                default:
                    completion(.failure(CloudKitError.iCloudAccountUnknown))
                }
            }
        }
    
    private static func requestApplicationPermission(completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { status, error in
                if status == .granted {
                    completion(.success(true))
                } else {
                    completion(.failure(CloudKitError.iCloudApplicationPermissionNotGranted))
            }
        }
    }
    
    static func requestApplicationPermission() -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.requestApplicationPermission { result in
                promise(result)
            }
        }
    }
    
    
    static func getiCloudStatus() -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.getiCloudStatus { result in
                promise(result)
            }
        }
    }
    
    static private func fetchUserRecordID(completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().fetchUserRecordID { id, error in
            if let id = id {
                completion(.success(id))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
            }
        }
    }
    
    static private func discoverUserIdentity(id: CKRecord.ID, completion: @escaping (Result<String, Error>) -> ()) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { id, error in
            if let name = id?.nameComponents?.givenName {
            completion(.success(name))
        } else {
            completion(.failure(CloudKitError.iCloudCouldNotDiscoverUser))
        }
            
        }
    }
    
    static private func discoverUserIdentity(completion: @escaping (Result<String, Error>) -> ()) {
        fetchUserRecordID { fetchCompletion in
            switch fetchCompletion {
            case let .success(id):
                CloudKitUtility.discoverUserIdentity(id: id, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    static func discoverUserIdentity() -> Future<String, Error> {
        Future { promise in
            CloudKitUtility.discoverUserIdentity { result in
                promise(result)
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
        case iCloudApplicationPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }
    
    
    
    func createBot() {
        let record = CKRecord(recordType: "TradeBot")
        record.setValuesForKeys([
            "budget": 10000,
            "cash": 10000,
            "accumulatedShares": 0,
            
        ])
    }

}
