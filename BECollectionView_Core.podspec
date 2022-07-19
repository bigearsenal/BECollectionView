Pod::Spec.new do |s|
  s.name             = 'BECollectionView_Core'
  s.version          = '1.0.0'
  s.summary          = 'Base components for BECollectionView & BECollectionView_Combine.'

  s.description      = <<-DESC
Base components that reusable among BECollectionView & BECollectionView_Combine.
                       DESC

  s.homepage         = 'https://github.com/bigearsenal/BECollectionView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chung Tran' => 'bigearsenal@gmail.com' }
  s.source           = { :git => 'https://github.com/bigearsenal/BECollectionView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Sources/BECollectionView_Core/**/*'
end
