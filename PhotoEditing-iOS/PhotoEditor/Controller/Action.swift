import Foundation
import PixelEnginePackage
import QCropper

public enum PhotoEditingControllerAction {
    case setFilter((inout EditingStack.Edit.Filters) -> Void)
    case applyFilter((inout EditingStack.Edit.Filters) -> Void)
    case commit
    case revert
    case undo
    case applyRecipe(RecipeObject)
}
