//
//  StatusBar.swift
//  WebToNative
//
//  Created by Orufy MacMini 3 on 18/08/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//


import SwiftUI
import WebToNativeCore
import WebKit


struct MainView<Content: View>: View {
    @ViewBuilder var content: Content
    @State var webView: WKWebView
    
    @State private var statusBarWindow: UIWindow?
    
    var body : some View {
        content.onAppear {
            if statusBarWindow == nil {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    let statusBarWindow = UIWindow(windowScene: windowScene)
                    statusBarWindow.windowLevel = .statusBar
                    statusBarWindow.tag = 0320
                    let controller = MainViewController()
                    controller.view.backgroundColor = .clear
                    controller.view.isUserInteractionEnabled = false
                    statusBarWindow.rootViewController = controller
                    statusBarWindow.isHidden = false
                    statusBarWindow.isUserInteractionEnabled = false
                    self.statusBarWindow = statusBarWindow
                    
                }
            }
        }
    }
}


extension UIApplication {
    func setStatusBarStyle(_ style : UIStatusBarStyle){
        if let statusBarWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }), let statusbarController = statusBarWindow.rootViewController as? MainViewController {
            statusbarController.statusBarStyle = style
            statusbarController.setNeedsStatusBarAppearanceUpdate()
            
        }
    }
    
    func customBackHandling(_ value : Bool){
        if let statusBarWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: { $0.tag == 0320 }), let statusbarController = statusBarWindow.rootViewController as? MainViewController {
            statusbarController.isCustomBackHandlingEnabled = value
            
        }
    }
}


class MainViewController : UIViewController,UIGestureRecognizerDelegate, WKHTTPCookieStoreObserver {
    var statusBarStyle: UIStatusBarStyle = .default
    var statusBarColor : String = WebToNativeConfig.sharedConfig?.statusBarColor ?? ""
    var customSwipeGesture: UIGestureRecognizer?
    var enableCookiesUpdate: Bool = true
    
    var isCustomBackHandlingEnabled: Bool = false {
        didSet {
            // Change123 check webview null
            if WebToNativeCore.webView != nil{
                updateBackHandlingMode()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        return WebToNativeConfig.sharedConfig?.enableFullScreen == true || WebToNativeConfig.sharedConfig?.showTopSafeArea == false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            // Change123 check webview null
        if WebToNativeCore.webView != nil{
            updateBackHandlingMode()
        }
        
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        cookieStore.add(self)
    }
    
    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        print("cookies123: cookiesDidChange called")
//        if enableCookiesUpdate {
//            enableCookiesUpdate = false
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5){
//                self.enableCookiesUpdate = true
//                extendCookieExpiry()
//            }
//        }
    }
    
    
    
    private func updateBackHandlingMode() {
        if isCustomBackHandlingEnabled {
            
            // Disable WKWebView’s native swipe
            WebToNativeCore.webView.allowsBackForwardNavigationGestures = false
            
            // Attach custom gesture if not already added
            if customSwipeGesture == nil {
                if UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.orientation.isLandscape {
                    if customSwipeGesture as? UIScreenEdgePanGestureRecognizer != nil {
                        view.removeGestureRecognizer(customSwipeGesture!)
                        WebToNativeCore.webView.removeGestureRecognizer(customSwipeGesture!)
                    }
                    // iPad OR iPhone Landscape → full pan
                    let pan = UIPanGestureRecognizer(target: self, action: #selector(handleCustomBackSwipe(_:)))
                    pan.delegate = self
                    WebToNativeCore.webView.addGestureRecognizer(pan)
                    customSwipeGesture = pan
                } else {
                    if customSwipeGesture as? UIPanGestureRecognizer != nil {
                        view.removeGestureRecognizer(customSwipeGesture!)
                        WebToNativeCore.webView.removeGestureRecognizer(customSwipeGesture!)
                    }
                    // iPhone Portrait → edge swipe
                    let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleCustomBackSwipe(_:)))
                    edgePan.edges = .left
                    edgePan.delegate = self
                    WebToNativeCore.webView.addGestureRecognizer(edgePan)
                    customSwipeGesture = edgePan
                }
            }
        } else {
            // Enable WKWebView’s native swipe
            WebToNativeCore.webView.allowsBackForwardNavigationGestures = true
            
            // Remove custom gesture if present
            if let gesture = customSwipeGesture {
                view.removeGestureRecognizer(gesture)
                WebToNativeCore.webView.removeGestureRecognizer(gesture)
                customSwipeGesture = nil
            }
        }
    }
    
    @objc private func handleCustomBackSwipe(_ gesture: UIGestureRecognizer) {
        if let edgePan = gesture as? UIScreenEdgePanGestureRecognizer {
            if edgePan.state == .recognized {
                sendBackHandlingDataToWebView()
            }
        } else if let pan = gesture as? UIPanGestureRecognizer {
            let translation = pan.translation(in: view)
            guard translation.x > 0, abs(translation.x) > abs(translation.y) else { return }
            
            if pan.state == .ended {
                sendBackHandlingDataToWebView()
            }
        }
    }
    
    
    private var isPad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
       private var isLandscape: Bool { UIDevice.current.orientation.isLandscape }

       /// Edge width for iPhone portrait so we don't clash with normal page pans
       private let leftEdgeWidth: CGFloat = 40
       /// Completion thresholds
       private let minHorizontalTravel: CGFloat = 80
       private let maxVerticalDeviation: CGFloat = 60
       private let minBeginVelocityX: CGFloat = 60
    
    
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            // Only begin for RIGHTWARD, predominantly horizontal swipes
            let v = pan.velocity(in: view)
            guard v.x > minBeginVelocityX, abs(v.x) > abs(v.y) else { return false }
            
            // Scope: iPhone portrait = left edge only; iPad & iPhone landscape = anywhere
            if !isPad && !isLandscape {
                let startX = pan.location(in: view).x
                return startX <= leftEdgeWidth // left edge only on iPhone portrait
            }
            
            return true
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOrientationChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }
    
    @objc private func handleOrientationChange() {
        // Reapply handling mode on orientation change
        if isCustomBackHandlingEnabled {
            // Remove old gesture and rebuild
            if let gesture = customSwipeGesture {
                WebToNativeCore.webView.removeGestureRecognizer(gesture)
                customSwipeGesture = nil
            }
            updateBackHandlingMode()
        }
    }
    

    
}
