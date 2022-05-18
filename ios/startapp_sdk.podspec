#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'startapp_sdk'
  s.version          = '0.3.0'
  s.summary          = 'iOS implementation of startapp_sdk Flutter Plugin'
  s.description      = <<-DESC
This is iOS plugin for Flutter implementation of StartAppSDK.
                       DESC
  s.homepage         = "https://www.start.io"
  s.license          = { :file => '../LICENSE' }
  s.author           = { "iOS Dev" => "iosdev@startapp.com" }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency "StartAppSDK", "~> 4.7.0"

  s.static_framework = true

  # Flutter.framework does not contain i386 slice, StartAppSDK does not contain arm64 slice. StartAppSDK is not modular framework
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'NO', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '$(inherited) i386 arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => '$(inherited) i386 arm64' }
end
