import Foundation

public extension CGSize {
    init(_ point: CGPoint) {
        self.init()
        self.width = point.x
        self.height = point.y
    }
    
    func friendlyString() -> String {
        return "(\(String(format: "%.2f", width)), \(String(format: "%.2f", height)))"
    }
    
    static func + (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }
    
    static func - (left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width - right.width, height: left.height - right.height)
    }
    
    static func += (left: inout CGSize, right: CGSize) {
        left = left + right
    }
    
    static func -= (left: inout CGSize, right: CGSize) {
        left = left - right
    }
    
    static func / (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width / right, height: left.height / right)
    }
    
    static func * (left: CGSize, right: CGFloat) -> CGSize {
        return CGSize(width: left.width * right, height: left.height * right)
    }
    
    static func /= (left: inout CGSize, right: CGFloat) {
        left = left / right
    }
    
    static func *= (left: inout CGSize, right: CGFloat) {
        left = left * right
    }
}
