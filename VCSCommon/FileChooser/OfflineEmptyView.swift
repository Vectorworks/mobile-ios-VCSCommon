//
//  OfflineEmptyView.swift
//  mobile-ios-VCSCommon
//
//  Created by Veneta Todorova on 4.11.24.
//
import SwiftUI

struct OfflineEmptyView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "icloud.and.arrow.down")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
            Text("No files available offline".vcsLocalized)
                .font(.headline)
                .foregroundColor(.primary)
            Text("Download some files to access them offline.".vcsLocalized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}
