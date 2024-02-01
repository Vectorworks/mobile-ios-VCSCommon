import Foundation

public class VCSFolderStatResponse: NSObject, Codable {
    public let folders, files: VCSAssetStatResponse
}

public class VCSAssetStatResponse: NSObject, Codable {
    public let count: Int
}
