import Foundation
import SwiftUI
import AVFoundation
import UIKit

public enum EnumAccessPermission: Int {
    case undefined
    case allowed
    case denied
    case restricted
}

public enum MediaType: String {
    case photos, camera
    
    var description: String {
        return self.rawValue.firstCapitalized
    }
}

public class VCSDevicePermissions {
    
    public static func openSettings(completionHandler completion: ((Bool) -> Void)? = nil)
    {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, completionHandler: completion)
    }
    
    public static func showMissingPermissionsAlert(forMediaType media: MediaType, withAccessPermission permission: EnumAccessPermission, presenter: UIViewController, andCancelHandler cancelHandler: @escaping () -> Void) {
        var message = ""
        switch media {
        case .photos:
            message = permission == .denied ? "This feature requires access to Camera.\r\n\r\nYou can enable access in Privacy Settings." : "This feature requires access to Photos. You can enable access in Restrictions Settings."
        case .camera:
            message = permission == .denied ? "This feature requires access to Camera.\r\n\r\nYou can enable access in Privacy Settings." : "This feature requires access to Camera. You can enable access in Restrictions Settings."
        }
        let missingPermissionsAlert = UIAlertController(title: nil, message: Localization.default.string(key: message), preferredStyle: .alert)
        
        let cancelButtonTitle = permission == .denied ? "Cancel" : "OK"
        let cancelAction = UIAlertAction(title: cancelButtonTitle.vcsLocalized, style: .cancel) { (_) in
            cancelHandler()
        }
        
        if (permission == .denied)
        {
            let confirmAction = UIAlertAction(title: Localization.default.string(key: "Settings"), style: .default) { (_) in
                VCSDevicePermissions.openSettings()
            }
            missingPermissionsAlert.addAction(confirmAction)
        }
        
        missingPermissionsAlert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            presenter.present(missingPermissionsAlert, animated: true, completion: nil)
        }
    }
    
    public static func checkForCameraAccessPermission(with completion: @escaping (EnumAccessPermission) -> ()) {
        var cameraPermission = EnumAccessPermission.undefined
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        var completionDelayed = false
        switch cameraAuthorizationStatus {
        case .authorized:
            cameraPermission = .allowed
            break
        case .denied:
            cameraPermission = .denied
            break
        case .restricted:
            cameraPermission = .restricted
            break
        default:
            // Prompting user for the permission to use the camera.
            completionDelayed = true
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted { cameraPermission = .allowed }
                else { cameraPermission = .denied }
                
                completion(cameraPermission)
            }
        }
        
        if (!completionDelayed) { completion(cameraPermission) }
    }
    
}

public struct VCSDevicePermissionsSUI: ViewModifier {
    @Environment(\.dismiss) var dismiss
    @State var showNotAllowedAlert = false
    
    @State var media: MediaType
    @Binding var permissionGranted: EnumAccessPermission
    
    
    
    var alertMessage: String {
        switch media {
        case .photos:
            return permissionGranted == .denied ? "This feature requires access to Camera.\r\n\r\nYou can enable access in Privacy Settings." : "This feature requires access to Photos. You can enable access in Restrictions Settings."
        case .camera:
            return permissionGranted == .denied ? "This feature requires access to Camera.\r\n\r\nYou can enable access in Privacy Settings." : "This feature requires access to Camera. You can enable access in Restrictions Settings."
        }
    }
    
    var alertCancelButtonTitle: String {
        return permissionGranted == .denied ? "Cancel" : "OK"
    }
    
    public func body(content: Content) -> some View {
        content
            .alert(alertMessage.vcsLocalized, isPresented: $showNotAllowedAlert, actions: {
                Button(alertCancelButtonTitle.vcsLocalized, role: .destructive) {
                    dismiss()
                }
                if (permissionGranted == .denied) {
                    Button("Settings".vcsLocalized) {
                        VCSDevicePermissions.openSettings()
                    }
                }
                
            })
            .onAppear() {
                VCSDevicePermissions.checkForCameraAccessPermission { (permission) in
                    permissionGranted = permission
                    if permission != .allowed {
                        self.showNotAllowedAlert = true
                    }
                }
            }
        
    }
}

public extension View {
    func checkForCameraAccessPermission(forMediaType media: MediaType, permissionGranted: Binding<EnumAccessPermission>) -> some View {
        modifier(VCSDevicePermissionsSUI(media: media, permissionGranted: permissionGranted))
    }
}
