#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'startapp_sdk'
  s.version          = '0.4.2'
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
  s.dependency "StartAppSDK", "~> 4.10"
  s.platform                = :ios
  s.ios.deployment_target   = '9.0'

  s.static_framework = true

  s.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) STA_PLUGIN_VERSION=\"${STA_PLUGIN_VERSION}\"', 'STA_PLUGIN_VERSION' => "#{s.version}" }
end
