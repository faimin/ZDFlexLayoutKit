#
#  Be sure to run `pod spec lint ZDFlexLayout.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "ZDFlexLayoutKit"
  spec.version      = "0.0.1"
  spec.summary      = "Flex Layout in Objective-C"
  spec.description  = <<-DESC
    flex layout in Objective-C base on yoga
                   DESC
  spec.homepage     = "https://github.com/faimin/ZDFlexLayoutKit"
  spec.license      = "MIT"
  spec.author       = { "faimin" => "fuxianchao@gmail.com" }
  spec.requires_arc = true
  spec.platform     = :ios, "8.0"
  spec.source       = { :git => "https://github.com/faimin/ZDFlexLayoutKit.git", :tag => "#{spec.version}" }
  spec.source_files  = "Source/**/*.{h,m}"
  spec.public_header_files = "Source/ZDFlexLayoutKit.h"

  spec.module_name = 'ZDFlexLayoutKit'
  #spec.preserve_path = 'Source/module.modulemap'
  spec.module_map = 'Source/module.modulemap'
  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
  
  spec.subspec 'Core' do |s|
    s.source_files = "Source/Core/*.{h,m}"
    s.dependency 'Yoga'
  end
  spec.subspec 'Maker' do |s|
    s.source_files = "Source/Maker/*.{h,m}"
    s.dependency 'ZDFlexLayoutKit/Core'
  end
  spec.subspec 'Helper' do |s|
    s.source_files = "Source/Helper/*.{h,m}"
    s.dependency 'ZDFlexLayoutKit/Core'
  end
end
