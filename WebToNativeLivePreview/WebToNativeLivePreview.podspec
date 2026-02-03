Pod::Spec.new do |s|
  s.name             = 'WebToNativeLivePreview'
  s.version          = '1.0.0'
  s.summary          = 'A short description of WebToNativeLivePreview.'
  s.homepage         = 'https://github.com/webtonative/WebToNativeLivePreview'
  s.author           = { 'WebToNative' => 'yash@orufy.com' }
  s.license          = "MIT"
  s.source           = { :git => 'https://github.com/webtonative/WebToNativeLivePreview.git', :tag => s.version.to_s }
  s.ios.deployment_target = '14.0'
  s.source_files = 'Sources/WebToNativeLivePreview/**/*'
  s.dependency 'WebToNativeCore'
  s.static_framework = true
end

