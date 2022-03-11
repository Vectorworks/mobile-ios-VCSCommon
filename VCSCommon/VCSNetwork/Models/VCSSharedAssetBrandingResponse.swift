import Foundation

@objc public class VCSSharedAssetBrandingResponse: NSObject, Codable {
    public let active: Bool?
    public let position: BrandingLogoPosition?
    public let image: String?
    public let opacity, size: Float?
    public var realmID: String?
    
    init(active: Bool?, position: BrandingLogoPosition?, image: String?, opacity: Float?, size: Float?, realmID: String? = nil) {
        self.realmID = realmID
        self.active = active
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

@objc public class BrandingLogoPosition: NSObject, Codable {
    public let top, left, logoAR: Double
    
    public init(top: Double, left: Double, logoAR: Double) {
        self.top = top
        self.left = left
        self.logoAR = logoAR
    }
}
