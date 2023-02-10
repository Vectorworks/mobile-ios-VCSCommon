import SwiftUI

public struct FCRouteData: Hashable, Identifiable {
    public var id: String { return self.resourceURI }
    
    public init(folder: VCSFolderResponse) {
        self.resourceURI = folder.resourceURI
        self.folderResponse = folder
        self.breadcrumbsName = folder.name.isEmpty ? folder.storageType.displayName : folder.name
    }
    
    public init(resourceURI: String, breadcrumbsName: String) {
        self.resourceURI = resourceURI
        self.breadcrumbsName = breadcrumbsName
        self.folderResponse = nil
    }
    
    public let resourceURI: String
    public let breadcrumbsName: String
    public let folderResponse: VCSFolderResponse?
    
    public var folderResult: Result<VCSFolderResponse, Error>? {
        var result: Result<VCSFolderResponse, Error>? = nil
        if let folderResponse = self.folderResponse {
            result = .success(folderResponse)
        }
        return result
    }
}
