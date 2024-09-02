import Foundation
import CoreLocation
import CocoaLumberjackSwift

private let REQUESTED_LOCATION_ALWAYS_KEY = "re.notifica.geo.requested_location_always"

public class VCSLocationServices: NSObject {
    public static let `default` = VCSLocationServices()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    private let locationManager = CLLocationManager()
    private var requestedPermission: LocationPermissionGroup?
    private var authorizationStatus: CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    private func requestWhenInUseLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func requestAlwaysLocationPermission() {
        locationManager.requestAlwaysAuthorization()
    }
    
    public func requestLocation() {
        let status = checkLocationPermissionStatus(permission: .locationWhenInUse)
        if status != .granted {
            // Location When in Use permission request denied
            requestWhenInUseLocationPermission()
            return
        }
        
        locationManager.requestLocation()
    }
}

extension VCSLocationServices: CLLocationManagerDelegate {
    private func checkLocationPermissionStatus(permission: LocationPermissionGroup) -> LocationPermissionStatus {
        if permission == .locationAlways {
            switch authorizationStatus {
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .restricted
            case .denied:
                return .permanentlyDenied
            case .authorizedWhenInUse:
                return UserDefaults.standard.bool(forKey: REQUESTED_LOCATION_ALWAYS_KEY) ? .permanentlyDenied : .notDetermined
            case .authorizedAlways:
                return .granted
            @unknown default:
                return .notDetermined
            }
        }
        
        switch authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .permanentlyDenied
        case .authorizedWhenInUse, .authorizedAlways:
            return .granted
        @unknown default:
            return .notDetermined
        }
    }
    
    private func requestLocationPermission(permission: LocationPermissionGroup) {
        requestedPermission = permission
        
        if permission == .locationWhenInUse {
            requestWhenInUseLocationPermission()
        } else if permission == .locationAlways {
            requestAlwaysLocationPermission()
            
            // Helps us to identify if Always permission has already been requested
            UserDefaults.standard.set(true, forKey: REQUESTED_LOCATION_ALWAYS_KEY)
        }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationStatusChange(manager.authorizationStatus)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        DDLogError("locationManager didFailWithError: \(error)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DDLogInfo("locationManager didUpdateLocations: \(locations)")
//        let fistLocationAccuracy = locations.first
    }
    
    private func onAuthorizationStatusChange(_ authorizationStatus: CLAuthorizationStatus) {
        if authorizationStatus == .notDetermined {
            // When the user changes to "Ask Next Time" via the Settings app.
            UserDefaults.standard.removeObject(forKey: REQUESTED_LOCATION_ALWAYS_KEY)
        }
        
        guard let requestedPermission = requestedPermission else {
            // Location permission status did change but you didnt request any permission, meaning user did some changes in application settings
            return
        }
        
        self.requestedPermission = nil
        
        let status = checkLocationPermissionStatus(permission: requestedPermission)
        if requestedPermission == .locationWhenInUse {
            if status != .granted {
                // Location When in Use permission request denied
                
                return
            }
        }
        
        if requestedPermission == .locationAlways {
            if status == .granted {
                // Location Always permission request granted, enabling location updates
                
                return
            }
        }
    }
}

private extension VCSLocationServices {
    enum LocationPermissionGroup: String, CaseIterable {
        case locationWhenInUse = "When in Use"
        case locationAlways = "Always"
    }
    
    enum LocationPermissionStatus: String, CaseIterable {
        case notDetermined = "Not Determined"
        case granted = "Granted"
        case restricted = "Restricted"
        case permanentlyDenied = "Permanently Denied"
    }
}

