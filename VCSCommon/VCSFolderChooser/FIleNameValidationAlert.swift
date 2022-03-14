import Foundation
import UIKit

@objc public enum FileTypeForAlert: Int {
    case folder
    case photo
    case measurement
    case project
    case assets
    case pdf
}

public enum SelectedAssetsForPhotogrammetry {
    case files(count: Int)
    case folder(name: String)
}

@objc public protocol FileNameValidationAlert: AnyObject {
    var fileType: FileTypeForAlert { get }
    var title: String { get }
    var message: String { get }
    var modifiedMessage: String? { get set }
    
    var cancelActionTitle: String { get }
    var cancelActionTitleIsEnabled: Bool { get }
    var cancelActionHandler: (UIAlertAction) -> Void { get }
    
    var defaultActionTitle: String { get }
    var defaultActionTitleIsEnabled: Bool { get }
    var defaultActionHandler: (UIAlertAction, String) -> Void { get }
    
    var textFieldConfigurationHandler: ((UITextField) -> Void)? { get }
}

public class CreateMeasurementLocalizedAlert: FileNameValidationAlert {
    public let fileType: FileTypeForAlert = .measurement
        
    public var title: String = "Save Measurement".vcsLocalized
    
    public var message: String {
        return modifiedMessage ?? "Please enter a filename.".vcsLocalized
    }
    
    public var modifiedMessage: String?
    
    public var defaultActionTitle: String = "Save".vcsLocalized
    
    public var defaultActionTitleIsEnabled: Bool = true
    
    public var defaultActionHandler: (UIAlertAction, String) -> Void
    
    public var textFieldConfigurationHandler: ((UITextField) -> Void)?
    
    public var cancelActionTitle: String = "Cancel".vcsLocalized
    
    public var cancelActionTitleIsEnabled: Bool = true
    
    public var cancelActionHandler: (UIAlertAction) -> Void {
        return { (_) in }
    }
    
    public init(defaultActionHandler: @escaping (UIAlertAction, String) -> Void, textFieldConfigurationHandler: ((UITextField) -> Void)?) {
        self.defaultActionHandler = defaultActionHandler
        self.textFieldConfigurationHandler = textFieldConfigurationHandler
    }
}

public class CreatePhotoLocalizedAlert: FileNameValidationAlert {
    public let fileType: FileTypeForAlert = .photo
    
    public var title: String = "Upload Photo".vcsLocalized
    
    public var message: String {
        return modifiedMessage ?? "Please enter a filename.".vcsLocalized
    }
    
    public var modifiedMessage: String?
    
    public var defaultActionTitle: String = "OK".vcsLocalized
    
    public var defaultActionTitleIsEnabled: Bool = true
    
    public var defaultActionHandler: (UIAlertAction, String) -> Void
    
    public var textFieldConfigurationHandler: ((UITextField) -> Void)?
    
    public var cancelActionTitle: String = "Cancel".vcsLocalized
    
    public var cancelActionTitleIsEnabled: Bool = true
    
    public var cancelActionHandler: (UIAlertAction) -> Void {
        return { (_) in }
    }
    
    public init(defaultActionHandler: @escaping (UIAlertAction, String) -> Void, textFieldConfigurationHandler: ((UITextField) -> Void)?) {
        self.defaultActionHandler = defaultActionHandler
        self.textFieldConfigurationHandler = textFieldConfigurationHandler
    }
}

public class CreateProjectLocalizedAlert: FileNameValidationAlert {
    public let fileType: FileTypeForAlert = .project
    
    public var title: String = "New project".vcsLocalized
    
    public var message: String {
        return modifiedMessage ?? ""
    }
    
    public var modifiedMessage: String?
    
    public var defaultActionTitle: String = "Create".vcsLocalized
    
    public var defaultActionTitleIsEnabled: Bool = true
    
    public var defaultActionHandler: (UIAlertAction, String) -> Void
    
    public var textFieldConfigurationHandler: ((UITextField) -> Void)?
    
    public var cancelActionTitle: String = "Cancel".vcsLocalized
    
    public var cancelActionTitleIsEnabled: Bool = true
    
    public var cancelActionHandler: (UIAlertAction) -> Void {
        return { (_) in }
    }
    
    public init(defaultActionHandler: @escaping (UIAlertAction, String) -> Void, textFieldConfigurationHandler: ((UITextField) -> Void)?) {
        self.defaultActionHandler = defaultActionHandler
        self.textFieldConfigurationHandler = textFieldConfigurationHandler
    }
}

public class CreateFolderLocalizedAlert: FileNameValidationAlert {
    public let fileType: FileTypeForAlert = .folder
    
    public var title: String = "Folder name".vcsLocalized
    
    public var message: String {
        return modifiedMessage ?? ""
    }
    
    public var modifiedMessage: String?
    
    public var defaultActionTitle: String = "Create".vcsLocalized
    
    public var defaultActionTitleIsEnabled: Bool = true
    
    public var defaultActionHandler: (UIAlertAction, String) -> Void
    
    public var textFieldPlaceholder: String = "Folder name".vcsLocalized
    
    public var textFieldConfigurationHandler: ((UITextField) -> Void)?
    
    public var cancelActionTitle: String = "Cancel".vcsLocalized
    
    public var cancelActionTitleIsEnabled: Bool = true
    
    public var cancelActionHandler: (UIAlertAction) -> Void {
        return { (_) in }
    }
    
    public init(defaultActionHandler: @escaping (UIAlertAction, String) -> Void, textFieldConfigurationHandler: ((UITextField) -> Void)?) {
        self.defaultActionHandler = defaultActionHandler
        self.textFieldConfigurationHandler = textFieldConfigurationHandler
    }
}

public class AssetsToPhotogramLocalizedAlert: FileNameValidationAlert {
    public let fileType: FileTypeForAlert = .assets
    
    public let selectedAssets: SelectedAssetsForPhotogrammetry
    
    public var title: String = "Photos to 3D Model".vcsLocalized
    
    public var message: String {
        switch selectedAssets {
        case .files(count: let count):
            return "%d images selected.".vcsLocalized.replacingOccurrences(of: "%d", with: "\(count)")
        case .folder(name: let name):
            return "Folder '%@' selected.".vcsLocalized.replacingOccurrences(of: "'%@'", with: "\(name)")
        }
    }
    
    public var modifiedMessage: String?
    
    public var defaultActionTitle: String = "Start".vcsLocalized
    
    public var defaultActionTitleIsEnabled: Bool = false
    
    public var defaultActionHandler: (UIAlertAction, String) -> Void
    
    public var textFieldPlaceholder: String = "Output folder name".vcsLocalized
    
    public var textFieldConfigurationHandler: ((UITextField) -> Void)?
    
    public var cancelActionTitle: String = "Cancel".vcsLocalized
    
    public var cancelActionTitleIsEnabled: Bool = true
    
    public var cancelActionHandler: (UIAlertAction) -> Void {
        return { (_) in }
    }

    public init(selectedAssets: SelectedAssetsForPhotogrammetry, defaultActionHandler: @escaping (UIAlertAction, String) -> Void) {
        self.selectedAssets = selectedAssets
        self.defaultActionHandler = defaultActionHandler
    }
}

@objc public class CreatePdfLocalizedAlert: NSObject, FileNameValidationAlert {
    public let fileType: FileTypeForAlert = .pdf
    
    public var title: String = "Name of Saved File".vcsLocalized
    
    public var message: String {
        return modifiedMessage ?? "Please enter a filename.".vcsLocalized
    }
    
    public var modifiedMessage: String?
    
    public var defaultActionTitle: String = "Save".vcsLocalized
    
    public var defaultActionTitleIsEnabled: Bool = true
    
    public var defaultActionHandler: (UIAlertAction, String) -> Void
    
    public var textFieldConfigurationHandler: ((UITextField) -> Void)?
    
    public var cancelActionTitle: String = "Cancel".vcsLocalized
    
    public var cancelActionTitleIsEnabled: Bool = true
    
    public var cancelActionHandler: (UIAlertAction) -> Void {
        return { (_) in }
    }
    
    @objc public init(defaultActionHandler: @escaping (UIAlertAction, String) -> Void, textFieldConfigurationHandler: ((UITextField) -> Void)?) {
        self.defaultActionHandler = defaultActionHandler
        self.textFieldConfigurationHandler = textFieldConfigurationHandler
    }
}

