use_frameworks!

link_with 'MeteorPromissum', 'MeteorPromissumTests'

pod 'Meteor'
pod 'Promissum'

post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end