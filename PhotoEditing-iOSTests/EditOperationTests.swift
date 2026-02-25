//import XCTest
//import CoreImage
//import SwiftUI
//import PixelEnginePackage
//@testable import PhotoEditing_iOS
//
///// Unit тесты для EditOperation моделей
//class EditOperationTests: XCTestCase {
//    
//    var testImage: CIImage!
//    
//    override func setUp() {
//        super.setUp()
//        
//        // Создаём тестовое изображение
//        let size = CGSize(width: 100, height: 100)
//        let rect = CGRect(origin: .zero, size: size)
//        testImage = CIImage(color: CIColor(red: 1, green: 0, blue: 0))
//            .cropped(to: rect)
//    }
//    
//    override func tearDown() {
//        testImage = nil
//        super.tearDown()
//    }
//    
//    // MARK: - FilterOperation Tests
//    
//    func testFilterOperation_Initialization() {
//        // When
//        let operation = FilterOperation(
//            filterName: "TestFilter",
//            lutIdentifier: "test_lut",
//            intensity: 0.8,
//            parameters: ["exposure": 0.5]
//        )
//        
//        // Then
//        XCTAssertEqual(operation.filterName, "TestFilter")
//        XCTAssertEqual(operation.lutIdentifier, "test_lut")
//        XCTAssertEqual(operation.intensity, 0.8)
//        XCTAssertEqual(operation.parameters["exposure"], 0.5)
//        XCTAssertEqual(operation.type, .filter)
//        XCTAssertTrue(operation.isReversible)
//        XCTAssertNotNil(operation.id)
//    }
//    
//    func testFilterOperation_Description() {
//        // Given
//        let operation = FilterOperation(filterName: "Vintage")
//        
//        // When
//        let description = operation.description
//        
//        // Then
//        XCTAssertTrue(description.contains("Vintage"))
//    }
//    
//    func testFilterOperation_Apply() {
//        // Given
//        let operation = FilterOperation(
//            filterName: "Test",
//            parameters: ["exposure": 0.5]
//        )
//        
//        // When
//        let result = operation.apply(to: testImage)
//        
//        // Then
//        XCTAssertNotNil(result)
//        // Базовая реализация возвращает то же изображение
//        XCTAssertEqual(result.extent, testImage.extent)
//    }
//    
//    // MARK: - TextOperation Tests
//    
//    func testTextOperation_Initialization() {
//        // When
//        let operation = TextOperation(
//            text: "Hello World",
//            position: CGPoint(x: 50, y: 100),
//            fontSize: 32,
//            fontName: "Helvetica",
//            color: .red,
//            rotation: 45,
//            scale: 1.5,
//            alignment: .center,
//            isBold: true,
//            isItalic: false
//        )
//        
//        // Then
//        XCTAssertEqual(operation.text, "Hello World")
//        XCTAssertEqual(operation.position, CGPoint(x: 50, y: 100))
//        XCTAssertEqual(operation.fontSize, 32)
//        XCTAssertEqual(operation.fontName, "Helvetica")
//        XCTAssertEqual(operation.rotation, 45)
//        XCTAssertEqual(operation.scale, 1.5)
//        XCTAssertEqual(operation.alignment, .center)
//        XCTAssertTrue(operation.isBold)
//        XCTAssertFalse(operation.isItalic)
//        XCTAssertEqual(operation.type, .text)
//        XCTAssertTrue(operation.isReversible)
//    }
//    
//    func testTextOperation_DefaultValues() {
//        // When
//        let operation = TextOperation(text: "Test")
//        
//        // Then
//        XCTAssertEqual(operation.fontSize, 24)
//        XCTAssertEqual(operation.fontName, "System")
//        XCTAssertEqual(operation.position, .zero)
//        XCTAssertEqual(operation.rotation, 0)
//        XCTAssertEqual(operation.scale, 1.0)
//        XCTAssertEqual(operation.alignment, .center)
//        XCTAssertFalse(operation.isBold)
//        XCTAssertFalse(operation.isItalic)
//    }
//    
//    func testTextOperation_Description() {
//        // Given
//        let operation = TextOperation(text: "This is a very long text that should be truncated")
//        
//        // When
//        let description = operation.description
//        
//        // Then
//        XCTAssertTrue(description.contains("Текст"))
//        XCTAssertTrue(description.contains("This is a very long"))
//    }
//    
//    func testTextOperation_Apply() {
//        // Given
//        let operation = TextOperation(text: "Test")
//        
//        // When
//        let result = operation.apply(to: testImage)
//        
//        // Then
//        XCTAssertNotNil(result)
//    }
//    
//    // MARK: - StickerOperation Tests
//    
//    func testStickerOperation_Initialization() {
//        // When
//        let operation = StickerOperation(
//            stickerIdentifier: "sticker_001",
//            imageName: "heart.png",
//            position: CGPoint(x: 100, y: 200),
//            size: CGSize(width: 50, height: 50),
//            rotation: 30,
//            scale: 1.2,
//            opacity: 0.8
//        )
//        
//        // Then
//        XCTAssertEqual(operation.stickerIdentifier, "sticker_001")
//        XCTAssertEqual(operation.imageName, "heart.png")
//        XCTAssertEqual(operation.position, CGPoint(x: 100, y: 200))
//        XCTAssertEqual(operation.size, CGSize(width: 50, height: 50))
//        XCTAssertEqual(operation.rotation, 30)
//        XCTAssertEqual(operation.scale, 1.2)
//        XCTAssertEqual(operation.opacity, 0.8)
//        XCTAssertEqual(operation.type, .sticker)
//        XCTAssertTrue(operation.isReversible)
//    }
//    
//    func testStickerOperation_DefaultValues() {
//        // When
//        let operation = StickerOperation(
//            stickerIdentifier: "test",
//            imageName: "test.png"
//        )
//        
//        // Then
//        XCTAssertEqual(operation.position, .zero)
//        XCTAssertEqual(operation.size, CGSize(width: 100, height: 100))
//        XCTAssertEqual(operation.rotation, 0)
//        XCTAssertEqual(operation.scale, 1.0)
//        XCTAssertEqual(operation.opacity, 1.0)
//    }
//    
//    func testStickerOperation_Description() {
//        // Given
//        let operation = StickerOperation(
//            stickerIdentifier: "heart_001",
//            imageName: "heart.png"
//        )
//        
//        // When
//        let description = operation.description
//        
//        // Then
//        XCTAssertTrue(description.contains("Стикер"))
//        XCTAssertTrue(description.contains("heart_001"))
//    }
//    
//    // MARK: - AdjustmentOperation Tests
//    
//    func testAdjustmentOperation_Exposure() {
//        // When
//        let operation = AdjustmentOperation(adjustmentType: .exposure, value: 0.5)
//        
//        // Then
//        XCTAssertEqual(operation.adjustmentType, .exposure)
//        XCTAssertEqual(operation.value, 0.5)
//        XCTAssertEqual(operation.type, .adjustment)
//        XCTAssertTrue(operation.isReversible)
//    }
//    
//    func testAdjustmentOperation_AllTypes() {
//        // Given
//        let types: [AdjustmentType] = [
//            .exposure, .contrast, .saturation, .brightness,
//            .temperature, .highlights, .shadows, .vignette,
//            .sharpen, .blur, .clarity
//        ]
//        
//        // When & Then
//        for type in types {
//            let operation = AdjustmentOperation(adjustmentType: type, value: 0.5)
//            XCTAssertEqual(operation.adjustmentType, type)
//            XCTAssertEqual(operation.value, 0.5)
//        }
//    }
//    
//    func testAdjustmentOperation_Description() {
//        // Given
//        let operation = AdjustmentOperation(adjustmentType: .exposure, value: 75)
//        
//        // When
//        let description = operation.description
//        
//        // Then
//        XCTAssertTrue(description.contains("Экспозиция"))
//        XCTAssertTrue(description.contains("75"))
//    }
//    
//    func testAdjustmentOperation_ApplyExposure() {
//        // Given
//        let operation = AdjustmentOperation(adjustmentType: .exposure, value: 0.5)
//        
//        // When
//        let result = operation.apply(to: testImage)
//        
//        // Then
//        XCTAssertNotNil(result)
//        // Проверяем что применён фильтр
//        XCTAssertNotEqual(result, testImage)
//    }
//    
//    func testAdjustmentOperation_ApplyContrast() {
//        // Given
//        let operation = AdjustmentOperation(adjustmentType: .contrast, value: 1.5)
//        
//        // When
//        let result = operation.apply(to: testImage)
//        
//        // Then
//        XCTAssertNotNil(result)
//    }
//    
//    func testAdjustmentOperation_ApplySaturation() {
//        // Given
//        let operation = AdjustmentOperation(adjustmentType: .saturation, value: 1.2)
//        
//        // When
//        let result = operation.apply(to: testImage)
//        
//        // Then
//        XCTAssertNotNil(result)
//    }
//    
//    // MARK: - AdjustmentType Tests
//    
//    func testAdjustmentType_DisplayNames() {
//        // Given
//        let expectedNames: [AdjustmentType: String] = [
//            .exposure: "Экспозиция",
//            .contrast: "Контраст",
//            .saturation: "Насыщенность",
//            .brightness: "Яркость",
//            .temperature: "Температура",
//            .highlights: "Света",
//            .shadows: "Тени",
//            .vignette: "Виньетка",
//            .sharpen: "Резкость",
//            .blur: "Размытие",
//            .clarity: "Четкость"
//        ]
//        
//        // When & Then
//        for (type, expectedName) in expectedNames {
//            XCTAssertEqual(type.displayName, expectedName)
//        }
//    }
//    
//    // MARK: - CodableColor Tests
//    
//    func testCodableColor_FromColor() {
//        // Given
//        let color = Color.red
//        
//        // When
//        let codableColor = CodableColor(color: color)
//        
//        // Then
//        XCTAssertGreaterThan(codableColor.red, 0.9)
//        XCTAssertLessThan(codableColor.green, 0.1)
//        XCTAssertLessThan(codableColor.blue, 0.1)
//        XCTAssertEqual(codableColor.alpha, 1.0, accuracy: 0.01)
//    }
//    
//    func testCodableColor_ToColor() {
//        // Given
//        let codableColor = CodableColor(color: Color.blue)
//        
//        // When
//        let color = codableColor.color
//        
//        // Then
//        XCTAssertNotNil(color)
//        // Проверяем что цвет синий (приблизительно)
//        let uiColor = UIColor(color)
//        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
//        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
//        XCTAssertLessThan(r, 0.1)
//        XCTAssertLessThan(g, 0.1)
//        XCTAssertGreaterThan(b, 0.9)
//    }
//    
//    func testCodableColor_RoundTrip() {
//        // Given
//        let originalColor = Color(red: 0.5, green: 0.7, blue: 0.3, opacity: 0.9)
//        
//        // When
//        let codable = CodableColor(color: originalColor)
//        let reconstructed = codable.color
//        
//        // Then
//        XCTAssertEqual(codable.red, 0.5, accuracy: 0.01)
//        XCTAssertEqual(codable.green, 0.7, accuracy: 0.01)
//        XCTAssertEqual(codable.blue, 0.3, accuracy: 0.01)
//        XCTAssertEqual(codable.alpha, 0.9, accuracy: 0.01)
//    }
//    
//    // MARK: - TextAlignment Tests
//    
//    func testTextAlignment_AllCases() {
//        // Given
//        let alignments: [PhotoEditing_iOS.TextAlignment] = [.left, .center, .right]
//        
//        // When & Then
//        for alignment in alignments {
//            XCTAssertNotNil(alignment.rawValue)
//        }
//    }
//    
//    // MARK: - AnyEditOperation Tests
//    
//    func testAnyEditOperation_WrapFilterOperation() {
//        // Given
//        let filterOp = FilterOperation(filterName: "Test")
//        
//        // When
//        let anyOp = AnyEditOperation(filterOp)
//        
//        // Then
//        XCTAssertEqual(anyOp.type, .filter)
//        XCTAssertEqual(anyOp.id, filterOp.id)
//        XCTAssertNotNil(anyOp.asFilterOperation())
//        XCTAssertNil(anyOp.asTextOperation())
//    }
//    
//    func testAnyEditOperation_WrapTextOperation() {
//        // Given
//        let textOp = TextOperation(text: "Test")
//        
//        // When
//        let anyOp = AnyEditOperation(textOp)
//        
//        // Then
//        XCTAssertEqual(anyOp.type, .text)
//        XCTAssertEqual(anyOp.id, textOp.id)
//        XCTAssertNotNil(anyOp.asTextOperation())
//        XCTAssertNil(anyOp.asFilterOperation())
//    }
//    
//    func testAnyEditOperation_WrapAdjustmentOperation() {
//        // Given
//        let adjOp = AdjustmentOperation(adjustmentType: .exposure, value: 0.5)
//        
//        // When
//        let anyOp = AnyEditOperation(adjOp)
//        
//        // Then
//        XCTAssertEqual(anyOp.type, .adjustment)
//        XCTAssertNotNil(anyOp.asAdjustmentOperation())
//        XCTAssertNil(anyOp.asStickerOperation())
//    }
//    
//    func testAnyEditOperation_Apply() {
//        // Given
//        let filterOp = FilterOperation(filterName: "Test", parameters: ["exposure": 0.5])
//        let anyOp = AnyEditOperation(filterOp)
//        
//        // When
//        let result = anyOp.apply(to: testImage)
//        
//        // Then
//        XCTAssertNotNil(result)
//    }
//    
//    // MARK: - Codable Tests
//    
//    func testFilterOperation_Codable() throws {
//        // Given
//        let operation = FilterOperation(
//            filterName: "TestFilter",
//            lutIdentifier: "test_lut",
//            intensity: 0.8,
//            parameters: ["exposure": 0.5, "contrast": 0.3]
//        )
//        
//        // When
//        let encoder = JSONEncoder()
//        let data = try encoder.encode(operation)
//        
//        let decoder = JSONDecoder()
//        let decoded = try decoder.decode(FilterOperation.self, from: data)
//        
//        // Then
//        XCTAssertEqual(decoded.filterName, operation.filterName)
//        XCTAssertEqual(decoded.lutIdentifier, operation.lutIdentifier)
//        XCTAssertEqual(decoded.intensity, operation.intensity)
//        XCTAssertEqual(decoded.parameters["exposure"], operation.parameters["exposure"])
//    }
//    
//    func testTextOperation_Codable() throws {
//        // Given
//        let operation = TextOperation(
//            text: "Test Text",
//            position: CGPoint(x: 100, y: 200),
//            fontSize: 24,
//            color: .red
//        )
//        
//        // When
//        let encoder = JSONEncoder()
//        let data = try encoder.encode(operation)
//        
//        let decoder = JSONDecoder()
//        let decoded = try decoder.decode(TextOperation.self, from: data)
//        
//        // Then
//        XCTAssertEqual(decoded.text, operation.text)
//        XCTAssertEqual(decoded.position, operation.position)
//        XCTAssertEqual(decoded.fontSize, operation.fontSize)
//    }
//    
//    func testAdjustmentOperation_Codable() throws {
//        // Given
//        let operation = AdjustmentOperation(adjustmentType: .exposure, value: 0.5)
//        
//        // When
//        let encoder = JSONEncoder()
//        let data = try encoder.encode(operation)
//        
//        let decoder = JSONDecoder()
//        let decoded = try decoder.decode(AdjustmentOperation.self, from: data)
//        
//        // Then
//        XCTAssertEqual(decoded.adjustmentType, operation.adjustmentType)
//        XCTAssertEqual(decoded.value, operation.value)
//    }
//    
//    func testAnyEditOperation_Codable() throws {
//        // Given
//        let filterOp = FilterOperation(filterName: "Test")
//        let anyOp = AnyEditOperation(filterOp)
//        
//        // When
//        let encoder = JSONEncoder()
//        encoder.dateEncodingStrategy = .iso8601
//        let data = try encoder.encode(anyOp)
//        
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        let decoded = try decoder.decode(AnyEditOperation.self, from: data)
//        
//        // Then
//        XCTAssertEqual(decoded.type, anyOp.type)
//        XCTAssertNotNil(decoded.asFilterOperation())
//    }
//    
//    // MARK: - Edge Cases
//    
//    func testFilterOperation_EmptyParameters() {
//        // When
//        let operation = FilterOperation(filterName: "Test", parameters: [:])
//        
//        // Then
//        XCTAssertTrue(operation.parameters.isEmpty)
//        XCTAssertNotNil(operation.apply(to: testImage))
//    }
//    
//    func testTextOperation_EmptyText() {
//        // When
//        let operation = TextOperation(text: "")
//        
//        // Then
//        XCTAssertEqual(operation.text, "")
//        XCTAssertTrue(operation.description.contains("Текст"))
//    }
//    
//    func testAdjustmentOperation_NegativeValue() {
//        // When
//        let operation = AdjustmentOperation(adjustmentType: .exposure, value: -1.0)
//        
//        // Then
//        XCTAssertEqual(operation.value, -1.0)
//        XCTAssertNotNil(operation.apply(to: testImage))
//    }
//    
//    func testAdjustmentOperation_LargeValue() {
//        // When
//        let operation = AdjustmentOperation(adjustmentType: .contrast, value: 10.0)
//        
//        // Then
//        XCTAssertEqual(operation.value, 10.0)
//        XCTAssertNotNil(operation.apply(to: testImage))
//    }
//}
