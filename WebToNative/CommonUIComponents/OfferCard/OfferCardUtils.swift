//
//  Utils.swift
//  WebToNative
//
//  Created by Akash Kamati on 14/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation

/**
 Calculates and returns the size of an offer card based on specified parameters.

 The `getOfferCardSize` function computes the dimensions of an offer card based on its original size, screen dimensions, and desired size type (`OfferCardSize`).
 */
func getOfferCardSize(originalSize:CGSize, screenHeight:CGFloat, screenWidth:CGFloat, size:OfferCardSize) -> CGSize{

    var width:CGFloat = 0
    var height:CGFloat = 0
    
    if(size == .small || size == .fullWidth){
        
        //landscape
        if screenHeight > screenWidth{
            
            width = size == .small ? screenWidth * 0.5 : screenWidth
            height = (originalSize.height/originalSize.width)*width
            
            if(height > screenHeight * 0.5){
                height = screenHeight * 0.5
                width = (originalSize.width/originalSize.height)*height
            }
            
            else if(height < screenHeight * 0.20){
                height = screenHeight * 0.20
                width = (originalSize.width/originalSize.height)*height
            }
        } 
        // portrait
        else{
            
            height = screenHeight/2
            width = (originalSize.width/originalSize.height)*height
            
            if width > screenWidth * 0.50 && size == .small{
                width = screenWidth * 0.50
                height = (originalSize.height/originalSize.width)*width
            }
            
        }
    }
    
    else if(size == .fullScreen){
        if screenHeight > screenWidth{
            width = screenWidth
            height = (originalSize.height/originalSize.width)*width
            
            if height > screenHeight{
                height = screenHeight
                width = (originalSize.width/originalSize.height)*height
            }
        } else{
            height = screenHeight
            width = (originalSize.width/originalSize.height)*height
            
            if width > screenWidth{
                width = screenWidth
                height = (originalSize.height/originalSize.width)*width
            }
        }
    }
    
    return CGSize(width: width, height: height)
}


func checkOfferCardScheduled(config: OfferCardConfig) -> Bool{
    if config.schedule == nil || config.schedule?.duration == nil || config.schedule?.unit == nil || config.id == nil {
        return true
    }
    else {
        let defaults = UserDefaults.standard
        let offerCardId = "offerCard\(config.id!)"
        
        if let storeTime = defaults.object(forKey: offerCardId){
            let currentTime = Date()
            let difference = Calendar.current.dateComponents([.day, .hour, .minute], from: storeTime as! Date, to: currentTime)
          
            if config.schedule?.unit == "days" && (config.schedule?.duration)! > difference.day ?? 0 {
                return false
            }
            else if config.schedule?.unit == "hours" && (config.schedule?.duration)! > difference.hour ?? 0{
                return false
            }
            else if config.schedule?.unit == "minutes" && (config.schedule?.duration)! > difference.minute ?? 0{
                return false
            }
            else {
                storeOfferCardTime(key: offerCardId)
                return true
            }
        }
        else {
            storeOfferCardTime(key: offerCardId)
            return true
        }
        
    }
}

func storeOfferCardTime(key: String){
    let defaults = UserDefaults.standard
    defaults.set(Date(), forKey: key)
}
