import Foundation
import CocoaLumberjackSwift

extension VCSStorageResponse {
    func getStorageAction(homeButton: UIButton, presenter: VCSFolderChooser) -> UIAlertAction {
        let storageAction = UIAlertAction(title: self.storageType.displayName, style: .default, handler: { (action) -> Void in
            presenter.activityIndicator?.startAnimating()
            
            if self.storageType == .GOOGLE_DRIVE {
                self.googleStorageAction(homeButton: homeButton, presenter: presenter)
            } else if self.storageType == .ONE_DRIVE {
                self.oneDriveStorageAction(homeButton: homeButton, presenter: presenter)
            } else {
                self.storageAction(presenter: presenter)
            }
            
        })
        storageAction.setValue(self.storageImage(), forKey: "image")
        
        return storageAction
    }
    
    private func storageAction(presenter: VCSFolderChooser) {
        guard self.folderURI != presenter.folder?.resourceURI else { return }
        
        presenter.changeStorage(storage: self)
    }
    
    private func googleStorageAction(homeButton: UIButton, presenter: VCSFolderChooser) {
        guard let pagesURL = self.pagesURL else { return }
        
        APIClient.getStoragePagesList(storagePagesURI: pagesURL).execute { (result: StoragePagesList) in
            self.setStoragePagesList(storagePages: result)
            self.addToCache()
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            result.forEach { (storagePage) in
                guard storagePage.id != "sharedWithMe" else { return }
                let storagePageAction = UIAlertAction(title: storagePage.name, style: .default, handler: { (action) -> Void in
                    guard storagePage.folderURI != presenter.folder?.resourceURI else { return }
                    presenter.changeStoragePage(storagePage: storagePage)
                })
                storagePageAction.setValue(storagePage.storageImage(), forKey: "image")
                alertController.addAction(storagePageAction)
            }
            
            let cancelButton = UIAlertAction(title: "Cancel".vcsLocalized, style: .cancel)
            alertController.addAction(cancelButton)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = homeButton
            }
            
            presenter.present(alertController, animated: true, completion: nil)
        } onFailure: { (error: Error) in
            DDLogError(error.localizedDescription)
        }
    }
    
    private func oneDriveStorageAction(homeButton: UIButton, presenter: VCSFolderChooser) {
        guard let pagesURL = self.pagesURL else { return }
        
        APIClient.getStoragePagesList(storagePagesURI: pagesURL).execute { (result: StoragePagesList) in
            self.setStoragePagesList(storagePages: result)
            self.addToCache()
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            result.forEach { (storagePage) in
                guard storagePage.id != "sharedWithMeOneDrive" else { return }
                let storagePageAction = UIAlertAction(title: storagePage.name, style: .default, handler: { (action) -> Void in
                    guard storagePage.folderURI != presenter.folder?.resourceURI else { return }
                    presenter.changeStoragePage(storagePage: storagePage)
                })
                storagePageAction.setValue(storagePage.storageImage(), forKey: "image")
                alertController.addAction(storagePageAction)
            }
            
            let cancelButton = UIAlertAction(title: "Cancel".vcsLocalized, style: .cancel)
            alertController.addAction(cancelButton)
            
            if let popoverController = alertController.popoverPresentationController {
                popoverController.sourceView = homeButton
            }
            
            presenter.present(alertController, animated: true, completion: nil)
        } onFailure: { (error: Error) in
            DDLogError(error.localizedDescription)
        }
    }
}
