//
//  ViewState.swift
//  mobile-ios-VCSCommon
//
//  Created by Veneta Todorova on 29.10.24.
//

enum FileChooserViewState: Equatable {
    case loading
    case error(String)
    case loaded
}
