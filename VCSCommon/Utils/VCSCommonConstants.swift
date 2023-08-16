import Foundation

@objc
public class VCSCommonConstants: NSObject {
    @objc public static let invalidCharacterSet = CharacterSet(charactersIn: "\\?<>:*|%&\"/~#")
    @objc public static let invalidCharacterListStringFormat = "\\ ? < > : * | %% & \" / ~ %@ #."
}
