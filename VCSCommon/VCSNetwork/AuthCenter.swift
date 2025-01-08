import Foundation

public class AuthCenter {
    public static let shared = AuthCenter()
    
    private static let loginSettingsKey = "AuthCenter.loginSettingsKey"
    
    public var loginSettings: VCSLoginSettingsResponse? {
        get { return VCSUserDefaults.default.getCodableItem(forKey: AuthCenter.loginSettingsKey) }
        set { VCSUserDefaults.default.setCodableItem(value: newValue, forKey: AuthCenter.loginSettingsKey) }
    }
}

public extension AuthCenter {
    func updateLogginSettings(redirectURI: String? = nil, sharedGroup: String? = nil, retryClearDataBlock: @escaping () -> Void, completion: ((Result<VCSLoginSettingsResponse, Error>) -> Void)? = nil) {
        APIClient.loginSettings().execute(onSuccess: { (result: VCSLoginSettingsResponse) in
            AuthCenter.shared.loginSettings = result
            APIClient.updateOAuthClient(loginSettings: result, retryClearDataBlock: retryClearDataBlock, redirectURI: redirectURI, sharedGroup: sharedGroup)
            completion?(.success(result))
        }, onFailure: { (error: Error) in
            completion?(.failure(error))
        })
    }
    
    func loadOAuthFromCache(loginSettings: VCSLoginSettingsResponse, retryClearDataBlock: @escaping () -> Void, sharedGroup: String? = nil) {
        APIClient.updateOAuthClient(loginSettings: loginSettings, retryClearDataBlock: retryClearDataBlock, sharedGroup: sharedGroup)
    }
}
