import Foundation

public class Localization: NSObject {
    public static var privateDefaultInstance: Localization = Localization()
    public static var `default`: Localization { return Localization.privateDefaultInstance }
    
    @objc
    public static var defaultOBJC: Localization { return Localization.default }
    
    var currentBundle: Bundle?
    public var devPseudoTranslations: Bool = false
    public var devDoubleSize: Bool = false
    public var devStringInTable: Bool = false
    
    private static let convertingDictionary: [String:String] = [
        "a" : "á",
        "b" : "ƀ",
        "c" : "ƈ",
        "d" : "ď",
        "e" : "ē",
        "f" : "ƒ",
        "g" : "ĝ",
        "h" : "ĥ",
        "i" : "ĩ",
        "j" : "ĵ",
        "k" : "ƙ",
        "l" : "ĺ",
        "m" : "ɱ",
        "n" : "ň",
        "o" : "ō",
        "p" : "ƥ",
        "q" : "ɋ",
        "r" : "ŕ",
        "s" : "ś",
        "t" : "ť",
        "u" : "ũ",
        "v" : "ʋ",
        "w" : "ŵ",
        "x" : "><",
        "y" : "ŷ",
        "z" : "ž"
    ]
    
    public var preferredLanguage: String {
        get { return Bundle.main.preferredLocalizations.first ?? "en" }
    }
    
    override init() {
        super.init()
        self.updateCurrentStringTable()
    }
    
    public func updateCurrentStringTable() {
        if let pathForStringTable = Bundle.main.path(forResource: self.preferredLanguage, ofType: "lproj"),
            let bundle = Bundle(path: pathForStringTable) {
            self.currentBundle = bundle
        }
    }
    
    public func string(key: String) -> String {
        var result = key
        var notFoundValue = ""
        
        if self.devStringInTable, self.preferredLanguage == "en" {
            notFoundValue = key.appending(" - VCS_LOCALIZED_STRING_NOT_ADDED")
            result = notFoundValue
        }
        
        if let localizedValue = self.currentBundle?.localizedString(forKey: key, value: notFoundValue, table: nil) {
            result = localizedValue
        }
        
        result = self.checkDevOptions(value: result)
        
        return result
    }
    
    private func checkDevOptions(value: String) -> String {
        var result = value
        guard self.preferredLanguage == "en" else { return result }
        guard (self.devPseudoTranslations || self.devDoubleSize) == true else { return result }
        
        if self.devPseudoTranslations {
            result = ""
            value.forEach {
                if let convertedChar = Localization.convertingDictionary[String($0)] {
                    result.append(convertedChar)
                }
            }
        }
        
        if self.devDoubleSize {
            result = result.appending(result)
        }
        
        return result
    }
}


public extension String {
    var vcsLocalized: String {
        return Localization.default.string(key: self)
    }
}

@objc public extension NSString {
    var vcsLocalized: String {
        return Localization.default.string(key: self as String)
    }
}
