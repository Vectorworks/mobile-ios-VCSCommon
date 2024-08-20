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
    
    var body: some View {
        Button(
            action: {
                onPress()
            },
            label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text(label)
                }
                .foregroundColor(.VCSTeal)
            }
        )
    }
}
