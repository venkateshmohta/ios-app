//
//  OfferCardConfig.swift
//  WebToNative
//
//  Created by Akash Kamati on 16/04/24.
//  Copyright © 2024 WebToNative. All rights reserved.
//

import Foundation

/**
 Configuration for an offer card, including action details, card appearance and schedule.

 - Parameters:
   - id: ID of the offer card; used for managing the schedule.
   - action: Details of the action associated with the offer card (`OfferCardAction`).
   - card: Configuration for the appearance and content of the card (`CardConfig`).
   - schedule: Schedule use for stop offer card visibility for particular duration

 This struct defines the structure and properties of an offer card, allowing customization of its action behavior and visual presentation.
 */
public struct OfferCardConfig:Decodable{
    let id: String?
    let action:OfferCardAction?
    let card:CardConfig?
    let schedule: OfferSchedule?
}

/**
 Represents the schedule for controlling the visibility of an offer card.

 - Parameters:
   - duration: The length of time to stop the visibility of the offer card.
   - unit: The unit of time for the duration, such as "days", "hours", or "minutes".

 This struct is used to define the time-based visibility schedule of an offer card.
 */
public struct OfferSchedule: Decodable{
    let duration: Int?
    let unit: String?
}

/**
 Details of an action associated with an offer card, including URL and button configuration.

 - Parameters:
   - url: URL to be loaded when the action associated with the card is triggered.
   - button: Configuration details for the action button (`OfferCardActionButton`).

 This struct defines the action that can be performed when interacting with the offer card.
 */
public struct OfferCardAction:Decodable{
    let url:String?
    let button:OfferCardActionButton?
}

/**
 Configuration details for an action button on an offer card.

 - Parameters:
   - url: URL to be loaded when the action button is clicked.
   - text: Text to be displayed on the action button.
   - textColor: Color of the text on the action button.
   - bgColor: Background color of the action button.

 This struct provides customization options for the appearance and behavior of the action button on an offer card.
 */
public struct OfferCardActionButton:Decodable{
    let url:String?
    var text:String?
    var textColor:String? = "#FFFFFF"
    var bgColor:String? = "#0000FF"
}

/**
 Configuration details for the appearance and content of an offer card.

 - Parameters:
   - size: Size of the offer card (`OfferCardSize`).
   - position: Position of the offer card on the screen (`OfferCardPosition`).
   - bgColor: Background color of the offer card.
   - content: Content to be displayed in the offer card (`OfferCardContent`).

 This struct defines how the offer card appears and where it is positioned on the screen, along with its background color and content.
 */
public struct CardConfig:Decodable{
    let size:OfferCardSize?
    var position:OfferCardPosition? = .right
    var bgColor:String? = "#111111"
    let content:OfferCardContent?
}

/**
 Content to be displayed within an offer card, specifying its type and associated URL.

 - Parameters:
   - type: Type of content to be displayed (`OfferCardContentType`).
   - url: URL pointing to the content to be displayed in the offer card.

 This struct defines the content that is shown inside an offer card, such as video or image content.
 */
public struct OfferCardContent:Decodable{
    let type: OfferCardContentType?
    let url:String?
}

/**
 Enumeration defining the type of content that can be displayed within an offer card.

 - Cases:
   - video: Video content.
   - image: Image content.

 This enum specifies the types of content that can be displayed within an offer card.
 */
public enum OfferCardContentType:String,Decodable{
    case video = "VIDEO"
    case image = "IMAGE"
}


/**
 Enumeration defining the position of an offer card on the screen.

 - Cases:
   - left: Left position.
   - right: Right position.

 This enum specifies where an offer card can be positioned on the screen.
 */
public enum OfferCardPosition:String,Decodable{
    case left = "LEFT"
    case right = "RIGHT"
}


/**
 Enumeration defining the size options for an offer card.

 - Cases:
   - fullScreen: Full-screen size.
   - fullWidth: Full-width size.
   - small: Small size.

 This enum specifies the different size options available for an offer card.
 */
public enum OfferCardSize:String,Decodable{
    case fullScreen = "FULL_SCREEN"
    case fullWidth = "FULL_WIDTH"
    case small = "SMALL"
}

/**
 Parses a JSON string into an `OfferCardConfig` object.

 - Parameters:
   - jsString: JSON string containing the configuration data for the offer card.

 - Returns: An `OfferCardConfig` object parsed from the JSON string, or `nil` if parsing fails.

 This function parses a JSON string representation of offer card configuration data into a structured `OfferCardConfig` object.
 */
public func getOfferCardConfig(jsString:String?)->OfferCardConfig?{
    if(jsString == nil) {return nil}
    guard let jsonData = jsString?.data(using: .utf8) else {
        return nil
    }
    do {
        return try JSONDecoder().decode(OfferCardConfig.self, from: jsonData)
    } catch {
        return nil
    }
}


