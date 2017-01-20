Pod::Spec.new do |s|
  s.name         = "TXChatSDK"
  s.version      = "2.2.0"
  s.summary      = "A sdk lib for tuxing chat."
  s.description  = <<-DESC
                   Tuxing chat ios sdk.
                   DESC
  s.homepage     = "http://182.92.236.193/lingqing.wan/txchat_ios_sdk/"
  s.license      = "MIT"
  s.author       = { "lingqingwan" => "" }
  s.source       = { :git => "http://182.92.236.193/ios/txchat_sdk.git", :tag=>s.version.to_s}
  s.source_files  = "Classes", "src/TXChatSDK/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.ios.dependency 'FMDB', '~> 2.5'
  s.ios.dependency 'ProtocolBuffers', '~> 1.9.8'
  s.ios.dependency 'Qiniu', '~> 7.0.11.1'
  s.ios.dependency 'AFNetworking', '~> 2.5.4'
end
