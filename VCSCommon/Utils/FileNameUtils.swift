import Foundation
import UIKit

@objc public class FileNameUtils: NSObject {
    @objc public static func appendingTimeStampToName(name: String) -> String { // "Nomad_20191111-163306.9260"
        let date = Date()
        return FileNameUtils.appendTimeStampToNameWithDate(name: name, date: date)
    }
    
    @objc public static func appendTimeStampToNameWithDate(name: String, date: Date) -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "YYYYMMdd-HHmmss.SSSS"
        return FileNameUtils.appendTimeStampToNameWithDateAndDateFormatter(name: name, date: date, dateFormatter: dayTimePeriodFormatter)
    }
    
    @objc public static func appendTimeStampToNameWithDateAndDateFormatter(name: String, date: Date, dateFormatter: DateFormatter) -> String {
        let dateString = dateFormatter.string(from: date)
        var sceneFileName = name.lastPathComponent
        sceneFileName = sceneFileName.deletingPathExtension
        let fileName = sceneFileName + "_" + dateString
        
        return fileName
    }
    
    @objc public static func filePath(fileName: String, directoryPath: String, extention: String = "jpg") -> String {
        var imagePath:String = directoryPath.appendingPathComponent(fileName)
        let extCheckPath = (fileName as NSString).pathExtension
        if (extCheckPath != extention) {
            imagePath = imagePath.appendingPathExtension(extention)
        }
        
        return imagePath
    }
}
