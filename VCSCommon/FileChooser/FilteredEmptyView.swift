//
//  FilteredEmptyView.swift
//  mobile-ios-VCSCommon
//
//  Created by Veneta Todorova on 4.11.24.
//
import SwiftUI

struct FilteredEmptyView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "folder")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
            Text("No files found".vcsLocalized)
                .font(.headline)
                .foregroundColor(.primary)
            Text("You don’t have any files of this type.".vcsLocalized)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}
