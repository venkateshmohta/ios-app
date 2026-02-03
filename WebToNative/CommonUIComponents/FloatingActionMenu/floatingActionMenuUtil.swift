//
//  floatingActionMenuUtil.swift
//  WebToNative
//
//  Created by yash saini on 19/08/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import WebToNativeCore

func getFloatingActionMenuData(url: String) -> FloatingActionMenuData?{
    let menuData = WebToNativeConfig.sharedConfig?.FLOATING_ACTION_MENU?.data
    if menuData == nil { return nil}
    
    var result: FloatingActionMenuData? = nil
    
    for data in menuData ?? [] {
        if let regex = try? NSRegularExpression(pattern: data?.regex ?? ""){
            if let _ = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) {
                //match found continue..
                result = data
                break
            }
        }
    }
    
    return result
    
}
