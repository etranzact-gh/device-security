#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint device_security_plus.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'device_security_plus'
  s.version          = '1.0.3'
  s.summary          = 'A Flutter plugin for device security checks.'
  s.description      = <<-DESC
A Flutter plugin to retrieve unique device identifiers and monitor real-time security statuses across iOS and Android.
                       DESC
  s.homepage         = 'https://github.com/etranzact-gh/device-security'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'eTranzact' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'device_security_plus/Sources/device_security_plus/**/*'
  s.resource_bundles = {'device_security_plus_privacy' => ['device_security_plus/Sources/device_security_plus/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform         = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
