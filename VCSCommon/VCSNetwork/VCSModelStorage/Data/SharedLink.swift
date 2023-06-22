import Foundation

public class SharedLink {
    public let isSampleFiles:Bool
    public let link:String
    private(set) public var linkName:String?
    private(set) public var linkThumbnailURL:URL?
    public let sharedAsset:VCSShareableLinkResponse?
    private(set) public var owner:VCSUser?
    public let dateCreated: Date
    
    public var followUpFileSrcID: String?
    
    public var isResolved: Bool { return self.sharedAsset != nil }
    
    public var metadataURLSuffixForRequest: String? {
        guard !self.isSampleFiles else { return self.samplesURLSuffixForRequest }
        
        let linkString = self.link.replacingOccurrences(of: VCSServer.default.serverURLString, with: "")
        guard linkString.hasPrefix("links/") else { return nil }
        guard var url = URL(string: VCSAPIVersion.v2.rawValue) else { return nil }
        url = url.appendingPathComponent("shareable_link/:metadata/")
        url = url.appendingPathComponent(linkString.replacingOccurrences(of: "links/", with: ""))
        let modifiedString = url.absoluteString
        
        return modifiedString
    }
    
    public var visitLinkURLSuffixForRequest: String? {
        let linkString = self.link.replacingOccurrences(of: VCSServer.default.serverURLString, with: "")
        guard linkString.hasPrefix("links/") else { return nil }
        guard var url = URL(string: VCSAPIVersion.v2.rawValue) else { return nil }
        url = url.appendingPathComponent("shareable_link/:visit/")
        url = url.appendingPathComponent(linkString.replacingOccurrences(of: "links/", with: ""))
        let modifiedString = url.absoluteString
        
        return modifiedString
    }
    
    private var samplesURLSuffixForRequest: String? {
        let linkString = self.link.replacingOccurrences(of: VCSServer.default.serverURLString, with: "")
        return linkString
    }
    
    public init(link:String, isSampleFiles:Bool = false, sharedAsset: VCSShareableLinkResponse? = nil, owner: VCSUser? = nil, date: Date? = nil, linkName: String? = nil, linkThumbnailURL: String? = nil) {
        self.isSampleFiles = isSampleFiles
        self.link = link.removingQueries.VCSNormalizedURLString()
        self.linkName = linkName
        
        if let urlString = linkThumbnailURL {
            self.linkThumbnailURL = URL(string: urlString)
        } else {
            self.linkThumbnailURL = nil
        }
        
        self.sharedAsset = sharedAsset
        self.owner = owner
        self.dateCreated = date ?? Date()
    }
    
    //Unresolved link data
    let unresolvedName = "Unknown link".vcsLocalized
    let unresolvedMoreInfo = "Click to open when internet connection is available.".vcsLocalized
    
    public lazy var sortingDate: Date = {
        var result = self.dateCreated
        if self.isSampleFiles {
            result = self.sharedAsset?.dateCreated.VCSDateFromISO8061 ?? self.dateCreated
        }
        return result
    }()
    
    public func updateOwner(_ owner: VCSUser?) {
        defer { VCSCache.addToCache(item: self, forceNilValuesUpdate: true) }
        
        self.owner = owner
    }
    
    public func updateLinkDetails(_ linkDetails: LinkDetailsData) {
        defer { VCSCache.addToCache(item: self, forceNilValuesUpdate: true) }
        
        self.linkName = linkDetails.title
        if let urlString = linkDetails.thumbnailURL {
            self.linkThumbnailURL = URL(string: urlString)
        } else {
            self.linkThumbnailURL = nil
        }
    }
}

extension SharedLink: FileCellPresentable {
    public var rID: String { return self.link }
    public var name: String { return self.sharedAsset?.asset.name ?? self.linkName ?? self.unresolvedName }
    public var hasWarning: Bool { return self.isResolved ? (self.sharedAsset?.asset.flags?.hasWarning ?? true) : false }
    public var isShared: Bool { return self.isResolved ? (self.sharedAsset?.asset.sharingInfo?.isShared ?? false) : false }
    public var hasLink: Bool { return self.isResolved ? !(self.sharedAsset?.asset.sharingInfo?.link.isEmpty ?? true) : false }
    public var sharingInfoData: VCSSharingInfoResponse? { return self.sharedAsset?.asset.sharingInfo }
    public var isAvailableOnDevice: Bool { return self.sharedAsset?.asset.isAvailableOnDevice ?? false }
    public var filterShowingOffline: Bool { return self.isResolved ? self.isAvailableOnDevice : true }
    public var lastModifiedString: String { return self.isResolved ? ((self.sharedAsset?.asset as? VCSFileResponse)?.lastModified ?? VCSFileResponse.defaultDateString) : ((self.linkName?.isEmpty ?? true) ? self.unresolvedMoreInfo : "Presentations".vcsLocalized) }
    public var sizeString: String { return self.isResolved ? ((self.sharedAsset?.asset as? VCSFileResponse)?.sizeString ?? "0 B") : "" }
    public var thumbnailURL: URL? { return (self.sharedAsset?.asset as? VCSFileResponse)?.thumbnailURL ?? self.linkThumbnailURL }
    public var fileTypeString: String? { return self.isResolved ? (self.sharedAsset?.asset as? VCSFileResponse)?.fileTypeString : VCSFileType.UNRESOLVED_LINK.rawValue }
    public var isFolder: Bool { return self.sharedAsset?.asset.isFolder ?? false }
    public var permissions: [String] { return [] }
    public func hasPermission(_ permission: String) -> Bool { self.permissions.contains(permission) }
}

extension SharedLink: VCSCellDataHolder {
    public var cellData: VCSCellPresentable {
        return self
    }
    public var cellFileData: FileCellPresentable? {
        return self
    }
    public var assetData: Asset? {
        return self.sharedAsset?.asset
    }
}

extension SharedLink: VCSCachable {
    public typealias RealmModel = RealmSharedLink
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        SharedLink.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if SharedLink.realmStorage.getByIdOfItem(item: self) != nil {
            SharedLink.realmStorage.partialUpdate(item: self)
        } else {
            SharedLink.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        SharedLink.realmStorage.partialUpdate(item: self)
    }
}
