Pod::Spec.new do |s|
  s.name                  = "MeteorPromissum"
  s.version               = "0.0.1"
  s.summary               = "A short description of Meteor+Promissum."
  s.homepage              = "https://github.com/Q42/Meteor-Promissum"
  s.license               = "MIT"
  s.author                = { "Tomas Harkema" => "tomas@harkema.in" }
  s.social_media_url      = "https://twitter.com/tomasharkema"
  s.ios.deployment_target = '8.0'
  s.platform              = :ios, "8.0"
  s.source                = { :git => "https://github.com/Q42/Meteor-Promissum.git", :tag => "0.0.1" }
  s.source_files          = "Meteor+Promissum"

  s.dependency "Meteor"
  s.dependency "Promissum"
end
