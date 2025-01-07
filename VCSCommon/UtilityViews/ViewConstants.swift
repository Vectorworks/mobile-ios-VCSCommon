//
//  K.swift
//  mobile-ios-VCSCommon
//
//  Created by Veneta Todorova on 3.01.25.
//

import UIKit
import SwiftUI


public struct ViewConstants {
    
    public struct Colors {
        static public func buttonBackground(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? Color.black.opacity(0.05) : Color.white.opacity(0.1)
        }
        
        static public func buttonTextColor(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light ? Color.black : Color.white
        }
    }
    
    public struct Sizes {
        static public var gridMinCellSize: CGFloat  {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                200
            } else {
                150
            }
        }
        
        static public var gridMaxCellSize: CGFloat {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                220
            } else {
                170
            }
        }
        
        static public var gridMinCellWidth: CGFloat  {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                170
            } else {
                120
            }
        }
        
        static public var gridMaxCellWidth: CGFloat  {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                220
            } else {
                150
            }
        }
        
        static public var gridCellImagePadding: CGFloat {
            10
        }
        
        static public var gridCellMaxImageSize: CGFloat {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                170
            } else {
                130
            }
        }
        
        static public var gridCellMinImageSize: CGFloat {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                150
            } else {
                100
            }
        }
        
        static public var gridCellImageBackgroundSize: CGFloat {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                200
            } else {
                160
            }
        }
        
        static public var gridCellImageSize: CGFloat {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                170
            } else {
                130
            }
        }
        
        static public let gridBadgeSize: CGFloat = 20
        
        static public let gridBadgeFrameSize: CGFloat = 30
        
        static public let gridTextFrameSize: CGFloat = 50
    }
}
