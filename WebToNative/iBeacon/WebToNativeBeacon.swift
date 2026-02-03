//
//  WebToNativeBeacon.swift
//  WebToNative
//
//  Created by Ravi Saharan on 20/06/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//

import Foundation
import CoreLocation
import WebToNativeCore

// MARK: - WebToNativeBeacon
public class WebToNativeBeacon {
    let locationManager : CLLocationManager? = WebToNativeCore.locationManager
    static var initializedSuccessfully: Bool = false
    var beaconRegion: CLBeaconRegion? = nil
    
    func beaconConfig(beaconData: [String: AnyObject]) {
        do {
            NotificationCenter.default.addObserver(
                 forName: .beaconPermissionChanged,
                 object: nil,
                 queue: nil
             ) { notification in
                 if self.locationManager?.authorizationStatus == .authorizedAlways && WebToNativeBeacon.initializedSuccessfully{
                     self.requestNotificationPermissionWithCallback()
                 }
             }
            
            var modified = beaconData
            
            // Convert userInfo dictionary to JSON string if needed
            if let userInfoDict = modified["userInfo"] as? [String: Any],
               let userInfoData = try? JSONSerialization.data(withJSONObject: userInfoDict),
               let userInfoString = String(data: userInfoData, encoding: .utf8) {
                modified["userInfo"] = userInfoString as AnyObject
            }

            // Use modified dictionary for JSON serialization
            let jsonData = try JSONSerialization.data(withJSONObject: modified, options: [])

            // Decode the data into BeaconData struct
            let decoded = try JSONDecoder().decode(BeaconData.self, from: jsonData)
    
            UserDefaults.standard.set(jsonData, forKey: "beaconData")
            setupBeacon(beaconData: decoded)
            
            WebToNativeBeacon.initializedSuccessfully = true
            
        } catch {
            print("Failed to decode beacon data: \(error.localizedDescription)")
            sendBeaconCallback(isSuccess: false, status: error.localizedDescription)
        }
    }

    
    private func setupBeacon(beaconData: BeaconData) {
        //Removing monitoring for any previously configured beacons
        stopMonitoringAllBeacons()
        //Started Monitoring for newly configured Beacons
        startMonitoring(beaconData: beaconData)
    }
    
    private func startMonitoring(beaconData: BeaconData) {
        guard let locationManager = locationManager,
              let beaconConfigArray = beaconData.beaconConfig else {
            return
        }
        
        for beaconConfig in beaconConfigArray {
            guard let beaconConfig,
                  let beaconUUID = beaconConfig.uuid,
                  let beaconMajor = beaconConfig.major,
                  let beaconMinor = beaconConfig.minor else{
                return
            }
            if let beaconStringUUID = UUID(uuidString: beaconUUID ) {
                beaconRegion = CLBeaconRegion(uuid: beaconStringUUID,
                                              major: CLBeaconMajorValue(beaconMajor),
                                              minor: CLBeaconMinorValue(beaconMinor),
                                              identifier: "beacon\(beaconUUID)\(beaconMajor)\(beaconMinor)")
                beaconRegion?.notifyOnEntry = true
                beaconRegion?.notifyOnExit = true
                locationManager.startMonitoring(for: beaconRegion!)
            }
        }
    }
    
    private func stopMonitoringAllBeacons() {
        guard let locationManager = locationManager else {
            return
        }
        let regions = locationManager.monitoredRegions
        guard !regions.isEmpty else {
            print("No regions to stop monitoring.")
            return
        }

        for region in regions {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    func handleNotification(region: CLRegion,status: String) {
        var responseData: [String: Any] = [:]
        let userDefaults = UserDefaults.standard
        
        if let data = userDefaults.data(forKey: "beaconData"),
           let beaconData = try? JSONDecoder().decode(BeaconData.self, from: data) {
            
            guard let beaconConfig = beaconData.beaconConfig,
                  let beaconRegion = region as? CLBeaconRegion else {
                print("Invalid beacon data or not a beacon region.")
                return
            }

            responseData["status"] = status
            responseData["beaconInfo"] = [
                "beaconUUID": beaconRegion.uuid.uuidString,
                "beaconMajor": beaconRegion.major?.intValue ?? 0,
                "beaconMinor": beaconRegion.minor?.intValue ?? 0
            ]
            responseData["userInfo"] = beaconData.userInfo
            responseData["FCMToken"] = userDefaults.string(forKey: "FCMToken")
            responseData["OneSignalPlayerId"] = userDefaults.string(forKey: "playerId")
            responseData["deviceInfo"] = userDefaults.dictionary(forKey: "deviceInfo")
            
            
            var notificationContentSource: NotificationContentSource? = nil
            var webHookUrl: String? = nil
            var defaultNotificationEnterData: NotificationContentData?
            var defaultNotificationExitData: NotificationContentData?
            var fetchNotificationData: NotificationContentData?
            var showNotificationOnEntry : Bool = false
            var showNotificationOnExit : Bool = false
            var notificationInterval : Int = 0
            var regionIdentifier : String?
            
            for beacon in beaconConfig {
                guard let beacon = beacon,
                      let beaconUuid = beacon.uuid,
                      let beaconMajor = beacon.major,
                      let beaconMinor = beacon.minor
                else{
                    return
                }
                if region.identifier == "beacon\(beaconUuid)\(beaconMajor)\(beaconMinor)" {
                    notificationContentSource = beacon.settings?.notificationContentSource
                    webHookUrl = beacon.webhookUrl
                    defaultNotificationEnterData = beacon.settings?.defaultNotificationEnterData
                    defaultNotificationExitData = beacon.settings?.defaultNotificationExitData
                    showNotificationOnEntry = beacon.settings?.showNotificationOnEntry ?? false
                    showNotificationOnExit = beacon.settings?.showNotificationOnExit ?? false
                    notificationInterval = beacon.settings?.notificationInterval ?? 0
                    regionIdentifier = "beacon\(beaconUuid)\(beaconMajor)\(beaconMinor)"
                }
            }
            
            guard let webHookUrl = webHookUrl,
                  let url = URL(string: webHookUrl) else {
                print("No webhook URL provided or invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do{
                request.httpBody = try JSONSerialization.data(withJSONObject: responseData, options: [])
            } catch {
                print("Failed to make httpBody: \(error.localizedDescription)")
            }
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // Handle error
                if let error = error {
                    print("Request error: \(error)")
                    return
                }
                
                // Ensure data is present
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                // Deserialize JSON
                do {
                    if notificationContentSource == .API_FETCHED {
                        let decodedData = try JSONDecoder().decode(NotificationContentData.self, from: data)
                        fetchNotificationData = decodedData
                    }
                    let notificationData: NotificationContentData?
                    
                    if notificationContentSource == .API_FETCHED {
                        notificationData = fetchNotificationData
                    } else {
                        notificationData = status == "CONNECTED" ? defaultNotificationEnterData : defaultNotificationExitData
                    }
                    
                    guard let notificationData = notificationData else {
                        return
                    }
                    
                    if (status == "CONNECTED" && showNotificationOnEntry) || (status == "DISCONNECTED" && showNotificationOnExit) {
                        self.showNotification(notificationData: notificationData,status: status,beaconRegionIdentifier: regionIdentifier,notificationInterval: notificationInterval)
                    }
                } catch {
                    print("Decoding error: \(error)")
                    if let raw = String(data: data, encoding: .utf8) {
                        print("❗Raw response string:\n\(raw)")
                    }
                }
            }
            task.resume()
        }
    }
    
    private func showNotification(notificationData: NotificationContentData,status: String,beaconRegionIdentifier: String?,notificationInterval: Int) {
        guard let beaconRegionIdentifier = beaconRegionIdentifier else { return }
        let defaultKey = beaconRegionIdentifier+status
        let userDefaults = UserDefaults.standard
        
        if userDefaults.object(forKey: defaultKey) == nil{
            userDefaults.set(Date().timeIntervalSince1970, forKey: defaultKey)
            showNotificationNow(notificationData: notificationData)
        }else{
            let currentTimeInterval = Date().timeIntervalSince1970
            let lastTimeInterval = userDefaults.double(forKey: defaultKey)

            if currentTimeInterval - lastTimeInterval >= TimeInterval(notificationInterval*60){
                userDefaults.set(currentTimeInterval, forKey: defaultKey)
                showNotificationNow(notificationData: notificationData)
            }
        }
    }
    
    private func showNotificationNow(notificationData: NotificationContentData){
        let content = UNMutableNotificationContent()
        content.title = notificationData.title ?? "Default Title"
        content.body = notificationData.body ?? "Default Body"
        content.userInfo = ["deepLink": notificationData.deepLink ?? ""]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "ibeaconLocalINAppNotification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func requestNotificationPermissionWithCallback() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Permission hasn't been asked yet, so request it
                NotificationCenter.default
                    .post(name: .notificationPermission, object: nil)
                
                NotificationCenter.default.addObserver(forName: .notificationPermissionChanged, object: nil, queue: .main) { data in
                    let error = data.userInfo?["error"] as? (any Error)
                    let granted = data.userInfo?["granted"] as? Bool ?? false
                    
                    if error == nil{
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                    if granted == true {
                        self.sendBeaconCallback(isSuccess: true, status: "BEACON_INITIALIZED")
                    }
                    else if granted == false{
                        self.sendBeaconCallback(isSuccess: true, status: "NOTIFICATION_PERMISSION_DENIED")
                    }
                }

            case .denied:
                // Permission was already denied
                self.sendBeaconCallback(isSuccess: true, status: "NOTIFICATION_PERMISSION_DENIED")

            case .authorized, .provisional, .ephemeral:
                // Already authorized (or limited auth); just register
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                self.sendBeaconCallback(isSuccess: true, status: "BEACON_INITIALIZED")

            @unknown default:
                self.sendBeaconCallback(isSuccess: false, status: "UNKNOWN_PERMISSION_STATUS")
            }
        }
    }

    
    func sendBeaconCallback(isSuccess: Bool, status: String){
        let data = ["type": "initBeaconData","isSuccess": isSuccess, "response": status] as [String : Any]
        WebToNativeCore.sendDataToWebView(data: data as [String: Any])
    }
}

// MARK: - Beacon Data Structure
struct BeaconData: Codable{
    public let beaconConfig: [BeaconConfigData?]?
    public let userInfo: String?
}

struct BeaconConfigData: Codable {
    let uuid: String?
    let major: Int?
    let minor: Int?
    let settings: SettingsData?
    let webhookUrl: String?
}

struct SettingsData: Codable {
    let showNotificationOnEntry: Bool?
    let showNotificationOnExit: Bool?
    let notificationInterval: Int?
    let notificationContentSource: NotificationContentSource?
    let defaultNotificationEnterData: NotificationContentData?
    let defaultNotificationExitData: NotificationContentData?
}

enum NotificationContentSource: String, Codable {
    case PRE_DEFINED = "PRE_DEFINED"
    case API_FETCHED = "API_FETCHED"
}

struct NotificationContentData: Codable {
    let title: String?
    let image: String?
    let body: String?
    let deepLink: String?
}

