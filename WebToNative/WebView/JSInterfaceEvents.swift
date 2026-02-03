//
//  JSInterfaceEvents.swift
//  WebToNative
//
//  Created by Akash Kamati on 14/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import WebToNativeCore
import WebKit

/**
 Enumeration of JavaScript interface events supported by the application.
 
 Each case corresponds to a specific JavaScript event name that can be handled by the native code.
 */
public enum JSInterfaceEvents: String, Decodable{
    case showOfferCard = "showOfferCard"
    case hideOfferCard = "hideOfferCard"
    case requestTrackingAuthorization = "requestTrackingAuthorization"
    case trackingConsentStatus = "trackingConsentStatus"
    case share = "share"
    case downloadFile = "downloadFile"
    case deviceInfo = "deviceInfo"
    case getClipBoardData = "getClipBoardData"
    case setClipBoardData = "setClipBoardData"
    case showAppRating = "showAppRating"
    case openAppSettingsPage = "openAppSettingsPage"
    case keepScreenOn = "keepScreenOn"
    case downloadBlob = "downloadBlob"
    case downloadBlobFile = "downloadBlobFile"
    case statusBar = "statusBar"
    case showSpinnerLoader = "showSpinnerLoader"
    case hideSpinnerLoader = "hideSpinnerLoader"
    case showHideStickyFooter = "showHideStickyFooter"
    case retryLoadWebsite = "retryLoadWebsite"
    case hideFloatingActionButton = "hideFloatingActionButton" 
    case showFloatingActionButton = "showFloatingActionButton"
    case getAddOnStatus = "getAddOnStatus"
    case closeApp = "closeApp"
    case openNewWindow = "openNewWindow"
    case firstCallWhenAppStarted = "firstCallWhenAppStarted"
    case updateAppIcon = "updateAppIcon"
    case disableScreenshotForPage = "disableScreenshotForPage"
    case checkPermission = "checkPermission"
    case openAppSettingForPermission = "openAppSettingForPermission"
    case showPermission = "showPermission"
    case getSafeArea = "getSafeArea"
    case initBeaconData = "initBeaconData"
    case hideNativeComponents = "hideNativeComponents"
    case showNativeComponents = "showNativeComponents"
    case disableSwipeBack = "customBackHandling"
    case registerNotification = "registerNotification"
    case showLivePreviewScreen = "showLivePreviewScreen"
    case hideLivePreview = "hideLivePreview"
    case refreshLivePreview = "refreshLivePreview"
    case showScreen = "showScreen"
    case clearAppCache = "clearAppCache"
    case resetPasscode = "resetPasscode"
    case setPasscode = "setPasscode"
    case openConnectWidget = "openConnectWidget"
    case cookiesUpdate = "cookiesUpdate"
}

/**
 Handles JavaScript interface events by executing corresponding native actions or behaviors.
 
 - Parameters:
    - event: The JSInterfaceEvents enum case representing the JavaScript event to handle.
    - data: Optional dictionary containing additional data associated with the JavaScript event.
 - Returns: `true` if the event was handled successfully; `false` if the event is not handled or unrecognized.
 */
public func isJSEventHandled(event:JSInterfaceEvents, data:[String:AnyObject]?)->Bool{
    
    var handled = true
    if event == .requestTrackingAuthorization{
        requestTrackingAuthorization(flag: true)
    }else if(event == .trackingConsentStatus){
        trackingConsentStatus()
    }else if(event == .share){
        let url = data?["url"] as? String ?? ""
        let type = data?["type"] as? String ?? ""
        if url.starts(with: "blob") && type == "file" {
            return false
        }
        shareHandler(data: data)
    }else if(event == .downloadFile){
        let appConfig = WebToNativeConfig.sharedConfig
        let enableDownloadFileManager = appConfig?.DOWNLOAD_MANAGER?.data?.enable ?? false
        let downloadUrl =  data?["downloadUrl"] as! String

        if enableDownloadFileManager {
            DownloadFileManager().startDownload(from: downloadUrl, controller: UIViewController())
        }
        else {
            DocumentManager().downloadFile(fileUrl: downloadUrl)
        }
    }else if(event == .deviceInfo){
        let responseObject = getDeviceInfo()
        WebToNativeCore.sendDataToWebView(data: responseObject)
    }else if(event == .getClipBoardData){
        getClipBoardData()
    }else if(event == .setClipBoardData){
        if let text = data?["text"] as? String, !text.isEmpty{
            setClipBoardData(text: text)
        }
    }else if(event == .showAppRating){
        let reviewManager = InAppReviewManager()
        reviewManager.showAppRating()
    } else if(event == .openAppSettingsPage) {
        openAppSettings()
    }else if(event == .keepScreenOn){
        if let flag = data?["flag"] as? Bool{
            keepScreenOn(flag: flag)
        }
    }else if(event == .downloadBlob){
        if let printData = data?["data"] as? String, let fileName = data?["filename"] as? String{
            try? BlobUrlFileDownloadUtil.shared.convertBase64StringToFileAndStoreIt(printData,actualFileName: fileName)
        }
    }else if(event == .getAddOnStatus){
        getAddOnStatus(addOnName: data?["addOnName"] as? String)
    }
    else if(event == .downloadBlobFile){
        if let fileName = data?["fileName"] as? String, let fileUrl = data?["url"] as? String{
            if let shareFileAfterDownload = data?["shareFileAfterDownload"] as? Bool{
                BlobUrlFileDownloadUtil.shared.shareFileAfterDownload = shareFileAfterDownload
            }
            if let openFileAfterDownload = data?["openFileAfterDownload"] as? Bool{
                BlobUrlFileDownloadUtil.shared.openFileAfterDownload = openFileAfterDownload
            }
            BlobUrlFileDownloadUtil.shared.downloadBlobFile(url: fileUrl, fileName: fileName)
        }
    }else if(event == .closeApp){
        if !WebToNativeCore.isLivePreviewVisible {
            exit(0)
        }
    }else if (event == .firstCallWhenAppStarted){
        checkFirstCallWhenAppStarted()
    }
    else if event == .openConnectWidget {
        callFunctionInternally(action: "showConversation")
    }
    else if event == .updateAppIcon {
        if WebToNativeConfig.sharedConfig?.DYNAMIC_ICON?.data?.isEmpty != true && WebToNativeCore.isLivePreviewVisible != true{
            let iconName = data?["iconName"] as? String? ?? nil
            let showAlertBox = data?["active"] as? Bool? ?? false
            updateAppIcon(iconName: iconName, showAlert: showAlertBox, showToast: true)
        }
    }
    else if(event == .checkPermission){
        var callbackData = ["type": "checkPermission", "permissionStatus": []] as [String : Any]

        let permissionNameList = data?["permissionName"] as? [String?]? ?? []
        if permissionNameList != nil && !(permissionNameList?.isEmpty  ?? true){
            let callbackDelay = 1.0
            var permissionStatusObject = [:] as [String: Any]
            permissionNameList?.forEach{ item in

                if WebToNativeConfig.sharedConfig?.NATIVE_CONTACTS?.data?.enable != true && item == "contact" {
                    permissionStatusObject["contact"] = "NOT_ALLOWED"
                }
                else if WebToNativeConfig.sharedConfig?.STRIPE_TAP_TO_PAY?.data?.enable != true && item == "bluetooth" {
                    permissionStatusObject["bluetooth"] = "NOT_ALLOWED"
                }
                else {
                    checkPermission(permission: item!,callBack: false,type: "checkPermission"){ status in
                        permissionStatusObject[item!] = status
                    }
                }
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + callbackDelay) {
                callbackData["permissionStatus"] = permissionStatusObject
                WebToNativeCore.sendDataToWebView(data: callbackData as [String: Any])
            }
            
        }
    }
    else if(event == .openAppSettingForPermission){
        openAppSetting(permissionName: data?["values"] as? String)
    }
    else if(event == .showPermission){
        let permission = data?["permission"] as? String
        let openAppSetting = data?["openAppSetting"] as? Bool
        let alertDialogStyle = data?["alertDialogStyle"] as? [String:AnyObject?]
        if permission == "contact" && !(WebToNativeConfig.sharedConfig?.NATIVE_CONTACTS?.data?.enable ?? false){
            sendAppPermissionCallback(type: "showPermission", status: "NOT_ALLOWED")

        }
        else if permission == "bluetooth" && !(
            WebToNativeConfig.sharedConfig?.STRIPE_TAP_TO_PAY?.data?.enable ?? false
        ) {
            sendAppPermissionCallback(type: "showPermission", status: "NOT_ALLOWED")
        }
        else {
            showPermission(permission: permission, openAppSetting: openAppSetting, alertDialogStyle: alertDialogStyle)
        }
    }else if(event == .initBeaconData){
        if WebToNativeConfig.sharedConfig?.BEACON?.data?.enable ?? false && WebToNativeCore.isLivePreviewVisible != true {
            showPermission(permission: "location_always", openAppSetting: nil, alertDialogStyle: nil)
            guard let data = data,
                  let beaconData = data["data"] as? [String: AnyObject] else {
                return true
            }
            let beaconClass = WebToNativeBeacon()
            beaconClass.beaconConfig(beaconData: beaconData)
            UserDefaults.standard.set(getDeviceInfo(), forKey: "deviceInfo")
        }
    }
    else if event == .cookiesUpdate {
        if let newCookies = data?["data"] as? [String: AnyObject] {
                print("cookiesData3322: newCookies=> \(newCookies)")
                extendCookieExpiry(newCookies: newCookies)
           
        }
    }
    else{
        handled = false
    }
    return handled
    
}


func shareHandler(data:[String:AnyObject]?){
    
    let type = data?["type"] as? String ?? ""
    let url = data?["url"] as? String
    let text = data?["text"] as? String
    let fileExtension = (data?["extension"] as? String ?? "").replacingOccurrences(of: ".", with: "")
    
    
    print("the type = \(type) url = \(String(describing: url)) text = \(String(describing: text))")
    
    if let controller = WebToNativeCore.viewController{
        if type == "file", let urlString = url{
            if url?.starts(with: "data:") == true, let fileUrl = url?.contains("filename") ?? false ? url : url?.appending("?filename=File.\(fileExtension)") {
                
                BlobUrlFileDownloadUtil.shared.sharingText = text
                BlobUrlFileDownloadUtil.shared.downloadDataUrlFile(from: fileUrl, calledByShare: true)
                
            }else {
                Toast.show(message: "Please wait downloading file to share..", controller: controller)
                DocumentManager().downloadFile(fileUrl: urlString,text: text)
            }
        } else{
            
            var activityItems: [Any] = []
            
            if let urlString = url, let url = NSURL(string: urlString){
                if !(text ?? "").isEmpty{
                    activityItems = [url,text!]
                } else{
                    activityItems = [url]
                }
            } else{
                if !(text ?? "").isEmpty{
                    activityItems = [text!]
                }
            }
            
            if !activityItems.isEmpty{
                let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                // to support ipad
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = controller.view
                    popoverController.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                controller.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

func clearAppCache(fullClear: Bool = false) {
    HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

    // Remove all WKWebView data
    WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records) {
            // Data cleared'
            print("WebView Cleared")
        }
    }
    if fullClear {
        // Remove all User Defaults Keys
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        // Clearing Caches and Files
        let fileManager = FileManager.default
        if let cacheDir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            try? fileManager.removeItem(at: cacheDir)
        }
        if let docsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            try? fileManager.removeItem(at: docsDir)
        }
    }
}
