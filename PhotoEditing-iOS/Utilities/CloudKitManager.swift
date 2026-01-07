// DEPRECATED: CloudKit requires paid Apple Developer Program
// Use FirebaseStorageManager instead

/*
import Foundation
import CloudKit
import UIKit

class CloudKitManager: ObservableObject {
    
    static let shared = CloudKitManager()
    
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase
    
    @Published var iCloudAvailable: Bool = false
    @Published var isUploading: Bool = false
    @Published var uploadProgress: Double = 0.0
    
    private init() {
        container = CKContainer.default()
        publicDatabase = container.publicCloudDatabase
        privateDatabase = container.privateCloudDatabase
        
        checkiCloudStatus()
    }
    
    // MARK: - iCloud Status
    
    func checkiCloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.iCloudAvailable = true
                case .noAccount:
                    print("iCloud: No account")
                    self?.iCloudAvailable = false
                case .restricted:
                    print("iCloud: Restricted")
                    self?.iCloudAvailable = false
                case .couldNotDetermine:
                    print("iCloud: Could not determine")
                    self?.iCloudAvailable = false
                case .temporarilyUnavailable:
                    print("iCloud: Temporarily unavailable")
                    self?.iCloudAvailable = false
                @unknown default:
                    self?.iCloudAvailable = false
                }
                
                if let error = error {
                    print("iCloud status check error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Save Image to iCloud
    
    func saveImageToiCloud(image: UIImage, 
                          filename: String? = nil,
                          completion: @escaping (Result<CKRecord, Error>) -> Void) {
        
        guard iCloudAvailable else {
            completion(.failure(CloudKitError.iCloudNotAvailable))
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            completion(.failure(CloudKitError.imageConversionFailed))
            return
        }
        
        DispatchQueue.main.async {
            self.isUploading = true
            self.uploadProgress = 0.0
        }
        
        // Create temp file
        let tempDirectory = FileManager.default.temporaryDirectory
        let imageFilename = filename ?? "photo_\(Date().timeIntervalSince1970).jpg"
        let fileURL = tempDirectory.appendingPathComponent(imageFilename)
        
        do {
            try imageData.write(to: fileURL)
            
            // Create CKAsset
            let asset = CKAsset(fileURL: fileURL)
            
            // Create record
            let record = CKRecord(recordType: "EditedPhoto")
            record["image"] = asset
            record["createdAt"] = Date()
            record["filename"] = imageFilename
            record["size"] = imageData.count
            
            // Save to iCloud
            privateDatabase.save(record) { [weak self] savedRecord, error in
                // Clean up temp file
                try? FileManager.default.removeItem(at: fileURL)
                
                DispatchQueue.main.async {
                    self?.isUploading = false
                    self?.uploadProgress = 1.0
                    
                    if let error = error {
                        completion(.failure(error))
                    } else if let savedRecord = savedRecord {
                        completion(.success(savedRecord))
                    } else {
                        completion(.failure(CloudKitError.unknownError))
                    }
                }
            }
            
        } catch {
            DispatchQueue.main.async {
                self.isUploading = false
            }
            completion(.failure(error))
        }
    }
    
    // MARK: - Fetch Images from iCloud
    
    func fetchImagesFromiCloud(limit: Int = 20, 
                               completion: @escaping (Result<[CKRecord], Error>) -> Void) {
        
        guard iCloudAvailable else {
            completion(.failure(CloudKitError.iCloudNotAvailable))
            return
        }
        
        let query = CKQuery(recordType: "EditedPhoto", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.resultsLimit = limit
        
        var fetchedRecords: [CKRecord] = []
        
        queryOperation.recordMatchedBlock = { recordID, result in
            switch result {
            case .success(let record):
                fetchedRecords.append(record)
            case .failure(let error):
                print("Error fetching record: \(error.localizedDescription)")
            }
        }
        
        queryOperation.queryResultBlock = { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(.success(fetchedRecords))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        privateDatabase.add(queryOperation)
    }
    
    // MARK: - Delete Image from iCloud
    
    func deleteImageFromiCloud(recordID: CKRecord.ID, 
                               completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard iCloudAvailable else {
            completion(.failure(CloudKitError.iCloudNotAvailable))
            return
        }
        
        privateDatabase.delete(withRecordID: recordID) { deletedRecordID, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

// MARK: - CloudKit Errors

enum CloudKitError: LocalizedError {
    case iCloudNotAvailable
    case imageConversionFailed
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .iCloudNotAvailable:
            return "iCloud is not available. Please check your iCloud settings."
        case .imageConversionFailed:
            return "Failed to convert image data."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
*/
