import XCTest
import CoreImage
import SwiftUI
import PixelEnginePackage
import Foundation
@testable import PhotoEditing_iOS

class TestHelpers {
    
    
    static func createTestImage(
        color: CIColor = CIColor(red: 1, green: 0, blue: 0),
        size: CGSize = CGSize(width: 100, height: 100)
    ) -> CIImage {
        let rect = CGRect(origin: .zero, size: size)
        return CIImage(color: color).cropped(to: rect)
    }
    
    static func createUIImage(
        color: UIColor = .red,
        size: CGSize = CGSize(width: 100, height: 100)
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
    static func createGradientImage(
        from: CIColor = CIColor(red: 0, green: 0, blue: 0),
        to: CIColor = CIColor(red: 1, green: 1, blue: 1),
        size: CGSize = CGSize(width: 100, height: 100)
    ) -> CIImage {
        let gradient = CIFilter(name: "CILinearGradient", parameters: [
            "inputPoint0": CIVector(x: 0, y: 0),
            "inputPoint1": CIVector(x: size.width, y: size.height),
            "inputColor0": from,
            "inputColor1": to
        ])
        
        return gradient?.outputImage?.cropped(to: CGRect(origin: .zero, size: size)) 
            ?? createTestImage(size: size)
    }
    
    
    static func createFilterOperation(
        name: String = "TestFilter",
        lutIdentifier: String? = "test_lut",
        intensity: Double = 1.0,
        parameters: [String: Double] = ["exposure": 0.5]
    ) -> FilterOperation {
        return FilterOperation(
            filterName: name,
            lutIdentifier: lutIdentifier,
            intensity: intensity,
            parameters: parameters
        )
    }
    
    static func createTextOperation(
        text: String = "Test Text",
        position: CGPoint = CGPoint(x: 100, y: 100),
        fontSize: CGFloat = 24,
        color: Color = .white
    ) -> TextOperation {
        return TextOperation(
            text: text,
            position: position,
            fontSize: fontSize,
            color: color
        )
    }
    
    static func createAdjustmentOperation(
        type: AdjustmentType = .exposure,
        value: Double = 0.5
    ) -> AdjustmentOperation {
        return AdjustmentOperation(adjustmentType: type, value: value)
    }
    
    static func createStickerOperation(
        identifier: String = "sticker_001",
        imageName: String = "test.png",
        position: CGPoint = .zero
    ) -> StickerOperation {
        return StickerOperation(
            stickerIdentifier: identifier,
            imageName: imageName,
            position: position
        )
    }
    
    
    static func assertImagesEqualInSize(
        _ image1: CIImage,
        _ image2: CIImage,
        accuracy: CGFloat = 0.1,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(image1.extent.width, image2.extent.width, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(image1.extent.height, image2.extent.height, accuracy: accuracy, file: file, line: line)
    }
    
    static func assertImageNotEmpty(
        _ image: CIImage?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertNotNil(image, "Image should not be nil", file: file, line: line)
        XCTAssertGreaterThan(image?.extent.width ?? 0, 0, "Image width should be > 0", file: file, line: line)
        XCTAssertGreaterThan(image?.extent.height ?? 0, 0, "Image height should be > 0", file: file, line: line)
    }
    
    
    static func createCodableColor(
        red: Double = 1.0,
        green: Double = 0.0,
        blue: Double = 0.0,
        alpha: Double = 1.0
    ) -> CodableColor {
        let color = Color(red: red, green: green, blue: blue, opacity: alpha)
        return CodableColor(color: color)
    }
    
    static func assertColorsEqual(
        _ color1: CodableColor,
        _ color2: CodableColor,
        accuracy: Double = 0.01,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(color1.red, color2.red, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(color1.green, color2.green, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(color1.blue, color2.blue, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(color1.alpha, color2.alpha, accuracy: accuracy, file: file, line: line)
    }
    
    
    static func encodeToJSON<T: Encodable>(
        _ object: T,
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .iso8601
    ) throws -> Foundation.Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(object)
    }
    
    static func decodeFromJSON<T: Decodable>(
        _ type: T.Type,
        from data: Foundation.Data,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601
    ) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        return try decoder.decode(type, from: data)
    }
    
    static func assertCodableRoundTrip<T: Codable & Equatable>(
        _ object: T,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let data = try encodeToJSON(object)
        let decoded = try decodeFromJSON(T.self, from: data)
        XCTAssertEqual(object, decoded, "Round-trip encoding/decoding should preserve equality", file: file, line: line)
    }
    
    
    static func waitForAsync(
        timeout: TimeInterval = 1.0,
        completion: @escaping (@escaping () -> Void) -> Void
    ) -> Bool {
        let expectation = XCTestExpectation(description: "Async operation")
        
        completion {
            expectation.fulfill()
        }
        
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
    
    
    static func measureTime(_ block: () -> Void) -> TimeInterval {
        let start = Date()
        block()
        return Date().timeIntervalSince(start)
    }
    
    static func assertPerformance(
        _ block: () -> Void,
        isFasterThan maxTime: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let elapsed = measureTime(block)
        XCTAssertLessThan(
            elapsed,
            maxTime,
            "Operation took \(elapsed)s, expected < \(maxTime)s",
            file: file,
            line: line
        )
    }
    
    
    static func createTestVectors(count: Int = 3) -> [CIVector] {
        return (0..<count).map { i in
            CIVector(x: CGFloat(i), y: CGFloat(i * 2), z: CGFloat(i * 3))
        }
    }
    
    static func assertVectorsEqual(
        _ vector1: CIVector,
        _ vector2: CIVector,
        accuracy: CGFloat = 0.001,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTAssertEqual(vector1.x, vector2.x, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(vector1.y, vector2.y, accuracy: accuracy, file: file, line: line)
        XCTAssertEqual(vector1.z, vector2.z, accuracy: accuracy, file: file, line: line)
    }
    
    
    static func randomDouble(min: Double = 0.0, max: Double = 1.0) -> Double {
        return Double.random(in: min...max)
    }
    
    static func randomCGFloat(min: CGFloat = 0.0, max: CGFloat = 1.0) -> CGFloat {
        return CGFloat.random(in: min...max)
    }
    
    static func randomPoint(
        xRange: ClosedRange<CGFloat> = 0...100,
        yRange: ClosedRange<CGFloat> = 0...100
    ) -> CGPoint {
        return CGPoint(
            x: CGFloat.random(in: xRange),
            y: CGFloat.random(in: yRange)
        )
    }
    
    static func randomColor() -> Color {
        return Color(
            red: randomDouble(),
            green: randomDouble(),
            blue: randomDouble()
        )
    }
}


extension XCTestCase {
    
    func expectation(timeout: TimeInterval = 1.0, description: String = "Async expectation") -> XCTestExpectation {
        return XCTestExpectation(description: description)
    }
    
    func wait(for expectations: [XCTestExpectation], timeout: TimeInterval = 1.0) {
        wait(for: expectations, timeout: timeout)
    }
}
