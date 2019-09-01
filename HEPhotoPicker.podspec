#
# Be sure to run `pod lib lint HEPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HEPhotoPicker'
  s.version          = '0.0.8'
  s.summary          = 'Elegant photo picker in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = 'Elegant photo picker in Swift. Inspired by Weibo.'

s.homepage         = 'https://github.com/heyode/HEPhotoPicker'
s.screenshots     = ['https://github.com/heyode/HEPhotoPicker/blob/master/ExampleImage/image%26video.gif',
                    'https://github.com/heyode/HEPhotoPicker/blob/master/ExampleImage/OnlyImage.gif',
                    'https://github.com/heyode/HEPhotoPicker/blob/master/ExampleImage/singlePicture.gif']
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'heyode' => '1025335931@qq.com' }
s.source           = { :git => "https://github.com/heyode/HEPhotoPicker.git", :tag => "#{s.version}" }
# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

s.ios.deployment_target = '9.0'
s.swift_version = '5.0'
s.source_files = ["Source/**/*.swift"]

s.resource_bundles = {
    'HEPhotoPicker' => [
    'Source/Assets.xcassets',
    'Source/**/*.xib'
    ]
}

  # s.public_header_files = 'Pod/Classes/**/*.h'
 s.frameworks = 'UIKit','Photos'
  # s.dependency 'AFNetworking', '~> 2.3'
end
