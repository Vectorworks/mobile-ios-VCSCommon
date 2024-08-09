import Foundation

public class VCSLoginSettingsResponse: Codable {
    public let loginServerSessionName, forgotPassword, loginURL, registerURL: String
    public let notifyChannels: VCSNotifyChannelsResponse
    public let loginWithTokenURL, logoutURL, loginWithServerAuthCode, loginServerCSRFName: String
    public let loginServer: String
    public let nomadClientID, oAuthAuthorizeURL, oAuthTokenURL: String
    public let nomadRedirectURLs: [String]
    public let dropboxIntegrateURL, driveIntegrateURL, oneDriveIntegrateURL: String
    
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
        case notifyChannels = "messenger_topics"
        case nomadClientID = "nomad_ios_client_id"
        case oAuthAuthorizeURL = "oauth2_authorize_uri"
        case oAuthTokenURL = "oauth2_token_uri"
        case nomadRedirectURLs = "oauth2_ios_nomad_redirect_uris"
        case dropboxIntegrateURL = "dropbox_integrate_url"
        case driveIntegrateURL = "drive_integrate_url"
        case oneDriveIntegrateURL = "one_drive_integrate_url"
    }
}

public class VCSNotifyChannelsResponse: Codable {
    public let jobs: String
    public let file: String
    public let folder: String
    public let notification: String
    public let featureNotification: String
    
    enum CodingKeys: String, CodingKey {
        case jobs = "jobs"
        case file = "file"
        case folder = "folder"
        case notification = "notification"
        case featureNotification = "feature_notification"
    }
}
