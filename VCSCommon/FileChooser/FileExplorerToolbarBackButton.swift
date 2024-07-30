//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct FileExplorerToolbarBackButton: View {
    @State var label: String
    var onPress: () -> Void
    var onLongPress: () -> Void
    
    @State private var isLongPressing = false
    
    var body: some View {
        Button(action: {
            if !isLongPressing {
                onPress()
            }
            isLongPressing = false
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text(label)
            }
            .padding()
            .foregroundColor(.VCSTeal)
        }
        .simultaneousGesture(LongPressGesture(minimumDuration: 1).onEnded { _ in
            isLongPressing = true
            onLongPress()
        })
    }
}
