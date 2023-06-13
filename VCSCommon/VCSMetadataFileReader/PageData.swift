import Foundation
import UIKit

@objc public class PageData: NSObject {
    @objc public static let DEFAULT_DEC_DIM_PRECISION: Int = 2
    @objc public static let DEFAULT_DPI: Int = 72
    @objc public var name: String = ""
    @objc private var _dpi: Int = 0
    @objc public var dpi: Int {
        set { _dpi = newValue }
        get { return _dpi == .zero ? PageData.DEFAULT_DPI : _dpi }
    }
    @objc public var style: Int = 0
    @objc public var unitsPerInch: Double = 0.0
    @objc public var unitMark: String = ""
    @objc public var decDimPrecision: Int = PageData.DEFAULT_DEC_DIM_PRECISION
    @objc public var angleUnit: Int = 0
    @objc public var angleDimPrecision: Int = 0
    @objc public var areaPerSqInch: Double = 0.0
    @objc public var areaUnitMark: String = ""
    @objc public var areaDecPrecision: Int = 0
    
    @objc public var viewports: [Viewport] = []
}

@objc public class VWPoint: NSObject {
    @objc public var x: Double = 0.0
    @objc public var y: Double = 0.0
}

@objc public class CropRect: NSObject {
    @objc public var x: Double = 0.0
    @objc public var y: Double = 0.0
    @objc public var width: Double = 0.0
    @objc public var height: Double = 0.0
}

@objc public class CropPoly: NSObject {
    @objc public var vertices: [VWPoint] = []
}

@objc public class CropOval: NSObject {
    @objc public var center: VWPoint = VWPoint()
    @objc public var radius: VWPoint = VWPoint()
}

@objc public class MeasurementLayer: CAShapeLayer {
}

@objc public class Viewport: NSObject {
    @objc public var x: Double = 0.0
    @objc public var y: Double = 0.0
    @objc public var rotation: Double = 0.0
    @objc public var scale: Double = 0.0
    @objc public var bezierPath: UIBezierPath?
    @objc public var measurementLayer: MeasurementLayer?
    
    @objc public var cropRect: CropRect?
    @objc public var cropPoly: CropPoly?
    @objc public var cropOval: CropOval?
}
