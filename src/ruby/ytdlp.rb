require 'net/http'
require 'open-uri'
require 'fileutils'

root_dir = File.expand_path('../../..', __FILE__)
bin_dir = File.join(root_dir, '/bin')

file_path = File.join(bin_dir, '/yt-dlp')

yt_dlp_path = %x(which yt-dlp).chomp
if File.exist?(file_path)
  #なにもしない
elsif %x(which yt-dlp) == ""
  url = 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp'
  open(file_path, 'wb') do |pass|
    URI.open(url) do |recieve|
      pass.write(recieve.read)
    end
  end


  FileUtils.chmod('+rx', file_path)

else
  File.symlink(yt_dlp_path, file_path)
end
