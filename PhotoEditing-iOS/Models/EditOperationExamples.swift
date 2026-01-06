import Foundation
import SwiftUI
import CoreImage

// MARK: - Example 1: Основное использование

class EditOperationExamples {
    
    static func example1_BasicUsage() {
        // Создаём менеджер
        let manager = EditOperationManager()
        
        // Устанавливаем оригинальное изображение
        if let image = UIImage(named: "sample") {
            let ciImage = CIImage(image: image)!
            manager.setOriginalImage(ciImage)
        }
        
        // Добавляем операцию фильтра
        let filterOp = FilterOperation(
            filterName: "Vintage",
            lutIdentifier: "vintage_01",
            intensity: 0.8,
            parameters: [
                "exposure": 0.2,
                "contrast": 1.1,
                "saturation": 0.9
            ]
        )
        manager.addOperation(filterOp)
        
        // Добавляем текст
        let textOp = TextOperation(
            text: "Summer Vibes",
            position: CGPoint(x: 100, y: 200),
            fontSize: 32,
            color: .white
        )
        manager.addOperation(textOp)
        
        // Добавляем регулировку яркости
        let adjustmentOp = AdjustmentOperation(
            adjustmentType: .brightness,
            value: 0.15
        )
        manager.addOperation(adjustmentOp)
        
        // Получаем финальное изображение
        if let finalImage = manager.getCurrentImage() {
            print("✅ Обработано с \(manager.operations.count) операциями")
        }
    }
    
    // MARK: - Example 2: Undo/Redo
    
    static func example2_UndoRedo() {
        let manager = EditOperationManager()
        
        // Добавляем несколько операций
        manager.addOperation(FilterOperation(filterName: "Filter 1"))
        manager.addOperation(TextOperation(text: "Hello"))
        manager.addOperation(AdjustmentOperation(adjustmentType: .contrast, value: 1.2))
        
        print("Операций: \(manager.operations.count)") // 3
        print("Текущий индекс: \(manager.currentIndex)") // 2
        
        // Отменяем последнюю
        manager.undo()
        print("После undo: индекс = \(manager.currentIndex)") // 1
        
        // Отменяем ещё одну
        manager.undo()
        print("После undo: индекс = \(manager.currentIndex)") // 0
        
        // Возвращаем
        manager.redo()
        print("После redo: индекс = \(manager.currentIndex)") // 1
    }
    
    // MARK: - Example 3: Фильтрация операций
    
    static func example3_FilterOperations() {
        let manager = EditOperationManager()
        
        // Добавляем разные типы операций
        manager.addOperation(FilterOperation(filterName: "Filter 1"))
        manager.addOperation(TextOperation(text: "Text 1"))
        manager.addOperation(FilterOperation(filterName: "Filter 2"))
        manager.addOperation(StickerOperation(stickerIdentifier: "heart", imageName: "heart"))
        manager.addOperation(TextOperation(text: "Text 2"))
        
        // Получаем только текстовые операции
        let textOps = manager.getOperations(ofType: .text)
        print("Текстовых операций: \(textOps.count)") // 2
        
        // Получаем только фильтры
        let filterOps = manager.getOperations(ofType: .filter)
        print("Фильтров: \(filterOps.count)") // 2
        
        // Статистика
        let stats = manager.getStatistics()
        print("Всего операций: \(stats.totalOperations)") // 5
        print("По типам: \(stats.operationsByType)")
    }
    
    // MARK: - Example 4: Сохранение и загрузка (рецепты)
    
    static func example4_SaveAndLoad() {
        let manager = EditOperationManager()
        
        // Добавляем операции
        manager.addOperation(FilterOperation(filterName: "Vintage"))
        manager.addOperation(AdjustmentOperation(adjustmentType: .exposure, value: 0.3))
        manager.addOperation(AdjustmentOperation(adjustmentType: .saturation, value: 1.2))
        
        // Экспортируем в Data
        if let exportedData = manager.exportOperations() {
            print("✅ Экспортировано \(exportedData.count) байт")
            
            // Сохраняем в файл или UserDefaults
            UserDefaults.standard.set(exportedData, forKey: "myRecipe")
            
            // Позже загружаем
            if let savedData = UserDefaults.standard.data(forKey: "myRecipe") {
                let newManager = EditOperationManager()
                try? newManager.importOperations(from: savedData)
                print("✅ Загружено \(newManager.operations.count) операций")
            }
        }
    }
    
    // MARK: - Example 5: Создание кастомной операции
    
    static func example5_CustomOperation() {
        // Создаём свою кастомную операцию
        struct VignetteOperation: EditOperation {
            let id = UUID()
            let type = EditOperationType.custom
            let timestamp = Date()
            
            var radius: Double
            var intensity: Double
            
            var description: String {
                return "Виньетка (радиус: \(radius), интенсивность: \(intensity))"
            }
            
            var isReversible: Bool { true }
            
            func apply(to image: CIImage) -> CIImage {
                let filter = CIFilter(name: "CIVignette")
                filter?.setValue(image, forKey: kCIInputImageKey)
                filter?.setValue(radius, forKey: "inputRadius")
                filter?.setValue(intensity, forKey: "inputIntensity")
                return filter?.outputImage ?? image
            }
        }
        
        // Используем
        let manager = EditOperationManager()
        let vignette = VignetteOperation(radius: 1.5, intensity: 0.8)
        manager.addOperation(vignette)
    }
    
    // MARK: - Example 6: Интеграция с существующим PhotoEditingController
    
    static func example6_Integration() {
        // В PhotoEditingController добавляем:
        // var operationManager = EditOperationManager()
        
        // При добавлении фильтра через старую систему,
        // также создаём операцию в новой:
        
        /*
        func applyFilterWithOperation(lutIdentifier: String) {
            // Старый способ (для совместимости с PixelEngine)
            editState?.set(filters: { filters in
                filters.colorCube = getFilter(for: lutIdentifier)
            })
            editState?.commit()
            
            // Новый способ (для истории и рецептов)
            let operation = FilterOperation(
                filterName: lutIdentifier,
                lutIdentifier: lutIdentifier,
                intensity: 1.0
            )
            operationManager.addOperation(operation)
            
            apply()
        }
        */
    }
    
    // MARK: - Example 7: Удаление конкретных операций
    
    static func example7_RemoveOperations() {
        let manager = EditOperationManager()
        
        // Добавляем операции
        let filter1 = FilterOperation(filterName: "Filter 1")
        let text1 = TextOperation(text: "Hello")
        let filter2 = FilterOperation(filterName: "Filter 2")
        
        manager.addOperation(filter1)
        manager.addOperation(text1)
        manager.addOperation(filter2)
        
        print("Операций до удаления: \(manager.operations.count)") // 3
        
        // Удаляем текстовую операцию по ID
        manager.removeOperation(id: text1.id)
        
        print("Операций после удаления: \(manager.operations.count)") // 2
        
        // Теперь остались только фильтры
        let remaining = manager.getOperations(ofType: .filter)
        print("Осталось фильтров: \(remaining.count)") // 2
    }
    
    // MARK: - Example 8: Snapshot/Restore для сложного undo
    
    static func example8_Snapshots() {
        let manager = EditOperationManager()
        
        // Начальное состояние
        manager.addOperation(FilterOperation(filterName: "Filter 1"))
        manager.addOperation(TextOperation(text: "Text 1"))
        
        // Создаём снимок
        let snapshot1 = manager.createSnapshot()
        print("Снимок 1: \(snapshot1.operations.count) операций")
        
        // Добавляем ещё операции
        manager.addOperation(FilterOperation(filterName: "Filter 2"))
        manager.addOperation(StickerOperation(stickerIdentifier: "heart", imageName: "heart"))
        
        // Создаём ещё снимок
        let snapshot2 = manager.createSnapshot()
        print("Снимок 2: \(snapshot2.operations.count) операций")
        
        // Добавляем ещё
        manager.addOperation(TextOperation(text: "Text 2"))
        print("Текущее: \(manager.operations.count) операций")
        
        // Возвращаемся к снимку 1
        manager.restore(from: snapshot1)
        print("После restore: \(manager.operations.count) операций")
    }
}

// MARK: - Migration Guide

/**
 ## Как мигрировать существующий код
 
 ### Было (старый подход):
 ```swift
 editState?.set(filters: { filters in
     filters.colorCube = someFilter
     filters.exposure = 0.5
     filters.contrast = 1.2
 })
 editState?.commit()
 ```
 
 ### Стало (новый подход):
 ```swift
 // Создаём операцию
 let operation = FilterOperation(
     filterName: "MyFilter",
     lutIdentifier: "filter_01",
     parameters: [
         "exposure": 0.5,
         "contrast": 1.2
     ]
 )
 
 // Добавляем в менеджер
 operationManager.addOperation(operation)
 
 // Для совместимости также применяем к EditingStack
 editState?.set(filters: { filters in
     filters.colorCube = someFilter
     filters.exposure = 0.5
     filters.contrast = 1.2
 })
 editState?.commit()
 ```
 
 ## Постепенная миграция
 
 1. Добавьте `EditOperationManager` в `PhotoEditingController`
 2. При каждом изменении фильтров создавайте соответствующую операцию
 3. Используйте операции для:
    - Сохранения рецептов
    - Истории изменений
    - Undo/Redo на более высоком уровне
 4. Постепенно переносите логику на операции
 
 ## Roadmap
 
 - [ ] Интегрировать EditOperationManager в PhotoEditingController
 - [ ] Добавить UI для просмотра истории операций
 - [ ] Реализовать сохранение операций в CoreData
 - [ ] Добавить поддержку слоёв (layers)
 - [ ] Реализовать композитные операции (macro operations)
 - [ ] Добавить превью для каждой операции в истории
 */

