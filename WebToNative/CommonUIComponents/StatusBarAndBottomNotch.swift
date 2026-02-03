//
//  StatusBarAndBottomNotch.swift
//  WebToNative
//
//  Created by Akash Kamati on 22/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore

/**
 SwiftUI view representing a customizable status bar and bottom notch bar.

 This view dynamically adjusts based on specified visibility and colors for the status bar and bottom notch bar.

 - Parameters:
   - showStatusBar: A boolean indicating whether to show the status bar.
   - showBottomNotchBar: A boolean indicating whether to show the bottom notch bar.
   - statusBarColor: The color of the status bar. This is a binding to allow dynamic updates.
   - bottomNotchColor: The color of the bottom notch bar. Default is configured from `WebToNativeConfig`'s safe area color.

 - Note: This view uses `GeometryReader` to adapt to different device sizes and safe areas. It adjusts the height of the status bar and bottom notch bar based on the device's actual safe area insets.

 - Important: Ensure proper configuration of `WebToNativeConfig` for consistent appearance across different devices and configurations.
 */

struct StatusBarAndBottomNotch: View {
    let showStatusBar:Bool
    let showBottomNotchBar:Bool
    let statusBarColor:String
    var bottomNotchColor:String = WebToNativeConfig.sharedConfig?.safeAreaColor ?? ""
    var bottomBarVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                if(showStatusBar && (geometry.safeAreaInsets.top > 0 || isStatusBarSupported())){
                    Color(UIColor(hex: statusBarColor))
                        .frame(height:geometry.safeAreaInsets.top)
                        .ignoresSafeArea(edges: .top)
                }
                Spacer()
                if showBottomNotchBar && (isBottomNotchSupported().hasBottomNotch)  {
                    Color(UIColor(hexString:bottomNotchColor))
                        .frame(height: bottomBarVisible ? 34 : (isBottomNotchSupported().inset))
                        .ignoresSafeArea(edges: .bottom)
                }
            }
        }
    }
}

