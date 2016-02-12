#
# Be sure to run `pod lib lint Notify.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "Notify"
  s.version          = "0.1.9"
  s.summary          = "Notify is a presentation layer for displaying notifications within your app."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
The purpose of notify is to present addressable notification to your users within your app.
Examples might include asking users to address permissions or whether they've seen some information relevant to them.
Notifications support enqueuing and are presented in a FIFO order.
Future features will include styling your notifications and the ability to show or hide the status bar.
                       DESC

  s.homepage         = "https://github.com/yourkarma/Notify"
  s.screenshots      = "https://github.com/yourkarma/Notify/raw/master/success.png?raw=true%20%22Success%20Notification%22%20=250x", "https://github.com/yourkarma/Notify/blob/master/error.png?raw=true%20%22Error%20Notification%22%20=250x"
  s.license          = 'MIT'
  s.author           = { "asowers" => "andrew.sowers@yourkarma.com", "klaaspieter" => "kpa@annema.me" }
  s.source           = { :git => "https://github.com/yourkarma/Notify.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/andrewsowers'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'Notify' => ['Pod/Assets/*.png']
  }

end
