//
//  WebViewUtil.swift
//  WebToNative
//
//  Created by Akash Kamati on 22/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import WebKit
import WebToNativeCore

/**
 Creates and configures a WKWebView instance with specified JavaScript overrides, user scripts, and configurations for WebView interactions.
 
 - Parameters:
    - javascriptOverride: The JavaScript override configuration for custom behaviors in WebView.
    - viewController: The UIViewController where the WebView will be presented.
    - coordinator: The WebViewCoordinator object responsible for handling WebView events and interactions.
    - url: Optional URL string to load initially in the WebView. If nil, the launch URL from WebToNativeConfig will be used.
 - Returns: An initialized WKWebView instance configured for use within the application.
 */
func createWebView(
    javascriptOverride:JavascriptOverride,
    viewController:UIViewController,
    coordinator:WebViewCoordinator,
    url:String? = nil
)->WKWebView{
    let appConfig = WebToNativeConfig.sharedConfig
    let preferences = WKPreferences();
    preferences.javaScriptEnabled = true
    preferences.javaScriptCanOpenWindowsAutomatically = true
    let webConfiguration = WKWebViewConfiguration()
    let userContentController = WKUserContentController()
    // adding appbounds makes service worker accessible from wkwebview
    if #available(iOS 14.0, *) {
        webConfiguration.limitsNavigationsToAppBoundDomains = appConfig?.limitNavigationToAppBounds ?? true
    }
    let customUserScript = """
           function retryPageLoad(){
               window.webkit.messageHandlers.webToNativeInterface.postMessage({action:'retryLoadWebsite'})
           }
       """
    let userScript = WKUserScript(source: customUserScript,
                                  injectionTime: .atDocumentEnd,
                                  forMainFrameOnly: true)
    userContentController.addUserScript(userScript)
    if !WebToNativeCore.isLivePreviewVisible{
        let globalCssString = appConfig?.globalCssString ?? ""
        if(!globalCssString.isEmpty){
            
            let source = """
                 var style = document.createElement('style');
                 style.innerHTML = `\(globalCssString)`;
                 document.head.appendChild(style);
               """;
            let userScript = WKUserScript(source: source,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: true)
            userContentController.addUserScript(userScript)
        }
    
        let globalJsString = appConfig?.globalJsString ?? ""
        if(!globalJsString.isEmpty){
            let userScript = WKUserScript(source: globalJsString,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: true)
            userContentController.addUserScript(userScript)
        } 
    }
    
    let navigationScript = WKUserScript(source: javascriptOverride.getJavaScripToEvaluate(),
                                        injectionTime: .atDocumentEnd,
                                        forMainFrameOnly: true)
    userContentController.addUserScript(navigationScript)
    webConfiguration.userContentController = userContentController
    webConfiguration.allowsInlineMediaPlayback = true
    
    if let disableCaching = appConfig?.disableCaching, disableCaching == true {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        // Set the cache policy for the URLCache
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
    }
    
    let webView = WebToNativeCore.getWebView(viewController: viewController, configuration: webConfiguration)
    
    if WebToNativeCore.defaultUserAgent == nil {
        WebToNativeCore.webView.evaluateJavaScript("navigator.userAgent") { [weak webView = WebToNativeCore.webView] (result, error) in
            if let webView = webView, let userAgent = result as? String {
                WebToNativeCore.defaultUserAgent = userAgent
            }
        }
    }
    
    setUserAgent(
        defaultUserAgent: WebToNativeCore.defaultUserAgent
    )
    
    javascriptOverride.setWebView(webView: webView);
    webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    

    let contentController = webView.configuration.userContentController
//    if WebToNativeCore.isLivePreviewVisible {
        contentController.removeScriptMessageHandler(forName: "webToNativeInterface")
//    }
    contentController.add(coordinator, name: "webToNativeInterface")
    
    
    webView.navigationDelegate = coordinator
    webView.uiDelegate = coordinator
    
    webView.configuration.preferences = preferences
    webView.allowsLinkPreview = !(appConfig?.disableLinkPreview ?? false)
    
    webView.scrollView.addObserver(coordinator, forKeyPath: "contentOffset", options: .new, context: nil)
    webView.addObserver(coordinator, forKeyPath: "estimatedProgress", options: .new, context: nil)
    webView.addObserver(coordinator, forKeyPath: "URL", options: .new, context: nil)
    WebToNativeCore.objserverAvailable = true
    
    
    // Add Pull to Refresh
    if(appConfig?.pullToRefresh == true) && WebToNativeCore.isLivePreviewVisible != true {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(coordinator, action: #selector(coordinator.refreshWebView(_:)), for: .valueChanged)
        refreshControl.tintColor = .darkGray
        webView.scrollView.addSubview(refreshControl)
        webView.scrollView.bounces = true
        refreshControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            refreshControl.centerXAnchor.constraint(equalTo: webView.scrollView.centerXAnchor),
            refreshControl.topAnchor.constraint(equalTo: webView.scrollView.topAnchor,constant: -40)
        ])
    }
    else {
        if appConfig?.disableWebViewOverScrolling == true {
            webView.scrollView.bounces = false
        }
    }
    
    if url != nil && url?.isEmpty == false{
        webView.loadUrl(url: url!)
    }else{
        webView.loadUrl(url: WebToNativeConfig.sharedConfig!.websiteLink.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    webView.allowsBackForwardNavigationGestures = true
    
//     if #available(iOS 16.4, *) {
//         webView.isInspectable = true
//     }
    
    return webView
    
}

func setUserAgent(
    defaultUserAgent : String?
){
    let customUserAgent = WebToNativeConfig.sharedConfig?.customUserAgent

    if(customUserAgent?.type == .custom){
        if(customUserAgent?.value != nil){
            if(!(customUserAgent?.value!.isEmpty ?? true)){
                WebToNativeCore.webView.customUserAgent = (customUserAgent?.value ?? "")
            } else {
                WebToNativeCore.webView.evaluateJavaScript("navigator.userAgent") { [weak webView = WebToNativeCore.webView] (result, error) in
                    if let webView = WebToNativeCore.webView, let userAgent = result as? String {
                        WebToNativeCore.webView.customUserAgent = userAgent + " w2n/iOS"
                    }
                }
            }
        }
    }else{
        var appendStr = customUserAgent != nil && customUserAgent?.value != "" ? customUserAgent?.value ?? "" : " w2n/iOS";
        if(appendStr.isEmpty == false){
            appendStr = " " + appendStr;
            WebToNativeCore.webView.evaluateJavaScript("navigator.userAgent") { [weak webView = WebToNativeCore.webView] (result, error) in
                if let webView = webView, let userAgent = result as? String {
                    if defaultUserAgent != nil {
                        webView.customUserAgent = defaultUserAgent! + appendStr
                    } else {
                        webView.customUserAgent = userAgent + appendStr
                    }

                }
            }
        }
    }
}

extension WKWebView{
    /**
     Loads a given URL string in the WKWebView instance.
     
     - Parameter url: The URL string to load in the WKWebView.
     */
    func loadUrl(url:String?){
        if url == nil || url?.isEmpty == true {return}
        if url!.starts(with: "w2n://") {
            W2NSchemeHandler.shared.handleW2NScheme(url: url!)
        }
        else if let URL = URL(string: url!) {
            let urlRequest = appendCustomHeader(urlRequest: URLRequest(url: URL))
            load(urlRequest)
        }
    }
}
