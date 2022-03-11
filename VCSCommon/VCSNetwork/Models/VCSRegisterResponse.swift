import Foundation

@objc public class VCSRegisterResponse: NSObject, Codable {
    @objc public let status: String?
    @objc public let detail: String
}
