#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_native_camera'
  s.version          = '0.0.1'
  s.summary          = 'Camera plugin using native camera libraries and platform-view'
  s.description      = <<-DESC
Camera plugin using native camera libraries and platform-view
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.dependency 'SwiftyCam', '~> 3.1.0' 

  s.ios.deployment_target = '9.0'
end

