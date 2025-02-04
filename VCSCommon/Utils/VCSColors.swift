import Foundation
import UIKit

public class VCSColors {
    public static var teal: UIColor {
        return UIColor(red: 0, green: 188, blue: 180)
    }
    
    public static var blackberry: UIColor {
        return UIColor(red:107, green: 35, blue: 86)
    }
    
    public static func addAlphaToColor(_ color: UIColor, alphaLevel newAlpha: CGFloat = 1) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return UIColor(red: red, green: green, blue: blue, alpha: newAlpha)
    }
}
