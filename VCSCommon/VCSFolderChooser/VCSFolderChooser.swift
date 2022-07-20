import Foundation
import UIKit
import Toast

public protocol VCSFolderChooserDelegate: AnyObject {
    func didChoose(folderResult: FolderChooserResult)
    func didCancel()
    func canCreateFolderIn(folder: VCSFolderResponse) -> Bool
    func createFolder(insideOf rootFolder: VCSFolderResponse, presenter: UIViewController)
}

public class VCSFolderChooser: UIViewController, UITableViewDelegate {
    
    public override class func vcsStoryboardID() -> String {return "VCSFolderChooser"}
    public override class func vcsStoryboardName() -> String {return "VCSFolderChooser"}
    
    public class func fromStoryboard(withDelegate delegate: VCSFolderChooserDelegate?, andFileName name: String) -> VCSFolderChooser? {
        guard let controller = VCSFolderChooser.storyboardInstance(Bundle.VCSCommon) as? VCSFolderChooser else { return nil }
        controller.delegate = delegate
        controller.fileName = name
        return controller
    }
    
    private static let removableFolderSuffix = "/"
    private var fileName: String = ""
    
    @IBOutlet weak var plusButton:UIButton?
    @IBOutlet weak var tableView:UITableView?
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView?
    @IBOutlet weak var messageView:VCSMessageView?
    @IBOutlet weak var storageButton:UIButton?
    @IBOutlet weak var folderPathLabel:UILabel?
    
    @IBAction func onCreateNewFolderButtonTap(_ sender: Any) {
        self.delegate?.createFolder(insideOf: self.folder!, presenter: self)
    }
    
    public weak var delegate:VCSFolderChooserDelegate?
    public var folder:VCSFolderResponse? {
        didSet {
            self.reloadBreadcrumbsView()
        }
    }
    
    var dataSource:VCSTableViewDataSource<VCSFolderResponse, VCSFolderCell> = VCSTableViewDataSource<VCSFolderResponse, VCSFolderCell>(models: [], reuseIdentifier: "") { (_,_) in } {
        didSet {
            self.tableView?.dataSource = self.dataSource
            self.reloadView()
        }
    }
    
    private func reloadView() {
        DispatchQueue.main.async {
            self.tableView?.refreshControl?.endRefreshing()
            self.activityIndicator?.stopAnimating()
            self.tableView?.reloadData()
        }
    }
    
    func checkForSubfolders() {
        DispatchQueue.main.async {
            guard let currentFolder = self.folder else {
                self.messageView?.isHidden = true
                return
            }
            guard let subfolders = currentFolder.subfolders else {
                self.messageView?.isHidden = true
                return
            }
            guard subfolders.count == 0 else {
                self.messageView?.isHidden = true
                return
            }
            
            let message = Localization.default.string(key: "Tap Done to select this folder.")
            let messageData = MessageData(message: message, imageName: nil)
            self.messageView?.setupView(data: messageData)
        }
    }
    
    func reloadBreadcrumbsView() {
        DispatchQueue.main.async {
            guard let currentFolder = self.folder else { return }
            
            self.setHeaderLabelText(currentFolder.prefix)
            
            var image: UIImage?
            if (AuthCenter.shared.user?.availableStorages.count ?? 0) > 1  {
                image = "drop_down_arrow".namedImage
            }
            self.storageButton?.setImage(image, for: .normal)
            
            guard let folderStorage = AuthCenter.shared.user?.availableStorages.first(where: { $0.storageType == currentFolder.storageType }) else { return }
            self.storageButton?.setTitle(folderStorage.storageType.displayName, for: .normal)
        }
    }
    
    func setHeaderLabelText(_ title: String) {
        var processedTitle = title.hasPrefix("/") ? title : "/" + (title)
        
        // drive /driveId_0AGVzBmfvEhnjUk9PVA/
        if let driveResult = title.range(of: StoragePage.driveIDRegXPattern, options:.regularExpression) {
            let replacingPathString = StoragePage.getNameFromURI(title).isEmpty ? "" : ("/" + StoragePage.getNameFromURI(title))
            processedTitle = title.replacingCharacters(in: driveResult, with: replacingPathString)
        }
        
        // share /driveId_sharedWithMebdee504c5156432fa83523a8ed5a9bdd/
        if let sharedResult = title.range(of: StoragePage.driveIDSharedRegXPattern, options:.regularExpression) {
            processedTitle = title.replacingCharacters(in: sharedResult, with: "/" + "Shared with me".vcsLocalized)
        }
        
        // share /driveId_sharedWithMeOneDrive90cefe5fad3849bebb4b4b284d0065fd/
        if let sharedResult = title.range(of: StoragePage.driveIDSharedOneDriveRegXPattern, options:.regularExpression) {
            processedTitle = title.replacingCharacters(in: sharedResult, with: "/" + "Shared".vcsLocalized)
        }
        
        if title == "/" || processedTitle == "/" {
            processedTitle = ""
        }
        
        self.folderPathLabel?.text = processedTitle
    }
    
    @objc func doneButtonPressed() {
        guard let resultfolder = self.folder else { return }
        let result = FolderChooserResult(ownerLogin: resultfolder.ownerLogin, storageType: resultfolder.storageType, prefix: resultfolder.prefix, fileName: self.fileName)
        if let files = resultfolder.files {
            let fileNames = files.map { $0.name }
            if fileNames.contains(self.fileName) {
                let alert = UIAlertController(title: "Error".vcsLocalized, message: "File with the same name already exists.".vcsLocalized, preferredStyle: .alert)
                alert.addTextField { (textField) in
                    textField.placeholder = "File name".vcsLocalized
                    textField.delegate = VCSAlertTextFieldValidator.defaultWithPresenter(self)
                    textField.text = result.fileName
                    textField.selectAll(nil)
                }
                let ok = UIAlertAction(title: "OK".vcsLocalized, style: .default) { (_) in
                    var newName = FileNameUtils.appendingTimeStampToName(name: "Measurement").appendingPathExtension("vwx")
                    if var newAlertName = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) {
                        if newAlertName.pathExtension != "vwx" {
                            newAlertName = newAlertName.deletingPathExtension.appendingPathExtension("vwx")
                        }
                        newName = newAlertName
                    }
                    result.fileName = newName
                    self.delegate?.didChoose(folderResult: result)
                }
                
                let cancel = UIAlertAction(title: "Cancel".vcsLocalized, style: .cancel, handler: nil)
                ok.isEnabled = false
                alert.addAction(ok)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
        self.delegate?.didChoose(folderResult: result)
    }
    
    @objc func cancelButtonPressed() {
        guard self.folder?.prefix == "/" else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        self.delegate?.didCancel()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadFolderData()
    }
    
    override public func viewDidLoad() {
        self.title = Localization.default.string(key: "Select Folder")
        let done = UIBarButtonItem(title: "Done".vcsLocalized, style: .done, target: self, action: #selector(doneButtonPressed))
        done.tintColor = .white
        self.navigationItem.rightBarButtonItem = done
        
        self.navigationItem.hidesBackButton = true
        let cancelTitle = self.folder == nil ? Localization.default.string(key: "Cancel") : Localization.default.string(key: "Back")
        let cancel = UIBarButtonItem(title: cancelTitle, style: .plain, target: self, action: #selector(cancelButtonPressed))
        cancel.tintColor = .white
        self.navigationItem.leftBarButtonItem = cancel
        
        self.plusButton?.isHidden = true
        
        self.tableView?.delegate = self
        self.tableView?.separatorStyle =  UITableViewCell.SeparatorStyle.none
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadFolderData), for: .valueChanged)
        self.tableView?.refreshControl = refreshControl
        
        self.activityIndicator?.startAnimating()
        
        self.reloadBreadcrumbsView()
    }
    
    @objc public func loadFolderData() {
        let assetURI = self.folder?.resourceURI ?? AuthCenter.shared.user?.availableStorages.first?.folderURI ?? ""
        
        APIClient.folderAsset(assetURI: assetURI, flags: true, thumbnail3D: false, fileTypes: false, sharingInfo: false)
            .execute(onSuccess: { (folderResult: VCSFolderResponse) in
                self.folder = folderResult
                self.setDataSource(with: folderResult)
                self.checkForSubfolders()
                self.plusButton?.isHidden = !(self.delegate?.canCreateFolderIn(folder: folderResult) ?? false)
            }, onFailure: { (err: Error) in
                print(err)
                let message = Localization.default.string(key: "There was an error while loading files. Please try again.")
                self.view.makeToast(message, duration: 3, position: .center)
                self.reloadView()
        })
    }
    
    func setDataSource(with folder:VCSFolderResponse) {
        let data: [VCSFolderResponse] = folder.subfolders?.sorted { $0.name < $1.name } ?? []
        self.dataSource = VCSTableViewDataSource<VCSFolderResponse, VCSFolderCell>(models: data, reuseIdentifier: VCSFolderCell.cellIdentifier, cellConfigurator: { (folder, cell) in
            cell.foderNameLabel?.text = folder.name
            
            guard let flags = folder.flags else { return }
            cell.folderWarningImageView.isHidden = !flags.hasWarning
            cell.folderWarningImageView.isHidden = !flags.hasWarning
            cell.folderWarningImageView.isHidden = !flags.hasWarning
            
            
            let isOwned = AuthCenter.shared.user?.login == nil || (folder.ownerLogin == AuthCenter.shared.user?.login)
            cell.sharedIconBadge.isHidden = isOwned
            cell.permissionBadge.isHidden = isOwned
            if !isOwned {
                var permissionBadgeImage: UIImage?
                print(folder.cellData.permissions)
                if folder.cellData.hasPermission(SharedWithMePermission.view.rawValue) {
                    permissionBadgeImage = VCSFCIconsStr.badge_view.namedImage
                }
                if folder.cellData.hasPermission(SharedWithMePermission.download.rawValue) {
                    permissionBadgeImage = VCSFCIconsStr.badge_download.namedImage
                }
                if folder.cellData.hasPermission(SharedWithMePermission.modify.rawValue) {
                    permissionBadgeImage = VCSFCIconsStr.badge_edit.namedImage
                }
                
                cell.permissionBadge.isHidden = permissionBadgeImage == nil
                if permissionBadgeImage != nil {
                    cell.permissionBadge.layer.cornerRadius = cell.permissionBadge.frame.size.width / 2
                    cell.permissionBadge.layer.masksToBounds = true
                    cell.permissionBadge.layer.borderWidth = 3
                    cell.permissionBadge.layer.borderColor = UIColor.systemBackground.cgColor
                    cell.permissionBadge.image = permissionBadgeImage
                }
            }
        })
    }
    
    public func openInNewController(folder: VCSFolderResponse) {
        guard let controller = VCSFolderChooser.fromStoryboard(withDelegate: self.delegate, andFileName: self.fileName) else { return }
        controller.folder = folder
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let folderData = self.dataSource.models[indexPath.row]
        guard let flags = folderData.flags else {
            let message = Localization.default.string(key: "The selected file or folder contains unsupported characters and cannot be opened.")
            self.view.makeToast(message, duration: 3, position: .center)
            return
        }
        guard flags.hasWarning == false else {
            let message = Localization.default.string(key: "The selected file or folder contains unsupported characters and cannot be opened.")
            self.view.makeToast(message, duration: 3, position: .center)
            return
        }
        
        self.openInNewController(folder: folderData)
    }
    
    @IBAction func storageButtonClicked(_ sender: UIButton) {
        APIClient.listStorage().execute(onSuccess: { (result: StorageList) in
            AuthCenter.shared.user?.setStorageList(storages: result)
            self.showStorageAlert(homeButton: sender)
        }, onFailure: { (err: Error) in
            print(err)
            self.showStorageAlert(homeButton: sender)
        })
    }
    
    private func showStorageAlert(homeButton: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        AuthCenter.shared.user?.availableStorages.forEach { [unowned self] (storage) in
            let storageAction = storage.getStorageAction(homeButton: homeButton, presenter: self)
            alertController.addAction(storageAction)
        }
        
        let cancelMessage = Localization.default.string(key: "Cancel")
        let cancelButton = UIAlertAction(title: cancelMessage, style: .cancel, handler: nil)
        alertController.addAction(cancelButton)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = homeButton
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func changeStorage(storage: VCSStorageResponse) {
        APIClient.folderAsset(assetURI: storage.folderURI, flags: true, thumbnail3D: true, fileTypes: true).execute(onSuccess: { (folder) in
            if let vc = self.navigationController?.viewControllers.first(where: { $0 is VCSFolderChooser }) as? VCSFolderChooser {
                vc.folder = folder
                vc.loadFolderData()
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }, onFailure: { (error: Error) in
            print("Error loading folder \(storage.folderURI)\n\(error)")
            let errMessage = Localization.default.string(key: "There was an error while loading files. Please try again.")
            self.view.makeToast(errMessage, duration: 3, position: .center)
            AuthCenter.shared.user?.removeAvailableStorage(storage: storage)
            
            self.changeBackToS3Storage(error: error, failedStorage: storage.storageType)
        })
    }
    
    func changeStoragePage(storagePage: StoragePage) {
        APIClient.folderAsset(assetURI: storagePage.folderURI, flags: true, thumbnail3D: true, fileTypes: true).execute(onSuccess: { (folder) in
            if let vc = self.navigationController?.viewControllers.first(where: { $0 is VCSFolderChooser }) as? VCSFolderChooser {
                vc.folder = folder
                vc.loadFolderData()
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }, onFailure: { (error: Error) in
            print("Error loading folder \(storagePage.folderURI)\n\(error)")
            let errMessage = Localization.default.string(key: "There was an error while loading files. Please try again.")
            self.view.makeToast(errMessage, duration: 3, position: .center)
            
            self.changeBackToS3Storage(error: error, failedStorage: StorageType.GOOGLE_DRIVE)
        })
    }
    
    private func changeBackToS3Storage(error: Error, failedStorage: StorageType) {
        if error.asAFError?.responseCode == 401,
            failedStorage.isExternal,
            let S3Storage = AuthCenter.shared.user?.availableStorages.first {
            self.changeStorage(storage: S3Storage)
        } else {
            self.activityIndicator?.startAnimating()
        }
    }
    
}
