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
    
    static let VCSTeal: Color = { return Color(uiColor: VCSColors.teal) }()
    static let VCSBlackberry: Color = { return Color(uiColor: VCSColors.blackberry) }()
    static let buttonDismissSheetFill: Color = { return Color(uiColor: UIColor(stringHex: "#F0F0F0")) }()
    static let resolvedCommentFill: Color = { return Color(uiColor: UIColor(stringHex: "#F7F7F7")) }()
}
