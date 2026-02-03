//
//  CookiesPersistence.swift
//  WebToNative
//
//  Created by yash saini on 10/12/25.
//  Copyright © 2025 WebToNative. All rights reserved.
//
import WebToNativeCore
import WebKit

/**
    Extend Cookies Expiry
 */
//func extendCookieExpiry(){
//    let data = WebToNativeConfig.sharedConfig?.cookiePersistence
//    if data?.days == nil || data?.days == "DEFAULT" || data?.domain?.isEmpty ?? true { return }
//    let cookieStore = WebToNativeCore.webView.configuration.websiteDataStore.httpCookieStore
//    
//    cookieStore.getAllCookies { cookies in
//        
//        for cookie in cookies {
//            // check current cookie exist before or not
//            let existed = WebToNativeConfig.runtimeTokens.cookies?
//                .contains(where: { $0?.name == cookie.name &&
//                    $0?.domain == cookie.domain &&
//                    $0?.path == cookie.path &&
//                    $0?.expiresDate == cookie.expiresDate
//                })
//            
//            
//            
//            if existed ?? false {
//                print("cookies123: cookie already existed \(cookie.name), expiry: \(cookie.expiresDate)")
//                continue
//            }
//            else {
//                print("cookies123: cookie not existed \(cookie.name), expiry: \(cookie.expiresDate)")
//            }
//            
//            // ---- NEW COOKIE FOUND ----
//
//            let days = Int(data?.days ?? "0")!
//            let expiryDate = Date().addingTimeInterval(TimeInterval(days * 24 * 60 * 60))
//
//            var newProps = cookie.properties ?? [:]
//            newProps[.expires] = expiryDate
//
//            if let updatedCookie = HTTPCookie(properties: newProps) {
//                // IMPORTANT: delete old cookie before adding
//                cookieStore.delete(cookie) {
//                    cookieStore.setCookie(updatedCookie) {
//                        print("🍪 Updated cookie \(cookie.name) expiry: \(cookie.expiresDate)")
//                    }
//                }
//            }
//        }
//        storeCookies()
//    }
//}

// Update all cookies on first App launch after 
func updateAllCookies(){
    let data = WebToNativeConfig.sharedConfig?.cookiePersistence
    if data?.days == nil || data?.days == "DEFAULT" || data?.domains?.isEmpty ?? true {
        UserDefaults.standard.set(data?.days, forKey: "extendCookieExpiry")
        return
    }
    
    let storeDays = UserDefaults.standard.string(forKey: "extendCookieExpiry")
    if storeDays == data?.days { return }
        
    let cookieStore = WebToNativeCore.webView.configuration.websiteDataStore.httpCookieStore

    cookieStore.getAllCookies { cookies in
        // Check if cookie existed before by name/domain/path ONLY
        for cookie in cookies {
            let domainExist = data?.domains?.contains(where: {$0?.domain == cookie.domain}) ?? false
            let nameExist = data?.domains?.contains(where: {$0?.keys?.contains(where: { $0 == cookie.name}) ?? false}) ?? false
            
            if !(domainExist && nameExist) { continue }
            
            let days = Int(data?.days ?? "0")!
            let expiryDate = Date().addingTimeInterval(TimeInterval(days * 24 * 60 * 60))

            var newProps = cookie.properties ?? [:]
            newProps[.expires] = expiryDate

            if let updatedCookie = HTTPCookie(properties: newProps) {
                // IMPORTANT: delete old cookie before adding
                cookieStore.delete(cookie) {
                    cookieStore.setCookie(updatedCookie)
                }
            }
        }
    }
    
    UserDefaults.standard.set(data?.days, forKey: "extendCookieExpiry")
}


//func storeCookies() {
//    let customCookiesExpiry = WebToNativeConfig.sharedConfig?.cookiePersistence
//    if customCookiesExpiry?.days == nil || customCookiesExpiry?.days == "DEFAULT" || customCookiesExpiry?.domain?.isEmpty ?? true { return }
//
//    let cookieStore = WebToNativeCore.webView.configuration.websiteDataStore.httpCookieStore
//    cookieStore.getAllCookies { cookies in
//        print("cookies123: mainScreen count: \(cookies.count)")
//        WebToNativeConfig.runtimeTokens.cookies = cookies
//    }
//}




func injectCookiesListener(){
    let customCookiesExpiry = WebToNativeConfig.sharedConfig?.cookiePersistence
    if customCookiesExpiry?.days == nil || customCookiesExpiry?.days == "DEFAULT" || customCookiesExpiry?.domains?.count ?? 0 ==  0 { return }

    
    let scriptSource = """
        (function() {
            // 1. Get the original cookie property descriptor
            // We check both Document and HTMLDocument prototypes to ensure compatibility
            var cookieDesc = Object.getOwnPropertyDescriptor(Document.prototype, 'cookie') ||
                             Object.getOwnPropertyDescriptor(HTMLDocument.prototype, 'cookie');
            
            var originalSet = cookieDesc ? cookieDesc.set : null;
            var originalGet = cookieDesc ? cookieDesc.get : null;

            // 2. Helper function to parse the cookie string into an object
            function parseCookieString(cookieStr) {
                var parts = cookieStr.split(';');
                
                // The first part is always name=value
                var pair = parts[0].trim();
                var sepIdx = pair.indexOf('=');
                
                var name = sepIdx > -1 ? pair.substring(0, sepIdx) : pair;
                var value = sepIdx > -1 ? pair.substring(sepIdx + 1) : '';

                // Initialize with Defaults
                // If the JS doesn't specify domain/path, the browser uses these defaults
                var cookieObj = {
                    name: name,
                    value: value,
                    domain: window.location.hostname, 
                    path: '/',
                    raw: cookieStr 
                };

                // Loop through attributes (path, domain, secure, etc.)
                for (var i = 1; i < parts.length; i++) {
                    var part = parts[i].trim();
                    var sep = part.indexOf('=');
                    var key, val;

                    if (sep > -1) {
                        key = part.substring(0, sep).toLowerCase();
                        val = part.substring(sep + 1);
                    } else {
                        key = part.toLowerCase();
                        val = true; // For attributes like 'secure' or 'httponly'
                    }

                    if (key === 'path') cookieObj.path = val;
                    if (key === 'domain') cookieObj.domain = val;
                    if (key === 'expires') cookieObj.expires = val;
                    if (key === 'secure') cookieObj.secure = true;
                }

                return cookieObj;
            }

            // 3. Override the cookie property
            Object.defineProperty(document, 'cookie', {
                get: function() {
                    return originalGet ? originalGet.call(document) : '';
                },
                set: function(val) {
                    try {
                        // Parse the raw string into a usable object
                        var parsedData = parseCookieString(val);

                        // Send the structured object to iOS
                        if (window.webkit && window.webkit.messageHandlers.webToNativeInterface) {
                            window.webkit.messageHandlers.webToNativeInterface.postMessage({
                                "action": "cookiesUpdate",
                                "data": parsedData
                            });
                        }
                    } catch (e) {
                        console.error("Cookie intercept error:", e);
                    }

                    // Important: Actually set the cookie in the browser
                    if (originalSet) {
                        originalSet.call(document, val);
                    }
                }
            });
        })();
        """
    
    let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    WebToNativeCore.webView.configuration.userContentController.addUserScript(userScript)
}


func extendCookieExpiry(newCookies: [String: AnyObject]){
    let data = WebToNativeConfig.sharedConfig?.cookiePersistence
    if data?.days == nil || data?.days == "DEFAULT" || data?.domains?.isEmpty ?? true { return }

    let cookieStore = WebToNativeCore.webView.configuration.websiteDataStore.httpCookieStore

    cookieStore.getAllCookies { cookies in
        print("cookies123: updated cookies count: \(cookies.count)")
        // Check if cookie existed before by name/domain/path ONLY
        
        //        var existed = false
        //        for cookie1 in cookies {
        //            print("existedCheck: name: \(cookie1.name), name2: \(newCookies["name"] as? String), domain: \(cookie1.domain), domain2: \(newCookies["domain"] as? String), path: \(cookie1.path) => \(cookie1.name == newCookies["name"] as? String), \(cookie1.domain ==  newCookies["domain"] as? String), \(cookie1.path ==  newCookies["path"] as? String)")
        //
        //
        //            if cookie1.name == newCookies["name"] as? String && cookie1.domain ==  newCookies["domain"] as? String && cookie1.path ==  newCookies["path"] as? String {
        //                existed = true
        //                break
        //            }
        //        }
        
        let domainExist = data?.domains?.contains(where: {$0?.domain == newCookies["domain"] as? String}) ?? false
        let nameExist = data?.domains?.contains(where: {$0?.keys?.contains(where: { $0 == newCookies["name"] as? String}) ?? false}) ?? false
        
        if !(domainExist && nameExist) { return }
        
        
        
        var existed = cookies
            .contains(where: { $0.name == newCookies["name"] as? String &&
                ($0.domain == newCookies["domain"] as? String || $0.domain == "." + (newCookies["domain"] as? String ?? "")) &&
                $0.path == newCookies["path"] as? String })
        
        
        if !existed {
            
            print("notExisted: name: \(newCookies["name"] as? String ?? ""), domain: \(newCookies["domain"] as? String ?? ""), path: \(newCookies["path"] as? String ?? ""), expiry: \(String(describing: newCookies["expires"] as? Date)) ")
            return
            
        }
        for cookie in cookies {

            let deletePreviousCookie = !existed
            
            if existed && cookie.name == newCookies["name"] as? String && (cookie.domain == newCookies["domain"] as? String || cookie.domain == "." + (newCookies["domain"] as? String ?? "")) && cookie.path == newCookies["path"] as? String{
                if cookie.expiresDate != newCookies["expires"] as? Date {
                    existed = false
                }
                else {
                    break
                    print("cookies78877: name: \(cookie.name), domain: \(cookie.domain), path: \(cookie.path), expiry: \(String(describing: cookie.expiresDate))")
                }
    
                print("cookies78899: name: \(cookie.name), domain: \(cookie.domain), path: \(cookie.path), expiry: \(String(describing: cookie.expiresDate))")
            }
            if existed {
                print("cookies123: cookie already existed \(cookie.name), expiry: \(cookie.expiresDate)")
                continue
            }

            // ---- NEW COOKIE FOUND ----
            print("newCookie123: \(cookie)")

            let days = Int(data?.days ?? "0")!
            let expiryDate = Date().addingTimeInterval(TimeInterval(days * 24 * 60 * 60))

            var newProps = cookie.properties ?? [:]
            newProps[.expires] = expiryDate

            print("8899: new expiry = \(expiryDate)")

            if let updatedCookie = HTTPCookie(properties: newProps) {

                if deletePreviousCookie {
                    // IMPORTANT: delete old cookie before adding
                    cookieStore.delete(cookie) {
                        cookieStore.setCookie(updatedCookie) {
                            print("🍪 Updated cookie \(cookie.name) expiry: \(cookie.expiresDate)")
                        }
                    }
                }
                else {
                    cookieStore.setCookie(updatedCookie) {
                        print("🍪 Updated cookie 2 \(cookie.name) expiry: \(String(describing: cookie.expiresDate))")
                    }
                }
            }
            break
        }
    }
}
