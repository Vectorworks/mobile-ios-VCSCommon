import Foundation

public class UserLogoutRequest: Codable {
    public let loginServer:String
    public let logoutURL:String
    public let loginServerCSRFName:String
    
    
    public init(loginServer:String, logoutURL:String, loginServerCSRFName:String) {
        self.loginServer = loginServer
        self.logoutURL = logoutURL
        self.loginServerCSRFName = loginServerCSRFName
    }
    
    public init?(_ loginSettings: VCSLoginSettingsResponse?) {
        guard let lSettings = loginSettings  else { return nil }
        
        self.loginServer = lSettings.loginServer
        self.logoutURL = lSettings.logoutURL
        self.loginServerCSRFName = lSettings.loginServerCSRFName
    }
}
