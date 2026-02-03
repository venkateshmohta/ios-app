//
//  AdMobHandler.swift
//  WebToNative
//
//  Created by Akash Kamati on 31/05/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation
import WebToNativeCore

/**
 A singleton class responsible for handling AdMob ads in the application.

 The `AdMobHandler` class provides functionality to load and display ads based on the provided URL. It matches the URL against a predefined set of ad data and displays the corresponding ad if a match is found. It also manages hiding and showing banner ads as needed.
 */
class AdMobHandler{
    
    /// Shared instance of `AdMobHandler` for singleton usage.
    public static let shared = AdMobHandler()
    
    /// Array of ad data configurations.
    private let adMobData = WebToNativeConfig.sharedConfig?.admobAds?.data ?? []
    
    /**
       Loads an ad based on the provided URL and bottom bar visibility.
       
       - Parameters:
          - url: The URL to match against the ad data.
          - isBottomBarVisible: A boolean indicating whether the bottom bar is visible.
       */
    func loadAd(url:String,isBottomBarVisible:Bool){
        findMatchingAdDataAndDisplay(inputString: url,isBottomBarVisible: isBottomBarVisible)
    }
    
    /**
       Finds matching ad data based on the provided URL.
       
       - Parameter url: The URL to match against the ad data.
       - Returns: An optional `AdMobData` object if a match is found, or `nil` otherwise.
       */
    func getMatchingData(url:String) -> AdMobData?{
        var result:AdMobData? = nil
        if WebToNativeConfig.sharedConfig?.enableAdMob ?? false{
            for data in adMobData {
                if let regexPattern = data.regex, let regex = try? NSRegularExpression(pattern: regexPattern) {
                    if let _ = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)) {
                        //match found continue..
                        result = data
                    }
                }
            }
        }
        return result
            
    }

    /**
      Finds matching ad data and displays the corresponding ad.
      
      - Parameters:
         - inputString: The input string to match against the ad data.
         - isBottomBarVisible: A boolean indicating whether the bottom bar is visible.
      */
    private func findMatchingAdDataAndDisplay(inputString: String,isBottomBarVisible:Bool=false) {
        hideBannerAdIfVisible()
        if let data = getMatchingData(url: inputString){
            displayMatchingAd(adData: data,isBottomBarVisible:isBottomBarVisible)
        }
     }


    /**
        Hides the currently visible banner ad, if any.
        */
    private func hideBannerAdIfVisible(){
        NotificationCenter.default.post(name: Notification.Name("LOAD_ADS"), object: nil, userInfo: ["action": "hide"])
    }
    
    /**
     Displays the matching ad based on the provided ad data and bottom bar visibility.
     
     - Parameters:
        - adData: The ad data to display.
        - isBottomBarVisible: A boolean indicating whether the bottom bar is visible.
     */
    private func displayMatchingAd(adData:AdMobData,isBottomBarVisible:Bool=false){
        let task = DispatchWorkItem {
            let adType = adData.adType
            if adType != nil{
                let adPosition : AdPosition = adData.position ?? .bottom
                NotificationCenter.default.post(name: Notification.Name("LOAD_ADS"), object: nil, userInfo: ["action": "show","type":adType!,"adId":adData.adId ?? "","position":adPosition,"isBottomBarVisible":isBottomBarVisible])
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(adData.initialShowDelay ?? 0), execute: task)
    }
}
