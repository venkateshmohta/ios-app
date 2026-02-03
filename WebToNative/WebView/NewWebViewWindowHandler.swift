//
//  NewWebViewWindow.swift
//  WebToNative
//
//  Created by Akash Kamati on 21/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import WebKit
import UIKit
import WebToNativeIcons
import WebToNativeCore
import SafariServices

/**
 Handles the creation and management of a popup WKWebView window within a view controller.
 
 This class manages the lifecycle of a popup WKWebView window, including toolbar creation for navigation controls and methods for handling user interactions.
 */
class NewWebViewWindowHandler{
    
    /// The view controller instance where the popup WKWebView will be displayed.
    let viewController = WebToNativeCore.viewController
    /// The popup WKWebView instance.
    var popupWebView: WKWebView?
    /// The toolbar instance for controlling navigation within the popup WKWebView.
    var popupWebviewToolbar: UIToolbar?
    

    
    // MARK: - Toolbar Delegates
    
    /// Handles the action when the back button on the toolbar is pressed.
    @objc func onBackButtonPressed(button: UIBarButtonItem) {
        if (self.popupWebView!.canGoBack) { //allow the user to go back to the previous page.
            self.popupWebView!.goBack()
        }
    }
    /// Handles the action when the forward button on the toolbar is pressed.
    @objc func onForwardButtonPressed(button: UIBarButtonItem) {
        if (self.popupWebView!.canGoForward) { //allow the user to go back to the previous page.
            self.popupWebView!.goForward()
        }
    }
    
    /// Handles the action when the close button on the toolbar is pressed.
    @objc func closePopupWebview(button: UIBarButtonItem) {
        closeWebViewWindow(self.popupWebView!)
    }
    
    /// Generates a UIBarButtonItem with an icon and action selector.
    ///
    /// - Parameters:
    ///   - icon: The icon identifier string for the UIBarButtonItem.
    ///   - action: The selector method to be invoked on button tap.
    /// - Returns: A UIBarButtonItem configured with the provided icon and action.
    func getUIBarButton(icon:String,action:Selector) -> UIBarButtonItem{
        let customButton : UIButton = UIButton(type : .custom)
        
        customButton.setImage(WebToNativeIcons.imageForIconIdentifier(icon, size: 32, color: UIColor.black), for: UIControl.State.normal)
        customButton.titleLabel?.numberOfLines = 0; // Dynamic number of lines
        customButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;
        customButton.titleLabel?.textAlignment = NSTextAlignment.center;
        customButton.imageView?.contentMode = .scaleAspectFit
        customButton.translatesAutoresizingMaskIntoConstraints = false
        customButton.sizeToFit()
        customButton.addTarget(self, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: customButton as UIView)
    }
    
    /// Appends a toolbar with navigation controls to the view controller's view.
    func appendPopupWebViewToolbar(){
        self.popupWebviewToolbar = UIToolbar()
        var items:[UIBarButtonItem] = []
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        flexibleSpace.width = 0
        items.append(flexibleSpace)
        items.append(getUIBarButton(icon: "fas fa-arrow-left",action: #selector(onBackButtonPressed)))
        items.append(flexibleSpace)
        items.append(getUIBarButton(icon: "fas fa-arrow-right",action: #selector(onForwardButtonPressed)))
        items.append(flexibleSpace)
        items.append(getUIBarButton(icon: "fas fa-times",action: #selector(closePopupWebview)))
        items.append(flexibleSpace)
        
        self.popupWebviewToolbar!.items = items
        viewController?.view.addSubview(self.popupWebviewToolbar!)
    }
    
 
    
    /// Creates a new popup WKWebView window.
    ///
    /// - Parameters:
    ///   - webView: The WKWebView instance to be displayed in the popup window.
    ///   - configuration: The WKWebViewConfiguration to apply to the popup WKWebView.
    ///   - navigationAction: The WKNavigationAction that triggered the creation of the popup window.
    ///   - windowFeatures: The WKWindowFeatures describing the features of the popup window.
    /// - Returns: The WKWebView instance representing the newly created popup window.
    func createWebViewWindow(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let view = (viewController?.view)!
        let linkType = ExternalInternalUrlHandler.shared.getLinkHandleType(request: navigationAction.request, isMainFrame: true, isUserAction: true, hideWebview: false)
        print("createWebView", linkType)
        
        if (linkType == LinkHandleType.w2nExternal){
            if let url = navigationAction.request.url{
                WebToNativeCore.webView.load(URLRequest(url: url))
            }
            return nil
        }
        else if (linkType == LinkHandleType.w2nCustom || linkType == LinkHandleType.w2nInApp) {
            if let url = navigationAction.request.url{
                let vc = SFSafariViewController(url: url)
                viewController?.present(vc, animated: true)
            }
            return nil
        }
        
        if (linkType != LinkHandleType.w2nInternal) {
            return nil;
        }
        
        
        WebToNativeCore.popWebView = WKWebView(frame: view.bounds, configuration: configuration)
        popupWebView = WebToNativeCore.popWebView
        popupWebView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        popupWebView!.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_7_2 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.3 Mobile/15E148 Safari/604.1"
        view.addSubview(popupWebView!)
        appendPopupWebViewToolbar()
        
        
        popupWebView?.translatesAutoresizingMaskIntoConstraints = false
        self.popupWebviewToolbar!.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            self.popupWebviewToolbar!.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            self.popupWebviewToolbar!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.popupWebviewToolbar!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.popupWebviewToolbar!.heightAnchor.constraint(equalToConstant: 50),
            self.popupWebView!.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 50),
            self.popupWebView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.popupWebView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.popupWebView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        return popupWebView!
    }
    /// Closes the popup WKWebView window.
    ///
    /// - Parameter webView: The WKWebView instance representing the popup window to be closed.
    func closeWebViewWindow(_ webView: WKWebView) {
        webView.removeFromSuperview()
        popupWebView = nil
        WebToNativeCore.popWebView = nil
        self.popupWebviewToolbar?.removeFromSuperview()
        popupWebviewToolbar = nil
    }
    /* to open new browser window */
    
}
