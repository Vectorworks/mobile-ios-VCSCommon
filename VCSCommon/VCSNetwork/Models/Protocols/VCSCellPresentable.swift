import Foundation

public protocol VCSCellPresentable {
    var rID: String { get }
    var name: String { get }
    var hasWarning: Bool { get }
    var isShared: Bool { get }
    var hasLink: Bool { get }
    var sharingInfoData: VCSSharingInfoResponse? { get }
    var sortingDate: Date { get }
    var isFolder: Bool { get }
    var isAvailableOnDevice: Bool { get }
    var filterShowingOffline: Bool { get }
    func hasPermission(_ permission: String) -> Bool
    var permissions: [String] { get }
}
