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
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
        case iCloudApplicationPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }

}

// MARK: USER FUNCTIONS

extension CloudKitUtility {
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

}

// MARK: CRUD FUNCTIONS

extension CloudKitUtility {

    static func fetch(predicate: NSPredicate, recordType: CKRecord.RecordType, sortDescriptors: [NSSortDescriptor]? = nil, resultsLimit: Int? = nil, completion: @escaping (_ items: TradeBot) -> Void) {
        let operation = createOperation(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit)

        // Get items in query
        var returnedItems: TradeBot!
        addRecordMatchedBlock(operation: operation) { item in
            returnedItems = item
        }
        
        addQueryResultBlock(operation: operation) { finished in
            completion(returnedItems)
        }


        add(operation: operation)
    }

    static private func createOperation(predicate: NSPredicate, recordType: CKRecord.RecordType, sortDescriptors: [NSSortDescriptor]? = nil, resultsLimit: Int? = nil) -> CKQueryOperation {
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        let queryOperation = CKQueryOperation(query: query)
        if let limit = resultsLimit {
        queryOperation.resultsLimit = limit
        }
        return queryOperation
    }

    static private func addRecordMatchedBlock(operation: CKQueryOperation, completion: @escaping (_ tradeBot: TradeBot) -> ()) {
        operation.recordFetchedBlock = { record in
            //Convert record to tradebot and call completion
            
            
            
        }
    }
    
    static private func addQueryResultBlock(operation: CKQueryOperation, completion: @escaping (_ finished: Bool) -> ()) {
        operation.queryCompletionBlock = { cursor, error in
            completion(true)
        }
    }

    static private func add(operation: CKDatabaseOperation) {
        CKContainer.default().privateCloudDatabase.add(operation)
    }
}
