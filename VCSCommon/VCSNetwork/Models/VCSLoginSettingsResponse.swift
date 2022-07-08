import Foundation

@objc public class VCSLoginSettingsResponse: NSObject, Codable {
    @objc public let loginServerSessionName, forgotPassword, loginURL, registerURL: String
    @objc public let notifyChannels: VCSNotifyChannelsResponse
    @objc public let loginWithTokenURL, logoutURL, loginWithServerAuthCode, loginServerCSRFName: String
    @objc public let loginServer, notifyServer: String
    @objc public let nomadClientID, oAuthAuthorizeURL, oAuthTokenURL: String
    @objc public let nomadRedirectURLs: [String]
    @objc public let dropboxIntegrateURL, driveIntegrateURL, oneDriveIntegrateURL: String
    
    enum CodingKeys: String, CodingKey {
        case loginURL = "login_url"
        case logoutURL = "logout_url"
        case registerURL = "register_url"
        case loginWithTokenURL = "login_with_token_url"
        case loginWithServerAuthCode = "login_with_server_auth_code"
        case forgotPassword = "forgot_password_page"
        case loginServer = "login_server"
        case loginServerSessionName = "login_server_session_name"
        case loginServerCSRFName = "login_server_csrf_name"
        case notifyServer = "notify_server"
        case notifyChannels = "notify_channels"
        case nomadClientID = "nomad_ios_client_id"
        case oAuthAuthorizeURL = "oauth2_authorize_uri"
        case oAuthTokenURL = "oauth2_token_uri"
        case nomadRedirectURLs = "oauth2_ios_nomad_redirect_uris"
        case dropboxIntegrateURL = "dropbox_integrate_url"
        case driveIntegrateURL = "drive_integrate_url"
        case oneDriveIntegrateURL = "one_drive_integrate_url"
    }
}

@objc public class VCSNotifyChannelsResponse: NSObject, Codable {
    @objc public let jobs: String
    @objc public let file: String
    @objc public let folder: String
    @objc public let notification: String
    @objc public let featureNotification: String
    
    enum CodingKeys: String, CodingKey {
        case jobs = "jobs"
        case file = "file"
        case folder = "folder"
        case notification = "notification"
        case featureNotification = "feature_notification"
    }
}
