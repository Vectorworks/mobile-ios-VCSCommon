import Foundation

@objc
public class VCSCommonConstants: NSObject {
    public static let invalidCharacterSet = CharacterSet(charactersIn: "\\?<>:*|%&\"/~#")
    public static let invalidCharacterListStringFormat = "\\ ? < > : * | %% & \" / ~ %@ #."
}
