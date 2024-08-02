import Foundation
import SwiftData

@Model
public class VCSSharedAssetBrandingResponseWrapper: Codable {
    @Relationship(deleteRule: .cascade)
    public let branding: VCSSharedAssetBrandingResponse
    
    private enum CodingKeys: String, CodingKey {
        case branding
    }
    
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.branding = try container.decode(VCSSharedAssetBrandingResponse.self, forKey: CodingKeys.branding)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.branding, forKey: CodingKeys.branding)
    }
}

@Model
public final class VCSSharedAssetBrandingResponse: Codable {
    @Relationship(deleteRule: .cascade)
    public let position: BrandingLogoPosition?
    public let image: String?
    public let opacity: Float?
    public let size: Float?
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
    
    private enum CodingKeys: String, CodingKey {
        case position
        case image
        case opacity
        case size
        case realmID
    }
    
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //TODO: REALM_CHANGE
//        let position = try container.decode(BrandingLogoPosition?.self, forKey: CodingKeys.position)
//        self.position = position
        self.image = try container.decode(String?.self, forKey: CodingKeys.image)
        self.opacity = try container.decode(Float?.self, forKey: CodingKeys.opacity)
        self.size = try container.decode(Float?.self, forKey: CodingKeys.size)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.position, forKey: CodingKeys.position)
        try container.encode(self.image, forKey: CodingKeys.image)
        try container.encode(self.opacity, forKey: CodingKeys.opacity)
        try container.encode(self.size, forKey: CodingKeys.size)
        try container.encode(self.realmID, forKey: CodingKeys.realmID)
    }
}

extension VCSSharedAssetBrandingResponse: VCSCacheable {
    public var rID: String { return realmID ?? VCSUUID().systemUUID.uuidString }
}

extension VCSSharedAssetBrandingResponse {
    
    public static var savedUserBranding: VCSSharedAssetBrandingResponse? {
        //TODO: REALM_CHANGE
        return nil// VCSSharedAssetBrandingResponse.realmStorage.getAll().first { $0.realmID == VCSUser.savedUser?.login }
    }
    
    public static func brandingFromDatabase(realmID: String) -> VCSSharedAssetBrandingResponse? {
        return nil
//        return VCSSharedAssetBrandingResponse.realmStorage.getAll().first { $0.realmID == realmID }
    }
}

@Model
public class BrandingLogoPosition: Codable {
    public let top: Double
    public let left: Double
    public let logoAR: Double
    public var realmID: String?
    
    public init(top: Double, left: Double, logoAR: Double, realmID: String?) {
        self.realmID = realmID
        self.top = top
        self.left = left
        self.logoAR = logoAR
    }
    
    private enum CodingKeys: String, CodingKey {
        case top
        case left
        case logoAR
        case realmID
    }
    
    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.top = try container.decode(Double.self, forKey: CodingKeys.top)
        self.left = try container.decode(Double.self, forKey: CodingKeys.left)
        self.logoAR = try container.decode(Double.self, forKey: CodingKeys.logoAR)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.top, forKey: CodingKeys.top)
        try container.encode(self.left, forKey: CodingKeys.left)
        try container.encode(self.logoAR, forKey: CodingKeys.logoAR)
        try container.encode(self.realmID, forKey: CodingKeys.realmID)
    }
}
