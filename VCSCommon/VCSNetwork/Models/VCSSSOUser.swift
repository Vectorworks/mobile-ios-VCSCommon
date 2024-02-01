import Foundation

public class VCSSSOUser: NSObject, Codable {
    public let id: Int
    public let firstName, lastName, email: String
    public let isActive: Bool
    public let login, nvwuid, gender: String
    public let industry, phone: String?
    public let honorific, language: String
    public let socialProviders: [String]
    public let hasPassword: Bool
    public let emails: [Email]
    public let isVerified, isEmployee: Bool
    public let otherLogins: [OtherLogin]
    public let otherUids: [String]
    public let apiToken: String
    public let groups: [String]
    public let vssid: String
    public let canEditEmail, canEditLogin: Bool
    private(set) public var isLoggedIn: Bool = false
    
    init(id: Int, firstName: String, lastName: String, email: String, isActive: Bool, login: String, nvwuid: String, gender: String, industry: String?, phone: String?, honorific: String, language: String, socialProviders: [String], hasPassword: Bool, emails: [Email], isVerified: Bool, isEmployee: Bool, otherLogins: [OtherLogin], otherUids: [String], apiToken: String, groups: [String], vssid: String, canEditEmail: Bool, canEditLogin: Bool, isLoggedIn: Bool) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.isActive = isActive
        self.login = login
        self.nvwuid = nvwuid
        self.gender = gender
        self.industry = industry
        self.phone = phone
        self.honorific = honorific
        self.language = language
        self.socialProviders = socialProviders
        self.hasPassword = hasPassword
        self.emails = emails
        self.isVerified = isVerified
        self.isEmployee = isEmployee
        self.otherLogins = otherLogins
        self.otherUids = otherUids
        self.apiToken = apiToken
        self.groups = groups
        self.vssid = vssid
        self.canEditEmail = canEditEmail
        self.canEditLogin = canEditLogin
        self.isLoggedIn = isLoggedIn
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case isActive = "is_active"
        case login, nvwuid, gender, phone, industry, honorific, language
        case socialProviders = "social_providers"
        case hasPassword = "has_password"
        case emails
        case isVerified = "is_verified"
        case isEmployee = "is_employee"
        case otherLogins = "other_logins"
        case otherUids = "other_uids"
        case apiToken = "api_token"
        case groups, vssid
        case canEditEmail = "can_edit_email"
        case canEditLogin = "can_edit_login"
    }
}

public class OtherLogin: NSObject, Codable {
    public let id: Int
    public let firstName, lastName, email: String
    public let isActive: Bool
    public let login, nvwuid, gender: String
    public let industry, phone: String?
    public let honorific, language, sourceSystem: String
    
    init(id: Int, firstName: String, lastName: String, email: String, isActive: Bool, login: String, nvwuid: String, gender: String, industry: String?, phone: String?, honorific: String, language: String, sourceSystem: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.isActive = isActive
        self.login = login
        self.nvwuid = nvwuid
        self.gender = gender
        self.industry = industry
        self.phone = phone
        self.honorific = honorific
        self.language = language
        self.sourceSystem = sourceSystem
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case isActive = "is_active"
        case login, nvwuid, gender, phone, industry, honorific, language
        case sourceSystem = "source_system"
    }
}
