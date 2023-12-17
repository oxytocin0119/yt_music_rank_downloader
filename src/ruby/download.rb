require 'json'
require 'date'
require 'csv'

root_dir = File.expand_path('../../..', __FILE__)
json_dir = File.join(root_dir, "/db/json")
tmp_dir = File.join(json_dir, "/tmp")
data_dir = File.join(json_dir, "/data")
save_dir = File.join(root_dir, "/db/downloads")
all_dir = File.join(save_dir, "/all")
unless Dir.exist?(all_dir)
  Dir.mkdir(all_dir)
end
csv_dir = File.join(root_dir, "/db/csv")


csv_file = File.join(csv_dir, "/download_list.csv")

json_files = Dir.glob(File.join(tmp_dir, '*.json'))

latest_date = nil
latest_file = nil

json_files.each do |json_file|
  match = File.basename(json_file).match(/source_(\d{8})\.json/)
  
  if match
    current_date = Date.parse(match[1])

    if latest_date.nil? || current_date > latest_date
      latest_date = current_date
      latest_file = json_file
    end
  end
end

if latest_date

  json_data = File.read(latest_file)
  hash_data = JSON.parse(json_data)

  date_dir = File.join(save_dir, "/#{latest_date}")

  unless Dir.exist?(date_dir)
    Dir.mkdir(date_dir)
  else
  end

  contents = hash_data["contents"]["sectionListRenderer"]["contents"].first

  #100
  top100 = contents["musicAnalyticsSectionRenderer"]["content"]["trackTypes"].first["trackViews"]
  
  downloads = {}
  csv_data = nil
  if File.exist?(csv_file)
    csv_data = CSV.read(csv_file)
  end

  top100.each_with_index do |elem, index|
    tmp_hash = {
      "name" => elem["name"],
      "url" => "https://youtu.be/#{elem['encryptedVideoId']}"
    }
    downloads["#{index+1}"] = tmp_hash
    begin
      p "#{index+1} #{tmp_hash['name']}"
      tmp_name = tmp_hash['name'].gsub(' ', '_')
      if csv_data && csv_data.any?{ |row| row[1].chomp == tmp_hash['url'].chomp }
        p "downloaded"
      else
        %x(#{root_dir}/bin/yt-dlp --extract-audio --audio-format mp3 --output "#{all_dir}/#{tmp_name}.%(ext)s" #{tmp_hash['url']})
      end
      tmp_file_path = File.join(all_dir, "/#{tmp_name}.mp3")
      if File.exist?(tmp_file_path)
        CSV.open(csv_file, File.exist?(csv_file) ? 'a' : 'w') do |csv|
          csv << [tmp_hash["name"], tmp_hash["url"]]
        end
        symlink_path = File.join(date_dir, "/#{tmp_name}.mp3")
        File.symlink(tmp_file_path, symlink_path)
      end
    rescue
      puts "Failed! #{tmp_hash['name']}"
      puts "#{tmp_hash['url']}"
    end
  end
  
  date = Time.now.strftime('%Y%m%d')

  File.write("#{data_dir}/data_#{date}.json", downloads.to_json)
  
else
  p "not found"
end
