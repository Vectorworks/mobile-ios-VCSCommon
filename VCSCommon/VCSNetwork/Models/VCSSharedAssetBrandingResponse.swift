import Foundation

public class VCSSharedAssetBrandingResponseWrapper: NSObject, Codable {
    public let branding: VCSSharedAssetBrandingResponse
}

public class VCSSharedAssetBrandingResponse: NSObject, Codable {
    public let position: BrandingLogoPosition?
    public let image: String?
    public let opacity, size: Float?
    public var realmID: String? {
        didSet {
            self.position?.realmID = realmID
        }
    }
    
    public init(position: BrandingLogoPosition?, image: String?, opacity: Float?, size: Float?, realmID: String?) {
        self.realmID = realmID
        self.position = position
        self.image = image
        self.opacity = opacity
        self.size = size
    }
}

extension VCSSharedAssetBrandingResponse: VCSCachable {
    public typealias RealmModel = RealmSharedAssetBranding
    private static let realmStorage: VCSGenericRealmModelStorage<RealmModel> = VCSGenericRealmModelStorage<RealmModel>()
    
    public func addToCache() {
        VCSSharedAssetBrandingResponse.realmStorage.addOrUpdate(item: self)
    }
    
    public func addOrPartialUpdateToCache() {
        if VCSSharedAssetBrandingResponse.realmStorage.getByIdOfItem(item: self) != nil {
            VCSSharedAssetBrandingResponse.realmStorage.partialUpdate(item: self)
        } else {
            VCSSharedAssetBrandingResponse.realmStorage.addOrUpdate(item: self)
        }
    }
    
    public func partialUpdateToCache() {
        VCSSharedAssetBrandingResponse.realmStorage.partialUpdate(item: self)
    }
}

extension VCSSharedAssetBrandingResponse {
    
    public static var savedUserBranding: VCSSharedAssetBrandingResponse? {
        return VCSSharedAssetBrandingResponse.realmStorage.getAll().first { $0.realmID == AuthCenter.shared.user?.login }
    }
    
    public static func brandingFromDatabase(realmID: String) -> VCSSharedAssetBrandingResponse? {
        return VCSSharedAssetBrandingResponse.realmStorage.getAll().first { $0.realmID == realmID }
    }
}

public class BrandingLogoPosition: NSObject, Codable {
    public let top, left, logoAR: Double
    public var realmID: String?
    
    public init(top: Double, left: Double, logoAR: Double, realmID: String?) {
        self.realmID = realmID
        self.top = top
        self.left = left
        self.logoAR = logoAR
    }
}
