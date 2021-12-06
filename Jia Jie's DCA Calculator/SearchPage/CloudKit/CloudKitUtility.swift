//
//  CloudKitUtility.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/12/21.
//

import Foundation
import CloudKit
import Combine

protocol CloudKitInterchangeable {
    init?(record: CKRecord)
    var record: CKRecord { get }
    func update() -> Self
}

protocol CloudChild {}

extension CloudKitInterchangeable where Self: CloudChild {
    func setReference(parent: CloudKitInterchangeable) {
        self.record[parent.record.recordType] = CKRecord.Reference(record: parent.record, action: .deleteSelf)
    }
}

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
    
    static let container = CKContainer(identifier: "iCloud.jiajiechan")

}

// MARK: USER FUNCTIONS

extension CloudKitUtility {
    static private func getiCloudStatus(completion: @escaping (Result<Bool, Error>) -> ()) {
        container.accountStatus { status, error in
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
        container.requestApplicationPermission([.userDiscoverability]) { status, error in
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
        container.fetchUserRecordID { id, error in
            if let id = id {
                completion(.success(id))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
            }
        }
    }

    static private func discoverUserIdentity(id: CKRecord.ID, completion: @escaping (Result<String, Error>) -> ()) {
        container.discoverUserIdentity(withUserRecordID: id) { id, error in
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
    
    static func fetch<T: CloudKitInterchangeable>(predicate: NSPredicate, recordType: CKRecord.RecordType, sortDescriptors: [NSSortDescriptor]? = nil, resultsLimit: Int? = nil) -> Future<[T], Error> {
        Future { promise in
            CloudKitUtility.fetch(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit) { (items: [T]) in
                promise(.success(items))
            }
        }
    }

    static private func fetch<T: CloudKitInterchangeable>(predicate: NSPredicate, recordType: CKRecord.RecordType, sortDescriptors: [NSSortDescriptor]? = nil, resultsLimit: Int? = nil, completion: @escaping (_ items: [T]) -> Void) {
        let operation = createOperation(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit)

        // Get items in query
        var returnedItems: [T] = []
        addRecordMatchedBlock(operation: operation) { item in
            returnedItems.append(item)
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

    static private func addRecordMatchedBlock<T: CloudKitInterchangeable>(operation: CKQueryOperation, completion: @escaping (_ tradeBot: T) -> ()) {
        operation.recordFetchedBlock = { record in
            //Convert record to tradebot and call completion
            guard let item = T(record: record) else { return }
            completion(item)
        }
    }
    
    static private func addQueryResultBlock(operation: CKQueryOperation, completion: @escaping (_ finished: Bool) -> ()) {
        operation.queryCompletionBlock = { cursor, error in
            completion(true)
        }
    }

    static private func add(operation: CKDatabaseOperation) {
        container.publicCloudDatabase.add(operation)
    }
    
    static func add<T: CloudKitInterchangeable>(item: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        let record = item.record
        save(record: record, completion: completion)
    }
    
    static func update<T: CloudKitInterchangeable>(item: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        add(item: item, completion: completion)
    }
    
    static func save(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> Void) {
        container.publicCloudDatabase.save(record) { record, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    static func delete<T: CloudKitInterchangeable>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CloudKitUtility.delete(item: item, completion: promise)
        }
    }
    
    static private func delete<T: CloudKitInterchangeable>(item: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        CloudKitUtility.delete(record: item.record, completion: completion)
    }
    
    static private func delete(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> Void) {
        container.publicCloudDatabase.delete(withRecordID: record.recordID) {
            id, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    
    //MARK: - CHILD PARENT GETTERS
    static func fetchChildren<T: CloudKitInterchangeable, S: CloudKitInterchangeable>(parent: T, children: CKRecord.RecordType, completion: @escaping ([S]) -> Void) where S: CloudChild {
        let predicate = NSPredicate(format: parent.record.recordType, parent.record)
        fetch(predicate: predicate, recordType: children)
            .sink { _ in
                
            } receiveValue: { value in
                completion(value)
            }
    }
  
    
    //MARK: - CHILD PARENT SETTERS
    private static func setParent<T: CloudKitInterchangeable, S: CloudKitInterchangeable>(parent: T, child: S) where S: CloudChild {
        child.setReference(parent: parent)
    }
    
    private static func initializeArray<T: CloudKitInterchangeable, S: CloudKitInterchangeable>(array: [S], for parent: T) where S: CloudChild {
        array.forEach { child in
            CloudKitUtility.setParent(parent: parent, child: child)
        }
    }
    
    static private func addModifyRecordsBlock(operation: CKModifyRecordsOperation, completion: @escaping (_ finished: Bool) -> ()) {
        operation.modifyRecordsCompletionBlock = { x, y, z in
            completion(true)
        }
    }
    
    private static func saveArray<T: CloudKitInterchangeable, S: CloudKitInterchangeable>(array: [S], for parent: T, completion: @escaping (Bool) -> Void) where S: CloudChild {
        initializeArray(array: array, for: parent)
        let operation = CKModifyRecordsOperation(recordsToSave: array.map { $0.record }, recordIDsToDelete: nil)
        addModifyRecordsBlock(operation: operation) { success in
            completion(success)
        }
    }
    
    
}
