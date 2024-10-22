//
//  VCSSearchResponse.swift
//  mobile-ios-VCSCommon
//
//  Created by Veneta Todorova on 8.10.24.
//
import Foundation

public struct VCSSearchResponse: Codable {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let results: [VCSSearchResult]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.count = try container.decode(Int.self, forKey: CodingKeys.count)
        self.next = try container.decodeIfPresent(String.self, forKey: CodingKeys.next)
        self.previous = try container.decodeIfPresent(String.self, forKey: CodingKeys.previous)
        self.results = try container.decode([VCSSearchResult].self, forKey: CodingKeys.results)
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }
}

public struct VCSSearchResponseSharedWithMe: Codable {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let results: [VCSSharedWithMeAsset]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.count = try container.decode(Int.self, forKey: CodingKeys.count)
        self.next = try container.decodeIfPresent(String.self, forKey: CodingKeys.next)
        self.previous = try container.decodeIfPresent(String.self, forKey: CodingKeys.previous)
        self.results = try container.decode([VCSSharedWithMeAsset].self, forKey: CodingKeys.results)
    }

    private enum CodingKeys: String, CodingKey {
        case count
        case next
        case previous
        case results
    }
}

public struct VCSSearchResult: Codable {
    public let asset: Asset
    public let assetType: AssetType
    public let resourceURI: String

    private enum CodingKeys: String, CodingKey {
        case asset
        case assetType = "asset_type"
        case resourceURI = "resource_uri"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.assetType = try container.decode(AssetType.self, forKey: CodingKeys.assetType)
        self.resourceURI = try container.decode(String.self, forKey: CodingKeys.resourceURI)

        switch self.assetType {
        case .file:
            self.asset = try container.decode(VCSFileResponse.self, forKey: CodingKeys.asset)
        case .folder:
            self.asset = try container.decode(VCSFolderResponse.self, forKey: CodingKeys.asset)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.assetType, forKey: CodingKeys.assetType)
        try container.encode(self.resourceURI, forKey: CodingKeys.resourceURI)

        switch self.assetType {
        case .file:
            if let fileAsset = self.asset as? VCSFileResponse {
                try container.encode(fileAsset, forKey: CodingKeys.asset)
            }
        case .folder:
            if let folderAsset = self.asset as? VCSFolderResponse {
                try container.encode(folderAsset, forKey: CodingKeys.asset)
            }
        }
    }
}
