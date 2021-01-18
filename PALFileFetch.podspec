#
# Be sure to run `pod lib lint PALFileFetch.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PALFileFetch'
  s.version          = '0.1.0'
  s.summary          = 'PALFileFetch'
  s.description      = <<-DESC
My Lib PALFileFetch
                       DESC
  s.homepage         = 'https://github.com/pikachu987/PALFileFetch'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pikachu987' => 'pikachu77769@gmail.com' }
  s.source           = { :git => 'https://github.com/pikachu987/PALFileFetch.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'PALFileFetch/Classes/**/*'
  s.swift_version = '5.0'
end
