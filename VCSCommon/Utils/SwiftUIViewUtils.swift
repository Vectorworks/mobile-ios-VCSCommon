//
//  File.swift
//  
//
//  Created by Veneta Todorova on 24.07.24.
//

import Foundation
import SwiftUI

extension Text {
    public func gridCellTextModifier() -> some View {
        self
            .font(.headline)
            .fontWeight(.regular)
            .lineLimit(1)
            .frame(height: K.Sizes.gridTextFrameSize)
            .truncationMode(.middle)
            .tint(Color.label)
    }
    
    public func listCellTextModifier() -> some View {
        self
            .font(.headline)
            .fontWeight(.regular)
            .lineLimit(1)
            .truncationMode(.middle)
            .tint(Color.label)
    }
}
