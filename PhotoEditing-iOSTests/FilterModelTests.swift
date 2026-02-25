import XCTest
import PixelEnginePackage
@testable import PhotoEditing_iOS

class FilterModelTests: XCTestCase {
    func testFilterModel_InitializationWithImage() {
        let model = FilterModel("Brightness", image: "brightness_icon", edit: .exposure)
        XCTAssertEqual(model.name, "Brightness")
        XCTAssertEqual(model.image, "brightness_icon")
        XCTAssertEqual(model.edit, .exposure)
    }
    
    func testFilterModel_InitializationWithoutImage() {
        let model = FilterModel("Contrast", edit: .contrast)
        XCTAssertEqual(model.name, "Contrast")
        XCTAssertEqual(model.image, "contrast")
        XCTAssertEqual(model.edit, .contrast)
    }
    
    func testFilterModel_InitializationDefaultsToLowercaseName() {

        let model = FilterModel("SATURATION", edit: .saturation)
        XCTAssertEqual(model.name, "SATURATION")
        XCTAssertEqual(model.image, "saturation")
    }
    
    func testFilterModel_EmptyName() {

        let model = FilterModel("", edit: .none)
        XCTAssertEqual(model.name, "")
        XCTAssertEqual(model.image, "")
    }
    
    func testFilterModel_NoneFilter() {

        let model = FilterModel.noneFilterModel
        XCTAssertEqual(model.name, "")
        XCTAssertEqual(model.edit, .none)
    }
    
 EditMenu Tests
    
    func testEditMenu_AllCases() {
        let allCases: [EditMenu] = [
            .none, .exposure, .contrast, .clarity, .temperature,
            .saturation, .fade, .highlights, .shadows, .vignette,
            .sharpen, .gaussianBlur, .color, .hls, .tone, .white_balance
        ]
        
        for editCase in allCases {
            let model = FilterModel("Test", edit: editCase)
            XCTAssertEqual(model.edit, editCase)
        }
    }
    
    func testEditMenu_NoneCase() {
        let model = FilterModel("Test", edit: .none)
        
        let editMenu = model.edit
        XCTAssertEqual(editMenu, .none)
    }
    
 Image Name Tests
    
    func testFilterModel_CustomImageName() {

        let model = FilterModel("My Filter", image: "custom_icon", edit: .exposure)
        XCTAssertEqual(model.image, "custom_icon")
        XCTAssertNotEqual(model.image, model.name.lowercased())
    }
    
    func testFilterModel_ImageNameFromName() {

        let model = FilterModel("Temperature", edit: .temperature)
        XCTAssertEqual(model.image, "temperature")
    }
    
    func testFilterModel_ImageNameWithSpaces() {

        let model = FilterModel("White Balance", edit: .white_balance)
        XCTAssertEqual(model.image, "white balance")
    }
    
    func testFilterModel_ImageNameWithUpperCase() {

        let model = FilterModel("EXPOSURE", edit: .exposure)
        XCTAssertEqual(model.image, "exposure")
    }
    
 Static Instance Tests
    
    func testFilterModel_NoneFilterModelIsStatic() {
        let model1 = FilterModel.noneFilterModel
        let model2 = FilterModel.noneFilterModel
        XCTAssertTrue(model1 === model2, "noneFilterModel should be the same instance")
    }
    
    func testFilterModel_NoneFilterModelProperties() {

        let model = FilterModel.noneFilterModel
        XCTAssertEqual(model.name, "")
        XCTAssertEqual(model.image, "")
        XCTAssertEqual(model.edit, .none)
    }
    
 Multiple Instances Tests
    
    func testFilterModel_MultipleInstances() {
        let models = [
            FilterModel("Exposure", edit: .exposure),
            FilterModel("Contrast", edit: .contrast),
            FilterModel("Saturation", edit: .saturation),
            FilterModel("Temperature", edit: .temperature),
            FilterModel("Highlights", edit: .highlights),
            FilterModel("Shadows", edit: .shadows)
        ]
        XCTAssertEqual(models.count, 6)
        XCTAssertEqual(models[0].edit, .exposure)
        XCTAssertEqual(models[1].edit, .contrast)
        XCTAssertEqual(models[2].edit, .saturation)
        XCTAssertEqual(models[3].edit, .temperature)
        XCTAssertEqual(models[4].edit, .highlights)
        XCTAssertEqual(models[5].edit, .shadows)
    }
    
 Edge Cases
    
    func testFilterModel_SpecialCharactersInName() {

        let model = FilterModel("Filter@#$%", edit: .exposure)
        XCTAssertEqual(model.name, "Filter@#$%")
        XCTAssertEqual(model.image, "filter@#$%")
    }
    
    func testFilterModel_NumbersInName() {

        let model = FilterModel("Filter123", edit: .exposure)
        XCTAssertEqual(model.name, "Filter123")
        XCTAssertEqual(model.image, "filter123")
    }
    
    func testFilterModel_UnicodeInName() {

        let model = FilterModel("Фильтр", edit: .exposure)
        XCTAssertEqual(model.name, "Фильтр")
        XCTAssertEqual(model.image, "фильтр")
    }
    
    func testFilterModel_EmojiInName() {

        let model = FilterModel("Filter 🎨", edit: .color)
        XCTAssertEqual(model.name, "Filter 🎨")
        XCTAssertTrue(model.image.contains("🎨"))
    }
    
    func testFilterModel_VeryLongName() {
        let longName = String(repeating: "a", count: 1000)
        

        let model = FilterModel(longName, edit: .exposure)
        XCTAssertEqual(model.name, longName)
        XCTAssertEqual(model.image, longName.lowercased())
    }
    
 EditMenu Enum Tests
    
    func testEditMenu_EquatableConformance() {
        let menu1: EditMenu = .exposure
        let menu2: EditMenu = .exposure
        let menu3: EditMenu = .contrast
        XCTAssertEqual(menu1, menu2)
        XCTAssertNotEqual(menu1, menu3)
    }
    
    func testEditMenu_SwitchStatement() {
        let menus: [EditMenu] = [.exposure, .contrast, .none, .color]
        
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
    
 Practical Usage Tests
    
    func testFilterModel_CreatingFilterList() {
        let filterList = [
            FilterModel("None", edit: .none),
            FilterModel("Exposure", edit: .exposure),
            FilterModel("Contrast", edit: .contrast),
            FilterModel("Saturation", edit: .saturation)
        ]
        XCTAssertEqual(filterList.count, 4)
        XCTAssertEqual(filterList[0].edit, .none)
        XCTAssertEqual(filterList[1].name, "Exposure")
        XCTAssertEqual(filterList[2].image, "contrast")
        XCTAssertEqual(filterList[3].edit, .saturation)
    }
    
    func testFilterModel_FilterByEditType() {
        let allFilters = [
            FilterModel("Exposure", edit: .exposure),
            FilterModel("Contrast", edit: .contrast),
            FilterModel("Exposure2", edit: .exposure),
            FilterModel("Saturation", edit: .saturation)
        ]
        

        let exposureFilters = allFilters.filter { $0.edit == .exposure }
        XCTAssertEqual(exposureFilters.count, 2)
        XCTAssertTrue(exposureFilters.allSatisfy { $0.edit == .exposure })
    }
    
    func testFilterModel_FindByName() {
        let filters = [
            FilterModel("Brightness", edit: .exposure),
            FilterModel("Contrast", edit: .contrast),
            FilterModel("Saturation", edit: .saturation)
        ]
        

        let found = filters.first { $0.name == "Contrast" }
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.edit, .contrast)
    }
}
