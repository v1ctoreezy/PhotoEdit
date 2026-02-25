import XCTest
import PixelEnginePackage
@testable import PhotoEditing_iOS

/// Unit тесты для FilterModel
class FilterModelTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func testFilterModel_InitializationWithImage() {
        // When
        let model = FilterModel("Brightness", image: "brightness_icon", edit: .exposure)
        
        // Then
        XCTAssertEqual(model.name, "Brightness")
        XCTAssertEqual(model.image, "brightness_icon")
        XCTAssertEqual(model.edit, .exposure)
    }
    
    func testFilterModel_InitializationWithoutImage() {
        // When
        let model = FilterModel("Contrast", edit: .contrast)
        
        // Then
        XCTAssertEqual(model.name, "Contrast")
        XCTAssertEqual(model.image, "contrast")
        XCTAssertEqual(model.edit, .contrast)
    }
    
    func testFilterModel_InitializationDefaultsToLowercaseName() {
        // When
        let model = FilterModel("SATURATION", edit: .saturation)
        
        // Then
        XCTAssertEqual(model.name, "SATURATION")
        XCTAssertEqual(model.image, "saturation")
    }
    
    func testFilterModel_EmptyName() {
        // When
        let model = FilterModel("", edit: .none)
        
        // Then
        XCTAssertEqual(model.name, "")
        XCTAssertEqual(model.image, "")
    }
    
    func testFilterModel_NoneFilter() {
        // When
        let model = FilterModel.noneFilterModel
        
        // Then
        XCTAssertEqual(model.name, "")
        XCTAssertEqual(model.edit, .none)
    }
    
    // MARK: - EditMenu Tests
    
    func testEditMenu_AllCases() {
        // Given
        let allCases: [EditMenu] = [
            .none, .exposure, .contrast, .clarity, .temperature,
            .saturation, .fade, .highlights, .shadows, .vignette,
            .sharpen, .gaussianBlur, .color, .hls, .tone, .white_balance
        ]
        
        // When & Then
        for editCase in allCases {
            let model = FilterModel("Test", edit: editCase)
            XCTAssertEqual(model.edit, editCase)
        }
    }
    
    func testEditMenu_NoneCase() {
        // Given
        let model = FilterModel("Test", edit: .none)
        
        // When
        let editMenu = model.edit
        
        // Then
        XCTAssertEqual(editMenu, .none)
    }
    
    // MARK: - Image Name Tests
    
    func testFilterModel_CustomImageName() {
        // When
        let model = FilterModel("My Filter", image: "custom_icon", edit: .exposure)
        
        // Then
        XCTAssertEqual(model.image, "custom_icon")
        XCTAssertNotEqual(model.image, model.name.lowercased())
    }
    
    func testFilterModel_ImageNameFromName() {
        // When
        let model = FilterModel("Temperature", edit: .temperature)
        
        // Then
        XCTAssertEqual(model.image, "temperature")
    }
    
    func testFilterModel_ImageNameWithSpaces() {
        // When
        let model = FilterModel("White Balance", edit: .white_balance)
        
        // Then
        XCTAssertEqual(model.image, "white balance")
    }
    
    func testFilterModel_ImageNameWithUpperCase() {
        // When
        let model = FilterModel("EXPOSURE", edit: .exposure)
        
        // Then
        XCTAssertEqual(model.image, "exposure")
    }
    
    // MARK: - Static Instance Tests
    
    func testFilterModel_NoneFilterModelIsStatic() {
        // Given
        let model1 = FilterModel.noneFilterModel
        let model2 = FilterModel.noneFilterModel
        
        // Then
        XCTAssertTrue(model1 === model2, "noneFilterModel should be the same instance")
    }
    
    func testFilterModel_NoneFilterModelProperties() {
        // When
        let model = FilterModel.noneFilterModel
        
        // Then
        XCTAssertEqual(model.name, "")
        XCTAssertEqual(model.image, "")
        XCTAssertEqual(model.edit, .none)
    }
    
    // MARK: - Multiple Instances Tests
    
    func testFilterModel_MultipleInstances() {
        // Given
        let models = [
            FilterModel("Exposure", edit: .exposure),
            FilterModel("Contrast", edit: .contrast),
            FilterModel("Saturation", edit: .saturation),
            FilterModel("Temperature", edit: .temperature),
            FilterModel("Highlights", edit: .highlights),
            FilterModel("Shadows", edit: .shadows)
        ]
        
        // Then
        XCTAssertEqual(models.count, 6)
        XCTAssertEqual(models[0].edit, .exposure)
        XCTAssertEqual(models[1].edit, .contrast)
        XCTAssertEqual(models[2].edit, .saturation)
        XCTAssertEqual(models[3].edit, .temperature)
        XCTAssertEqual(models[4].edit, .highlights)
        XCTAssertEqual(models[5].edit, .shadows)
    }
    
    // MARK: - Edge Cases
    
    func testFilterModel_SpecialCharactersInName() {
        // When
        let model = FilterModel("Filter@#$%", edit: .exposure)
        
        // Then
        XCTAssertEqual(model.name, "Filter@#$%")
        XCTAssertEqual(model.image, "filter@#$%")
    }
    
    func testFilterModel_NumbersInName() {
        // When
        let model = FilterModel("Filter123", edit: .exposure)
        
        // Then
        XCTAssertEqual(model.name, "Filter123")
        XCTAssertEqual(model.image, "filter123")
    }
    
    func testFilterModel_UnicodeInName() {
        // When
        let model = FilterModel("Фильтр", edit: .exposure)
        
        // Then
        XCTAssertEqual(model.name, "Фильтр")
        XCTAssertEqual(model.image, "фильтр")
    }
    
    func testFilterModel_EmojiInName() {
        // When
        let model = FilterModel("Filter 🎨", edit: .color)
        
        // Then
        XCTAssertEqual(model.name, "Filter 🎨")
        XCTAssertTrue(model.image.contains("🎨"))
    }
    
    func testFilterModel_VeryLongName() {
        // Given
        let longName = String(repeating: "a", count: 1000)
        
        // When
        let model = FilterModel(longName, edit: .exposure)
        
        // Then
        XCTAssertEqual(model.name, longName)
        XCTAssertEqual(model.image, longName.lowercased())
    }
    
    // MARK: - EditMenu Enum Tests
    
    func testEditMenu_EquatableConformance() {
        // Given
        let menu1: EditMenu = .exposure
        let menu2: EditMenu = .exposure
        let menu3: EditMenu = .contrast
        
        // Then
        XCTAssertEqual(menu1, menu2)
        XCTAssertNotEqual(menu1, menu3)
    }
    
    func testEditMenu_SwitchStatement() {
        // Given
        let menus: [EditMenu] = [.exposure, .contrast, .none, .color]
        
        // When & Then
        for menu in menus {
            switch menu {
            case .none:
                XCTAssertEqual(menu, .none)
            case .exposure:
                XCTAssertEqual(menu, .exposure)
            case .contrast:
                XCTAssertEqual(menu, .contrast)
            case .color:
                XCTAssertEqual(menu, .color)
            default:
                XCTFail("Unexpected menu case")
            }
        }
    }
    
    // MARK: - Practical Usage Tests
    
    func testFilterModel_CreatingFilterList() {
        // Given
        let filterList = [
            FilterModel("None", edit: .none),
            FilterModel("Exposure", edit: .exposure),
            FilterModel("Contrast", edit: .contrast),
            FilterModel("Saturation", edit: .saturation)
        ]
        
        // Then
        XCTAssertEqual(filterList.count, 4)
        XCTAssertEqual(filterList[0].edit, .none)
        XCTAssertEqual(filterList[1].name, "Exposure")
        XCTAssertEqual(filterList[2].image, "contrast")
        XCTAssertEqual(filterList[3].edit, .saturation)
    }
    
    func testFilterModel_FilterByEditType() {
        // Given
        let allFilters = [
            FilterModel("Exposure", edit: .exposure),
            FilterModel("Contrast", edit: .contrast),
            FilterModel("Exposure2", edit: .exposure),
            FilterModel("Saturation", edit: .saturation)
        ]
        
        // When
        let exposureFilters = allFilters.filter { $0.edit == .exposure }
        
        // Then
        XCTAssertEqual(exposureFilters.count, 2)
        XCTAssertTrue(exposureFilters.allSatisfy { $0.edit == .exposure })
    }
    
    func testFilterModel_FindByName() {
        // Given
        let filters = [
            FilterModel("Brightness", edit: .exposure),
            FilterModel("Contrast", edit: .contrast),
            FilterModel("Saturation", edit: .saturation)
        ]
        
        // When
        let found = filters.first { $0.name == "Contrast" }
        
        // Then
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.edit, .contrast)
    }
}
