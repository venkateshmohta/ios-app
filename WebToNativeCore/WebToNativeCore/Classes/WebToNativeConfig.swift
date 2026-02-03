//
//  WebToNativeConfig.swift
//  
//
//  Created by Himanshu Khantwal on 23/10/22.
//

import Foundation

/**
 A structure to hold the configuration data for the WebToNative application. This structure is used to decode JSON configuration data and provide access to various settings and options for the application.
 */
public struct WebToNativeConfigData: Decodable {
    /// The URL to launch.
    public var websiteLink: String
    /// app name
    public var appName: String?
    /// Configuration for
    public var splash: Splash?
    /// Configuration for sticky footer.
    public var bottomNavigation: BottomNavigation?
    /// Configuration for Appsflyer.
    public var APPS_FLYER: Appsflyer?
    /// Configuration for biometric authentication.
    public var BIOMETRIC: Biometric?
    /// A flag indicating whether in-app purchases are enabled.
    public var IN_APP_PURCHASE: InAppPurchase?
    /// A flag indicating whether to open links in the same webview.
    public var openLinkInSameWebview: Bool?
    /// A flag indicating whether to enable Facebook App Events.
    public var FB_ANALYTICS: FacebookAppEvents?
    /// A flag indicating whether to enable Firebase Events.
    public var FIREBASE_ANALYTICS: FirebaseAnalytics?
    /// A flag indicating whether to enable Firebase notifications.
    public var FIREBASE_NOTIFICATION: FirebaseNotification?
    /// The application ID.
    public var appId: String?
    /// Configuration for social login.
    public var SOCIAL_LOGIN: SocialLogin?
    /// A flag indicating whether to enable native contacts.
    public var NATIVE_CONTACTS: NativeContacts?
    /// A flag indicating whether to keep the screen on.
    public var keepScreenOn: Bool?
    /// The custom URL scheme.
    public var customUrlScheme: String?
    /// A flag indicating whether to enable background location tracking.
    public var BACKGROUND_LOCATION: BackgroundLocation?
    /// A flag indicating whether to enable in-app reviews.
    public var enableInAppReview: Bool?
    /// A flag indicating whether to request tracking consent on load.
    public var requestTrackingConsentOnLoad: Bool?
    /// The ad unit ID for banner ads.
    public var bannerAdUnitId: String?
    /// A flag indicating whether to show a soft prompt for OneSignal.
    public var oneSignalSoftPrompt: Bool?
    /// A flag indicating whether to enable barcode scanning.
    public var barcodeScan: barcodeScan?
    /// A flag indicating whether to enable haptic effects.
    public var HAPTIC_FEEDBACK: HapticFeedback?
    /// The custom user agent configuration.
    public var customUserAgent: CustomUserAgent?
    /// A flag indicating whether to enable pull-to-refresh.
    public var pullToRefresh: Bool?
    /// A flag indicating whether to show the page navigation loader.
    public var pageNavigationLoader: Bool?
    /// Configuration for the navigation loader.
    public var navigationLoader: NavigationLoader?
    /// The OneSignal ID.
    public var oneSignalId: String?
    /// Global CSS string to apply to the webview.
    public var globalCssString: String?
    /// Global JavaScript string to apply to the webview.
    public var globalJsString: String?
    /// A flag indicating whether to show the top safe area.
    public var showTopSafeArea: Bool?
    /// The color of the status bar.
    public var statusBarColor: String?
    /// A flag indicating whether to show the bottom safe area.
    public var safeArea: Bool?
    /// The color of the safe area.
    public var safeAreaColor: String?
    /// The width of the splash icon.
    public var splashIconWidth: Int?
    /// The height of the splash icon.
    public var splashIconHeight: Int?
    /// A flag indicating whether to loop the splash animation.
    public var loopAnimation: Bool?
    /// The type of animation end.
    public var animationEndType: String?
    /// The number of times to loop the animation.
    public var loopTimes: Int?
    /// Configuration for internal and external URL handling.
    public var internalExternalLinks: [InternalExternalRule]?
    /// A flag indicating whether to enable local settings.
    public var enableLocalSetting: Bool?
    /// A flag indicating whether to enable the app update popup.
    public var enableAppUpdatePopup: Bool?
    /// A flag indicating whether to enable full-screen mode.
    public var enableFullScreen: Bool?
    /// The timing for the splash screen.
    public var splashTiming: Int?
    /// Configuration for onboarding.
    public var ONBOARDING_SCREEN: ONBOARDING_SCREEN?
    /// Configuration for no internet data.
    public var noInternetData: NoInternetData?
    /// Admob key
    public var enableAdMob: Bool?
    /// Configuration for AdMob ads.
    public var admobAds: AdMobAds?
    /// The orientation type of the application.
    public var screenOrientation: OrientationType?
    /// Configuration for app shortcuts.
    public var APP_SHORTCUTS: APP_SHORTCUTS?
    /// Data for floating action buttons.
    public var floatingButton: floatingButton?
    /// Configuration for the offer card.
    public var OFFER_CARD: OfferCard?
    /// Configuration for connect data.
    public var connectData: ConnectData?
    /// Configuration for the secondary footer.
    public var SECONDARY_NAVIGATION: SECONDARY_NAVIGATION?
    /// disable webView cache
    public var disableCaching: Bool?
    /// enable Splash Full Screen
    public var splashFullScreen: Bool?
    /// disable webView over scrolling
    public var disableWebViewOverScrolling: Bool?
    /// A flag indicating whether to enable optIn and optOut.
    public var onesignalNotificationOptInOptOut: Bool?
    /// maximum progress for hide loader
    public var maxProgress: Double?
    /// enable Download File Manager
    public var DOWNLOAD_MANAGER: DOWNLOAD_MANAGER?
    /// A flag indicating whether to enable native dataStore
    public var NATIVE_DATA_STORE: NATIVE_DATA_STORE?
    /// Configuration for the intercom
    public var INTERCOM: Intercom?
    /// enable webpage scrolling on page loading
    public var enableScrollingOnPageLoading: Bool?
    /// Configuration for the intercom
    public var DYNAMIC_ICON: DYNAMIC_ICON?
    /// splash hide percentage key
    public var splashHidePercent: Double?
    // showCustomAlert
    public var showCustomAlert: ShowCustomAlert?
    /// open app unit id
    public var openAppUnitId: String?
    /// transition color between launch screen and splash screen
    public var transitionColorIsBlack : Bool?
    /// key to send foreground notification data
    public var disableNotificationInForeground: Bool?
    /// key to disable Notification banner when app is in foreground
    public var hideForegroundNotificationBanner : Bool?
    /// key to send appResumeCallback
    public var addCallbackOnAppResume : Bool?
    /// Configuration for the stripe
    public var STRIPE_TAP_TO_PAY: STRIPE_TAP_TO_PAY?
    ///Add-on to disable screenshot
    public var DISABLE_SCREENSHOT: DisableScreenShot?
    /// Configuration for the custom media player
    public var CUSTOM_MEDIA_PLAYER: CUSTOM_MEDIA_PLAYER?
    /// Configuration for rich bottom nav
    public var ADVANCED_BOTTOM_NAVIGATION: RichBottomBar?
    //Beacon Configuration Data
    public var BEACON: BEACON?
    /// A flag indicating whether to enable siri.
    public var SIRI_SUPPORT: SIRI_SUPPORT?
    /// Configuration for the Top App Bar
    public var w2nHeader: TopAppBar?
    /// for limiting app-bound domains
    public var limitNavigationToAppBounds : Bool?
    /// Configuration for the floating action menu
    public var FLOATING_ACTION_MENU: FloatingActionMenu?
    /// Configuration for the Disable Swipe Back
    public var enableCustomBackHandling: CustomBackHandling?
    /// Configuration for Defer Notification
    public var notificationPermissionOnLaunch : NotificationPermissionOnLaunch?
    /// Link Preview key
    public let disableLinkPreview: Bool?
    /// Revenue Cat
    public let REVENUECAT : RevenueCat?
    /// Force Reload
    public let enableForceReload: Bool?
    /// Live preview key
    public var LIVE_PREVIEW: LivePreview?
    /// Live preview local data
    public var livePreviewConfigData: LivePreviewConfigData?
    /// No Internet
    public var noInternet: Bool?
    /// for passcode
    public let PASSCODE : Passcode?
    /// for icon
    public let icon : Icons?
    /// Icon Libraries
    public var iconLibraries: [String]?
    /// Custom Header
    public let customRequestHeaders: [CustomHeaderData?]?
    /// Configuration for SideBar Navigation
    public var sidebarNavigation: SIDEBAR_NAVIGATION?
    /// cookie Persistence configuration
    public var cookiePersistence: CookiePersistence?
    /// Info Plist String
    public var infoPlistStrings : InfoPListStrings?
}

public struct InfoPListStrings : Decodable {
    public var serviceWorkerList : [String]?
}

public struct CookiePersistence: Decodable {
    public var days: String?
    public var domains: [Domain?]?
}

public struct SIDEBAR_NAVIGATION: Decodable {
    public var data: SideBarNavigationData?
}

public struct SideBarNavigationData: Decodable {
    public var enable: Bool?
    public var color: String?
    public var bgColor: String?
    public var showCrossButton: Bool?
    public var sidebarPlacement: String?
    public var tabs: [SideBarNavigationTab?]?
}

public struct SideBarNavigationTab: Decodable {
    public var url: String?
    public var type: String?
    public var label: String?
    public var showAppIcon: Bool?
    public var headerPlacement: String?
    public var title: String?
    public var items: [SideBarNavigationTabItem?]?
    public var itemsPerRow: Int?
    public var bgColor: String?
    public var color: String?
}

public struct SideBarNavigationTabItem: Decodable {
    public var icon: String?
    public var label: String?
    public var url: String?
    public var subMenu: [SideBarNavigationSubMenu?]?
}

public struct SideBarNavigationSubMenu: Decodable {
    public var label: String?
    public var url: String?
}

public struct Domain: Decodable {
    public var domain: String?
    public var keys: [String?]?
}
/**
    A structure representing the configuration of the custom header list data
 */
public struct CustomHeaderData: Decodable {
    public let name: String?
    public let value: String?
}

public struct BEACON: Decodable{
    public var data: CommonEnable?
}

public struct FacebookAppEvents : Decodable {
    public var data: CommonEnable?
}

public struct BackgroundLocation : Decodable {
    public var data: CommonEnable?
}

public struct InAppPurchase : Decodable {
    public var data: CommonEnable?
}

public struct FirebaseAnalytics : Decodable {
    public var data: CommonEnable?
}

public struct FirebaseNotification : Decodable {
    public var data: CommonEnable?
}

public struct HapticFeedback : Decodable {
    public var data: CommonEnable?
}

public struct FloatingActionMenu: Decodable {
    public var data: [FloatingActionMenuData?]?
}
public struct Splash: Decodable {
    public var customizationType: String?
    public var backgroundColor: String?
    public var splashJsonPath: String?
    public var animationBGColor: String?
    public var useAppIconForSplash: Bool?
    public var logoUrl: String?
    public var imgPath: String?
}

//public struct Onboarding: Decodable {
//
//}

public struct LivePreviewConfigData: Decodable{
    public var reloadWebView: Bool?
    public var reloadPreview: Bool?
}

/**
 A structure representing the configuration data for live preview
 */

public struct LivePreview: Decodable{
    /// A flag indication whether the live preview support is enabled
    public var data: CommonEnable?
}

public struct barcodeScan : Decodable{
    public var data : CommonEnable?
}


public struct NativeContacts : Decodable{
    public var data: CommonEnable?
}

public struct CommonEnable : Decodable{
    public var enable:Bool?
}

/**
 A structure representing the configuration data for custom back handling.
 */
public struct CustomBackHandling: Decodable{
    /// A flag indication whether the custom back handling is enabled
    public var enable: Bool?
    public var regEx: String?
}

/**
 A structure representing the configuration data for custom media player.
 */
public struct FloatingActionMenuData: Decodable {
    public var icon: String?
    public var regex: String?
    public var bgColor: String?
    public var showLabel: Bool?
    public var position: String?
    public var textColor: String?
    public var menuBgColor: String?
    public var menuTextColor: String?
    public var tabs: [Tab?]?
}

/**
 A structure representing the configuration data for tab
 */
public struct Tab: Decodable {
    public var url: String?
    public var icon: String?
    public var type: String?
    public var label: String?
}

/**
 A structure representing the configuration data for custom media player
 */
public struct CUSTOM_MEDIA_PLAYER : Decodable {
    /// A flag indicating whether the custom media player is enabled.
    public var data: CommonEnable?
}

/**
 A structure representing the configuration data for stripe.
 */
public struct STRIPE_TAP_TO_PAY :Decodable {
    public var data: CommonEnable?
}


public struct RichBottomBar: Decodable {
    /// Rich bottom nav bar data
    public var data: [RichBottomBarData?]?

}


public struct RichBottomBarData: Decodable {
    public var regex: String?
    public var iconColor: String?
    public var cornerRadius: Int?
    public var bgColor: String?
    public var floatingBtnBgColor: String?
    public var floatingBtnIconColor: String?
    public var activeColor: String?
    public var showShadow: Bool?
    public var tabs: [RichBottomBarTab?]?
}

public struct RichBottomBarTab: Decodable{
    public var url: String?
    public var label: String?
    public var icon: String?
    public var floatingBtnPosition: String?
    public var type: String?
    public var expandableIcons: [ExpandableIcons?]?
    public var hideIconsOfExpandableOptions: Bool?
    public var isExpandable: Bool?
}

public struct ExpandableIcons: Decodable{
    public var url: String?
    public var label: String?
    public var icon: String?
}

/**
 A structure representing the Top App Bar configuration.
 */
public struct TopAppBar: Decodable {
    /// Top App Bar data
    public var data: [TopAppBarData?]?
}

/**
 A structure representing the Top App Bar Data configuration.
 */
public struct TopAppBarData: Decodable {
    public var regex: String?
    public var headerConfig: HeaderConfig?
    public var logoConfig: LogoConfig?
    public var backBtn: BackBtn?
    public var tabs: [TopAppBarTab?]?
}

/**
 A structure representing the Top App Bar configuration.
 */
public struct HeaderConfig: Decodable {
    public var headerStyle: String?
    public var spaceFromTop: Int?
    public var headerBgColor: String?
    public var spaceFromSides: Int?
    public var enableFloatingHeader: Bool?

}
/**
 A structure representing the Top App Bar Logo configuration.
 */
public struct LogoConfig: Decodable {
    public var logoColor: String?
    public var logoPosition: String?
}

/**
 A structure representing the Top App Bar Back Button configuration.
 */
public struct BackBtn: Decodable {
    public var iconColor: String?
    public var iconBgColor: String?
    public var iconStrokeColor: String?
    public var iconStrokeWidth: Int?
    public var iconBorderRadius: Int?
    public var hideOnHome: Bool?

}

/**
 A structure representing the Top App Bar Tab configuration.
 */
public struct TopAppBarTab: Decodable {
    public var iconColor: String?
    public var iconBgColor: String?
    public var iconStrokeColor: String?
    public var iconStrokeWidth: Int?
    public var iconBorderRadius: Int?
    public var url: String?
    public var icon: String?
    public var type: String?
    public var label: String?
    public var id: String?
    public var isHidden: Bool?
    public var expandableIcons: [TopAppBarTab?]?
    public var expandableMenuStyle: String?
}


public struct DOWNLOAD_MANAGER: Decodable {
    public var data: DownloadFileManager?
}

/**
 A structure representing the Download File manager configuration.
 */
public struct DownloadFileManager: Decodable {
    /// A flag indicating whether the download file manager is enabled.
    public var enable: Bool?
    /// A flag indicating show download button on noInternet screen
    public var showOfflineOnNoInternetScreen: Bool?
    /// Download screen header title
    public var title: String? = "Downloads"
    /// Download screen header bg color
    public var titleBarBgColor: String? = "#fedcba"
    /// Download screen header content color
    public var titleBarContentColor: String? = "#abcdef"
    /// Download screen header content color
    public var downloadButtonText: String?
    /// Download button bg color
    public var btnBgColor: String?
    /// Download button border color
    public var borderColor: String?
    /// Download button border Width
    public var borderWidth: Int?
    /// Download button round corner percentage
    public var roundedCornerPercent: Int?
    /// Download button test color
    public var textColor: String?


}

/**
 A structure representing the InterCom configuration.
 */
public struct Intercom: Decodable{
    /// A flag indicating whether the InterCom is enabled.
    public var data: IntercomData?
}

public struct IntercomData: Decodable{
    /// A flag indicating whether the InterCom is enabled.
    public var enable: Bool?
    /// api key of InterCom
    public var apiKey: String?
    /// app Id for InterCom
    public var appId: String?
}
/**
 A structure representing the DYNAMIC APP ICON configuration.
 */
public struct DYNAMIC_ICON: Decodable{
    /// A flag indicating whether the DYNAMIC APP ICON is enabled.
    public var data: [DYNAMIC_ICON_DATA?]?
}

public struct DYNAMIC_ICON_DATA: Decodable{
    public var title: String?
    public var fileName: String?
}

public struct SECONDARY_NAVIGATION: Decodable{
    public var data: SecondaryFooter?
}
/**
 A structure representing the secondary footer configuration.
 */
public struct SecondaryFooter: Decodable {
    /// An array of secondary footer menus.
    public var menus: [SecondaryFooterMenu?]?
}

/**
 A structure representing a menu in the secondary footer.
 */
public struct SecondaryFooterMenu: Decodable {
    /// An array of menu items.
    public var items: [SecondaryFooterMenuItem?]?
    /// The regular expression to match URLs for this menu.
    public var regex: String?
    /// The text color of the menu.
    public var textColor: String?
    /// The background color of the menu.
    public var bgColor: String?
    /// The bottom margin of the menu.
    public var bottomMargin: Int?
}

/**
 A structure representing an item in a secondary footer menu.
 */
public struct SecondaryFooterMenuItem: Decodable {
    /// The label of the menu item.
    public var label: String?
    /// The file name associated with the menu item.
    public var fileName: String?
    /// The URL associated with the menu item.
    public var url: String?
    /// The URL of image
    public var fileUrl: String?
}

/**
 A structure representing the configuration for an offer card.
 */
public struct OfferCard: Decodable {
    public var data: CommonEnable?
}
/**
 A structure representing the configuration for a native storage
 */
public struct NATIVE_DATA_STORE: Decodable {
    /// A flag indicating whether the native storage is enable.
    public var data: CommonEnable?
}

public struct floatingButton: Decodable{
    public var data: [FABDataItem?]?
}

/**
 A structure representing the configuration data for a floating action button (FAB).
 */
public struct FABDataItem: Decodable {
    /// The background color of the FAB.
    public var bgColor: String?
    /// The file name associated with the FAB.
    public var fileName: String?
    /// The shape of the FAB.
    public var shape: FABShape?
    /// The position of the FAB.
    public var position: FABPosition?
    /// The URL associated with the FAB.
    public var url: String?
    /// The regular expression to match URLs for this FAB.
    public var regex: String?
    /// The URL of image
    public var fileUrl: String?
}

/**
 An enumeration representing the possible positions of a floating action button (FAB).
 */
public enum FABPosition: String, Decodable {
    case left = "LEFT"
    case right = "RIGHT"
    case center = "CENTER"
}

/**
 An enumeration representing the possible shapes of a floating action button (FAB).
 */
public enum FABShape: String, Decodable {
    case circular = "CIRCULAR"
    case square = "SQUARE"
}


public struct APP_SHORTCUTS: Decodable{
    public var data: [AppShortcutData?]?
}

/**
 A structure representing the configuration data for an app shortcut.
 */
public struct AppShortcutData: Decodable {
    /// The file name associated with the app shortcut.
    public var fileName: String?
    /// The URL associated with the app shortcut.
    public var url: String?
    /// The label of the app shortcut.
    public var label: String?
}

/**
 A structure representing the configuration data for a connect widget.
 */
public struct ConnectData: Decodable {
    /// The configuration of the connect widget.
    public var data: ConnectWidgetConf?
    /// A flag indicating whether the connect widget is active.
    public var active: Bool?
}

/**
 A structure representing the configuration of a connect widget.
 */
public struct ConnectWidgetConf: Decodable {
    /// The page setting of the connect widget.
    public var pageSetting: WidgetPageSetting?
    /// The ID of the widget.
    public var widgetId: String?
    /// The icon position of the widget.
    public var iconPosition: ConnectWidgetPosition?
    /// The file name associated with the widget.
    public var fileName: String?
}

/**
 A structure representing the page setting of a widget.
 */
public struct WidgetPageSetting: Decodable {
    /// The regular expression to match URLs for this page setting.
    public var regex: String?
}

/**
 An enumeration representing the possible positions of a connect widget.
 */
public enum ConnectWidgetPosition: String, Decodable {
    case BOTTOM_LEFT = "Bottom Left"
    case BOTTOM_RIGHT = "Bottom Right"
    case TOP_LEFT = "Top Left"
    case TOP_RIGHT = "Top Right"
    case LEFT_CENTER = "Left Center"
    case RIGHT_CENTER = "Right Center"
    case NONE = "None"
}

/**
 An enumeration representing the possible orientation types of the application.
 */
public enum OrientationType: String, Decodable {
    case all = "PORTRAIT_LANDSCAPE"
    case portrait = "PORTRAIT"
    case landscape = "LANDSCAPE"
}

/**
 A structure representing the configuration data for AdMob ads.
 */
public struct AdMobAds: Decodable {
    /// An array of AdMob data configurations.
    public var data: [AdMobData]?
}

/**
 A structure representing the configuration data for an AdMob ad.
 */
public struct AdMobData: Decodable {
    /// The regular expression to match URLs for this ad.
    public var regex: String?
    /// The initial delay before showing the ad.
    public var initialShowDelay: Int?
    /// The type of ad.
    public var adType: AdType?
    /// The ID of the ad.
    public var adId: String?
    /// The position of the ad.
    public var position: AdPosition?
}

/**
 An enumeration representing the possible positions of an ad.
 */
public enum AdPosition: String, Decodable {
    case bottom = "BOTTOM"
    case top = "TOP"
}

/**
 An enumeration representing the possible types of ads.
 */
public enum AdType: String, Decodable {
    case banner = "BANNER"
    case fullscreen = "FULLSCREEN"
    case reward = "REWARD"
}

/**
 A structure representing the configuration data for no internet pages.
 */
public struct NoInternetData: Decodable {
    /// An array of pages to show when there is no internet.
    public var pages: [Page]?
    /// An array of action buttons to show when there is no internet.
    public var actionButtons: [ButtonData]?
    /// The background color for the no internet pages.
    public var bgColor: String?
}

public struct ONBOARDING_SCREEN: Decodable {
    public var data: Onboarding?
}

/**
 A structure representing the configuration data for onboarding.
 */
public struct Onboarding: Decodable {
    /// A flag indicating whether the onboarding screen is enable.
    public var enable: Bool?
    /// The version of the onboarding configuration.
    public var version: Int?
    /// A flag indicating whether to always show the onboarding.
    public var showAlways: Bool?
    /// A flag indicating whether to show the onboarding on app update.
    public var showOnAppUpdate: Bool?
    /// The interval for showing the onboarding.
    public var onboardingShowInterval: Int?
    /// The background color for the onboarding pages.
    public var bgColor: String?
    /// The page indicator configuration for the onboarding.
    public var pageIndicator: PageIndicator?
    /// An array of action buttons for the onboarding.
    public var actionButtons: [ButtonData]?
    /// The skip button configuration for the onboarding.
    public var skipButton: ButtonData?
    /// An array of pages for the onboarding.
    public var pages: [Page]?
}

/**
 A structure representing a page in the onboarding process.
 */
public struct Page: Decodable {
    /// A flag indicating whether to show the skip button on this page.
    public var showSkipButton: Bool?
    /// An array of elements on this page.
    public var elements: [Element]?
    /// The top margin percentage for this page.
    public var topMarginPercent: Int?
}

/**
 A structure representing an element on a page.
 */
public struct Element: Decodable {
    /// The type of the element.
    public var type: ElementType
    /// The file name associated with the element.
    public var fileName: String?
    /// The value of the element.
    public var value: String?
    /// The text color of the element.
    public var textColor: String?
    /// The font weight of the element.
    public var fontWeight: Int?
    /// The font size of the element.
    public var fontSize: Int?
    /// The URL of image
    public var fileUrl: String?
}


/**
 An enumeration representing the possible types of elements.
 */
public enum ElementType: String, Decodable {
    case text = "text"
    case image = "image"
}

/**
 A structure representing the configuration data for a button.
 */
public struct ButtonData: Decodable {
    /// The text of the button.
    public var text: String?
    /// The text color of the button.
    public var textColor: String?
    /// The background color of the button.
    public var btnBgColor: String?
    /// The border color of the button.
    public var borderColor: String?
    /// The border width of the button.
    public var borderWidth: Int?
    /// The rounded corner percentage of the button.
    public var roundedCornerPercent: Int?
    /// The URL associated with the button.
    public var url: String?
}

/**
 A structure representing the configuration data for a page indicator.
 */
public struct PageIndicator: Decodable {
    /// The type of the page indicator.
    public var type: String?
    /// The active color of the page indicator.
    public var activeColor: String?
    /// The inactive color of the page indicator.
    public var inactiveColor: String?
    /// The position of the page indicator.
    public var position: String?
}

/**
 An enumeration representing the possible user agent types.
 */
public enum UserAgentType: String, Decodable {
    case append = "APPEND"
    case custom = "CUSTOM"
}

/**
 A structure representing the custom user agent configuration.
 */
public struct CustomUserAgent: Decodable {
    /// The type of the user agent.
    public var type: UserAgentType?
    /// The value of the user agent.
    public var value: String?
}

/**
 A structure representing the configuration for biometric authentication.
 */

public struct Biometric : Decodable {
    public var data : BiometricAuth?
}

public struct BiometricAuth: Decodable {
    /// A flag indicating whether biometric authentication is enabled.
    public var enable: Bool?
    /// A flag indicating whether to show biometric authentication on load.
    public var onAppLoad: Bool?
    /// A flag indicating whether domain whitelisting is enabled for biometric authentication.
    public var enableDomainWhitelisting: Bool?
    /// An array of whitelisted domains for biometric authentication.
    public var whiteListDomains: [String]?
    /// A flag to indicate the user wants content hidden while on biometric auth
    public var hideBackground: Bool?
}

/**
 An enumeration representing the possible types of navigation loaders.
 */
public enum NavigationLoaderType: String, Decodable {
    case LottieAnimation = "LottieAnimation"
    case ProgressBar = "ProgressBar"
    case CircularLoader = "CircularLoader"
}

/**
 An enumeration representing the possible shapes of navigation loader animations.
 */
public enum NavigationLoaderAnimationShape: String, Decodable {
    case CIRCULAR = "CIRCULAR"
    case RECTANGLE = "RECTANGLE"
}

/**
 An enumeration representing the possible sizes of navigation loader animations.
 */
public enum NavigationLoaderAnimationSize: String, Decodable {
    case FULL = "FULL"
    case LARGE = "LARGE"
    case MEDIUM = "MEDIUM"
    case SMALL = "SMALL"
    case FIXED_SIZE = "FIXED_SIZE"
}

public struct Icons : Decodable {
    public let imgPath : String?
}

/**
 A structure representing the configuration for navigation loaders.
 */
public struct NavigationLoader: Decodable {
    /// The type of the navigation loader.
    public var type: NavigationLoaderType?
    /// The background color of the navigation loader.
    public var bgColor: String?
    /// The color of the loader.
    public var loaderColor: String?
    /// The background color of the animation.
    public var animationBgColor: String?
    /// The shape of the animation.
    public var animationShape: NavigationLoaderAnimationShape?
    /// The size of the animation.
    public var animationSize: NavigationLoaderAnimationSize?
    /// The load percentage offset for the navigation loader.
    public var loadPercentOffset: Float?
    /// The width of the navigation loader.
    public var width: Float?
    /// The height of the navigation loader.
    public var height: Float?
    /// flag for enable shadow
    public var enableShadow: Bool?
    /// loader Url
    public var animationJsonUrl: String?

}

/**
 An enumeration representing the possible link handling types.
 */
public enum LinkHandleType: String, Decodable {
    case w2nInternal = "INTERNAL"
    case w2nExternal = "EXTERNAL"
    case w2nInApp = "IN_APP"
    case w2nCustom = "CUSTOM"
}

/**
 An enumeration representing the possible link handling page types
 */
public enum PageHandleType: String, Decodable {
    case allPages = "ALL_PAGES"
    case custom = "CUSTOM"
    case singlePage = "SINGLE_PAGE"
    case multiplePage = "MULTIPLE_PAGE"
}

/**
 A structure representing a rule for handling URLs.
 */
public struct InternalExternalRule: Decodable {
    /// The type of link handling.
    public var type: LinkHandleType
    /// The regular expression to match URLs for this rule.
    public var regex: String?
    /// the page type of handling
    public var pageType : PageHandleType?
}

/**
 A structure representing the configuration for social login.
 */
public struct SocialLogin: Decodable {
    public var data: CommonEnable?
}

/**
 A structure representing the configuration for Appsflyer.
 */
public struct Appsflyer: Decodable {
    public var data: AppsflyerData?
}

public struct AppsflyerData: Decodable {
    /// A flag indicating whether Appsflyer is enabled.
    public var enable: Bool?
    /// The developer key for Appsflyer.
    public var devKey: String?
}

/**
 A structure representing the configuration for a sticky footer.
 */
public struct BottomNavigation: Decodable {
    /// An array of sticky footer data configurations.
    public var data: [StickyFooterData]?
}

/**
 A structure representing the configuration data for a sticky footer.
 */
public struct StickyFooterData: Decodable {
    /// An array of sticky footer buttons.
    public var tabs: [StickyFooterButton]
    /// The regular expression to match URLs for this sticky footer.
    public var regEx: String
    /// The key associated with the sticky footer.
    public var key: String?
    /// The font family for the sticky footer text.
    public var fontFamily: String?
    /// The font size for the sticky footer text.
    public var fontSize: Int?
    /// The icon font size for the sticky footer.
    public var iconFontSize: Int?
    /// The active text color for the sticky footer.
    public var activeTextColor: String?
    /// The text color for the sticky footer.
    public var textColor: String?
    /// The active icon color for the sticky footer.
    public var activeIconColor: String?
    /// The icon color for the sticky footer.
    public var iconColor: String?
    /// The height of the sticky footer.
    public var height: Int?
    /// The background color of the sticky footer.
    public var bgColor: String?
}


/**
 A structure representing a button in a sticky footer.
 */
public struct StickyFooterButton: Decodable {
    /// The label of the button.
    public var label: String?
    /// The icon associated with the button.
    public var icon: String
    /// The link associated with the button.
    public var link: String
}
/**
A structure representing ShowCustomAlert data to decide whether to auto-dismiss JS alert or not
*/
public struct ShowCustomAlert : Decodable {
    public var enable : Bool?
    public var enableUrlRegex : String?
    public var disableUrlRegex : String?
}
/**
 A structure representing Siri Add-on data
 */

public struct SIRI_SUPPORT: Decodable {
    ///Add-on is enabled or not
    public var data: CommonEnable?
}

/**
 A structure representing the disableScreenShot Add-on
 */
public struct DisableScreenShot: Decodable {
    public var data: DisableScreenShotData?
}
public struct DisableScreenShotData: Decodable {
    ///Add-on is enabled or not
    public var enable: Bool?
    ///Screenshot disabled or not
    public var screenShotBlocked : Bool?
    ///Regex url to block screenshot for specific urls
    public var regEx : String?

}
/**
 A structure representing the config data of Beacon
 */
public struct Beacon: Decodable {
    public var enable: Bool?
}
/**
 A structure representing the config data of Beacon
 */
public struct NotificationPermissionOnLaunch: Decodable {
    public var enable: Bool?
    public var url: String?
}

/**
 Revenue Cat Structure Config Data
 */
public struct RevenueCat : Decodable {
    public let data: CommonEnable?
}
/**
    A Structure Representing config Data of Passcode
 */
public struct Passcode : Decodable {
    public let data : PasscodeData?
}
/**
  A Structure Representing cofig of Passcode Data
 */
public struct PasscodeData : Decodable {
    public let enable : Bool?
    public let setUpOnLaunch : Bool?
    public let type : String?
    public let maxAttempt : Int?
    public let recoveryMethod : String?
    public let redirectURL : String?
    public let autoLockAfter : Int?
    public let theme : String?
    public let showAppIcon : Bool?
}
/**
 A singleton class responsible for managing configuration data loaded from a local JSON file.
 */
public class WebToNativeConfig {
    
    /// Shared instance of `WebToNativeConfig`.
    public static var shared = WebToNativeConfig()
    
    /// The shared configuration data loaded from the JSON file.
    public static var sharedConfig: WebToNativeConfigData?
    
    /// The live preview configuration data loaded from the webstocks.
    public static var previewSharedConfig: WebToNativeConfigData?

    /// The live preview configuration data loaded from the webstocks.
    public static var appSharedConfig: WebToNativeConfigData?

    /// key to hold google auth
    public static var googleAuth : GoogleAuthData  = GoogleAuthData(redirectUri: "", state: "", scopes: [], serverAuthCode: "")

    /// key to hold runtime tokens
    public static var runtimeTokens : Tokens = Tokens()

    /**
     Reads a local JSON file from the main bundle.
     
     - Parameter name: The name of the JSON file (without extension) to read.
     - Returns: The data read from the JSON file, or nil if an error occurs.
     */
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    /**
     Loads the application configuration from a local JSON file into `sharedConfig` if not already loaded.
     */
    public func loadAppConfig() {
        // Check if configuration is already loaded
        if WebToNativeConfig.sharedConfig != nil {
            return
        }
        
        // Attempt to read and decode the local JSON file
        if let localData = self.readLocalFile(forName: "appConfig") {
            do {
                let decodedData = try JSONDecoder().decode(WebToNativeConfigData.self, from: localData)
                WebToNativeConfig.sharedConfig = decodedData
                WebToNativeConfig.appSharedConfig = decodedData
                previewAppConfig()
            } catch {
                print(error)
            }
        }
    }

    // Remove123
    public func previewAppConfig(){
        // Check if configuration is already loaded
        if WebToNativeConfig.previewSharedConfig != nil {
            return
        }

        // Attempt to read and decode the local JSON file
        do {
            let previewJson = """
                {
                    "websiteLink": "https://www.webtonative.com"
                }
                """.data(using: .utf8)!
            let decodedData = try JSONDecoder().decode(WebToNativeConfigData.self, from: previewJson)
            WebToNativeConfig.previewSharedConfig = decodedData
        } catch {
            print(error)
        }
    }
}

/**
 Google Primary Data Holding Class Functions With Social Login Addon
 */

public struct GoogleAuthData  {
    public var redirectUri : String
    public var state : String
    public var scopes : [String]
    public var serverAuthCode : String
}

/**
 Token for Data Holdings
 */
public struct Tokens {
    public var blockSwipeHandling: Bool?
    public var cookies: [HTTPCookie?]?
    public var onBackgroundPasscode: String?
    public var historyItemsBeforeForgotPasscode: Int = 0
}

extension GoogleAuthData  {
    
    /**
        Extension Function Saving data and Rewriting Old Values if Any Value is Not Provided.
     */
   public func copy(redirectUri: String? = nil, state: String? = nil, scopes: [String]? = nil,serverAuthCode: String? = nil) -> GoogleAuthData {
        return GoogleAuthData(
            redirectUri: redirectUri ?? self.redirectUri,
            state: state ?? self.state,
            scopes: scopes ?? self.scopes,
            serverAuthCode: serverAuthCode ?? self.serverAuthCode
        )
    }
    
    /**
     Final URL to Call in WebView
     */
    public func getGoogleFlowUrl() -> String {
        let urlOperator = self.redirectUri.contains("?") ? "&" : "?"
        let url = self.redirectUri + "\(urlOperator)state=" + self.state + "&code=" + self.serverAuthCode + "&scope=" + self.scopes.getScopes()
        return url
    }
}


extension Array where Element == String {
    public func getScopes() -> String {
       // --- Step 1: Partition the array into URLs and other scopes in a single pass ---
       // Using `reduce(into:_:)` is more efficient than filtering the array multiple times,
       // as it iterates through the collection only once.
       let (urls, otherScopes) = self.reduce(into: ([String](), [String]())) { result, scope in
         if scope.hasPrefix("https://") {
           result.0.append(scope)
         } else {
           result.1.append(scope)
         }
       }
       
       // --- Step 2: Sort the URLs for a consistent and predictable order ---
       // Sorting descending (by using >) matches the example's output order.
       let sortedUrls = urls.sorted(by: >)
       
       // --- Step 3: Derive short names from the sorted URLs ---
       // `compactMap` is used to safely transform each URL. It automatically unwraps
       // the optional result of `.last` and discards any `nil` values if a URL
       // doesn't contain a "." for some reason.
       let derivedNames = sortedUrls.compactMap { url -> String? in
         return url.split(separator: ".").last?.lowercased()
       }
       
       // --- Step 4: Combine all parts and join into the final string ---
       // The components are concatenated in the required order.
       // Note: The original non-URL scopes are also sorted for predictability.
       let allParts = sortedUrls + otherScopes.sorted() + derivedNames
       
       return allParts.joined(separator: "+")
     }
}
