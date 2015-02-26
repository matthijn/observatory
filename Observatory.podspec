#
# Be sure to run `pod lib lint Observatory.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Observatory"
  s.version          = "0.1.1"
  s.summary          = "Observatory is an improvement on the standard Objective-C KVO system."
  s.homepage         = "https://github.com/Matthijn/Observatory"
  s.license          = 'MIT'
  s.author           = { "Matthijn Dijkstra" => "matthijndijkstra@gmail.com" }
  s.source           = { :git => "https://github.com/Matthijn/Observatory.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/matthijn_indev'
  s.requires_arc = true

  s.source_files = 'Observatory/*'
  s.public_header_files = 'Observatory/*.h'
end
