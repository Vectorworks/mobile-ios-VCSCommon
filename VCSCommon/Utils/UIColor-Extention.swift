import Foundation
import UIKit
import SwiftUI

public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        let maxColorValue: CGFloat = CGFloat(255)
        let redValue: CGFloat = CGFloat(red)/maxColorValue
        let greenValue: CGFloat = CGFloat(green)/maxColorValue
        let blueValue: CGFloat = CGFloat(blue)/maxColorValue
        
        self.init(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
    }
    
    convenience init(hex: Int) {
        let redValue = CGFloat((hex & 0xFF0000) >> 16) / 255
        let greenValue = CGFloat((hex & 0x00FF00) >> 8) / 255
        let blueValue = CGFloat((hex & 0x0000FF)) / 255

        self.init(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
    }
    
    convenience init(stringHex: String) {
        var cString:String = stringHex.trimmingCharacters(in: .whitespacesAndNewlines)

        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(hex: Int(truncatingIfNeeded: rgbValue))
    }
}

public extension Color {
    static var label: Color = { return Color(uiColor: .label) }()
    static var secondaryLabel: Color = { return Color(uiColor: .secondaryLabel) }()
    static var tertiaryLabel: Color = { return Color(uiColor: .tertiaryLabel) }()
    static var quaternaryLabel: Color = { return Color(uiColor: .quaternaryLabel) }()
    
    static var systemBackground: Color = { return Color(uiColor: .systemBackground) }()
    static var secondarySystemBackground: Color = { return Color(uiColor: .secondarySystemBackground) }()
    static var tertiarySystemBackground: Color = { return Color(uiColor: .tertiarySystemBackground) }()
    
    static var VCSTeal: Color = { return Color(uiColor: VCSColors.teal) }()
}
