Pod::Spec.new do |s|

  s.name = "FDRequestClient"
  s.version = "0.2.1"
  s.summary = "1414 Degrees' networking layer."
  s.license = { :type => "MIT", :file => "LICENSE.md" }

  s.homepage = "https://github.com/reidmain/FDRequestClient"
  s.author = "Reid Main"
  s.social_media_url = "http://twitter.com/reidmain"

  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.source = { :git => "https://github.com/reidmain/FDRequestClient.git", :tag => s.version }
  s.source_files = "FDRequestClient/**/*.{h,m}"
  s.private_header_files = "FDRequestClient/**/*+Private.h"
  s.osx.exclude_files = "FDRequestClient/**/UI*.{h,m}"
  s.frameworks  = "Foundation"
  s.ios.frameworks = "UIKit"
  s.requires_arc = true
  s.dependency "FDFoundationKit"
end
