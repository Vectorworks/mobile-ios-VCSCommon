import Foundation

public enum VCSFileType: String
{
    case OTHER
    case VWX
    case PDF
    case SNAP
    case VWINFO
    case THUMB
    case THUMB_3D
    case SCENE
    case MATERIALS
    case VWXP
    case VWXW
    case IMG
    case VW3DW
    case VGX
    case PANORAMA
    case DIR
    case VIDEO
    case VIDEO_360
    
    //custom
    case PNG
    case JPG
    case TXT
    case XML
    case ZIP
    case VWSNAP
    case XMLZIP = "XML.ZIP"
    case VWXPNG = "VWX.PNG"
    case IMGPNG = "300X300.PNG"
    case UNRESOLVED_LINK
    case PTS
    case HEIC
    case TIF
    case JSON
    case VMSR
    case USDZ
    case ARWM
    case HTML
    case VCDOC
    case SAVEDVIEWS
    case REALITY
    case OBJ
    case CONNECTCAD
    
    case VWX_EXTENDED
    
    public func isInFileName(_ oName: String?) -> Bool {
        guard let name = oName else { return false }
        return self.isInFileName(name: name)
    }
    
    public func isInFile(file: VCSFileResponse) -> Bool {
        switch self {
        case VCSFileType.IMG, VCSFileType.PANORAMA, VCSFileType.VIDEO, VCSFileType.VIDEO_360:
            return file.fileType == self.rawValue
        default:
            return self.isInFileName(name: file.name)
        }
    }
    
    public func isInFile(fileType: String, fileName: String) -> Bool {
        switch self {
        case VCSFileType.IMG, VCSFileType.PANORAMA, VCSFileType.VIDEO, VCSFileType.VIDEO_360:
            return fileType == self.rawValue
        default:
            return self.isInFileName(name: fileName)
        }
    }
    
    public func isInFileName(name: String) -> Bool {
        switch self {
        case VCSFileType.XMLZIP, VCSFileType.VWXPNG, VCSFileType.IMGPNG:
            return self.isInFileNameSuffix(name: name)
        case .VWX_EXTENDED:
            return (name.pathExtension.lowercased() == VCSFileType.VWX.pathExt)
            || (name.pathExtension.lowercased() == VCSFileType.VWXP.pathExt)
            || (name.pathExtension.lowercased() == VCSFileType.VWXW.pathExt)
        default:
            return name.pathExtension.lowercased() == self.pathExt
        }
    }
    
    private func isInFileNameSuffix(name: String) -> Bool {
        return name.lowercased().hasSuffix(self.pathExt)
    }
    
    public var pathExt: String { return self.rawValue.lowercased() }
}
