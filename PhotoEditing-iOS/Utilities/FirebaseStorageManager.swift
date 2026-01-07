import Foundation
import UIKit
import FirebaseStorage
import FirebaseCore

class FirebaseStorageManager: ObservableObject {
    
    static let shared = FirebaseStorageManager()
    
    private let storage: Storage
    private let storageRef: StorageReference
    
    @Published var isAvailable: Bool = false
    @Published var isUploading: Bool = false
    @Published var uploadProgress: Double = 0.0
    
    private init() {
        // Firebase будет инициализирован в AppDelegate/SceneDelegate
        self.storage = Storage.storage()
        self.storageRef = storage.reference()
        
        // Проверяем доступность Firebase
        checkFirebaseStatus()
    }
    
    // MARK: - Firebase Status
    
    func checkFirebaseStatus() {
        // Проверяем, инициализирован ли Firebase
        if FirebaseApp.app() != nil {
            isAvailable = true
            print("Firebase Storage: Available")
        } else {
            isAvailable = false
            print("Firebase Storage: Not configured")
        }
    }
    
    // MARK: - Save Image to Firebase Storage
    
    func saveImageToFirebase(image: UIImage,
                            filename: String? = nil,
                            completion: @escaping (Result<URL, Error>) -> Void) {
        
        guard isAvailable else {
            completion(.failure(FirebaseStorageError.firebaseNotConfigured))
            return
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            completion(.failure(FirebaseStorageError.imageConversionFailed))
            return
        }
        
        DispatchQueue.main.async {
            self.isUploading = true
            self.uploadProgress = 0.0
        }
        
        // Создаем уникальное имя файла
        let imageFilename = filename ?? "edited_photo_\(Date().timeIntervalSince1970).jpg"
        let imageRef = storageRef.child("edited_photos/\(imageFilename)")
        
        // Метаданные
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.customMetadata = [
            "uploadDate": ISO8601DateFormatter().string(from: Date()),
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]
        
        // Загружаем файл
        let uploadTask = imageRef.putData(imageData, metadata: metadata) { [weak self] metadata, error in
            DispatchQueue.main.async {
                self?.isUploading = false
                self?.uploadProgress = 1.0
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Получаем URL загруженного файла
                imageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        print("Firebase Storage: Image uploaded successfully to \(url.absoluteString)")
                        completion(.success(url))
                    } else {
                        completion(.failure(FirebaseStorageError.unknownError))
                    }
                }
            }
        }
        
        // Отслеживаем прогресс загрузки
        uploadTask.observe(.progress) { [weak self] snapshot in
            guard let progress = snapshot.progress else { return }
            let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            
            DispatchQueue.main.async {
                self?.uploadProgress = percentComplete
            }
        }
    }
    
    // MARK: - Fetch Images from Firebase Storage
    
    func fetchImagesFromFirebase(limit: Int = 20,
                                 completion: @escaping (Result<[StorageReference], Error>) -> Void) {
        
        guard isAvailable else {
            completion(.failure(FirebaseStorageError.firebaseNotConfigured))
            return
        }
        
        let photosRef = storageRef.child("edited_photos")
        
        photosRef.listAll { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let result = result else {
                completion(.failure(FirebaseStorageError.unknownError))
                return
            }
            
            // Берем только нужное количество файлов
            let limitedItems = Array(result.items.prefix(limit))
            completion(.success(limitedItems))
        }
    }
    
    // MARK: - Delete Image from Firebase Storage
    
    func deleteImageFromFirebase(at path: String,
                                 completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard isAvailable else {
            completion(.failure(FirebaseStorageError.firebaseNotConfigured))
            return
        }
        
        let imageRef = storage.reference(withPath: path)
        
        imageRef.delete { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    print("Firebase Storage: Image deleted successfully")
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Download Image
    
    func downloadImage(from reference: StorageReference,
                      completion: @escaping (Result<UIImage, Error>) -> Void) {
        
        // Максимальный размер загрузки (10MB)
        let maxSize: Int64 = 10 * 1024 * 1024
        
        reference.getData(maxSize: maxSize) { data, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    completion(.failure(FirebaseStorageError.imageConversionFailed))
                    return
                }
                
                completion(.success(image))
            }
        }
    }
}

// MARK: - Firebase Storage Errors

enum FirebaseStorageError: LocalizedError {
    case firebaseNotConfigured
    case imageConversionFailed
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase is not configured. Please add GoogleService-Info.plist and initialize Firebase."
        case .imageConversionFailed:
            return "Failed to convert image data."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}

