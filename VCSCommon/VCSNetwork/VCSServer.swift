import Foundation

public enum VCSAPIVersion: String {
    case none = ""
    case v01 = "/api/public/v0.1/"
    case v02 = "/api/public/v0.2/"
    case v03 = "/api/public/v0.3/"
    case v04 = "/api/public/v0.4/"
    case v05 = "/api/public/v0.5/"
    case v06 = "/api/public/v0.6/"
    case v07 = "/api/public/v0.7/"
    case v08 = "/api/public/v0.8/"
    
    case v1 = "/restapi/public/v1/"
    case v2 = "/restapi/public/v2/"
}

public class VCSServer: Codable {
    public static var `default`: VCSServer { return VCSUserDefaults.default.getCodableItem(forKey: "VCSNetwork_defaultServer") ?? VCSServer.prod }
    
    public let serverURLString: String
    
    init(server:String) {
        self.serverURLString = server
    }
    
    static public let prod = VCSServer(server: "https://cloud.vectorworks.net/")
    static public let beta = VCSServer(server: "https://beta.vcs.vectorworks.net/")
    static public let test = VCSServer(server: "https://test.vcs.vectorworks.net/")
    static public let polaris = VCSServer(server: "https://polaris.vcs.vectorworks.net/")
    
    public static func setDefaultServer(server: VCSServer) {
        VCSUserDefaults.default.setCodableItem(value: server, forKey: "VCSNetwork_defaultServer")
    }
}

extension VCSServer: Equatable {
    public static func == (lhs: VCSServer, rhs: VCSServer) -> Bool {
        return lhs.serverURLString == rhs.serverURLString
    }    
}
