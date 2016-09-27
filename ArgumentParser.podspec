Pod::Spec.new do |s|
  s.name                  = "ArgumentParser"
  s.version               = "0.50"
  s.summary               = "A simple framework for parsing command-line arguments in Swift. Modeled after the Python version."
  s.author                = { "Michael Fessenden" => "michael.fessenden@gmail.com" }
  s.homepage              = "https://github.com/mfessenden/ArgumentParser"
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.osx.deployment_target = '10.10'
  s.source                = { :git => "https://github.com/mfessenden/ArgumentParser.git", :tag => s.version }
  s.source_files          = 'Sources/*.swift'
end
