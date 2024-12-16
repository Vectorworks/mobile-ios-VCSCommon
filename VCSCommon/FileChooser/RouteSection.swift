//
//  Section.swift
//  mobile-ios-VCSCommon
//
//  Created by Veneta Todorova on 6.12.24.
//

struct RouteSection : Identifiable {
    var route: FileChooserRouteData
    var index: Int
    var models: [FileChooserModel] = []
    var fileTypeStates: [String: FileTypePaginationState]
    var isInitialDataLoaded: Bool = false
    
    var isLoading: Bool = false
    
    var shouldRefresh: Bool = false
    
    var id: Int { index }
}
