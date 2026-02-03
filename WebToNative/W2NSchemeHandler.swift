//
//  W2NSchemeHandler.swift
//  WebToNative
//
//  Created by Akash Kamati on 28/02/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import WebToNativeCore
import WebKit

/**
 A singleton class that handles custom URL schemes for the WebToNative app.

 This class listens for and processes custom URL schemes used within the application. It supports opening a notification screen and loading a widget based on the URL scheme.

 - Properties:
   - shared: A shared instance of `W2NSchemeHandler`.
   - showNotificationScreen: A published property that indicates whether to show the notification screen.
   - notificationScreenConfig: A configuration object for the notification screen.

 - Methods:
   - handleW2NScheme(url: String): Processes the custom URL scheme and takes appropriate action based on the scheme.
 */
class W2NSchemeHandler : ObservableObject{
    /// A shared instance of `W2NSchemeHandler`.
    public static let shared = W2NSchemeHandler()
    /// A published property that indicates whether to show the notification screen.
    @Published var showNotificationScreen:Bool = false
    @Published var showDownloadScreen:Bool = false
    @Published var isSideBarVisible:Bool = false
    
    private let appConfig = WebToNativeConfig.sharedConfig

    /// A configuration object for the notification screen.
    var notificationScreenConfig:NotificationScreenConfig = NotificationScreenConfig(titleBarBgColor: "#FFFFFF", titleBarContentColor: "#000000", title: "Notifications")
      
    /**
       Processes the custom URL scheme and takes appropriate action based on the scheme.
       
       - Parameter url: The custom URL scheme to process.
       
       If the URL starts with "w2n://notification-screen", it parses the query parameters and updates the notification screen configuration. If the URL starts with "w2n://orufy-connect", it loads a widget.
       */
    func handleW2NScheme(url:String){
        if(url.starts(with:"w2n://notification-screen")){
            let queryParams = fetchQueryParamsFromUrl(url: url)
            notificationScreenConfig = getNotificationConfigFromParams(params: queryParams)
            showNotificationScreen = true
        }else if (url.starts(with:"w2n://orufy-connect")){
            ConnectWidget.loadWidget(webView: WebToNativeCore.webView)
        }
        else if (url.starts(with:"w2n://download-screen") && WebToNativeConfig.sharedConfig?.DOWNLOAD_MANAGER?.data?.enable ?? false ){
            let queryParams = fetchQueryParamsFromUrl(url: url)
            notificationScreenConfig = DownloadFileManager().getDownloadScreenConfigFromParams(params: queryParams)
            showDownloadScreen = true
        }
        else if (url.starts(with:"w2n://go_back")){
            if WebToNativeConfig.runtimeTokens.blockSwipeHandling == true {
                sendBackHandlingDataToWebView()
            } else if WebToNativeCore.webView.canGoBack && WebToNativeConfig.runtimeTokens.blockSwipeHandling != true {
                WebToNativeCore.webView.goBack()
            }
        }
        else if (url.starts(with: "w2n://permission-")){
            showPermission(permission: url,openAppSetting: nil,alertDialogStyle: nil)
        }
        else if (url.starts(with: "w2n://jsFunction:")) {
            callJsFunction(jsFunction: url.replacingOccurrences(of: "w2n://jsFunction:", with: ""))
        }
        else if url.starts(with: "w2n://live-preview-app"){
            if !WebToNativeCore.isLivePreviewVisible {
                WebToNativeCore.storeLivePreviewUrl = url
                fetchLivePreviewInitialData(url: url)
            }
        }
        else if url.starts(with: "w2n://open-sidebar"){
            if WebToNativeConfig.sharedConfig?.sidebarNavigation?.data != nil {
                isSideBarVisible = true
            }
        }
    }
}


private func callJsFunction(jsFunction: String){
    WebToNativeCore.webView.evaluateJavaScript(jsFunction, completionHandler: nil)
}


/**
 Sending Back Handling Data When Custom Back Handling is Enabled.
 */
func sendBackHandlingDataToWebView() {
        let jsFunction = "customBackHandling()"
        WebToNativeCore.webView?.evaluateJavaScript(jsFunction){ (result, error) in
            if let error = error {
                print("Error calling JavaScript function: \(error.localizedDescription)")
            } else {
                print("JavaScript function called successfully, result: \(String(describing: result))")
            }
        }
    }

/**
 Fetches query parameters from a URL.

 - Parameter url: The URL from which to extract query parameters.
 - Returns: A dictionary of query parameters and their values.
 
 This function parses the query parameters from the provided URL and returns them as a dictionary.
 */
func fetchQueryParamsFromUrl(url:String) -> [String:String]{
    var queryParams = [String: String]()
    
    if let url = URL(string: url.replacingOccurrences(of: "#", with: "%23")) {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                if let value = item.value {
                    // Percent decode the value
                    if let decodedValue = value.removingPercentEncoding {
                        queryParams[item.name] = decodedValue
                    } else {
                        queryParams[item.name] = value
                    }
                }
            }
            print("Query Parameters: \(queryParams)")
        }
    }
    return queryParams
}
