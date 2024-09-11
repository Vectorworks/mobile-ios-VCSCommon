//
//  File.swift
//  
//
//  Created by Veneta Todorova on 23.07.24.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    @State var error: String
    var onDismiss: (() -> Void)
    
    var body: some View {
        VStack {
            Label(title: {
                Text(error)
            }, icon: {
                Image(systemName: "exclamationmark.triangle")
            })
            Button {
                onDismiss()
            } label: {
                Text("Close".vcsLocalized)
            }
        }
    }
    
}
