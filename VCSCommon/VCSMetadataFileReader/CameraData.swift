import Foundation
import simd

@objc public class CameraData: NSObject {
    public var eyeVector = SIMD3<Float>()
    public var upVector = SIMD3<Float>()
    public var centerVector = SIMD3<Float>()
    public var centerPt = SIMD2<Float>()
    public var latBounds: CGRect = CGRect.zero
    
    public var projection: Int = 0
    public var zoom: Double = 0.0
    public var scale: Double = 0.0
    public var fieldOfView: Double = 0.0
}
