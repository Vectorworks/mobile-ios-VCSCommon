//
//  File.swift
//  
//
//  Created by Veneta Todorova on 18.07.24.
//

import Foundation

public protocol FileTypeFilter {
    var extensions: [VCSFileType] { get }
    var iconStr: String { get }
    var titleStr: String { get }
}
