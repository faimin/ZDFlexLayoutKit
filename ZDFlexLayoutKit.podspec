#
#  Be sure to run `pod spec lint ZDFlexLayout.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "ZDFlexLayoutKit"
  spec.version      = "0.1.1"
  spec.summary      = "Flex Layout in Objective-C"
  spec.description  = <<-DESC
    flex layout in Objective-C base on yoga
                   DESC
  spec.homepage     = "https://github.com/faimin/ZDFlexLayoutKit"
  spec.license      = "MIT"
  spec.author       = { "faimin" => "fuxianchao@gmail.com" }
  spec.requires_arc = true
  spec.platform     = :ios, "9.0"
  spec.source       = {
    :git => "https://github.com/faimin/ZDFlexLayoutKit.git",
    :tag => "#{spec.version}"
  }
  spec.prefix_header_file = false
  
  spec.source_files  = "Source/**/*.{h,m}"
  spec.public_header_files = "Source/Header/*.h"

  spec.module_name = 'ZDFlexLayoutKit'
  #spec.preserve_path = 'Source/module.modulemap', "Source/ZDFlexLayoutKit.h"
  #spec.module_map = 'Source/module.modulemap'
  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    #'SWIFT_INCLUDE_PATHS' => ["$(PODS_ROOT)/#{spec.module_name}/", "$(PODS_TARGET_SRCROOT)/#{spec.module_name}/"]
  }
  
  spec.swift_versions   = ['5.0']
  spec.default_subspecs = 'Core', 'OCMaker', 'Helper'
  
  spec.subspec 'Header' do |s|
    s.source_files = "Source/Header/ZDFlexLayoutKit.{h,m}"
  end
  spec.subspec 'Core' do |s|
    s.source_files = "Source/Core/**/*.{h,m}"
    s.public_header_files = "Source/Core/Public/*.h"
    s.private_header_files = "Source/Core/Private/*.h"
    s.dependency 'Yoga'
    s.dependency 'ZDFlexLayoutKit/Header'
  end
  spec.subspec 'OCMaker' do |s|
    s.source_files = "Source/OCMaker/*.{h,m}"
    s.dependency 'ZDFlexLayoutKit/Core'
    s.dependency 'ZDFlexLayoutKit/Header'
  end
  spec.subspec 'Helper' do |s|
    s.source_files = "Source/Helper/*.{h,m}"
    s.dependency 'ZDFlexLayoutKit/Core'
    s.dependency 'ZDFlexLayoutKit/Header'
  end
  spec.subspec 'SwiftMaker' do |s|
    s.source_files = "Source/SwiftMaker/*.swift"
    s.dependency 'ZDFlexLayoutKit/Core'
    s.dependency 'ZDFlexLayoutKit/Header'
    s.dependency 'Yoga'
  end
end
