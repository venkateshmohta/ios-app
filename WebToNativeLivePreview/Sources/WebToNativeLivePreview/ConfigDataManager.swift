//
//  ConfigDataManager.swift
//  WebToNative
//
//  Created by yash saini on 17/09/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//
import Foundation
import WebToNativeCore

class ConfigDataManager {
    private var configJson: [String: Any]
    private var isSocketReconnecting = false
    private var storeTabCount = -1
    
    private let initialJson = """
        {
            "websiteLink": "https://webtonative.com"
        }
    """
    
    init() throws {
        // Convert initial JSON string to dictionary
        guard let jsonData = initialJson.data(using: .utf8),
              let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid initial JSON string"))
        }
        self.configJson = jsonDict
    }
    
    // Function to update config with new JSON string
    private func updateConfig(with jsonString: String) throws {
        // Convert the incoming JSON string to a dictionary
        guard let jsonData = jsonString.data(using: .utf8),
              let newJsonDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid JSON string"))
        }
        
        // Merge dictionaries (new values overwrite old ones)
        configJson = configJson.merging(newJsonDict) { (_, new) in new }
    }
    
    // Get the current config as MyConfigData
    private func getConfig() throws -> WebToNativeConfigData {
        // Convert merged dictionary back to JSON data
        let mergedJsonData = try JSONSerialization.data(withJSONObject: configJson)
        
        // Decode into MyConfigData
        let decoder = JSONDecoder()
        return try decoder.decode(WebToNativeConfigData.self, from: mergedJsonData)
    }
    
    
    //Initialise Live Preview Config Data before showing Live Preview loading screen
    func initializeLivePreviewData(data: [String: AnyObject], onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void){
       if let requestId = data["requestId"] as? String, let previewId = data["previewId"] as? String, let userId = data["userId"] as? String{
            ApiManager().callApi(api: ApiManager().getDataApi, requestId: requestId, previewId: previewId, userId: userId) { data in
                // Set Live preview config
                self.updateLivePreviewData(config: data)
                onSuccess()
            } onFailure: { error in
                print("ApiError: \(error)")
                onFailure(error)
            }

        }
        else {
            onFailure("ID_MISSING")
        }
    }
    
    
    // Update Live Preview Data
    func updateLivePreviewData(config: Data, isSocketCalled: Bool = false){
        if WebToNativeCore.webView == nil {
            if !WebToNativeCore.isLivePreviewVisible{
                //Change123
                WebToNativeCore.webView = WebToNativeCore.storeAppWebView
            }
            return
        }

        getPreviewDataFromData(jsonData: config, isSocketCalled: isSocketCalled)

    }
    
    
    
    private func getPreviewDataFromData(jsonData: Data, isSocketCalled: Bool = false){
        do {
            // Convert to Dictionary
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                if jsonObject["type"] as? String  == "ACTIVE_USERS", let tabList = jsonObject["browserConnectionIds"] as? [String], isSocketCalled{
                    print("tabList: \(tabList)")
                    storeTabCount = tabList.count
                    
                    if !isSocketReconnecting && storeTabCount == 0{
                        isSocketReconnecting = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                            self.isSocketReconnecting = false
                            if self.storeTabCount == 0{
                                NotificationCenter.default.post(name: .livePreviewDataUpdated, object: nil, userInfo: ["isSocketConnected": false])
                                self.storeTabCount = -1
                            }
                        }
                    } else {
                        NotificationCenter.default.post(name: .livePreviewDataUpdated, object: nil, userInfo: ["isSocketConnected": true])
                    }
                }
                else {
//                    if isSocketReconnecting {
                        isSocketReconnecting = false
                        storeTabCount = -1
                        NotificationCenter.default.post(name: .livePreviewDataUpdated, object: nil, userInfo: ["isSocketConnected": true])
//                    }
                }
                
                if isSocketCalled && jsonObject["type"] as? String  != "CHANGE_IN_DATA" && jsonObject["os"] as? String != "ios"{
                    return
                }
                let configData = isSocketCalled ? jsonObject["data"] as? [String: Any]: jsonObject
                // Convert "data" back to JSON Data
                let dataJson = try JSONSerialization.data(withJSONObject: configData as Any, options: [.prettyPrinted])
                var isReloadRequired: Bool = false
                var isRefreshRequired: Bool = false
                let requiredKeys: [String] = [
                    "customUserAgent",
                    "globalCssString",
                    "globalJsString",
                    "DISABLE_SCREENSHOT"
                ]
                
                let refreshRequiredKeys: [String] = [
                    "enableFullScreen",
                    "internalExternalLinks"
                ]
                configData?.forEach { (key, value) in
                    requiredKeys.forEach { (requiredKey) in
                        if key == requiredKey {
                            isReloadRequired = true
                        }
                    }
                }
                
                for (key, value) in configData ?? [:] {
                    guard refreshRequiredKeys.contains(key) else { continue }

                    switch key {
                    case "enableFullScreen":
                        if let boolValue = value as? Bool,
                           boolValue != WebToNativeConfig.sharedConfig?.enableFullScreen {
                            isRefreshRequired = true
                            break
                        }
                    case "internalExternalLinks":
                        // --- inside your switch case "internalExternalLinks" ---

                        if let jsonArray = value as? [[String: String]] {
                            // Build current descriptors from incoming JSON
                            let currentDescriptors: [LinkDescriptor] = jsonArray.map { LinkDescriptor(dict: $0) }

                            // Build previous descriptors from your existing config (map to same type)
                            let previousDescriptors: [LinkDescriptor] = (WebToNativeConfig.sharedConfig?.internalExternalLinks ?? []).map { prev in
                                // adapt this to how previousJson stores fields (example uses rawValue etc.)
                                let dict: [String: String] = [
                                    "type": prev.type.rawValue,
                                    "regex": prev.regex ?? "",
                                    "pageType": prev.pageType?.rawValue ?? ""
                                ]
                                return LinkDescriptor(dict: dict)
                            }

                            let prevSet = Set(previousDescriptors)
                            let currSet = Set(currentDescriptors)

                            if prevSet == currSet {
                                // optionally set both flags false (explicit)
                                isRefreshRequired = false
                                isReloadRequired = false
                            } else {
                                // Something changed: find added and removed items
                                let added = currSet.subtracting(prevSet)    // present now, not before
                                let removed = prevSet.subtracting(currSet)  // present before, not now

                                // If either an added or removed item is CUSTOM -> refresh
                                let changeInvolvesCustom = added.contains { $0.type == "CUSTOM" } ||
                                                           removed.contains { $0.type == "CUSTOM" }

                                if changeInvolvesCustom {
                                    isRefreshRequired = true
                                    isReloadRequired = false
                                } else {
                                    // Changed, but no CUSTOM involved (external/internal etc.) -> reload
                                    isReloadRequired = true
                                    isRefreshRequired = false
                                }

                            }
                        }
                    default:
                        break
                    }

                    if isRefreshRequired { break }
                }

                // Convert JSON Data back to String
                if let dataString = String(data: dataJson, encoding: .utf8) {
                    print("DataString:  \(dataString)")
                    // Update with new JSON
                    try updateConfig(with: dataString)
                    // Get and print updated config
                    let updatedConfig = try getConfig()
                    WebToNativeConfig.previewSharedConfig = updatedConfig
                    
                    var headerIndex = 0
                    var tabIndex = 0
                    updatedConfig.w2nHeader?.data?.forEach { (header) in
                        header?.tabs?.forEach { (tab) in
                            if tab?.type == "logo" {
                                if let icon = tab?.icon {
                                    
                                    if isSocketCalled{
                                        if let config = jsonObject["data"] as? [String: Any], let w2nHeaderData = config["w2nHeader"] as? [String: Any], let images = w2nHeaderData["images"] as? [String: Any], let logo = images["\(icon)"] as? String{
                                            WebToNativeConfig.previewSharedConfig?.w2nHeader?.data?[headerIndex]?.tabs?[tabIndex]?.icon = logo
                                        }
                                    }
                                    else {
                                        if let w2nHeaderData = jsonObject["w2nHeader"] as? [String: Any], let images = w2nHeaderData["images"] as? [String: Any], let logo = images["\(icon)"] as? String{
                                            WebToNativeConfig.previewSharedConfig?.w2nHeader?.data?[headerIndex]?.tabs?[tabIndex]?.icon = logo
                                        }
                                    }
                                }
                            }
                            tabIndex += 1
                        }
                        headerIndex += 1
                        tabIndex = 0
                    }

                    if WebToNativeCore.isLivePreviewVisible {
                        WebToNativeConfig.sharedConfig = WebToNativeConfig.previewSharedConfig
                    }
                    // open Screen
                    if isRefreshRequired {
                        ScreenManager().webToNativeApp(restartLivePreview: true)
                    } else {
                        if let screenName = jsonObject["livePreviewNavigateScreen"] as? String {
                            let closedCurrentScreen = jsonObject["closedCurrentScreen"] as? Bool ?? false
                            ScreenManager()
                                .navigateToScreen(
                                    name: screenName,
                                    isReloadRequired: isReloadRequired,
                                    closedCurrentScreen: closedCurrentScreen
                                )
                        }
                        
                        if let data = jsonObject["data"] as? [String: Any],
                           let navigationLoaders = data["navigationLoader"] as? [String: Any],
                           let screenName = jsonObject["livePreviewNavigateScreen"] as? String, screenName == "loadingScreen" {

                            // Use nil coalescing operator to set closedCurrentScreen to nil if it's not present
                            let closedCurrentScreen = jsonObject["closedCurrentScreen"] as? Bool

                            // Only proceed if closedCurrentScreen is either nil or false
     
                                let animationUrl = navigationLoaders["animationJsonUrl"] as? String ?? ""
                                ScreenManager()
                                    .navigatorLoaderChange(
                                        animationUrl: animationUrl,
                                        closedCurrentScreen: closedCurrentScreen ?? false
                                    )
                            
                        }
                    }
                    if WebToNativeCore.isLivePreviewVisible {
                        ScreenManager().refreshLivePreview()
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
}


// Helper value type
struct LinkDescriptor: Hashable {
    let type: String      // e.g. "CUSTOM", "INTERNAL", "EXTERNAL"
    let regex: String?
    let pageType: String?

    init(dict: [String: String]) {
        self.type = dict["type"] ?? ""
        self.regex = dict["regex"]
        self.pageType = dict["pageType"]
    }

    // For readability when debugging
    var description: String {
        return "\(type)|\(regex ?? "")|\(pageType ?? "")"
    }
}
