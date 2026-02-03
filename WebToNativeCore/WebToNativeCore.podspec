Pod::Spec.new do |s|
  s.name             = 'WebToNativeCore'
  s.version          = '1.0.0'
  s.summary          = 'A short description of WebToNativeCore.'
  s.homepage         = 'https://github.com/webtonative/WebToNativeCore'
  s.author           = { 'WebToNative' => 'himanshu@webtonative.com' }
  s.source           = { :git => 'https://github.com/webtonative/WebToNativeCore.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'WebToNativeCore/Classes/**/*'
  s.resources = 'WebToNativeCore/Assets/*'
end
