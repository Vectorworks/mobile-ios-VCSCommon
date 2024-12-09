import SwiftUI

public typealias NameAndError = (name: String, error: FilenameValidationError)

public protocol FileUploadViewModel: ObservableObject {
    var lastSelectedFolderID: String { get set }
    var selectedFolder: VCSFolderResponse? { get set }
    
    var isUploading: Bool { get set }
    var totalProgress: Double { get set }
    var totalUploadsCount: Double { get set }
    
    
    var filesHasSameName: [NameAndError] { get }
    var filesHasInvalidName: [NameAndError] { get }
    var filesHasLongName: [NameAndError] { get }
    
    var itemsLocalNameAndPath: [LocalFileNameAndPath] { get set }
    
    var rootFolderResult: Result<VCSFolderResponse, Error>? { get set }
    
    func loadFolder(folderURI: String, folderResult: Binding<Result<VCSFolderResponse, Error>?>)
    
    func uploadAction(dismiss: DismissAction)
    
    func nameErrors() -> [NameAndError]
}

extension FileUploadViewModel {
    public var filesHasSameName: [NameAndError] {
        let result = nameErrors().filter({ $0.error == .exists})
        return result
    }
    
    public var filesHasInvalidName: [NameAndError] {
        let result = nameErrors().filter({ $0.error == .containsInvalidCharacters})
        return result
    }
    
    public var filesHasLongName: [NameAndError] {
        let result = nameErrors().filter({ $0.error == .lengthy})
        return result
    }
}

public protocol RCFileUploadViewModel: FileUploadViewModel {
    var baseFileName: String { get set }
    var newLocationName: String { get set }
    var isSaveButtonDisabled: Bool { get }
    var pickerProjectsBrowseOption: ProjectsBrowseOptions { get set }
    
    func loadHomeUserFolder()
    func isNewLocationNameError() -> NameAndError?
    func loadInitialRootFolder()
}

