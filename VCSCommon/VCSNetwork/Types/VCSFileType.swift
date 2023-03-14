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
    
    public func isInFileName(_ oName: String?) -> Bool {
        guard let name = oName else { return false }
        return self.isInFileName(name: name)
    }
    
    public func isInFileName(name: String) -> Bool {
        switch self {
        case VCSFileType.XMLZIP, VCSFileType.VWXPNG, VCSFileType.IMGPNG:
            return self.isInFileNameSuffix(name: name)
        default:
            return name.pathExtension.uppercased() == self.rawValue
        }
    }
    
    private func isInFileNameSuffix(name: String) -> Bool {
        return name.uppercased().hasSuffix(self.rawValue)
    }
    
    public var pathExt: String { return self.rawValue.lowercased() }
}
