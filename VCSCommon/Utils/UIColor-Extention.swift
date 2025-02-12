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
    
    static let VCSAccentColor: UIColor = .blue
//    static let VCSTeal: UIColor = UIColor(red: 0, green: 188, blue: 180)
    
    static let VCSOrange = UIColor(red:1.00, green:0.51, blue:0.00, alpha:1.0)
    
    static var VCSBlackberry: UIColor {
        return UIColor(red:107, green: 35, blue: 86)
    }
    
    func withAlphaModified(_ newAlpha: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return UIColor(red: red, green: green, blue: blue, alpha: newAlpha)
    }
    
    static func addAlphaToColor(_ color: UIColor, alphaLevel newAlpha: CGFloat = 1) -> UIColor {
        return color.withAlphaModified(newAlpha)
    }
}

public extension Color {
    static let label: Color = { return Color(uiColor: .label) }()
    static let secondaryLabel: Color = { return Color(uiColor: .secondaryLabel) }()
    static let tertiaryLabel: Color = { return Color(uiColor: .tertiaryLabel) }()
    static let quaternaryLabel: Color = { return Color(uiColor: .quaternaryLabel) }()
    
    static let systemBackground: Color = { return Color(uiColor: .systemBackground) }()
    static let secondarySystemBackground: Color = { return Color(uiColor: .secondarySystemBackground) }()
    static let tertiarySystemBackground: Color = { return Color(uiColor: .tertiarySystemBackground) }()
    
    static let systemFill: Color = { return Color(uiColor: .systemFill) }()
    static let secondarySystemFill: Color = { return Color(uiColor: .secondarySystemFill) }()
    static let tertiarySystemFill: Color = { return Color(uiColor: .tertiarySystemFill) }()
    
//    static let VCSTeal: Color = { return Color(uiColor: UIColor.VCSTeal) }()
    static let VCSBlackberry: Color = { return Color(uiColor: UIColor.VCSBlackberry) }()
    static let buttonDismissSheetFill: Color = { return Color(uiColor: UIColor(stringHex: "#F0F0F0")) }()
    static let resolvedCommentFill: Color = { return Color(uiColor: UIColor(stringHex: "#F7F7F7")) }()
    
    static let VCSAccentColor: Color = { return .blue }()
}
