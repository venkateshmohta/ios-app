// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation
import WebToNativeCore

public class WebToNativeLivePreview: NSObject {
    private var livePreviewWebSocket: NewLivePreviewSocket?
    private var livePreviewManager: LivePreviewManager?
    private var initializedCalledByRefresh: Bool = false
    private var isSocketConnected: Bool? = nil

    
    public override init(){
        super.init()
        WebToNativeBridge.shared.registerModule(moduleClass: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: .webToNativeInterface, object: nil)
    }
    /// Handles incoming notifications and performs actions based on the notification's content.
    /// This method processes notifications related to Intercom action,s such as showing or hiding
    /// the Intercom launcher icon, and setting its bottom padding. It also ensures that the
    /// Intercom SDK is properly configured before performing any actions.
    ///
    /// - Parameter notification: The notification object containing user info related to the action.

    @_documentation(visibility: public)
    @objc private func handleNotification(notification: Notification) {
        if let data = notification.userInfo as? [String:AnyObject]{
            let appConfig = WebToNativeConfig.sharedConfig
            guard let action = data["action"] as? String else{
                return
            }
            
            if livePreviewWebSocket == nil {
                livePreviewWebSocket = NewLivePreviewSocket()
            }
            
            if livePreviewManager == nil {
                livePreviewManager = LivePreviewManager(livePreviewWebSocket: livePreviewWebSocket!)
            }
            
            if appConfig?.LIVE_PREVIEW?.data?.enable != true {
                return
            }
            else if action == "initializeLivePreviewData" {
                isSocketConnected = isSocketConnected == nil ? false : true
                livePreviewManager?.initializeLivePreview(data: data, previewRefresh: isSocketConnected!)
            }
            else if action == "closeLivePreview" {
                isSocketConnected = nil
                livePreviewWebSocket?.disconnect(calledByModule: true)
                livePreviewWebSocket = nil
                livePreviewManager = nil
            }
            
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


