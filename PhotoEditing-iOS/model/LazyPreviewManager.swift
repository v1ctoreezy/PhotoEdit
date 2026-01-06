import Foundation
import SwiftUI
import PixelEnginePackage
import CoreImage

// MARK: - Lazy Preview Manager
/// Manages lazy loading of filter previews to optimize performance
class LazyPreviewManager: ObservableObject {
    
    // Singleton instance
    static let shared = LazyPreviewManager()
    
    // Published properties for SwiftUI updates
    @Published private var previewCache: [String: CGImage] = [:]
    
    // Private properties
    private let processingQueue = DispatchQueue(label: "com.photoediting.preview", qos: .userInitiated)
    private let maxConcurrentOperations = 3
    private let maxCacheSize = 50 // Maximum number of cached previews
    private var activeOperations = 0
    private let operationLock = NSLock()
    private var pendingOperations: [(id: String, priority: Int, work: () -> Void)] = []
    private var cacheAccessOrder: [String] = [] // LRU cache tracking
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Get cached preview or return nil
    func getCachedPreview(for identifier: String) -> CGImage? {
        if let image = previewCache[identifier] {
            // Update LRU order
            updateCacheAccess(for: identifier)
            return image
        }
        return nil
    }
    
    /// Check if preview is cached
    func isPreviewCached(for identifier: String) -> Bool {
        return previewCache[identifier] != nil
    }
    
    /// Request preview generation with priority
    func requestPreview(
        identifier: String,
        priority: Int = 0,
        sourceImage: CIImage,
        filter: FilterColorCube,
        completion: @escaping (CGImage?) -> Void
    ) {
        // Check cache first
        if let cached = previewCache[identifier] {
            DispatchQueue.main.async {
                completion(cached)
            }
            return
        }
        
        // Add to queue
        let work = { [weak self] in
            self?.generatePreview(
                identifier: identifier,
                sourceImage: sourceImage,
                filter: filter,
                completion: completion
            )
        }
        
        operationLock.lock()
        pendingOperations.append((id: identifier, priority: priority, work: { work() }))
        pendingOperations.sort { $0.priority > $1.priority }
        operationLock.unlock()
        
        processNextOperation()
    }
    
    /// Request recipe preview generation
    func requestRecipePreview(
        identifier: String,
        priority: Int = 0,
        sourceImage: CIImage,
        filters: @escaping (inout EditingStack.Edit.Filters) -> Void,
        completion: @escaping (CGImage?) -> Void
    ) {
        // Check cache first
        if let cached = previewCache[identifier] {
            DispatchQueue.main.async {
                completion(cached)
            }
            return
        }
        
        // Add to queue
        let work = { [weak self] in
            self?.generateRecipePreview(
                identifier: identifier,
                sourceImage: sourceImage,
                filters: filters,
                completion: completion
            )
        }
        
        operationLock.lock()
        pendingOperations.append((id: identifier, priority: priority, work: {work()}))
        pendingOperations.sort { $0.priority > $1.priority }
        operationLock.unlock()
        
        processNextOperation()
    }
    
    /// Clear all cached previews
    func clearCache() {
        previewCache.removeAll()
        cacheAccessOrder.removeAll()
        print("LazyPreviewManager: Cache cleared")
    }
    
    /// Clear specific preview from cache
    func clearPreview(for identifier: String) {
        previewCache.removeValue(forKey: identifier)
        if let index = cacheAccessOrder.firstIndex(of: identifier) {
            cacheAccessOrder.remove(at: index)
        }
    }
    
    /// Get cache statistics
    func getCacheStats() -> (count: Int, maxSize: Int) {
        return (previewCache.count, maxCacheSize)
    }
    
    // MARK: - Private Methods
    
    private func processNextOperation() {
        operationLock.lock()
        
        guard activeOperations < maxConcurrentOperations,
              !pendingOperations.isEmpty else {
            operationLock.unlock()
            return
        }
        
        let operation = pendingOperations.removeFirst()
        activeOperations += 1
        operationLock.unlock()
        
        processingQueue.async {
            operation.work()
            
            self.operationLock.lock()
            self.activeOperations -= 1
            self.operationLock.unlock()
            
            self.processNextOperation()
        }
    }
    
    private func generatePreview(
        identifier: String,
        sourceImage: CIImage,
        filter: FilterColorCube,
        completion: @escaping (CGImage?) -> Void
    ) {
        autoreleasepool {
            // Create a smaller preview image for better performance
            let preview = PreviewFilterColorCube(sourceImage: sourceImage, filter: filter)
            let cgImage = preview.cgImage
            
            // Cache the result
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.cachePreview(cgImage, for: identifier)
                completion(cgImage)
            }
        }
    }
    
    private func generateRecipePreview(
        identifier: String,
        sourceImage: CIImage,
        filters: (inout EditingStack.Edit.Filters) -> Void,
        completion: @escaping (CGImage?) -> Void
    ) {
        autoreleasepool {
            let draft = EditingStack(source: StaticImageSource(source: sourceImage))
            draft.set(filters: filters)
            
            guard let ciImage = draft.previewImage,
                  let cgImage = sharedContext.createCGImage(ciImage, from: ciImage.extent) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the result
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.cachePreview(cgImage, for: identifier)
                completion(cgImage)
            }
        }
    }
    
    // MARK: - Cache Management
    
    private func cachePreview(_ image: CGImage, for identifier: String) {
        // Add to cache
        previewCache[identifier] = image
        
        // Update access order
        updateCacheAccess(for: identifier)
        
        // Enforce cache size limit (LRU eviction)
        if previewCache.count > maxCacheSize {
            evictLeastRecentlyUsed()
        }
    }
    
    private func updateCacheAccess(for identifier: String) {
        // Remove from current position if exists
        if let index = cacheAccessOrder.firstIndex(of: identifier) {
            cacheAccessOrder.remove(at: index)
        }
        // Add to end (most recently used)
        cacheAccessOrder.append(identifier)
    }
    
    private func evictLeastRecentlyUsed() {
        guard !cacheAccessOrder.isEmpty else { return }
        
        // Remove oldest item
        let oldestIdentifier = cacheAccessOrder.removeFirst()
        previewCache.removeValue(forKey: oldestIdentifier)
        
        print("LazyPreviewManager: Evicted '\(oldestIdentifier)' from cache (LRU policy)")
    }
}

// MARK: - Lazy Preview State
/// State object for tracking preview loading in SwiftUI views
class LazyPreviewState: ObservableObject {
    @Published var image: CGImage?
    @Published var isLoading: Bool = false
    
    private var identifier: String?
    
    func loadPreview(
        identifier: String,
        priority: Int = 0,
        sourceImage: CIImage,
        filter: FilterColorCube
    ) {
        self.identifier = identifier
        
        // Check cache first
        if let cached = LazyPreviewManager.shared.getCachedPreview(for: identifier) {
            self.image = cached
            self.isLoading = false
            return
        }
        
        self.isLoading = true
        
        LazyPreviewManager.shared.requestPreview(
            identifier: identifier,
            priority: priority,
            sourceImage: sourceImage,
            filter: filter
        ) { [weak self] cgImage in
            guard self?.identifier == identifier else { return }
            self?.image = cgImage
            self?.isLoading = false
        }
    }
    
    func loadRecipePreview(
        identifier: String,
        priority: Int = 0,
        sourceImage: CIImage,
        filters: @escaping (inout EditingStack.Edit.Filters) -> Void
    ) {
        self.identifier = identifier
        
        // Check cache first
        if let cached = LazyPreviewManager.shared.getCachedPreview(for: identifier) {
            self.image = cached
            self.isLoading = false
            return
        }
        
        self.isLoading = true
        
        LazyPreviewManager.shared.requestRecipePreview(
            identifier: identifier,
            priority: priority,
            sourceImage: sourceImage,
            filters: filters
        ) { [weak self] cgImage in
            guard self?.identifier == identifier else { return }
            self?.image = cgImage
            self?.isLoading = false
        }
    }
}

