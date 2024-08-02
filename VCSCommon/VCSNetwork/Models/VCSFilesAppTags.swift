import Foundation
import SwiftData

@Model
public final class VCSFilesAppTags {
    public let tagData: Data?
    public var realmID: String = VCSUUID().systemUUID.uuidString
    
    public init(tagData: Data?, realmID: String) {
        self.realmID = realmID
        self.tagData = tagData
    }
}

extension VCSFilesAppTags: VCSCacheable {
    public var rID: String { return realmID }
}
