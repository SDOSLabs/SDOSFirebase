@version = "3.0.0"
Pod::Spec.new do |spec|
  spec.platform     = :ios, '10.0'
  spec.name         = 'SDOSFirebase'
  spec.authors      = 'SDOS'
  spec.version      = @version
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://github.com/SDOSLabs/SDOSFirebase'
  spec.summary      = 'Librería para integrar las analíticas de Firebase'
  spec.source       = { :git => "https://github.com/SDOSLabs/SDOSFirebase.git", :tag => "#{spec.version}" }
  spec.framework    = ['Foundation', 'UIKit']
  spec.requires_arc = true

  spec.subspec 'SDOSFirebase' do |s2|
    s2.preserve_paths = 'src/Classes/*'
    s2.source_files = ['src/Classes/*{*.m,*.h,*.swift}', 'src/Classes/**/*{*.m,*.h,*.swift}']
  end

  spec.dependency 'Firebase/Analytics', '~> 7.0'
  spec.static_framework = true

end
