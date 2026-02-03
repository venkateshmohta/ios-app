//
//  DocumentManager.swift
//  WebToNative
//
//  Created by WebToNative on 22/04/21.
//  Copyright © 2021 WebToNative. All rights reserved.
//

import UIKit
import WebToNativeCore
import WebKit

/**
 A utility class responsible for managing document-related tasks such as downloading files and obtaining cookies.

 */
class DocumentManager {
    
    /**
       Retrieves cookies for a specific domain.
       
       - Parameters:
          - domain: The domain for which to retrieve cookies. If `nil`, cookies for all domains will be retrieved.
          - completion: A closure to be called when the operation completes, providing the cookie header string.
       
       */
    func getCookies(for domain: String? = nil, completion: @escaping (String?)->())  {
        let httpCookieStore = WKWebsiteDataStore.default().httpCookieStore
        var cookieArr:[HTTPCookie] = []
        httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                if let domain = domain {
                    if cookie.domain.contains(domain) {
                        cookieArr.append(cookie as HTTPCookie)
                    }
                } else {
                    cookieArr.append(cookie as HTTPCookie)
                }
            }
                        
            
            let headerFields = HTTPCookie.requestHeaderFields(with: cookieArr)
            let cookieHeader = headerFields["Cookie"]
            completion(cookieHeader)
        }
    }
    
    /**
        Downloads a file from the provided URL.
        
        - Parameters:
           - fileUrl: The URL of the file to download.
           - controller: The view controller from which the download is initiated.
        
        */
    func downloadFile(fileUrl: String,text:String? = nil){
        guard let controller = WebToNativeCore.viewController else{
            return
        }
        var url = NSURL(string: fileUrl)! as URL;
        
        if url.absoluteString.contains("wtn-download-file=true"){
          url =  URL(string :url.absoluteString.replacingOccurrences(of: "?wtn-download-file=true", with: "")) ??  URL(
              string: fileUrl
          )!
          url =  URL(string :url.absoluteString.replacingOccurrences(of: "&wtn-download-file=true", with: "")) ??  URL(string: fileUrl)!
      }

        
        getCookies(for: url.host) { cookieHeader in
            let req = NSMutableURLRequest(url: url)
            if(cookieHeader != nil){
                req.addValue(cookieHeader ?? "", forHTTPHeaderField: "Cookie")
            }
            let session = URLSession.shared;
            let downloadTask = session.downloadTask(with: req as URLRequest) { location, response,error in
                let httpResponse = response as? HTTPURLResponse
                if((error != nil) || httpResponse?.statusCode != 200 || (location == nil)){
                    return
                }
                let fileManager = FileManager.default
                
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

                let documentsDirectoryPath = NSURL(fileURLWithPath:documentsPath)
                let destination = documentsDirectoryPath.appendingPathComponent(response!.suggestedFilename!)
                try? fileManager.removeItem(at: destination!)
                try? fileManager.moveItem(at: location!, to: destination!)
                DispatchQueue.main.async {
                    var activityItems: [Any] {
                                            var items : [Any] = [destination!]
                                            if text != nil {
                                                items.append(text!)
                                            }
                                            return items
                                        }
                    let avc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    if let popoverController = avc.popoverPresentationController {
                        popoverController.sourceView = controller.view
                        popoverController.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }
                    controller.present(avc, animated: true, completion: nil)
                }
                
            }
            
            downloadTask.resume()
        }
    }
}
