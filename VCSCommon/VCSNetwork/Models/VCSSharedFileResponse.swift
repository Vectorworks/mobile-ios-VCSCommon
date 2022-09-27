//
//  VCSSharedFileResponse.swift
//  VCSCommon
//
//  Created by gkarapetrov on 27.09.22.
//  Copyright © 2022 Georgi Karapetrov. All rights reserved.
//

import Foundation

public class VCSSharedFileResponse: Codable {
    public let file: VCSFileResponse?
    public let owner: String
    public let ownerEmail: String
    public let uploadPrefix: String
    public let ownerRegion: String
    public let hasJoined: Bool
    public let permission: [SharedWithMePermission]?
    public let dateCreated: String
    public var branding: VCSSharedAssetBrandingResponse?
    
    private enum CodingKeys: String, CodingKey {
        case file
        case owner
        case ownerEmail = "owner_email"
        case uploadPrefix = "upload_prefix"
        case ownerRegion = "owner_region"
        case hasJoined = "has_joined"
        case permission
        case dateCreated = "date_created"
        case branding
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.file = try? container.decode(VCSFileResponse.self, forKey: CodingKeys.file)
        self.owner = try container.decode(String.self, forKey: CodingKeys.owner)
        self.ownerEmail = try container.decode(String.self, forKey: CodingKeys.ownerEmail)
        self.uploadPrefix = try container.decode(String.self, forKey: CodingKeys.uploadPrefix)
        self.ownerRegion = try container.decode(String.self, forKey: CodingKeys.ownerRegion)
        self.hasJoined = try container.decode(Bool.self, forKey: CodingKeys.hasJoined)
        self.permission = try? container.decode([SharedWithMePermission].self, forKey: CodingKeys.permission)
        self.dateCreated = try container.decode(String.self, forKey: CodingKeys.dateCreated)
        self.branding = try? container.decode(VCSSharedAssetBrandingResponse.self, forKey: CodingKeys.branding)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.file, forKey: CodingKeys.file)
        try container.encode(self.owner, forKey: CodingKeys.owner)
        try container.encode(self.ownerEmail, forKey: CodingKeys.ownerEmail)
        try container.encode(self.uploadPrefix, forKey: CodingKeys.uploadPrefix)
        try container.encode(self.hasJoined, forKey: CodingKeys.hasJoined)
        try container.encode(self.permission, forKey: CodingKeys.permission)
        try container.encode(self.dateCreated, forKey: CodingKeys.dateCreated)
        try container.encode(self.branding, forKey: CodingKeys.branding)
    }
}
