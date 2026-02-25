//import XCTest
//import CoreImage
//import PixelEnginePackage
//@testable import PhotoEditing_iOS
//
///// Unit тесты для RecipeUtils
//class RecipeUtilsTests: XCTestCase {
//    
//    // MARK: - String to Array Vector Tests
//    
//    func testStringToArrayVector_EmptyString() {
//        // Given
//        let emptyString = ""
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(emptyString)
//        
//        // Then
//        XCTAssertEqual(result.count, FilterHLS.defaultValue.count)
//        // Проверяем что вернулось дефолтное значение
//        for (index, vector) in result.enumerated() {
//            let defaultVector = FilterHLS.defaultValue[index]
//            XCTAssertEqual(vector.x, defaultVector.x, accuracy: 0.001)
//            XCTAssertEqual(vector.y, defaultVector.y, accuracy: 0.001)
//            XCTAssertEqual(vector.z, defaultVector.z, accuracy: 0.001)
//        }
//    }
//    
//    func testStringToArrayVector_ValidString() {
//        // Given
//        let validString = "1.0,2.0,3.0;4.0,5.0,6.0;7.0,8.0,9.0"
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(validString)
//        
//        // Then
//        XCTAssertGreaterThanOrEqual(result.count, 3)
//        XCTAssertEqual(result[0].x, 1.0, accuracy: 0.001)
//        XCTAssertEqual(result[0].y, 2.0, accuracy: 0.001)
//        XCTAssertEqual(result[0].z, 3.0, accuracy: 0.001)
//        XCTAssertEqual(result[1].x, 4.0, accuracy: 0.001)
//        XCTAssertEqual(result[1].y, 5.0, accuracy: 0.001)
//        XCTAssertEqual(result[1].z, 6.0, accuracy: 0.001)
//    }
//    
//    func testStringToArrayVector_WithNegativeValues() {
//        // Given
//        let stringWithNegatives = "-1.5,2.5,-3.5;0.0,0.0,0.0"
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(stringWithNegatives)
//        
//        // Then
//        XCTAssertGreaterThanOrEqual(result.count, 2)
//        XCTAssertEqual(result[0].x, -1.5, accuracy: 0.001)
//        XCTAssertEqual(result[0].y, 2.5, accuracy: 0.001)
//        XCTAssertEqual(result[0].z, -3.5, accuracy: 0.001)
//        XCTAssertEqual(result[1].x, 0.0, accuracy: 0.001)
//    }
//    
//    func testStringToArrayVector_WithDecimals() {
//        // Given
//        let stringWithDecimals = "0.123,0.456,0.789"
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(stringWithDecimals)
//        
//        // Then
//        XCTAssertGreaterThanOrEqual(result.count, 1)
//        XCTAssertEqual(result[0].x, 0.123, accuracy: 0.001)
//        XCTAssertEqual(result[0].y, 0.456, accuracy: 0.001)
//        XCTAssertEqual(result[0].z, 0.789, accuracy: 0.001)
//    }
//    
//    func testStringToArrayVector_MalformedString() {
//        // Given
//        let malformedString = "invalid,data"
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(malformedString)
//        
//        // Then
//        // Должен вернуться массив векторов (возможно с нулями)
//        XCTAssertGreaterThan(result.count, 0)
//    }
//    
//    // MARK: - Array Vector to String Tests
//    
//    func testArrayVectorToString_Nil() {
//        // Given
//        let nilArray: [CIVector]? = nil
//        
//        // When
//        let result = RecipeUtils.arrayVectorToString(nilArray)
//        
//        // Then
//        XCTAssertEqual(result, "")
//    }
//    
//    func testArrayVectorToString_EmptyArray() {
//        // Given
//        let emptyArray: [CIVector] = []
//        
//        // When
//        let result = RecipeUtils.arrayVectorToString(emptyArray)
//        
//        // Then
//        XCTAssertEqual(result, "")
//    }
//    
//    func testArrayVectorToString_SingleVector() {
//        // Given
//        let vector = CIVector(x: 1.0, y: 2.0, z: 3.0)
//        let array = [vector]
//        
//        // When
//        let result = RecipeUtils.arrayVectorToString(array)
//        
//        // Then
//        XCTAssertTrue(result.contains("1.0"))
//        XCTAssertTrue(result.contains("2.0"))
//        XCTAssertTrue(result.contains("3.0"))
//        XCTAssertFalse(result.contains(";"))
//    }
//    
//    func testArrayVectorToString_MultipleVectors() {
//        // Given
//        let vector1 = CIVector(x: 1.0, y: 2.0, z: 3.0)
//        let vector2 = CIVector(x: 4.0, y: 5.0, z: 6.0)
//        let array = [vector1, vector2]
//        
//        // When
//        let result = RecipeUtils.arrayVectorToString(array)
//        
//        // Then
//        XCTAssertTrue(result.contains("1.0"))
//        XCTAssertTrue(result.contains("2.0"))
//        XCTAssertTrue(result.contains("3.0"))
//        XCTAssertTrue(result.contains("4.0"))
//        XCTAssertTrue(result.contains("5.0"))
//        XCTAssertTrue(result.contains("6.0"))
//        XCTAssertTrue(result.contains(";"))
//    }
//    
//    func testArrayVectorToString_WithNegativeValues() {
//        // Given
//        let vector = CIVector(x: -1.5, y: 2.5, z: -3.5)
//        let array = [vector]
//        
//        // When
//        let result = RecipeUtils.arrayVectorToString(array)
//        
//        // Then
//        XCTAssertTrue(result.contains("-1.5"))
//        XCTAssertTrue(result.contains("2.5"))
//        XCTAssertTrue(result.contains("-3.5"))
//    }
//    
//    func testArrayVectorToString_WithZeros() {
//        // Given
//        let vector = CIVector(x: 0.0, y: 0.0, z: 0.0)
//        let array = [vector]
//        
//        // When
//        let result = RecipeUtils.arrayVectorToString(array)
//        
//        // Then
//        XCTAssertTrue(result.contains("0.0"))
//    }
//    
//    // MARK: - Round Trip Tests
//    
//    func testVectorConversion_RoundTrip() {
//        // Given
//        let originalVectors = [
//            CIVector(x: 1.0, y: 2.0, z: 3.0),
//            CIVector(x: 4.5, y: 5.5, z: 6.5),
//            CIVector(x: -1.0, y: -2.0, z: -3.0)
//        ]
//        
//        // When
//        let string = RecipeUtils.arrayVectorToString(originalVectors)
//        let reconstructed = RecipeUtils.stringToArrayVector(string)
//        
//        // Then
//        XCTAssertGreaterThanOrEqual(reconstructed.count, 3)
//        for i in 0..<3 {
//            XCTAssertEqual(reconstructed[i].x, originalVectors[i].x, accuracy: 0.001)
//            XCTAssertEqual(reconstructed[i].y, originalVectors[i].y, accuracy: 0.001)
//            XCTAssertEqual(reconstructed[i].z, originalVectors[i].z, accuracy: 0.001)
//        }
//    }
//    
//    func testVectorConversion_RoundTripWithDecimals() {
//        // Given
//        let originalVectors = [
//            CIVector(x: 0.123, y: 0.456, z: 0.789),
//            CIVector(x: 1.111, y: 2.222, z: 3.333)
//        ]
//        
//        // When
//        let string = RecipeUtils.arrayVectorToString(originalVectors)
//        let reconstructed = RecipeUtils.stringToArrayVector(string)
//        
//        // Then
//        XCTAssertGreaterThanOrEqual(reconstructed.count, 2)
//        for i in 0..<2 {
//            XCTAssertEqual(reconstructed[i].x, originalVectors[i].x, accuracy: 0.001)
//            XCTAssertEqual(reconstructed[i].y, originalVectors[i].y, accuracy: 0.001)
//            XCTAssertEqual(reconstructed[i].z, originalVectors[i].z, accuracy: 0.001)
//        }
//    }
//    
//    func testVectorConversion_RoundTripEmptyString() {
//        // Given
//        let emptyString = ""
//        
//        // When
//        let vectors = RecipeUtils.stringToArrayVector(emptyString)
//        let backToString = RecipeUtils.arrayVectorToString(vectors)
//        let backToVectors = RecipeUtils.stringToArrayVector(backToString)
//        
//        // Then
//        XCTAssertEqual(vectors.count, backToVectors.count)
//    }
//    
//    // MARK: - Format Tests
//    
//    func testArrayVectorToString_Format() {
//        // Given
//        let vector1 = CIVector(x: 1.0, y: 2.0, z: 3.0)
//        let vector2 = CIVector(x: 4.0, y: 5.0, z: 6.0)
//        let array = [vector1, vector2]
//        
//        // When
//        let result = RecipeUtils.arrayVectorToString(array)
//        
//        // Then
//        // Проверяем формат: "x,y,z;x,y,z"
//        let components = result.components(separatedBy: ";")
//        XCTAssertEqual(components.count, 2)
//        
//        let firstVector = components[0].components(separatedBy: ",")
//        XCTAssertEqual(firstVector.count, 3)
//    }
//    
//    func testStringToArrayVector_HandlesWhitespace() {
//        // Given
//        let stringWithSpaces = "1.0, 2.0, 3.0"
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(stringWithSpaces)
//        
//        // Then
//        // Функция должна обработать пробелы
//        XCTAssertGreaterThan(result.count, 0)
//    }
//    
//    // MARK: - Edge Cases
//    
//    func testStringToArrayVector_SingleNumber() {
//        // Given
//        let singleNumber = "5.0"
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(singleNumber)
//        
//        // Then
//        XCTAssertGreaterThan(result.count, 0)
//    }
//    
//    func testStringToArrayVector_ExtraCommas() {
//        // Given
//        let extraCommas = "1.0,2.0,3.0,,,"
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(extraCommas)
//        
//        // Then
//        XCTAssertGreaterThan(result.count, 0)
//    }
//    
//    func testStringToArrayVector_ExtraSemicolons() {
//        // Given
//        let extraSemicolons = "1.0,2.0,3.0;;4.0,5.0,6.0"
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(extraSemicolons)
//        
//        // Then
//        XCTAssertGreaterThan(result.count, 0)
//    }
//    
//    func testArrayVectorToString_LargeNumbers() {
//        // Given
//        let vector = CIVector(x: 999999.999, y: -999999.999, z: 0.000001)
//        let array = [vector]
//        
//        // When
//        let result = RecipeUtils.arrayVectorToString(array)
//        
//        // Then
//        XCTAssertFalse(result.isEmpty)
//        XCTAssertTrue(result.contains("999999"))
//    }
//    
//    func testStringToArrayVector_VerySmallNumbers() {
//        // Given
//        let smallNumbers = "0.0001,0.0002,0.0003"
//        
//        // When
//        let result = RecipeUtils.stringToArrayVector(smallNumbers)
//        
//        // Then
//        XCTAssertGreaterThan(result.count, 0)
//        XCTAssertEqual(result[0].x, 0.0001, accuracy: 0.00001)
//    }
//    
//    // MARK: - Performance Tests
//    
//    func testArrayVectorToString_Performance() {
//        // Given
//        var largeArray: [CIVector] = []
//        for i in 0..<100 {
//            largeArray.append(CIVector(x: CGFloat(i), y: CGFloat(i * 2), z: CGFloat(i * 3)))
//        }
//        
//        // When & Then
//        measure {
//            _ = RecipeUtils.arrayVectorToString(largeArray)
//        }
//    }
//    
//    func testStringToArrayVector_Performance() {
//        // Given
//        var components: [String] = []
//        for i in 0..<100 {
//            components.append("\(i).0,\(i * 2).0,\(i * 3).0")
//        }
//        let largeString = components.joined(separator: ";")
//        
//        // When & Then
//        measure {
//            _ = RecipeUtils.stringToArrayVector(largeString)
//        }
//    }
//}
