//
//  SideBarUtil.swift
//  WebToNative
//
//  Created by yash saini on 18/12/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//
import Foundation
import SwiftUI
import WebToNativeCore

/// Calculate sidebar sheet width
/// - Parameter geometry: use for calcuate sidebar width
/// - Returns: sheet width
public func sideBarSheetWidth(geometry: GeometryProxy) -> CGFloat{
    let isLandscapeMode = geometry.size.width > geometry.size.height
    let screenWidth = geometry.size.width
    let isIpad = isIPad()
    
    if isIpad {
        return 350.0
    }
    else if isLandscapeMode {
        return screenWidth * 0.5
    }
    else {
        return screenWidth * 0.8
    }
}

/// Check bottom safe area available or not and return safe area size according visibility
/// - Returns: Safe area size
public func sideBarBottomSafeAreaPadding() -> CGFloat{
    let isIpad = isIPad()
    let bottomSafeAreaSize = UIApplication.shared.windows.first { $0.isKeyWindow }?.safeAreaInsets.bottom ?? 0
 
    let bottomSafeAreaEnable = WebToNativeConfig.sharedConfig?.safeArea == true && WebToNativeConfig.sharedConfig?.enableFullScreen != true
    
    
    if !isIpad {
        if !bottomSafeAreaEnable { return 0 }
        else { return bottomSafeAreaSize }
    }
    
    return bottomSafeAreaSize
}


public func sideBarHeader(sideBarData: SIDEBAR_NAVIGATION?) -> SideBarNavigationTab?{
    return sideBarData?.data?.tabs?[0]
}
