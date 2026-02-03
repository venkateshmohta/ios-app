//
//  Extensions.swift
//  
//
//  Created by Himanshu Khantwal on 31/10/22.
//

import Foundation

extension String {
    /**
     Removes the first and last 4 characters from the string.

     This method is intended to remove markup around a contact label.

     - Returns: A new string with the first and last 4 characters removed.
     */
    public func removeMarkUpAroundContactLabel() -> String {
        var newString = self
        newString = String(newString.dropFirst(4))
        newString = String(newString.dropLast(4))
        return newString
    }

    /**
     Escapes the string for JSON encoding.

     This computed property encodes the string as JSON, and then removes the leading and trailing quotes.

     - Returns: A JSON-escaped string without leading and trailing quotes, or the original string if encoding fails.
     */
    public var escaped: String {
        if let data = try? JSONEncoder().encode(self) {
            let escaped = String(data: data, encoding: .utf8)!
            // Remove leading and trailing quotes
            let set = CharacterSet(charactersIn: "\"")
            return escaped.trimmingCharacters(in: set)
        }
        return self
    }
}

extension Notification.Name {
    /// Notification for opening a URL.
    public static let openUrl = Notification.Name("openUrl")

    /// Notification for web-to-native interface calls.
    public static let webToNativeInterface = Notification.Name("webToNativeInterface")

    /// Notification for application delegate events.
    public static let applicationDelegates = Notification.Name("applicationDelegates")
    
    /// Notification for displaying ad through swiftui wrapper after ads is loaded
    public static let displayBannerAd = Notification.Name("displayBannerAd")
    
    /// Notification for showing dismiss button on top of banner
    public static let showBannerDismissBtn = Notification.Name("showBannerDismissBtn")
    
    /// Notification for webviewNavigation
    public static let onWebViewNavigation = Notification.Name("onWebViewNavigation")
        /// Notification for webviewNavigation
    public static let onWebViewRefresh = Notification.Name("onWebViewRefresh")
    /// Notification for contactsPermissionChanged
    public static let contactsPermissionChanged = Notification.Name("contactsPermissionChanged")
    /// Notification for bluetoothPermissionChanged
    public static let bluetoothPermissionChanged = Notification.Name("bluetoothPermissionChanged")
    /// Notification for beacon always allow location permission
    public static let beaconPermissionChanged = Notification.Name("beaconPermissionChanged")
    /// Notification for Notification Permission Asked
    public static let notificationPermission = Notification.Name("requestNotificationPermission")
    /// Notification for Notification Permission Changed
    public static let notificationPermissionChanged = Notification.Name("notificationPermissionChanged")
    /// Notification For Requesting Biometric From Module
    public static let biometricRequested = Notification.Name("biometricRequested")
    /// Notification For Getting Data Back from the Biometric Module
    public static let biometricAuthenticated = Notification.Name("biometricAuthenticated")
    /// Notification for Showing Blur View When Biometric Requested.
    public static let biometricBlurViewShown = Notification.Name("biometricBlurViewShown")
    /// Notification for passcode after Interval
    public static let passcodeAfterInterval = Notification.Name("passcodeAfterInterval")
    /// Refresh Main Screen components
    public static let mainScreenPreviewHandler = Notification.Name("mainScreenPreviewHandler")
    public static let switchScreenView = Notification.Name("switchScreenView")
    public static let updateLoadingIndicator = Notification.Name("updateLoadingIndicator")
    public static let webToNativeApp = Notification.Name("webToNativeApp")
    public static let livePreviewDataUpdated = Notification.Name("livePreviewDataUpdated")


}


