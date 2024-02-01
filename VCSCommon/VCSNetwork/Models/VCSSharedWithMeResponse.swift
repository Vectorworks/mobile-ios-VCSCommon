import Foundation

public class VCSSharedWithMeResponse: NSObject, Codable {
    public let count: Int
    public let next, previous: String?
    public let results: [VCSSharedWithMeAsset?]
}
