import Foundation
import UIKit

@objc public extension UIColor {
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
