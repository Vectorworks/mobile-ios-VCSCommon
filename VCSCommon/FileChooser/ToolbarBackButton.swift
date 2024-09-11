//
//  File.swift
//
//
//  Created by Veneta Todorova on 29.07.24.
//

import Foundation
import SwiftUI

struct ToolbarBackButton: View {
    @State var label: String
    @State var viewWidth: CGFloat
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
                .truncationMode(.middle)
                .frame(maxWidth: viewWidth, alignment: .leading)
                .foregroundColor(.VCSTeal)
            }
        )
    }
}
