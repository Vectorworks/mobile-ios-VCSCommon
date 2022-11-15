import Foundation
import simd

@objc public class CameraData: NSObject {
    public var eyeVector: float3 = []
    public var upVector: float3 = []
    public var centerVector: float3 = []
    public var centerPt: float2 = []
    public var latBounds: CGRect = CGRect.zero
    
    public var projection: Int = 0
    public var zoom: Double = 0.0
    public var scale: Double = 0.0
    public var fieldOfView: Double = 0.0
}
