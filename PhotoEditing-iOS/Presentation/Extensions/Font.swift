//
//  Font.swift
//  UMobile
//
//  Created by Victor Cherkasov on 09.12.2024.
//

import Foundation
import SwiftUI

extension Font {
    enum AppFontWeight {
        case regular, bold
    }
    
    // MARK: - New DS Fonts
    /** 10 Шрифт */
    static let app_2XS_Bold = appFont(size: 10, weight: .bold)
    /** 10 Шрифт */
    static let app_2XS = appFont(size: 10, weight: .regular)
    
    /** 12 Шрифт */
    static let app_XS_Bold = appFont(size: 12, weight: .bold)
    /** 12 Шрифт */
    static let app_XS = appFont(size: 12, weight: .regular)
    
    /** 14 Шрифт */
    static let app_S_Bold = appFont(size: 14, weight: .bold)
    /** 14 Шрифт */
    static let app_S = appFont(size: 14, weight: .regular)
    
    /** 16 Шрифт */
    static let app_M_Bold = appFont(size: 16, weight: .bold)
    /** 16 Шрифт */
    static let app_M = appFont(size: 16, weight: .regular)

    /** 20 Шрифт */
    static let app_L_Bold = appFont(size: 20, weight: .bold)
    /** 20 Шрифт */
    static let app_L = appFont(size: 20, weight: .regular)
    
    /** 24 Шрифт */
    static let app_XL_Bold = appFont(size: 24, weight: .bold)
    /** 24 Шрифт */
    static let app_XL = appFont(size: 24, weight: .regular)

    /** 32 Шрифт */
    static let app_2XL_Bold = appFont(size: 32, weight: .bold)
    /** 32 Шрифт */
    static let app_2XL = appFont(size: 32, weight: .regular)

    /** 40 Шрифт */
    static let app_3XL_Bold = appFont(size: 40, weight: .bold)
    /** 40 Шрифт */
    static let app_3XL = appFont(size: 40, weight: .regular)
    
    /** 48 Шрифт */
    static let app_4XL_Bold = appFont(size: 48, weight: .bold)
    /** 48 Шрифт */
    static let app_4XL = appFont(size: 48, weight: .regular)
    
    /** 64 Шрифт */
    static let app_5XL_Bold = appFont(size: 64, weight: .bold)
    /** 64 Шрифт */
    static let app_5XL = appFont(size: 64, weight: .regular)

    static func appFont(size: Float, weight: AppFontWeight) -> Font {
        let fontName = weight == .regular ? "Onest-Regular" : "Onest-Bold"
        return Font.custom(fontName, fixedSize: CGFloat(size))
    }
}

extension UIFont {
    static func appFont(size: Float, weight: Font.AppFontWeight) -> UIFont {
        let fontName = weight == .regular ? "Onest-Regular" : "Onest-Bold"
        return UIFont(name: fontName, size: CGFloat(size))!
    }
}
