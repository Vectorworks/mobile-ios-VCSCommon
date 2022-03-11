import Foundation

@objc public class UserLogoutRequest: NSObject, Codable {
    public let loginServer:String
    public let logoutURL:String
    public let loginServerCSRFName:String
    
    
    @objc public init(loginServer:String, logoutURL:String, loginServerCSRFName:String) {
        self.loginServer = loginServer
        self.logoutURL = logoutURL
        self.loginServerCSRFName = loginServerCSRFName
    }
    
    @objc public init?(_ loginSettings: VCSLoginSettingsResponse?) {
        guard let lSettings = loginSettings  else { return nil }
        
        self.loginServer = lSettings.loginServer
        self.logoutURL = lSettings.logoutURL
        self.loginServerCSRFName = lSettings.loginServerCSRFName
    }
}
