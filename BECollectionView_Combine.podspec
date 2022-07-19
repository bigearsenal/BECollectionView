Pod::Spec.new do |s|
  s.name             = 'BECollectionView_Combine'
  s.version          = '1.0.0'
  s.summary          = 'An easy data-driven CollectionView with Combine.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/bigearsenal/BECollectionView'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chung Tran' => 'bigearsenal@gmail.com' }
  s.source           = { :git => 'https://github.com/bigearsenal/BECollectionView.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/BECollectionView_Combine/**/*'
  
  # s.resource_bundles = {
  #   'BECollectionView' => ['BECollectionView/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'BECollectionView_Core'
  s.dependency 'CombineCocoa', '~> 0.4.0'
end
