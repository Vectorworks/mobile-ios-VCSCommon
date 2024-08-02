import Foundation

public enum FilenameValidationError: Error {
    case empty, containsInvalidCharacters, exists
    
    public var localizedErrorText: String {
        switch self {
        case .empty:
            return "Empty Filename".vcsLocalized
        case .containsInvalidCharacters:
            return "Unsupported characters".vcsLocalized
        case .exists:
            return "File with the same name already exists".vcsLocalized
        }
    }
}

public enum FolderNameValidationError: Error {
    case lengthy, containsInvalidChaaracters
    
    public var localizedErrorText: String {
        switch self {
        case .lengthy:
            return "The maximum length is 255 characters.".vcsLocalized
        case .containsInvalidChaaracters:
            return "\("The following characters are invalid:".vcsLocalized)\(VCSCommonConstants.invalidCharacterListStringFormat)"
        }
    }
}

public class FilenameValidator {
    public static func validateFilename(ownerLogin: String, storage: String, prefix: String) ->
    Result<String, FilenameValidationError> {
        let name = prefix.lastPathComponent
        if name.isEmpty {
            return .failure(FilenameValidationError.empty)
        }
        else if FolderNameValidator.doesAssetNameContainsIllegalSymbols(name) {
            return .failure(FilenameValidationError.containsInvalidCharacters)
        }
        else if FilenameValidator.doesExist(ownerLogin: ownerLogin, storage: storage, prefix: prefix) {
            return .failure(FilenameValidationError.exists)
        }
        
        return .success(name)
    }

    public static func doesExist(ownerLogin: String, storage: String, prefix: String) -> Bool {
        let predicate = NSPredicate(format: "ownerLogin == %@ && storageType == %@ && prefix == %@", ownerLogin, storage, prefix)
        //TODO: REALM_CHANGE
//        if VCSGenericRealmModelStorage<VCSFileResponse.RealmModel>().getAll(predicate: predicate).first != nil {
//            return true
//        }
//        
//        if VCSGenericRealmModelStorage<UploadJobLocalFile.RealmModel>().getAll(predicate: predicate).first != nil {
//            return true
//        }
        
        return false
    }
    
    public static func validateMeasureProjectPath(path: String) -> Result<String, FilenameValidationError> {
        let name = path.lastPathComponent
        if name.isEmpty {
            return .failure(FilenameValidationError.empty)
        }
        else if FolderNameValidator.doesAssetNameContainsIllegalSymbols(name) {
            return .failure(FilenameValidationError.containsInvalidCharacters)
        }
        else if FilenameValidator.doesMeasureProjectExist(path: path) {
            return .failure(FilenameValidationError.exists)
        }
        
        return .success(name)
    }
    
    public static func doesMeasureProjectExist(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}

public struct FolderNameValidator {
    public static func doesAssetNameContainsIllegalSymbols(_ name: String) -> Bool {
        return name.rangeOfCharacter(from: VCSCommonConstants.invalidCharacterSet) != nil
    }
    
    public static func validate(_ name: String) -> Result<String, FolderNameValidationError> {
        if name.count > 255 {
            return .failure(FolderNameValidationError.lengthy)
        } else if doesAssetNameContainsIllegalSymbols(name) {
            return .failure(FolderNameValidationError.containsInvalidChaaracters)
        }
        return .success(name)
    }
}
