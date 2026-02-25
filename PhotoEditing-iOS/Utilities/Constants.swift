import Foundation

public class Constants{
    static var supportFilters:[FilterModel] = [
        FilterModel("Brightness", image: "sun.max", edit: EditMenu.exposure),
        FilterModel("Contrast", image: "circle.lefthalf.filled", edit: EditMenu.contrast),
        FilterModel("Saturation", image: "paintpalette", edit: EditMenu.saturation),
        FilterModel("White Balance", image: "thermometer.sun", edit: EditMenu.white_balance),
        FilterModel("Tone", image: "circle.bottomhalf.filled", edit: EditMenu.tone),
        FilterModel("HSL", image: "slider.horizontal.3", edit: EditMenu.hls),
        FilterModel("Fade", image: "circle.dotted", edit: EditMenu.fade),
    ]
}
