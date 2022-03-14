import Foundation
import UIKit

struct MessageData {
    let message:String
    let imageName:String?
    
    init(message:String, imageName:String?) {
        self.message = message
        self.imageName = imageName
    }
}

class VCSMessageView: UIView {
    
    @IBOutlet weak var messageLabel:UILabel?
    @IBOutlet weak var imageView:UIImageView?
    
    func setupView(data:MessageData) {
        self.isHidden = false
        self.messageLabel?.text = data.message
        
        if let imageName = data.imageName {
            let image = imageName.namedImage
            self.imageView?.image = image
        }
    }
}
