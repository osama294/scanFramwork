
Pod::Spec.new do |s|

s.name         = "scanCocoaPod"
s.version      = "1.0.0"
s.summary      = "This is Scanning Framwork for Covid Lateral Devices"
s.description  = "This is for multiple project, scan the test results, QR Scan and Device Size"
s.homepage     = "https://github.com/osama294/scanFramwork"
s.license      = "MIT"
s.author       = { "OSAMA SHIRAZ" => "osamashiraz60@gmail.com" }
s.platform     = :ios, "14.0"
s.source       = { :git => "https://github.com/osama294/scanFramwork.git", :tag => "1.0.0" }
s.source_files = "scanCocoaPod","scanCocoaPod/**/*.{h,m}"

end
