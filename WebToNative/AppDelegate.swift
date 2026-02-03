import WebToNativeCore
import WebToNativeBiometric
import WebToNativeFBSDK
import WebToNativeAppsFlyer
import WebToNativeGoogleSignIn
import WebToNativeAdMob
import WebToNativeFirebase
import WebToNativeBarcode
import WebToNativeIcons
import WebToNativeCalender
import WebToNativeHapticEffect
import WebToNativeLocationManager
import WebToNativeContactManager
import WebToNativeAppleSignIn
import WebToNativeIAPManager
import WebToNativeLocalSettings
import WebToNativeUpdateAppPopup
import WebToNativeOneSignal
import CoreData
import WebToNativeOrufyConnectSDK
import WebToNativeIntercom
import WebToNativeStripePayment
import WebToNativeMediaPlayer
import CoreLocation
import WebToNativeSiri
import WebToNativeNativeStorage
import WebToNativeRevenueCat
import WebToNativeLivePreview


/**
 The `AppDelegate` class is the central point of control and coordination for apps running in iOS. It manages the app's lifecycle events and coordinates app-wide behaviors such as handling notifications and app configuration.

 - Properties:
   - window: The main window of the app.
   - orientationLock: A static property that controls the supported interface orientations.
   - notificationService: A lazy-initialized property that provides access to the `CoreDataNotificationService`.
   - appConfig: A variable that holds the app configuration data.

 - Methods:
   - application(_:didFinishLaunchingWithOptions:): Sets up the app configuration and initializes various services when the app finishes launching.
   - application(_:supportedInterfaceOrientationsFor:): Returns the supported interface orientations for the app.
   - application(_:performActionFor:completionHandler:): Handles quick actions (shortcut items) invoked by the user.
   - application(_:configurationForConnecting:options:): Configures a new scene session.
   - application(_:open:options:): Handles opening of URLs.
   - application(_:continue:restorationHandler:): Handles user activities such as Handoff and Universal Links.
   - application(_:didRegisterForRemoteNotificationsWithDeviceToken:): Handles successful registration for remote notifications.
   - application(_:didFailToRegisterForRemoteNotificationsWithError:): Handles failure to register for remote notifications.
   - applicationWillResignActive(_:): Prepares the app to move from active to inactive state.
   - applicationDidEnterBackground(_:): Handles tasks when the app enters the background.
   - applicationWillEnterForeground(_:): Prepares the app to transition from the background to the active state.
   - applicationDidBecomeActive(_:): Restarts tasks that were paused or not yet started while the app was inactive.
   - applicationWillTerminate(_:): Handles tasks when the app is about to terminate.
   - userNotificationCenter(_:willPresent:withCompletionHandler:): Handles the presentation of notifications while the app is in the foreground.
   - userNotificationCenter(_:didReceive:withCompletionHandler:): Handles the response to notifications.

 */
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,CLLocationManagerDelegate {

    /// The window of the application.
    var window: UIWindow?
    let locationManager = CLLocationManager()
    let beaconClass = WebToNativeBeacon()
    let notificationClass = NotificationPermissionUtil()
    static var currentBeaconRegion:CLRegion? = nil

    /// Instance of orientation reference
    static var orientationLock = UIInterfaceOrientationMask.all
    
    /// Instance of notification service `CoreDataNotificationService`
    lazy var notificationService:CoreDataNotificationService = {
        CoreDataNotificationService(coreDataManager: CoreDataManager(modelName: "WebToNative"))
    }()
    
    /// The configuration data for the WebToNative module.
    var appConfig: WebToNativeConfigData?;

  
    /// Method called when the application finishes launching.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        locationManager.delegate = self
        WebToNativeConfig.shared.loadAppConfig()
        appConfig = WebToNativeConfig.sharedConfig
        

        if let notificationOnLaunch = appConfig?.notificationPermissionOnLaunch, notificationOnLaunch.enable != false && (
            notificationOnLaunch.url == nil || notificationOnLaunch.url == ""
        ) && !(appConfig?.oneSignalSoftPrompt ?? false)  {
            // request for notification permission
            NotificationCenter.default
                .post(name: .notificationPermission, object: nil)
            
            NotificationCenter.default.addObserver(forName: .notificationPermissionChanged, object: nil, queue: .main) { data in
                let error = data.userInfo?["error"] as? (any Error)
                let granted = data.userInfo?["granted"] as? Bool
                if granted ?? false {
                    return;
                }
            }

            application.registerForRemoteNotifications()
        }
        
        let _ = WebToNativeBiometric.shared
        let _ = WebToNativeFBSDK()
        let _ = WebToNativeAppsFlyer()
        let _ = WebToNativeGoogleSignIn()
        let _ = WebToNativeAdMob()
        let _ = WebToNativeCalender()
        let _ = WebToNativeFirebase()
        let _ = WebToNativeBarcode()
        let _ = WebToNativeHapticEffect()
        let _ = WebToNativeLocationManager()
        let _ = WebToNativeContactManager()
        let _ = WebToNativeAppleSignIn()
        let _ = WebToNativeIAPManager()
        let _ = WebToNativeLocalSettings()
        let _ = WebToNativeUpdateAppPopup()
        let _ = WebToNativeOneSignal()
        let _ = WebToNativeOrufyConnectSDK()
        let _ = WebToNativeIntercom()
        let _ = WebToNativeStripePayment()
        let _ = WebToNativeMediaPlayer()
        let _ = WebToNativeSiri()
        let _ = WebToNativeNativeStorage()
        let _ = WebToNativeLivePreview()
        let _ = WebToNativeRevenueCat()

        
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        WebToNativeCore.locationManager = locationManager
        WebToNativeCore.application = application
        WebToNativeCore.launchOptions = launchOptions
        WebToNativeCore.notifyApplicationDelegates(event: WebToNativeCore.ApplicationDelegatesEvent.applicationDidFinishLaunchingWithOptions)
        
        setupAppShortCut(application, launchOptions: launchOptions)
        
        // Override point for customization after application launch.
        return true
    }
    
    /**
       Determines the supported interface orientations for the app's windows.
       
       - Parameter application: The singleton app object.
       - Parameter window: The app's main window, or a window that belongs to the app.
       - Returns: A mask of the interface orientations supported by the app.
       */
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        let orientation = WebToNativeConfig.sharedConfig?.screenOrientation
        AppDelegate.orientationLock = getDefaultScreenOrientation(orientation: orientation)
        return WebToNativeCore.isLivePreviewVisible ? .all : AppDelegate.orientationLock
    }
    
    /**
       Tells the delegate that the user's action generated a specific shortcut action from the home screen quick actions menu.
       
       - Parameter application: The singleton app object.
       - Parameter shortcutItem: The shortcut item that the user selected.
       - Parameter completionHandler: The handler to call when you finish processing the shortcut item. You must call this handler as soon as you finish processing the shortcut item. Failure to execute this handler delays the future presentation of your shortcuts.
       */
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortCutItem = handleShortCutItem(shortcutItem)
        completionHandler(handledShortCutItem)
    }
    
    /**
       Asks the delegate for the configuration to use when creating a new scene session.
       
       - Parameter application: The application requesting the scene configuration.
       - Parameter connectingSceneSession: The new scene session being created.
       - Parameter options: The options that describe how to configure the new scene.
       
       - Returns: The configuration object that provides the initial state for the scene session.
       */
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
           if let shortcutItem = options.shortcutItem {
               let _ = handleShortCutItem(shortcutItem)
           }

           let sceneConfiguration = UISceneConfiguration(name: "Custom Configuration", sessionRole: connectingSceneSession.role)
           sceneConfiguration.delegateClass = SceneDelegate.self

           return sceneConfiguration
       }


    /**
     Tells the delegate that the app received a continue user activity request.
     
     - Parameter application: The singleton app object.
     - Parameter userActivity: The user activity object containing the details of the activity.
     - Parameter restorationHandler: A handler block to call if the app restores the state asynchronously. Pass an array of objects to be restored when the app is ready.
     
     - Returns: `true` if the app successfully handled the user activity; otherwise, `false`.
     */
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            WebToNativeCore.notifyOpenUrl(openUrl: url.absoluteString)
        }
        return true
    }
    
    /**
     Tells the delegate that the app successfully registered for remote notifications.
     
     - Parameter application: The singleton app object.
     - Parameter deviceToken: A token that identifies the device to APNs (Apple Push Notification service).
     */
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        WebToNativeCore.deviceToken = deviceToken
        let event: WebToNativeCore.ApplicationDelegatesEvent = .applicationDidRegisterForRemoteNotificationsWithDeviceToken
        WebToNativeCore.notifyApplicationDelegates(event: event)
        
    }
    
    /**
        Tells the delegate that the app failed to register for remote notifications.
        
        - Parameter application: The singleton app object.
        - Parameter error: An error object containing the reason registration failed.
        */
    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        let event: WebToNativeCore.ApplicationDelegatesEvent = .applicationDidFailToRegisterForRemoteNotificationsWithError
        WebToNativeCore.notifyApplicationDelegates(event: event)
    }
    
    /**
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
     */
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    /** Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    /// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    /// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    func applicationDidBecomeActive(_ application: UIApplication) {
        let event: WebToNativeCore.ApplicationDelegatesEvent = .applicationDidBecomeActive
        WebToNativeCore.notifyApplicationDelegates(event: event)
    }
    
    /// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    /**
      Tells the delegate that a notification is about to be presented to the user.
      
      - Parameter center: The notification center that received the notification.
      - Parameter notification: The notification object that is about to be presented.
      - Parameter completionHandler: The block to execute with the presentation options for the notification. Use this block to specify how to handle the notification.
     
     -Note: Notification Handling in Foreground
            -> First priority is disableNotificationInForeground if it is true, then notification banner will not be shown in foreground and data will be send to the user in JSON, user has to implement wtnGetForegroundNotificationData(data) JS function ,here data is our JSON data
            -> If disableNotificationInForeground is false or nil , then we will check hideForegroundNotificationBanner
            -> If hideForegroundNotificationBanner is true, then banner will not be shown in foreground, it wil appear in Notification Center
            -> if hideForegroundNotificationBanner is false or nil, then notification banner will be shown to the user in foreground
      */
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        ///checking whether to send notification data or not, if true data will be send and banner will not be shown
        if WebToNativeConfig.sharedConfig!.disableNotificationInForeground ?? false {
            ///serializing notification data and calling the js function with that data
            let rawData: Any
            if notification.request.identifier == "ibeaconLocalINAppNotification" {
                rawData = [
                    "title": notification.request.content.title,
                    "body": notification.request.content.body,
                    "userInfo": notification.request.content.userInfo,
                    "type": "beacon"
                ]
            } else {
                rawData = notification.request.content.userInfo
            }


            guard let jsonData = try? JSONSerialization.data(withJSONObject: rawData, options: []),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                print("Failed to serialize or encode userInfo")
                return
            }
            let jsFunction = "wtnGetForegroundNotificationData('\(jsonString)')"
            WebToNativeCore.webView.evaluateJavaScript(jsFunction){ (result, error) in
                if let error = error {
                    print("Error calling JavaScript function: \(error.localizedDescription)")
                } else {
                    print("JavaScript function called successfully, result: \(String(describing: result))")
                }
            }
            completionHandler([])
        }else {
            ///checking whether to show notification banner or not
            if WebToNativeConfig.sharedConfig!.hideForegroundNotificationBanner ?? false {
                completionHandler([.list,.sound,.badge])
            }else{
                completionHandler([.banner,.sound,.badge])
            }
        }
    }
    
    /**
        Tells the delegate that the user responded to a notification by opening it, dismissing it, or choosing a custom action.
        
        - Parameter center: The notification center that received the notification.
        - Parameter response: The user’s response to the notification.
        - Parameter completionHandler: The block to execute after the user's response has been handled by the app.
        */
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let payload = response.notification.request.content
        let userInfo = payload.userInfo
        let imageObj = userInfo["fcm_options"] as? [String:Any]
        var imageUrl = imageObj?["image"] as? String ?? ""
        if imageUrl.isEmpty{
            // for onesignal image url
            imageUrl = (userInfo["att"] as? [String:Any])?["id"] as? String ?? ""
        }
        
        var deepLink = userInfo["deepLink"] as? String ?? ""
        if deepLink.isEmpty{
            // for onesignal launch url
            deepLink = (userInfo["custom"] as? [String:Any])?["u"] as? String ?? ""
        }
        let fromConnect = userInfo["fromConnect"] as? Bool ?? false

        WebToNativeCore.unNotificationResponse = response
        WebToNativeCore.notifyApplicationDelegates(event: WebToNativeCore.ApplicationDelegatesEvent.userNotificationCenter)
        
        notificationService.insertNotification(NotificationData(id: UUID(), title: payload.title, body: payload.body, isRead: false, imageUrl: imageUrl, deepLink: deepLink, date: Date()))
        
        switch response.actionIdentifier {
            case UNNotificationDismissActionIdentifier:
                print("Dismiss Action")
            case UNNotificationDefaultActionIdentifier:
            if(!deepLink.isEmpty && !fromConnect){
                    WebToNativeCore.notifyOpenUrl(openUrl: deepLink)
                }
                print("Open Action")
            case "Snooze":
                print("Snooze")
            case "Delete":
                print("Delete")
            default:
                print("default")
        }
        completionHandler()
    }
  /**
        Beacon Functions Starts
   */
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        beaconClass.handleNotification(region: region,status: "CONNECTED")
        AppDelegate.currentBeaconRegion = region
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        beaconClass.handleNotification(region: region,status: "DISCONNECTED")
        AppDelegate.currentBeaconRegion = region
    }

    public func locationManager(_ manager: CLLocationManager,
                         didStartMonitoringFor region: CLRegion) {
      manager.requestState(for: region)
    }

    public func locationManager(_ manager: CLLocationManager,
                         didDetermineState state: CLRegionState,
                         for region: CLRegion) {
      if state == .inside {
          print("Device is already inside the monitored region.")
          if AppDelegate.currentBeaconRegion == nil{
              AppDelegate.currentBeaconRegion = region
          } else if AppDelegate.currentBeaconRegion != region{
              beaconClass.handleNotification(region: region,status: "CONNECTED")
              AppDelegate.currentBeaconRegion = region
          }
      } else {
          print("Device is outside the monitored region.")
          if AppDelegate.currentBeaconRegion == nil{
              AppDelegate.currentBeaconRegion = region
          } else if AppDelegate.currentBeaconRegion != region{
              beaconClass.handleNotification(region: region,status: "DISCONNECTED")
              AppDelegate.currentBeaconRegion = region
          }
      }
    }
    /**
        Beacon Functions Ends
     */


    public func blurView(show:Bool) {
        if show {
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                blurEffectView.frame = window.bounds
                blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                window.addSubview(blurEffectView)
                blurEffectView.tag = 99
            }
        } else {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let blurView = window.viewWithTag(99) {
                blurView.removeFromSuperview()
            }
        }
    }
}
