Pod::Spec.new do |s|
  s.name         = "PopupController"
  s.version      = "0.0.1"
  s.summary      = "PopupController is a controller for showing temporary popup view."
  s.homepage     = "https://github.com/daisuke310vvv/PopupController"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Daisuke Sato" => "daisuke.sato1991@gmail.com" }
  s.social_media_url   = "http://twitter.com/st_dsk"

  s.platform    = :ios,  '8.0'
  s.requires_arc = true

  s.source        = { :git => "https://github.com/daisuke310vvv/PopupController.git", :tag => s.version.to_s }
  s.source_files  = "Classes/*.swift"
end
