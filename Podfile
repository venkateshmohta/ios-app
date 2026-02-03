# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'


target 'NotificationServiceExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'OneSignal', '>= 5.2.5'
  pod 'FirebaseMessaging', '>= 10.24.0'
  pod 'GoogleUtilities', '>= 7.12.0'
  # Pods for NotificationServiceExtension
end

target 'WebToNative' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  # Pods for WebToNative
  pod 'lottie-ios', '>= 4.4.3'
  pod 'Kingfisher', '>= 7.11.0'

  pod 'WebToNativeCore', :path => './WebToNativeCore'
  pod 'WebToNativeIcons', :path => './WebToNativeIcons'
  pod 'WebToNativeBiometric', :path => './WebToNativeBiometric'
  pod 'WebToNativeFBSDK', :path => './WebToNativeFBSDK'
  pod 'WebToNativeAppsFlyer', :path => './WebToNativeAppsFlyer'
  pod 'WebToNativeGoogleSignIn', :path => './WebToNativeGoogleSignIn'
  pod 'WebToNativeAdMob', :path => './WebToNativeAdMob'
  pod 'WebToNativeFirebase', :path => './WebToNativeFirebase'
  pod 'WebToNativeBarcode', :path => './WebToNativeBarcode'
  pod 'WebToNativeCalender', :path => './WebToNativeCalender'
  pod 'WebToNativeHapticEffect', :path => './WebToNativeHapticEffect'
  pod 'WebToNativeLocationManager', :path => './WebToNativeLocationManager'
  pod 'WebToNativeContactManager', :path => './WebToNativeContactManager'
  pod 'WebToNativeAppleSignIn', :path => './WebToNativeAppleSignIn'
  pod 'WebToNativeIAPManager', :path => './WebToNativeIAPManager'
  pod 'WebToNativeLocalSettings', :path => './WebToNativeLocalSettings'
  pod 'WebToNativeUpdateAppPopup', :path => './WebToNativeUpdateAppPopup'
  pod 'WebToNativeOneSignal', :path => './WebToNativeOneSignal'
  pod 'WebToNativeOrufyConnectSDK', :path => './WebToNativeOrufyConnectSDK'
  pod 'WebToNativeIntercom', :path => './WebToNativeIntercom'
  pod 'WebToNativeStripePayment', :path => './WebToNativeStripePayment'
  pod 'WebToNativeMediaPlayer', :path => './WebToNativeMediaPlayer'
  pod 'WebToNativeSiri', :path => './WebToNativeSiri'
  pod 'WebToNativeNativeStorage', :path => './WebToNativeNativeStorage'
  pod 'WebToNativeLivePreview', :path => './WebToNativeLivePreview'
  pod 'WebToNativeRevenueCat', :path => './WebToNativeRevenueCat'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
