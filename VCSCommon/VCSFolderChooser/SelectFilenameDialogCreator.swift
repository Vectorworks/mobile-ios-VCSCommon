import Foundation
import UIKit

public final class SelectFilenameDialogCreator: NSObject {
    
    private static func createCreationAlert(alertInfo: FileNameValidationAlert) -> UIAlertController {
        return UIAlertController(title: alertInfo.title, message: alertInfo.message, preferredStyle: .alert)
    }
    
    private static func presentCreationAlert(createFileAlert: UIAlertController, presenter: UIViewController, alertInfo: FileNameValidationAlert, handler: ((UIAlertAction) -> Void)? = nil) {
        let cancelAction = UIAlertAction(title: alertInfo.cancelActionTitle, style: .cancel, handler: alertInfo.cancelActionHandler)
        let createAction = UIAlertAction(title: alertInfo.defaultActionTitle, style: .default, handler: handler)
        
        createAction.isEnabled = alertInfo.defaultActionTitleIsEnabled
        cancelAction.isEnabled = alertInfo.cancelActionTitleIsEnabled

        createFileAlert.addAction(createAction)
        createFileAlert.addAction(cancelAction)
        
        if let textFieldConfigurationHandler = alertInfo.textFieldConfigurationHandler {
            createFileAlert.addTextField(configurationHandler: textFieldConfigurationHandler)
        }

        DispatchQueue.main.async {
            presenter.present(createFileAlert, animated: true, completion: nil)
        }
    }
    
    public static func createAndPresentFileCreationAlert(folderInfo: ContainingFolderMetadata, presenter: UIViewController, alertInfo: FileNameValidationAlert) {
        let createFileAlert = createCreationAlert(alertInfo: alertInfo)
        let handler: ((UIAlertAction) -> Void)? = { [unowned presenter] (action) in
            guard let fileName = createFileAlert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
            var filePrefix = folderInfo.prefix.appendingPathComponent(fileName)
            filePrefix = appendFileExtensionIfNeeded(filePrefix: filePrefix, fileType: alertInfo.fileType)
            
            
            let validationResult = FilenameValidator.validateFilename(ownerLogin: folderInfo.ownerLogin, storage: folderInfo.storageType.rawValue, prefix: filePrefix)
            switch validationResult {
            case .valid:
                alertInfo.defaultActionHandler(action, fileName)
            case .invalid(.containsInvalidCharacters):
                alertInfo.modifiedMessage = "A space at the beginning of the name is not allowed, and the following characters are invalid:".vcsLocalized + "\\ ? < > : * | %% & \" / ~ %@ #."
            case .invalid(.empty):
                alertInfo.modifiedMessage = "Please enter a filename.".vcsLocalized
            case .invalid(.exists):
                presentExistingFilenameAlert(alertInfo: alertInfo, folderInfo: folderInfo, presenter: presenter, fileName: fileName)
            }
        }
        
        presentCreationAlert(createFileAlert: createFileAlert, presenter: presenter, alertInfo: alertInfo, handler: handler)
    }
    
//    public static func createAndPresentMeasureProjectCreationAlert(path: String, presenter: UIViewController, alertInfo: FileNameValidationAlert) {
//        let createFileAlert = createCreationAlert(alertInfo: alertInfo)
//        let handler: ((UIAlertAction) -> Void)? = { [unowned presenter] (action) in
//            guard let fileName = createFileAlert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
//            let projectPrefix = path.appendingPathComponent(fileName)
//            
//            
//            let validationResult = FilenameValidator.validateMeasureProjectPath(path: projectPrefix)
//            switch validationResult {
//            case .valid:
//                alertInfo.defaultActionHandler(action, fileName)
//            case .invalid(.containsInvalidCharacters):
//                alertInfo.modifiedMessage = "A space at the beginning of the name is not allowed, and the following characters are invalid:".vcsLocalized + "\\ ? < > : * | %% & \" / ~ %@ #."
//            case .invalid(.empty):
//                alertInfo.modifiedMessage = "Please enter a filename.".vcsLocalized
//            case .invalid(.exists):
//                presentExistingMeasureProjectAlert(alertInfo: alertInfo, path: path, presenter: presenter, fileName: fileName)
//            }
//        }
//        
//        presentCreationAlert(createFileAlert: createFileAlert, presenter: presenter, alertInfo: alertInfo, handler: handler)
//    }
    
    //TODO: Cover all file type cases
    private static func appendFileExtensionIfNeeded(filePrefix: String, fileType: FileTypeForAlert) -> String {
        switch(fileType) {
        case .photo:
            if (filePrefix.pathExtension == Photo.fileExtension) {
                return filePrefix
            }
            return filePrefix.appendingPathExtension(Photo.fileExtension)
        case .pdf:
            if (filePrefix.pathExtension == "pdf") {
                return filePrefix
            }
            return filePrefix.appendingPathExtension("pdf")
        default:
            return filePrefix;
        }
    }
    
    private static func presentExistingFilenameAlert(alertInfo: FileNameValidationAlert, folderInfo: ContainingFolderMetadata, presenter: UIViewController, fileName: String) {
        let existingFilenameAlert: UIAlertController
        if (alertInfo.fileType == .folder) {
            existingFilenameAlert = existingFolderNameAlert(defaultHandler: { [unowned presenter] _ in
                createAndPresentFileCreationAlert(folderInfo: folderInfo, presenter: presenter, alertInfo: alertInfo)
            })
        }
        else if (folderInfo.storageType.isExternal) {
            existingFilenameAlert = permanentlyOverwriteExistingFileAlert(defaultHandler: { (action) in
                alertInfo.defaultActionHandler(action, fileName)
            }, cancelHandler: alertInfo.cancelActionHandler)
        }
        else {
            existingFilenameAlert = reversablyOverwriteExistingFileAlert(defaultHandler: { (action) in
                alertInfo.defaultActionHandler(action, fileName)
            }, cancelHandler: alertInfo.cancelActionHandler)

        }
        DispatchQueue.main.async {
            presenter.present(existingFilenameAlert, animated: true, completion: nil)
        }
    }
    
    private static func presentExistingMeasureProjectAlert(alertInfo: FileNameValidationAlert, path: String, presenter: UIViewController, fileName: String) {
        let existingFilenameAlert: UIAlertController
        if (alertInfo.fileType == .folder) {
            existingFilenameAlert = existingFolderNameAlert(defaultHandler: { [unowned presenter] _ in
//                createAndPresentMeasureProjectCreationAlert(path: path, presenter: presenter, alertInfo: alertInfo)
            })
        }
        else {
            existingFilenameAlert = reversablyOverwriteExistingFileAlert(defaultHandler: { (action) in
                alertInfo.defaultActionHandler(action, fileName)
            }, cancelHandler: alertInfo.cancelActionHandler)

        }
        DispatchQueue.main.async {
            presenter.present(existingFilenameAlert, animated: true, completion: nil)
        }
    }
    
    public static func reversablyOverwriteExistingFileAlert(defaultHandler: @escaping ((UIAlertAction) -> Void), cancelHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let existingFilenameAlert = UIAlertController(title: "Warning".vcsLocalized,
                                                      message: "File(s) with the same name already exist in your folder. Click Continue to overwrite. The previous file(s) will be available from their version history.".vcsLocalized,
                                                      preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Continue".vcsLocalized, style: .default, handler: defaultHandler)
        let cancelAction = UIAlertAction(title: "Cancel upload".vcsLocalized, style: .cancel, handler: cancelHandler)
        
        existingFilenameAlert.addAction(confirmAction)
        existingFilenameAlert.addAction(cancelAction)
        
        return existingFilenameAlert
    }
    
    public static func permanentlyOverwriteExistingFileAlert(defaultHandler: @escaping ((UIAlertAction) -> Void), cancelHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let existingFilenameAlert = UIAlertController(title: "Error".vcsLocalized,
                                                      message: "File with the same name already exists. Please enter another name.".vcsLocalized,
                                                      preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Overwrite".vcsLocalized, style: .destructive, handler: defaultHandler)
        let cancelAction = UIAlertAction(title: "Cancel".vcsLocalized, style: .cancel, handler: cancelHandler)
        
        existingFilenameAlert.addAction(confirmAction)
        existingFilenameAlert.addAction(cancelAction)
        
        return existingFilenameAlert
    }
    
    static func existingFolderNameAlert(defaultHandler: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let existingDirnameAlert = UIAlertController(title: Localization.default.string(key: "Error"), message: Localization.default.string(key: "Folder with the same name already exists."), preferredStyle: .alert)
        
        let ok = UIAlertAction(title: Localization.default.string(key: "OK"), style: .cancel, handler: defaultHandler)
        existingDirnameAlert.addAction(ok)
        
        return existingDirnameAlert
    }
}
