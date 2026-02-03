//
//  WebToNativeApp.swift
//  WebToNative
//
//  Created by Akash Kamati on 22/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import SwiftUI
import WebToNativeCore
import WebKit

/**
 The main application struct for the WebToNativeApp.

 This struct defines the entry point and main structure of the application using the SwiftUI `App` protocol. It sets up the application delegate, state objects, and the main content view. It also handles URL opening, network connectivity changes, and various application lifecycle events.

 - Properties:
   - appDelegate: The application delegate, adapted to `UIApplicationDelegateAdaptor`.
   - networkManagerService: An instance of `NetworkManagerService` to monitor network connectivity.
   - openUrl: A state variable to hold the URL to be opened.

 - Methods:
   - onLoad(): Performs initial setup tasks when the app loads.
 */
@main
struct WebToNativeApp: App {
    /// The application delegate, adapted to `UIApplicationDelegateAdaptor`.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    /// An instance of `NetworkManagerService` to monitor network connectivity.
    @StateObject var networkManagerService = NetworkManagerService()
    /// A state variable to hold the URL to be opened.
    @State var openUrl:String = ""
    /// Live Preview
    @State var previewUrl: String = "" // store preview url
    @State var showPreviewScreen = false // Manage Live Preview Screen Visibility
    @State var mainWebView: WKWebView = WKWebView() // create webView for Base App
    @State var previewWebView: WKWebView = WKWebView() // webView for livePreview
    @State var refreshPreview = true
    @State var showLivePreviewBg = false
    @State var showMainScreenforce = false
    @State var previewCoordinator: WebViewCoordinator?
    // inCaseOfBarcode use for stop base url loading in live preview(in case of barcode & other screen appear on live preview main Screen)
    @State var inCaseOfBarcode = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(
                    isLivePreviewScreen: false,
                    openUrl: $openUrl,
                    refreshPreview: $refreshPreview,
                    webView: $mainWebView,
                    showPreviewScreen: $showPreviewScreen, webViewCoordinator: WebViewCoordinator(webView: mainWebView),
                    notificationScreenViewModel: NotificationScreenViewModel(
                        notificationService: appDelegate.notificationService
                    ),
                    showMainScreenForce: $showMainScreenforce
                )
                    .onOpenURL(perform: { url in
                        openUrl = url.absoluteString
                    })
                    .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                        guard let url = userActivity.webpageURL else {
                            return
                        }
                        openUrl = url.absoluteString
                    }
                    .environmentObject(networkManagerService)
                    .onReceive(notification: .openUrl) { notification in
                        if let openUrl = notification.userInfo?["openUrl"] as? String, !openUrl.isEmpty {
                            self.openUrl = openUrl
                        }
                    }.onAppear{
                        if previewCoordinator == nil {
                            previewCoordinator = WebViewCoordinator(webView: previewWebView)
                        }
                        onLoad()
                    }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification)) { _ in
                        WebToNativeCore.notifyApplicationDelegates(event: .applicationDidFinishLaunchingWithOptions)
                    }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        if WebToNativeConfig.sharedConfig?.requestTrackingConsentOnLoad == true{
                            requestTrackingAuthorization(flag: false)
                        }
                        DispatchQueue.main.async {
                            if !networkManagerService.isConnected{
                                showNoInternetToast()
                            }
                        }
                    }.onChange(of: networkManagerService.isConnected){value in
                        if(!value){
                            showNoInternetToast()
                        }
                    }.onReceive(NotificationCenter.default.publisher(for: .biometricBlurViewShown)) { value in
                         let show = value.userInfo?["show"] as? Bool ?? false
                         if WebToNativeConfig.sharedConfig?.BIOMETRIC?.data?.hideBackground ?? false {
                             appDelegate.blurView(show: show )
                         }
                     }
                
                // Live Preview Screen
                ZStack{
                    // livePreview background
                    if showLivePreviewBg {
                        Color.white.ignoresSafeArea()
                    }

                    if showPreviewScreen{
                        ZStack{
                            if refreshPreview{
                                
                                ContentView(
                                    isLivePreviewScreen: true,
                                    openUrl: $previewUrl,
                                    refreshPreview: $refreshPreview,
                                    webView: $previewWebView,
                                    showPreviewScreen: $showPreviewScreen,
                                    webViewCoordinator: previewCoordinator!,
                                    notificationScreenViewModel: NotificationScreenViewModel(
                                        notificationService: appDelegate.notificationService
                                    ),
                                    showMainScreenForce: $showMainScreenforce
                                )
                                .environmentObject(networkManagerService)
                                .onAppear{
                                    if WebToNativeConfig.appSharedConfig != nil {
                                        hideIntercomIcon()
                                    }
                                    showLivePreviewBg = true
                                    if WebToNativeCore.isLivePreviewVisible && !WebToNativeCore.isOpenedFirstTime {
                                        WebToNativeCore.isOpenedFirstTime = true
                                    }
                                    if inCaseOfBarcode == false {
                                        previewUrl = WebToNativeConfig.previewSharedConfig?.websiteLink ?? ""
                                       // onLoad()
                                        inCaseOfBarcode = true
                                    } else {
                                        previewUrl = previewWebView.url?.absoluteString ?? WebToNativeConfig.previewSharedConfig?.websiteLink ?? ""
                                    }
                                    WebToNativeCore.isLivePreviewVisible = true
                                    // Disable Screen Sleep
                                    UIApplication.shared.isIdleTimerDisabled = true
                                    
                                }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didFinishLaunchingNotification)) { _ in
                                    WebToNativeCore.notifyApplicationDelegates(event: .applicationDidFinishLaunchingWithOptions)
                                }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                                    if WebToNativeConfig.sharedConfig?.requestTrackingConsentOnLoad == true{
                                        requestTrackingAuthorization(flag: false)
                                    }
                                    DispatchQueue.main.async {
                                        if !networkManagerService.isConnected{
                                            showNoInternetToast()
                                        }
                                    }
                                }.onChange(of: networkManagerService.isConnected){ value in
                                    if(!value){
                                        showNoInternetToast()
                                    }
                                }
                                .onChange(of: WebToNativeCore.isLivePreviewVisible){ value in
                                    if !value{
                                        showPreviewScreen = false
                                    }
                                }.onReceive(NotificationCenter.default.publisher(for: .biometricBlurViewShown)) { value in
                                    let show = value.userInfo?["show"] as? Bool ?? false
                                    if WebToNativeConfig.sharedConfig?.BIOMETRIC?.data?.hideBackground ?? false {
                                        appDelegate.blurView(show: show )
                                    }
                                }.onReceive( NotificationCenter.default.publisher(for: .webToNativeApp)) { newValue in
                                    
                                    let restartLivePreview = newValue.userInfo?["restartLivePreview"] as? Bool ?? false
                                    let isCloseLivePreview = newValue.userInfo?["closeLivePreview"] as? Bool ?? false
                                    
                                    if restartLivePreview {
                                        reloadLivePreview()
                                    }
                                    
                                    if isCloseLivePreview {
                                        if WebToNativeConfig.appSharedConfig != nil {
                                            showIntercomIcon()
                                        }
                                        closeLivePreview()
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    
                    // livePreview menu & Bar
                    if showLivePreviewBg {
                        PreviewBar(closeClick: {
                            if WebToNativeConfig.appSharedConfig != nil {
                                showIntercomIcon()
                            }
                            /// close live preview
                            inCaseOfBarcode = false
                            closeLivePreview()
                        }, reloadClick: {
                            /// reload Live Preview
                            inCaseOfBarcode = false
                            reloadLivePreview()
                        })
                    }
                }

            }

        }
    }
    
    private func closeLivePreview(){
        if WebToNativeCore.webView.url != nil{
            showMainScreenforce = true
            // Add Close Click here
            changeConfigurationAndWebview(isLivePreview: false)
            showPreviewScreen = false
            callFunctionInternally(action: "refreshLivePreview")
            callFunctionInternally(action: "closeLivePreview")
            showLivePreviewBg = false
            WebToNativeConfig.previewSharedConfig = nil
            previewWebView.backForwardList.perform(Selector(("_removeAllItems")))

            // set base app config data
            if WebToNativeConfig.sharedConfig == nil{
                WebToNativeConfig.sharedConfig = WebToNativeConfig.appSharedConfig
            }
            // Reset Screen Sleep
            UIApplication.shared.isIdleTimerDisabled = WebToNativeConfig.sharedConfig?.keepScreenOn ?? false
            NotificationCenter.default.post(name: .mainScreenPreviewHandler, object: nil, userInfo: ["rematch": true])


        }
    }
    
    // Reload the live preview, reset the configuration data, and fetch the live preview data again.
    private func reloadLivePreview(){
//        showLivePreviewBg = true
        changeConfigurationAndWebview(isLivePreview: false)
        // hide live preview screen
        showPreviewScreen = false
        callFunctionInternally(action: "refreshLivePreview")
        // fetch live preview config data again
        fetchLivePreviewInitialData(url: WebToNativeCore.storeLivePreviewUrl!)
    }
    /**
     Performs initial setup tasks when the app loads.
     
     This method checks various configuration settings and sets up the initial state of the application, such as keeping the screen on and handling launch URLs.
     */
    func onLoad(){
        
        if(WebToNativeConfig.sharedConfig?.keepScreenOn == true){
            keepScreenOn(flag: true)
        }
        
        if let launchUrl = WebToNativeCore.openUrl, !launchUrl.isEmpty{
            openUrl = launchUrl
        }
    }
}

