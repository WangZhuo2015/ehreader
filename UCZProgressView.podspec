Pod::Spec.new do |s|
s.name             = "UCZProgressView"
s.version          = "0.0.1"
s.summary          = "Easy-to-use and highly customizable fullscreen image gallery with support for local and remote images written in Swift."

s.description      = <<-DESC
DESC

s.homepage         = "https://github.com/zzycami/UCZProgressView"
s.license          = 'MIT'
s.author           = { "zzycami" => "zzycami@gmail.com" }
s.source           = { :git => "https://github.com/zzycami/UCZProgressView.git", :tag => s.version.to_s }

s.platform     = :ios, '8.0'
s.requires_arc = true

s.source_files = 'UCZProgressView/Classes/**/*'
s.resource_bundles = {
    'CollieGallery' => ['UCZProgressView/Assets/*.png']
}
end
