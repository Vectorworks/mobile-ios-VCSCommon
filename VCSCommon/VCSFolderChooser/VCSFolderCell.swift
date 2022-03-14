import Foundation
import UIKit

class VCSFolderCell: UITableViewCell {
    static let cellIdentifier = "VCSFolderCell"
    
    @IBOutlet weak var folderThumbnailImageView: UIImageView!
    @IBOutlet weak var folderWarningImageView: UIImageView!
    @IBOutlet weak var foderNameLabel: UILabel!
    @IBOutlet weak var sharedIconBadge: UIImageView!
    @IBOutlet weak var permissionBadge: UIImageView!
    
    
    var folder: VCSFolderResponse?
}
