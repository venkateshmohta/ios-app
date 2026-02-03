//
//  ScreenManager.swift
//  WebToNativeLivePreview
//
//  Created by yash saini on 13/10/25.
//
import WebToNativeCore

// Manage Live Preview Screen & App Screen
class ScreenManager {
    func navigateToScreen(name: String, isReloadRequired: Bool = false, closedCurrentScreen: Bool = false) {
        DispatchQueue.main.async {
            NotificationCenter.default
                .post(
                    name: .switchScreenView,
                    object: nil,
                    userInfo: ["screen":name, "reload":isReloadRequired, "closedCurrentScreen": closedCurrentScreen]
                )
        }
        
    }
    
    func navigatorLoaderChange(animationUrl : String,closedCurrentScreen: Bool = false) {
        DispatchQueue.main.async {
            NotificationCenter.default
                .post(
                    name: .updateLoadingIndicator,
                    object: nil,
                    userInfo: [
                        "animationUrl":animationUrl,
                        "closedCurrentScreen": closedCurrentScreen
                    ]
                )
        }
        
    }

    func webToNativeApp(restartLivePreview: Bool = false){
        if WebToNativeCore.isLivePreviewVisible {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default
                    .post(
                        name: .webToNativeApp,
                        object: nil,
                        userInfo: [
                            "restartLivePreview": restartLivePreview
                        ]
                    )
            }
        }
    }
    

    // Refresh Current Screen and component in Live Preview screen
    func refreshLivePreview(){
        if WebToNativeCore.isLivePreviewVisible {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(name: .mainScreenPreviewHandler, object: nil,userInfo: ["refresh": true])
            }
        }
    }
    
    func showLivePreviewScreen(){
        DispatchQueue.main.async {
            WebToNativeCore.webView.evaluateJavaScript("""
       window.webkit.messageHandlers.webToNativeInterface.postMessage({
                                   action: "showLivePreviewScreen"
                               })
"""
            )
        }
    }
}
