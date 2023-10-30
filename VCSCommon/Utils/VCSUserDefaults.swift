import Foundation

@objc
public class VCSUserDefaults: UserDefaults {
    fileprivate static var privateAppGroupDefaults: VCSUserDefaults = VCSUserDefaults()
    public static var `default`: VCSUserDefaults { return VCSUserDefaults.privateAppGroupDefaults }
    
    @objc
    public static var defaultOBJC: VCSUserDefaults { return VCSUserDefaults.default }
    
    public static func useProvidedAppGroupDefaults(_ ud: VCSUserDefaults?) {
        guard let newUD = ud else {
            print("failed setting useProvidedAppGroupDefaults")
            return
        }
        VCSUserDefaults.privateAppGroupDefaults = newUD
    }
    
    public func setCodableItem<Element: Codable>(value: Element, forKey key: String) {
        let data = try? JSONEncoder().encode(value)
        VCSUserDefaults.default.setValue(data, forKey: key)
        VCSUserDefaults.default.synchronize()
    }
    
    public func getCodableItem<Element: Codable>(forKey key: String) -> Element? {
        guard let data = VCSUserDefaults.default.data(forKey: key) else { return nil }
        let element = try? JSONDecoder().decode(Element.self, from: data)
        return element
    }
}

@propertyWrapper
public struct VCSUserDefault<T> {
    let key: String
    let defaultValue: T
    
    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get { return VCSUserDefaults.default.object(forKey: key) as? T ?? defaultValue }
        set { VCSUserDefaults.default.set(newValue, forKey: key) }
    }
}
