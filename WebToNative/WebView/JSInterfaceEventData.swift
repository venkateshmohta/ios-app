//
//  JSInterfaceEventData.swift
//  WebToNative
//
//  Created by Akash Kamati on 14/06/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation

/**
 Struct representing data associated with a JavaScript interface event.
 
 This struct encapsulates the payload data received from JavaScript events for native code handling.
 */
public struct JSInterfaceEventData: Equatable {
    /**
     Compares two `JSInterfaceEventData` instances for equality.
     
     - Parameters:
     - lhs: The left-hand side `JSInterfaceEventData` to compare.
     - rhs: The right-hand side `JSInterfaceEventData` to compare.
     - Returns: `true` if both instances have the same content in their `data` dictionaries; otherwise, `false`.
     */
    public static func == (lhs: JSInterfaceEventData, rhs: JSInterfaceEventData) -> Bool {
        return NSDictionary(dictionary: lhs.data).isEqual(to: rhs.data)
    }
    
    /// Data dictionary containing information associated with the JavaScript event.
    let data: [String: AnyObject]
}
