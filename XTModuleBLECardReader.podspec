#
# Be sure to run `pod lib lint XTModuleBLECardReader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XTModuleBLECardReader'
  s.version          = '1.0.4'
  s.summary          = 'XTModuleBLECardReader.描述'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!11

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/leblanc-zx/XTModuleBLECardReader'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'leblanc-zx' => '351706354@qq.com' }
  s.source           = { :git => 'https://github.com/leblanc-zx/XTModuleBLECardReader.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

s.source_files = 'XTModuleBLECardReader/*.{h,m}'
s.vendored_libraries = 'XTModuleBLECardReader/LocalDependency/**.a'
  # 配置子目录

  s.subspec 'LocalDependency' do |localDependency|
  localDependency.source_files = 'XTModuleBLECardReader/LocalDependency/*'
  end

  s.subspec 'Socket' do |socket|
  socket.source_files = 'XTModuleBLECardReader/Socket/*'
  end

  s.subspec 'Models' do |models|
  models.source_files = 'XTModuleBLECardReader/Models/*'
  end

  s.subspec 'BLECardReader' do |bleCardReader|
  bleCardReader.source_files = 'XTModuleBLECardReader/BLECardReader/*'
  bleCardReader.dependency 'XTModuleBLECardReader/Models'
  bleCardReader.dependency 'XTModuleBLECardReader/LocalDependency'
  end

  s.subspec 'BLECardReaderMinimalis' do |bleCardReaderMinimalis|
  bleCardReaderMinimalis.source_files = 'XTModuleBLECardReader/BLECardReaderMinimalis/*'
  bleCardReaderMinimalis.dependency 'XTModuleBLECardReader/BLECardReader'
  bleCardReaderMinimalis.dependency 'XTModuleBLECardReader/Socket'
  end
  
  # s.resource_bundles = {
  #   'XTModuleBLECardReader' => ['XTModuleBLECardReader/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'XTComponentSocket', '~> 1.0.4'
end
