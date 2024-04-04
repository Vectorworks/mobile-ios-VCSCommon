import Foundation

public enum AssetNameValidationResult<ValidationError: Error> {
    case valid
    case invalid(ValidationError)
}

public enum FilenameValidationError: Error {
    case empty, containsInvalidCharacters, exists
}

public enum FolderNameValidationError: Error {
    case lengthy, containsInvalidCaharacters
    
    public var localizedDescription: String {
        switch self {
        case .lengthy:
            return "The maximum length is 255 characters.".vcsLocalized
        case .containsInvalidCaharacters:
            return "\("The following characters are invalid:".vcsLocalized)\(VCSCommonConstants.invalidCharacterListStringFormat)"
        }
    }
}

public class FilenameValidator {
    public static func isNameValid(ownerLogin: String, storage: String, prefix: String, name: String) -> Bool {
        if name.isEmpty {
            return false
        } else if FolderNameValidator.doesAssetNameContainsIllegalSymbols(name) {
            return false
        } else if FilenameValidator.doesExist(ownerLogin: ownerLogin, storage: storage, prefix: prefix) {
            return false
        }
        
        return true
    }
    
    public static func validateFilename(ownerLogin: String, storage: String, prefix: String) -> AssetNameValidationResult<FilenameValidationError> {
        let name = prefix.lastPathComponent
        if name.isEmpty {
            return .invalid(.empty)
        }
        else if FolderNameValidator.doesAssetNameContainsIllegalSymbols(name) {
            return .invalid(.containsInvalidCharacters)
        }
        else if FilenameValidator.doesExist(ownerLogin: ownerLogin, storage: storage, prefix: prefix) {
            return .invalid(.exists)
        }
        
        return .valid
    }

    public static func doesExist(ownerLogin: String, storage: String, prefix: String) -> Bool {
        let predicate = NSPredicate(format: "ownerLogin == %@ && storageType == %@ && prefix == %@", ownerLogin, storage, prefix)
        if VCSGenericRealmModelStorage<VCSFileResponse.RealmModel>().getAll(predicate: predicate).first != nil {
            return true
        }
        
        if VCSGenericRealmModelStorage<UploadJobLocalFile.RealmModel>().getAll(predicate: predicate).first != nil {
            return true
        }
        
        return false
    }
    
    public static func validateMeasureProjectPath(path: String) -> AssetNameValidationResult<FilenameValidationError> {
        let name = path.lastPathComponent
        if name.isEmpty {
            return .invalid(.empty)
        }
        else if FolderNameValidator.doesAssetNameContainsIllegalSymbols(name) {
            return .invalid(.containsInvalidCharacters)
        }
        else if FilenameValidator.doesMeasureProjectExist(path: path) {
            return .invalid(.exists)
        }
        
        return .valid
    }
    
    public static func doesMeasureProjectExist(path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
}

public struct FolderNameValidator {
    public static func doesAssetNameContainsIllegalSymbols(_ name: String) -> Bool {
        return name.rangeOfCharacter(from: VCSCommonConstants.invalidCharacterSet) != nil
    }
    
    public static func validate(_ name: String) -> AssetNameValidationResult<FolderNameValidationError> {
        if name.count > 255 {
            return .invalid(.lengthy)
        } else if doesAssetNameContainsIllegalSymbols(name) {
            return .invalid(.containsInvalidCaharacters)
        }
        return .valid
    }
}
