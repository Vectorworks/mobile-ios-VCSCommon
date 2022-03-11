import Foundation

public struct VCSRequestURL {
    public let vcsServer:VCSServer
    public let apiVersion:VCSAPIVersion
    
    public init(vcsServer:VCSServer, APIVersion:VCSAPIVersion) {
        self.vcsServer = vcsServer
        self.apiVersion = APIVersion
    }
    
    public func urlString() -> String {
        return self.vcsServer.serverURLString.stringByAppendingPath(path: self.apiVersion.rawValue)
    }
}
