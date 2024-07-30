//
//  File.swift
//  
//
//  Created by Veneta Todorova on 23.07.24.
//

import Foundation
import Combine

public class ViewsLayoutSetting: ObservableObject {
    public static let listDefault = ViewsLayoutSetting(layoutKey: "ViewsLayoutSetting-List-Layout", layoutDV: ListLayoutCriteria.list.rawValue)
    public static let homeDefault = ViewsLayoutSetting(layoutKey: "ViewsLayoutSetting-Home-Layout", layoutDV: ListLayoutCriteria.grid.rawValue)
    
    private let layoutDV: Int
    private let layoutKey: String
    
    public let objectWillChange = PassthroughSubject<Void, Never>()
    
    public init(layout: Int? = nil, layoutKey: String, layoutDV: Int) {
        self.layoutDV = layoutDV
        self.layoutKey = layoutKey
        
        if let layoutValue = layout {
            self.layout = layoutValue
        }
    }

    public var layout: Int {
        get { return VCSUserDefaults.default.object(forKey: layoutKey) as? Int ?? layoutDV }
        set {
            VCSUserDefaults.default.set(newValue, forKey: layoutKey)
            objectWillChange.send()
        }
    }
}

public enum ListLayoutCriteria: Int {
    case list
    case grid
    
    public var buttonName: String {
        switch self {
        case .list:
            return Localization.default.string(key: "List".vcsLocalized)
        case .grid:
            return Localization.default.string(key: "Grid".vcsLocalized)
        }
    }
    
    public var buttonImageName: String {
        switch self {
        case .list:
            return "list-view-icon"
        case .grid:
            return "grid"
        }
    }
}

extension Int {
    public var asListLayoutCriteria: ListLayoutCriteria { return ListLayoutCriteria(rawValue: self) ?? .list }
}
