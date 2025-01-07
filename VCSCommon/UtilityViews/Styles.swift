//
//  Styles.swift
//  mobile-ios-VCSCommon
//
//  Created by Veneta Todorova on 7.01.25.
//

import SwiftUI

struct FilesViewSlimRoundedCornerStyle: ViewModifier {
    let colorScheme: ColorScheme

    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(ViewConstants.Colors.buttonBackground(for: colorScheme))
            .cornerRadius(5)
    }
}

extension View {
    public func filesViewSlimRoundedCornerStyle(for colorScheme: ColorScheme) -> some View {
        self.modifier(FilesViewSlimRoundedCornerStyle(colorScheme: colorScheme))
    }
}

//public struct FilesViewSlimRoundedCornerStyle: ButtonStyle {
//    public func makeBody(configuration: Configuration) -> some View {
//        ButtonWithEnvironmentValues(configuration: configuration)
//    }
//    
//    struct ButtonWithEnvironmentValues: View {
//        let configuration: ButtonStyle.Configuration
//        @Environment(\.isEnabled) private var isEnabled: Bool
//        @Environment(\.colorScheme) var colorScheme
//        var body: some View {
//            configuration.label
//                .padding(.vertical, 8)
//                .padding(.horizontal, 12)
//                .background(ViewConstants.Colors.buttonBackground(for: colorScheme))
//                .cornerRadius(5)
//        }
//    }
//}
//extension ButtonStyle where Self == FilesViewSlimRoundedCornerStyle {
//    @MainActor public static var filesViewSlimRoundedCornerStyle: FilesViewSlimRoundedCornerStyle { FilesViewSlimRoundedCornerStyle() }
//}
