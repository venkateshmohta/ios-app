//
//  LivePreviewUtil.swift
//  WebToNative
//
//  Created by yash saini on 25/11/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//
import WebToNativeCore

/**
    Change the Configuration data and the webview
 */
func changeConfigurationAndWebview(isLivePreview: Bool){
    WebToNativeConfig.sharedConfig = nil
    if isLivePreview && WebToNativeCore.isLivePreviewVisible == false{
        if WebToNativeCore.storeAppWebView == nil {
            WebToNativeCore.storeAppWebView = WebToNativeCore.webView
        }
        WebToNativeCore.webView = WebToNativeCore.storePreviewWebView
        WebToNativeConfig.sharedConfig = WebToNativeConfig.previewSharedConfig
        WebToNativeCore.isLivePreviewVisible = true
    }
    else if WebToNativeCore.isLivePreviewVisible == true{
        if WebToNativeCore.storePreviewWebView == nil {
            WebToNativeCore.storePreviewWebView = WebToNativeCore.webView
        }
        WebToNativeCore.isLivePreviewVisible = false
        WebToNativeCore.webView = WebToNativeCore.storeAppWebView
        WebToNativeConfig.sharedConfig = WebToNativeConfig.appSharedConfig
    }

}


private func initializeLivePreview(requestId: String?, previewId: String?, userId: String?) {
    if let requestId = requestId, let previewId = previewId, let userId = userId {
        WebToNativeCore.webView.evaluateJavaScript("""
       window.webkit.messageHandlers.webToNativeInterface.postMessage({
       "action": "initializeLivePreviewData",
       "requestId": "\(requestId)",
       "previewId": "\(previewId)",
       "userId": "\(userId)"
       });
"""
        )
    }
}



func fetchLivePreviewInitialData(url: String) {
    let queryParams = fetchQueryParamsFromUrl(url: url)
    initializeLivePreview(requestId: queryParams["requestId"], previewId: queryParams["previewId"], userId: queryParams["userId"])
}
