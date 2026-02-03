//
//  WebViewNavigationHandler.swift
//  WebToNative
//
//  Created by Akash Kamati on 21/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import WebKit
import WebToNativeCore
import SafariServices

/**
 Handles navigation actions in a WKWebView, deciding whether to allow or cancel navigation based on various conditions.

 This class provides a static method to handle navigation actions (`decidePolicyFor navigationAction:`) in a WKWebView. It examines the URL of the navigation request and makes decisions based on predefined rules and configurations. Actions include handling special schemes, file downloads, calendar events, blob URLs, and more. It also manages opening URLs in the default browser, custom tabs, or within the app based on the defined logic.

 - Note: This class interacts with other modules like `W2NSchemeHandler`, `DocumentManager`, `BlobUrlFileDownloadUtil`, `ExternalInternalUrlHandler`, and `WebToNativeConfig` to determine navigation policies and execute appropriate actions.

 */
class WebViewNavigationHandler{
    
    /// Handles the navigation policy for a WKWebView.
    ///
    /// - Parameters:
    ///   - webView: The WKWebView instance where the navigation action is triggered.
    ///   - navigationAction: Information about the navigation action.
    ///   - decisionHandler: A closure to call with the navigation action policy (allow or cancel).
    public static func webView(_ webView: WKWebView,
                                decidePolicyFor navigationAction: WKNavigationAction,
                                decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ){
        var urlRequest = navigationAction.request
        let url = urlRequest.url
        let urlString = url!.absoluteString
        let viewController = WebToNativeCore.viewController
        let appConfig = WebToNativeConfig.sharedConfig
        let socialLogin = appConfig?.SOCIAL_LOGIN?.data?.enable ?? false
        var redirectUrl: String? = nil
        var state: String? = nil

        if urlString.starts(with: "https://accounts.google.com/o/oauth2/") && socialLogin == true {
            // Handling Google Sign In Flow With Addon
            let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
            let queryItem = components?.queryItems
            redirectUrl = queryItem?.first(where: {$0.name == "redirect_uri"})?.value ?? nil
            state = queryItem?.first(where: {$0.name == "state"})?.value ?? nil
        }

        if urlString.starts(with: "https://accounts.google.com/o/oauth2/") && socialLogin == true && redirectUrl != nil && state != nil {
            decisionHandler(.cancel)
            WebToNativeConfig.googleAuth =  WebToNativeConfig.googleAuth.copy(redirectUri:redirectUrl!.removingPercentEncoding!,state:state!.removingPercentEncoding!)

            googleLoginWithoutFun(webView: webView)
        } else {
            
            /// handle w2n scheme
            if(urlString.starts(with: "w2n://")){
                W2NSchemeHandler.shared.handleW2NScheme(url: urlString)
                decisionHandler(.cancel)
                return;
            }
            
            if(urlString.range(of:"wtn-download-file=true") != nil) {
                let enableDownloadFileManager = appConfig?.DOWNLOAD_MANAGER?.data?.enable ?? false
                if enableDownloadFileManager {
                    DownloadFileManager().startDownload(from: urlString, controller: viewController)
                }
                else {
                    DocumentManager().downloadFile(fileUrl: urlString)
                }
                decisionHandler(.cancel)
                return;
            }
            
            if urlString.contains("data:text/calendar") ||  urlString.contains(".ics") {
                WebToNativeCore.notifyWebviewNavigation(url: urlString)
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
            
            if urlString.starts(with:"blob") && urlString.contains("filename") {
                let jsString = BlobUrlFileDownloadUtil.shared.getBase64StringFromBlobUrl(blobUrl:urlString)
                
                webView.evaluateJavaScript(jsString)
                
                decisionHandler(.cancel)
                return;
            }
            
            if urlString.starts(with: "data:") && urlString.contains("filename") {
                BlobUrlFileDownloadUtil.shared.downloadDataUrlFile(from: urlString)
                decisionHandler(.cancel)
                return
            }
            
            if ((urlString.range(of:"open-url-in-browser") != nil ) || (urlString.range(of:"loadIn=defaultBrowser") != nil ) || (urlString.range(of:"tel:") != nil ) || (urlString.range(of:"mailto:") != nil ) || (urlString.range(of:"sms:") != nil )) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                }
                decisionHandler(.cancel)
                return;
            }
            
            if ((urlString.range(of:"open-url-in-custom-tab") != nil ) || (urlString.range(of:"loadIn=customTab") != nil ) ){
                let url = URL(string: urlString)
                let vc = SFSafariViewController(url: url!)
                viewController?.present(vc, animated: true)
                decisionHandler(.cancel)
                return;
            }
            
            if(appConfig?.customUrlScheme?.isEmpty == false && appConfig?.customUrlScheme != nil){
                if urlString.starts(with: appConfig!.customUrlScheme! + ".http"){
                    if let range = urlString.range(of:(appConfig?.customUrlScheme ?? "") + ".") {
                        let replaced = urlString.replacingCharacters(in: range, with:"");
                        decisionHandler(.cancel)
                        WebToNativeCore.notifyOpenUrl(openUrl: replaced)
                        return;
                    }
                }
                else if urlString.starts(with: appConfig!.customUrlScheme! + ":")  {
                    if let range = urlString.range(of:(appConfig?.customUrlScheme ?? "")) {
                        let replaced = urlString.replacingCharacters(in: range, with:"https");
                        decisionHandler(.cancel)
                        WebToNativeCore.notifyOpenUrl(openUrl: replaced)
                        return;
                    }
                }
            }
            
            let isUserAction = navigationAction.navigationType == WKNavigationType.linkActivated || navigationAction.navigationType == WKNavigationType.formSubmitted;
            let isMainFrame = navigationAction.targetFrame?.isMainFrame ?? false
            let linkType = ExternalInternalUrlHandler.shared.getLinkHandleType(request: navigationAction.request, isMainFrame: isMainFrame, isUserAction: isUserAction, hideWebview: true)
            let isIframe = !isMainFrame && urlString != navigationAction.request.mainDocumentURL?.absoluteString
            let loadInSameTab = !isIframe && appConfig?.openLinkInSameWebview ?? true && navigationAction.targetFrame == nil
            print("navigationAction", linkType)
            
            // append custom header in urlRequest
            urlRequest = appendCustomHeader(urlRequest: navigationAction.request, isMainFrame: navigationAction.targetFrame?.isMainFrame ?? false)
            
            if(linkType == LinkHandleType.w2nExternal){
                callFunctionInternally(action: "hideSpinnerLoader")
                UIApplication.shared.open(urlRequest.url!, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            }else if linkType == LinkHandleType.w2nInApp || linkType == LinkHandleType.w2nCustom{
                callFunctionInternally(action: "hideSpinnerLoader")
                let url = URL(string: urlString)
                let vc = SFSafariViewController(url: url!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                    viewController?.present(vc, animated: true)
                }
                decisionHandler(.cancel)
            }else if loadInSameTab || !isAllCustomHeaderAvailable(navigationAction: navigationAction) {
                webView.load(urlRequest)
                decisionHandler(.cancel)
            }else{
                decisionHandler(.allow)
            }
            injectCss()
            injectCookiesListener()
        }
    }



    /// Injects custom CSS into a specified `WKWebView` instance.
    ///
    /// This function takes a `WKWebView` and an optional configuration object, `WebToNativeConfigData`.
    /// If the `globalCssString` property of the configuration object is not empty, it creates a new
    /// `<style>` element containing the CSS and appends it to the document's `<head>`.
    /// The CSS will be injected at the end of the document loading process.
    ///
    /// - Parameters:
    ///   - webView: The `WKWebView` instance into which the CSS will be injected.
    ///   - appConfig: An optional `WebToNativeConfigData` object that may contain the CSS string to be injected.
    ///                 If `nil` or if `globalCssString` is empty, no CSS will be injected.
    ///
    /// - Note: This method adds a `WKUserScript` to the `userContentController` of the `WKWebView`'s configuration,
    ///         ensuring that the CSS is applied to the main frame only after the document has finished loading.
    private static func injectCss(){
        let globalCssString = WebToNativeConfig.sharedConfig?.globalCssString ?? ""
        if(!globalCssString.isEmpty && !WebToNativeCore.isLivePreviewVisible){
            let globalCssString = WebToNativeConfig.sharedConfig?.globalCssString ?? ""
            
            let source = """
             var style = document.createElement('style');
             style.innerHTML = `\(globalCssString)`;
             document.head.appendChild(style);
           """;
            let userScript = WKUserScript(source: source,
                                          injectionTime: .atDocumentEnd,
                                          forMainFrameOnly: true)
            WebToNativeCore.webView.configuration.userContentController.addUserScript(userScript)
        }
    }
}

func googleLoginWithoutFun(webView: WKWebView){
        webView.evaluateJavaScript("""
           window.webkit.messageHandlers.webToNativeInterface.postMessage({
                                       action:"googleSignIn"
                                   })
"""
        )
}


