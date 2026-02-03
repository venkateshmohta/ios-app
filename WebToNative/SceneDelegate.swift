//
//  SceneDelegate.swift
//  WebToNative
//
//  Created by Ravi Saharan on 16/06/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import Foundation
import UIKit
import WebToNativeCore

/**
 Manages the scene-specific behavior and actions for the app's windows.
 */
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private var hasLaunched = false

    /**
       Performs the specified action for the shortcut item associated with the window scene.
       
       - Parameter windowScene: The window scene where the shortcut item is triggered.
       - Parameter shortcutItem: The shortcut item representing the action to be performed.
       - Parameter completionHandler: The closure to call upon completion of handling the shortcut item.
       */
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let _ = handleShortCutItem(shortcutItem)
    }
    
    /// Called when a scene (UI window/session) is being created or restored,
    /// and allows handling of any incoming user activity (e.g., from a Universal Link or Siri Shortcut).
    ///
    /// This implementation checks for a `NSUserActivity` containing a `webpageURL`,
    /// and if present, notifies the native layer via `WebToNativeCore.notifyOpenUrl(...)`.
    ///
    /// - Parameters:
    ///   - scene: The `UIScene` being connected — represents one UI window/session.
    ///   - session: The `UISceneSession` associated with the scene.
    ///   - connectionOptions: Contains launch metadata, including any `NSUserActivity` or URL contexts
    ///     passed when the app was launched or resumed.	
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        if let userActivity = connectionOptions.userActivities.first,
           let url = userActivity.webpageURL {
            WebToNativeCore.notifyOpenUrl(openUrl: url.absoluteString)
        }
    }
    
    ///  Handles continuation of user activity, typically triggered by Siri or universal links
    /// - Parameters:
    ///   - scene: The scene associated with the user activity.
    ///   - userActivity: The user activity containing relevant information, such as a URL.
    func scene(_ scene: UIScene,continue userActivity: NSUserActivity){
        ///Action will be triggered only if siri Add-on is enabled
        if WebToNativeConfig.sharedConfig!.SIRI_SUPPORT?.data?.enable == true {
            if let url = userActivity.webpageURL {
                WebToNativeCore.notifyOpenUrl(openUrl: url.absoluteString)
            }
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if WebToNativeConfig.sharedConfig?.PASSCODE?.data != nil {
            let futureTime = WebToNativeConfig.runtimeTokens.onBackgroundPasscode ?? "EMPTY"
            NotificationCenter.default
                .post(name: .passcodeAfterInterval, object: nil)
        }
        ///calls the JS function wtnAppResumeCallback when app becomes active again
        if WebToNativeConfig.sharedConfig?.addCallbackOnAppResume ?? false && hasLaunched {
            let jsFunction = "appResumeCallback()"
            WebToNativeCore.webView.evaluateJavaScript(jsFunction){ (result, error) in
                if let error = error {
                    print("Error calling JavaScript function: \(error.localizedDescription)")
                } else {
                    print("JavaScript function called successfully, result: \(String(describing: result))")
                }
            }
        }
        else {
            hasLaunched = true
        }
    }

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        let appConfig = WebToNativeConfig.sharedConfig
        if(appConfig?.customUrlScheme?.isEmpty == false){
            let urlString = URLContexts.first?.url.absoluteString
            if let urlString = urlString{
                if let range = urlString.range(
                    of:(appConfig?.customUrlScheme ?? "") + "."
                ) {
                    let replaced = urlString.replacingCharacters(
                        in: range,
                        with:""
                    );
                    WebToNativeCore.notifyOpenUrl(openUrl: replaced)
                }
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if WebToNativeConfig.sharedConfig?.PASSCODE?.data != nil {
            let futureTime = getFutureDate(
                intervalMinutes: WebToNativeConfig.sharedConfig?.PASSCODE?.data?.autoLockAfter ?? 0
            )
            WebToNativeConfig.runtimeTokens.onBackgroundPasscode = futureTime
        }
    }
}
