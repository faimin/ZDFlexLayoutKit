#
#  Be sure to run `pod spec lint ZDFlexLayout.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "ZDFlexLayoutKit"
  spec.version      = "0.1.6"
  spec.summary      = "Flex Layout for iOS"
  spec.description  = <<-DESC
    flex layout for iOS powered by yoga
                   DESC
  spec.homepage     = "https://github.com/faimin/ZDFlexLayoutKit"
  spec.license      = "MIT"
  spec.author       = { "faimin" => "fuxianchao@gmail.com" }
  spec.requires_arc = true
  spec.platform     = :ios, "9.0"
  spec.source       = {
    :git => "https://github.com/faimin/ZDFlexLayoutKit.git",
    :tag => spec.version.to_s
  }
  spec.prefix_header_file = false

  spec.header_dir = "./"
  spec.module_name = 'ZDFlexLayoutKit'
  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }
  
  spec.swift_versions = ['5.1']
  
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
  end
  
end
