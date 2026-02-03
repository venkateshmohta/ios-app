//
//  AddOnStatus.swift
//  WebToNative
//
//  Created by Akash Kamati on 17/07/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import WebToNativeCore

/// Represents the available add-on feature names used in the application.
///
/// Each case corresponds to a specific add-on that can be enabled or disabled
/// based on the app configuration.
enum AddOnName:String{

    case ONESIGNAL = "ONESIGNAL"
    case FIREBASE_NOTIFICATION = "FIREBASE_NOTIFICATION"
    case FIREBASE_ANALYTICS = "FIREBASE_ANALYTICS"
    case IN_APP_PURCHASE = "IN_APP_PURCHASE"
    case BARCODE_SCANNING = "BARCODE_SCANNING"
    case BACKGROUND_LOCATION = "BACKGROUND_LOCATION"
    case BIOMETRIC_AUTHENTICATION = "BIOMETRIC_AUTHENTICATION"
    case HAPTIC_FEEDBACK = "HAPTIC_FEEDBACK"
    case OFFER_CARD = "OFFER_CARD"
    case CALENDER = "CALENDER"
    case APPSFLYER = "APPSFLYER"
    case NATIVE_CONTACTS = "NATIVE_CONTACTS"
    case IN_APP_REVIEW = "IN_APP_REVIEW"
    case FACEBOOK_APP_EVENTS = "FACEBOOK_APP_EVENTS"
    case ONBOARDING_SCREEN = "ONBOARDING_SCREEN"
    case FLOATING_BUTTON = "FLOATING_BUTTON"
    case APP_SHORTCUTS = "APP_SHORTCUTS"
    case SECONDARY_NAVIGATION = "SECONDARY_NAVIGATION"
    case BOTTOM_NAVIGATION = "BOTTOM_NAVIGATION"
    case SOCIAL_LOGIN = "SOCIAL_LOGIN"

}


/// Checks the status of a specified add-on based on the current application configuration. send add-on status to webView
///
/// - Parameter addOnName: An optional `String` representing the name of the add-on.
///                        If `nil` or unrecognized, the status defaults to "inactive".
///
/// - Note: The function evaluates conditions from `WebToNativeConfig.sharedConfig`
///         to determine if the add-on is "active" or "inactive".
func getAddOnStatus(addOnName: String?) {
    let appConfig = WebToNativeConfig.sharedConfig
    var status = "inactive"
    
    if let addOnName = addOnName, let addOn = AddOnName(rawValue: addOnName) {
        let addOnConditions: [AddOnName: Bool] = [
            .ONESIGNAL: !(appConfig?.oneSignalId?.isEmpty ?? true),
            .FIREBASE_NOTIFICATION: appConfig?.FIREBASE_NOTIFICATION?.data?.enable == true,
            .FIREBASE_ANALYTICS: appConfig?.FIREBASE_ANALYTICS?.data?.enable == true,
            .IN_APP_PURCHASE: appConfig?.IN_APP_PURCHASE?.data?.enable == true,
            .BARCODE_SCANNING: appConfig?.barcodeScan?.data?.enable == true,
            .BACKGROUND_LOCATION: appConfig?.BACKGROUND_LOCATION?.data?.enable == true,
            .HAPTIC_FEEDBACK: appConfig?.HAPTIC_FEEDBACK?.data?.enable == true,
            .BIOMETRIC_AUTHENTICATION: appConfig?.BIOMETRIC?.data?.enable == true,
            .OFFER_CARD: appConfig?.OFFER_CARD?.data?.enable == true,
            .CALENDER: true,
            .APPSFLYER: appConfig?.APPS_FLYER?.data?.enable == true,
            .NATIVE_CONTACTS: appConfig?.NATIVE_CONTACTS?.data?.enable == true,
            .IN_APP_REVIEW: appConfig?.enableInAppReview == true,
            .FACEBOOK_APP_EVENTS: appConfig?.FB_ANALYTICS?.data?.enable == true,
            .ONBOARDING_SCREEN: !(appConfig?.ONBOARDING_SCREEN?.data?.pages?.isEmpty ?? true),
            .FLOATING_BUTTON: !(appConfig?.floatingButton?.data?.isEmpty ?? true),
            .APP_SHORTCUTS: !(appConfig?.APP_SHORTCUTS?.data?.isEmpty ?? true),
            .SECONDARY_NAVIGATION: !(appConfig?.SECONDARY_NAVIGATION?.data?.menus?.isEmpty ?? true),
            .BOTTOM_NAVIGATION: appConfig?.bottomNavigation?.data?.isEmpty ?? true,
            .SOCIAL_LOGIN: appConfig?.SOCIAL_LOGIN?.data?.enable == true
        ]
        
        if addOnConditions[addOn] == true {
            status = "active"
        }
    }
    
    let data = ["addOnName": addOnName, "status": status]
    WebToNativeCore.sendDataToWebView(data: data as [String: Any])
}
