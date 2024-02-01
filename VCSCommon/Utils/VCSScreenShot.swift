import Foundation
import UIKit

public class ScreenshotCaptureData:NSObject {
    public let captureView:UIView
    public let filePath:String
    public let saveToGallery:Bool
    
    public let toastView:UIView?
    public let flashingView:UIView?
    
    public init(viewToCapture:UIView, filePath:String, saveToGallery:Bool, viewForToast:UIView?, viewToFlash:UIView?) {
        self.captureView = viewToCapture
        self.filePath = filePath
        self.saveToGallery = saveToGallery
        
        self.toastView = viewForToast
        self.flashingView = viewToFlash
    }    
}

public protocol ScreenCaptureHandler {
    func captureScreen(screenCaptureData:ScreenshotCaptureData)
}
