import UIKit

class LetterAvatarBuilderConfiguration {
    var size: CGSize = CGSize(width: 100, height: 100)
    var name: String?
    var email: String?
    var login: String?

    let lettersColor: UIColor = UIColor(red: 235, green: 235, blue: 235)

    var borderWidth: CGFloat = 2.0
    var borderColor: UIColor = UIColor.white
}

extension LetterAvatarBuilderConfiguration {
    var letters: String {
        guard let name = self.name else { return self.email ?? "?" }
        let letters = name.split(separator: " ").compactMap { $0.first }.map { String($0) }
        return letters.joined()
    }
    
    var backgroundColor: UIColor {
        guard let _ = self.name else { return LetterAvatarBuilderConfiguration.stringToColor() }
        let name = self.name ?? ""
        let email = self.email ?? ""
        let login = self.login ?? ""
        return LetterAvatarBuilderConfiguration.stringToColor(name + email + login)
    }
    
    static func stringToColor(_ string: String? = nil) -> UIColor {
        guard let str = string else { return UIColor(hex: 0xbababa) }
        let strHash = str.stringHash.stringHEXRGBA.shade
        let res = UIColor(stringHex: strHash)
        return res
    }
}

extension String {
    var stringHash: Int {
        var result = 0
        self.forEach {
            let p1 = $0.ASCIIValue
            let p3 = result
            let p2 = Int32(truncatingIfNeeded: result << 5)
            result = p1 &+ (Int(p2) &- p3)
        }
        return result
    }
    
    var shade: String {
        let num = Int(self, radix: 16)!
        let num32 = Int32(truncatingIfNeeded:num)
        let amt = -25
        let R = Int( Int32(truncatingIfNeeded:num32 >> 16) ) + amt
        let G = Int( Int32(truncatingIfNeeded:num32 >> 8 & 0x00FF) ) + amt
        let B = Int( Int32(truncatingIfNeeded:num32 & 0x0000FF) ) + amt
        
        let hashTag = 0x1000000
        let rTag = (R < 255 ? (R < 1 ? 0 : R) : 255) * 0x10000
        let gTag = (G < 255 ? (G < 1 ? 0 : G) : 255) * 0x100
        let bTag = (B < 255 ? (B < 1 ? 0 : B) : 255)
        
        
        var result = (hashTag
            + rTag
            + gTag
            + bTag).toString16
        result.removeFirst()
        return result
    }
}

extension Character {
    var ASCIIValue: Int {
        let unicode = String(self).unicodeScalars
        return Int(unicode[unicode.startIndex].value)
    }
}

extension Int {
    var stringHEXRGBA: String {
        let hR = ((self >> 24) & 0xFF).toString16
        let hG = ((self >> 16) & 0xFF).toString16
        let hB = ((self >> 8) & 0xFF).toString16
        let hA = (self & 0xFF).toString16
        return hR + hG + hB + hA
    }
    
    var toString16: String {
        return String(self, radix: 16, uppercase: false)
    }
}
