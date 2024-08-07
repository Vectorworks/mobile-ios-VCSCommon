import Foundation
import UIKit

public class PageData {
    public static let DEFAULT_DEC_DIM_PRECISION: Int = 2
    public static let DEFAULT_DPI: Int = 72
    public var name: String = ""
    private var _dpi: Int = 0
    public var dpi: Int {
        set { _dpi = newValue }
        get { return _dpi == .zero ? PageData.DEFAULT_DPI : _dpi }
    }
    public var style: Int = 0
    public var unitsPerInch: Double = 0.0
    public var unitMark: String = ""
    public var decDimPrecision: Int = PageData.DEFAULT_DEC_DIM_PRECISION
    public var angleUnit: Int = 0
    public var angleDimPrecision: Int = 0
    public var areaPerSqInch: Double = 0.0
    public var areaUnitMark: String = ""
    public var areaDecPrecision: Int = 0
    
    public var viewports: [Viewport] = []
}

public class VWPoint: Equatable {
    public var x: Double = 0.0
    public var y: Double = 0.0
    
    public static func == (lhs: VWPoint, rhs: VWPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

public class CropRect {
    public var x: Double = 0.0
    public var y: Double = 0.0
    public var width: Double = 0.0
    public var height: Double = 0.0
    
    public init() {}
}

public class CropPoly {
    public var vertices: [VWPoint] = []
}

public class CropOval {
    public var center: VWPoint = VWPoint()
    public var radius: VWPoint = VWPoint()
}

public class MeasurementLayer: CAShapeLayer {
}

public class Viewport {
    public var x: Double = 0.0
    public var y: Double = 0.0
    public var rotation: Double = 0.0
    public var scale: Double = 0.0
    public var bezierPath: UIBezierPath?
    public var measurementLayer: MeasurementLayer?
    
    public var cropRect: CropRect?
    public var cropPoly: CropPoly?
    public var cropOval: CropOval?
    
    public init() {}
}
