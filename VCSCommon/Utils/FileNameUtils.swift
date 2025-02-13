import Foundation
import UIKit

public class FileNameUtils {
    public static func appendingShortUUIDName(name: String, UUDIString: String? = nil) -> String { // "Nomad_20191111-163306.9260"
        return name + "_" + (UUDIString ?? VCSUUID().shortenString())
    }
    
    public static func filePath(fileName: String, directoryPath: String, extention: String = "jpg") -> String {
        var imagePath:String = directoryPath.appendingPathComponent(fileName)
        let extCheckPath = (fileName as NSString).pathExtension
        if (extCheckPath != extention) {
            imagePath = imagePath.appendingPathExtension(extention)
        }
        
        return imagePath
    }
    
    public static func appendingTimestamp(name: String) -> String {
        let format: String = "yyyy-MM-dd HH-mm-ss"
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let timestamp = formatter.string(from: Date())
        return name.appending(timestamp)
    }
}
