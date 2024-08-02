import Foundation
import UIKit

public class FolderCreator: NSObject {

    public static func sendCreateFolderRequest(_ foldername: String, _ storage: StorageType, _ parentPrefix: String, owner: String, _ presenter: UIViewController?) {
        guard let presenterVC = presenter else { return }
        
        APIClient.createFolder(storage: storage, name: foldername, parentFolderPrefix: parentPrefix, owner: owner).execute(onSuccess: { (result: VCSFolderResponse) in
            result.addToCache()
            if let folderChooser = presenter as? VCSFolderChooser {
                folderChooser.openInNewController(folder: result)
            }
        }, onFailure: { (error: Error) in
            let localizedTitle = "Could Not Create Folder".vcsLocalized
            var localizedMessage = "Invalid Name".vcsLocalized
            let localizedActionTitle = "OK".vcsLocalized
            
            if error.responseCode == 409 {
                localizedMessage = "Folder with the same name already exists. Please enter another name.".vcsLocalized
            }
            
            let alertView = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: localizedActionTitle, style: .default, handler: nil)

            alertView.addAction(okAction)

            presenterVC.present(alertView, animated: true, completion: nil)
        })
    }
}
