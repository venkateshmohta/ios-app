//
//  WebViewCoordinator.swift
//  WebToNative
//
//  Created by Akash Kamati on 22/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import WebKit
import WebToNativeCore
import IntentsUI

/**
 Handles interactions and events between the native application and a WKWebView instance, including navigation, JavaScript interface calls, and UI events.
 */
class WebViewCoordinator: NSObject, WKNavigationDelegate, ObservableObject,WKUIDelegate, WKScriptMessageHandler {
    let webView: WKWebView
    // MARK: - Published Properties
    /// The current URL being displayed in the WKWebView.
    @Published var currentURL: URL?
    /// The current progress of page loading in the WKWebView.
    @Published var progress: Double = 0.0
    /// Data received from JavaScript interface events.
    @Published var jsEventData: JSInterfaceEventData = JSInterfaceEventData(data: [:])
    /// Type of JavaScript interface event currently handled.
    @Published var jsInterfaceEvent:JSInterfaceEvents? = nil
    // MARK: - Properties
    
    /// Flag indicating if a new window is open in the WKWebView.
    var isNewWindowOpen:Bool = false
    /// Handler for managing new web view windows.
    var webViewWindowHandler:NewWebViewWindowHandler!
    
    
    init(webView: WKWebView){
        self.webView = webView
    }
    
    /**
      Receives messages from JavaScript running in the WKWebView and handles them appropriately.
      
      - Parameter userContentController: The user content controller that received the message.
      - Parameter message: The message sent from JavaScript.
      */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "webToNativeInterface" {
            guard let data = message.body as? [String : AnyObject] else {
                return
            }
            guard let event = JSInterfaceEvents(rawValue: data["action"] as! String) else{
                WebToNativeCore.notifyJSInterfaceCall(data: data)
                return
            }
            
            if !isJSEventHandled(event: event, data: data){
                jsInterfaceEvent = event
                jsEventData = JSInterfaceEventData(data: data)
            }

        }
    }
    
    // MARK: - WKNavigationDelegate
     
     /**
      Called when a navigation action requests to open a new web view.
      
      - Returns: A new WKWebView instance if a new window should be opened, nil otherwise.
      */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        isNewWindowOpen = true
        webViewWindowHandler = NewWebViewWindowHandler()
        
        
        if let popupWebView = webViewWindowHandler.createWebViewWindow(webView, createWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures){
            popupWebView.navigationDelegate = self
            popupWebView.uiDelegate = self
            return popupWebView
        }else{
            if let url = navigationAction.request.url{
                UIApplication.shared.openURL(url)
            }
            return nil
        }
    }
    
    /**
     Called when the web view closes a previously opened web view window.
     */
    func webViewDidClose(_ webView: WKWebView) {
        isNewWindowOpen = false
        webViewWindowHandler?.closeWebViewWindow(webView)
    }
    
    /**
     Called when the web view closes a previously opened web view.
     */
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if !isNewWindowOpen{
            currentURL = webView.url
        }
    }
    
    /**
     Called when the web view begins to receive content for a navigation.
     */
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if !isNewWindowOpen{
            progress = webView.estimatedProgress
        }
    }
    
    // MARK: - Other WKUIDelegate Methods
      
    /**
     Called to refresh the WKWebView when a refresh control triggers the action.
     
     - Parameter sender: The UIRefreshControl instance triggering the refresh.
     */
    @objc func refreshWebView(_ sender: UIRefreshControl) {
        NotificationCenter.default.post(name: .onWebViewRefresh, object: nil)
        WebToNativeCore.webView.reload()
        sender.endRefreshing()
    }
    
    // Handle media capture permission requests
    @available(iOS 15.0, *)
    func webView(
          _ webView: WKWebView,
          requestMediaCapturePermissionFor origin: WKSecurityOrigin,
          initiatedByFrame frame: WKFrameInfo,
          type: WKMediaCaptureType,
          decisionHandler: @escaping (WKPermissionDecision) -> Void
      ) {
          manageAppPermission(type: type, decisionHandler: { value in
              decisionHandler(value)
          })
      }
    
    /**
     * Handles the display and operation of an authentication popup for a WebView.
     */
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            WebToNativeCore.httpAuthenticationComplete = false
            showLoginAlert(completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    /**
     Handles JavaScript alert panels triggered by web content in the WKWebView.
     */
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        WebViewAlertsHandler.webView(webView, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
    }
    
    /**
     Handles JavaScript confirm panels triggered by web content in the WKWebView.
     */
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        if  WebToNativeConfig.sharedConfig?.showCustomAlert?.enable == true {
//            webView.stopLoading()
            let alertController = UIAlertController(title: "Confirm", message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completionHandler(true)
            }))

            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                completionHandler(false)
            }))
            ///Whether to auto-dismiss alert or not based on regex matching
            if WebToNativeCore.autoDismiss{
                alertController.dismiss(animated: true){
                    completionHandler(true)
                }
            }
           
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rootViewController.present(alertController, animated: true, completion: nil)
            }
            
        }
        else {
            WebViewAlertsHandler.webView(webView, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
        }
    }
    
    /**
     Handles JavaScript text input panels triggered by web content in the WKWebView.
     */
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
       
        WebViewAlertsHandler.webView(webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText, initiatedByFrame: frame, completionHandler: completionHandler)
       
    }
    
    /**
       Decides whether to allow or cancel a navigation request from the WKWebView.
       */
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        WebViewNavigationHandler.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        
    }
    /// This function get calls when Webview is about to get destroyed due to reasons like Out of Memory Error etc.
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        webView.reload()
    }
    

    func isValidUrl(url:String) -> Bool{
            let regexPattern = #"^https:\/\/[^\s\/?#].[^\s]*$"#
            do {
                let regex = try NSRegularExpression(pattern: regexPattern)
                let range = NSRange(url.startIndex..., in: url)
                let matches = regex.matches(in: url, range: range)

                if !matches.isEmpty {
                    return true
                } else {
                    return false
                }
            } catch {
                return false
            }
        }
    // MARK: - KVO and Deinitialization
     
     /**
      Observes changes in properties of the WKWebView using Key-Value Observing (KVO).
      */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let webView = object as? WKWebView else { return }
        
        if keyPath == "estimatedProgress" {
            self.progress = webView.estimatedProgress
        } else if keyPath == "URL" {
            self.currentURL = webView.url
        }
    }
    
    /**
     Deinitializes the WebViewCoordinator instance, removing observers and handlers.
     */
    deinit {
        // change123  WebToNativeConfig.sharedConfig => appSharedConfig
        if WebToNativeConfig.appSharedConfig == nil && WebToNativeConfig.sharedConfig?.LIVE_PREVIEW?.data?.enable != true {
//          Clean up observers and handlers
            webView.removeObserver(self, forKeyPath: "contentOffset")
            webView.removeObserver(self, forKeyPath: "estimatedProgress")
            webView.removeObserver(self, forKeyPath: "URL")
            webView.configuration.userContentController.removeScriptMessageHandler(forName: "webToNativeInterface")
        }
    }
}
