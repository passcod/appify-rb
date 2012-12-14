## Appify <https://rubygems.org/gems/appify>
#
# Inspired (and ported, somewhat, from) Adam Backstrom's appify.sh
# (http://git.abackstrom.com/appify.git)
#
# See gemspec for authors and other info.
# Released in the Public Domain.
#
# If such release isn't possible in your legislation,
# this is licensed under the Unlicense: http://unlicense.org
#

require 'pathname'

module Appify
  class App
    def initialize
    end
    
    def run; @run; end
    def run=(cont)
      raise Appify::FileTooShortError.new if cont.length < 28
      @run = cont
    end
    def runfile=(file)
      file = Pathname.new(file) unless file.is_a? Pathname
      raise Appify::FileTooShortError.new if file.size < 28
      @run = file.read
    end
    
    def write(path)
      path = Pathname.new(path) unless path.is_a? Pathname
      path.rmtree if path.exist?
      path.mkpath
      
      runfl = path.join "Contents", "MacOS", "run.sh"
      infop = path.join "Contents", "Info.plist"
      resrc = path.join "Contents", "Resources"
      runfl.dirname.mkpath
      resrc.mkpath
      
      IO.write infop, Appify.info
      IO.write runfl, @run
      runfl.chmod 0755
      
      return path
    end
  end
  
  def self.info
    <<-PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>run.sh</string>
    <key>CFBundleIconFile</key>
    <string></string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
</dict>
</plist>
PLIST
  end
  
  class FileTooShortError < RuntimeError
  end
end