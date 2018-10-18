

Pod::Spec.new do |s|


  s.name         = "HEPhotoPicker"
  s.version      = "0.0.1"
  s.summary      = "A short description of HEPhotoPicker."

  s.description  = <<-DESC
                   DESC

  s.homepage     = "https://github.com/JiongXing/PhotoBrowser"
  s.screenshots  = "https://github.com/heyode/PhotoPicker/blob/master/Resources/photopicker.gif"

  s.license      = { :type => "MIT", :file => "LICENSE" }



  s.author             = { "heyode" => "1025335931@qq.com" }
  # Or just: s.author    = "heyode"
  # s.authors            = { "heyode" => "1025335931@qq.com" }
  # s.social_media_url   = "http://twitter.com/heyode"

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If this Pod runs only on iOS or OS X, then specify the platform and
  #  the deployment target. You can optionally include the target after the platform.
  #

  s.platform     = :ios

  s.source       = { :git => "git@github.com:heyode/PhotoPicker.git", :tag => "#{s.version}" }



  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"


  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
