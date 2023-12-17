require 'net/http'
require 'json'

root_dir = File.expand_path('../../..', __FILE__)
json_dir = File.join(root_dir, "/db/json")
tmp_dir = File.join(json_dir, "/tmp")

url = URI.parse('https://charts.youtube.com/youtubei/v1/browse?alt=json&key=AIzaSyCzEW7JUJdSql0-2V4tHUb6laYm4iAE_dM')

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true if url.scheme == 'https'

headers = {
  'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0',
  'Accept' => '*/*',
  'Accept-Language' => 'ja,en-US;q=0.7,en;q=0.3',
  'Content-Type' => 'application/json',
  'X-Goog-Visitor-Id' => '',
  'X-YouTube-Client-Name' => '31',
  'X-YouTube-Client-Version' => '2.0',
  'X-YouTube-Page-CL' => '585811258',
  'X-YouTube-Utc-Offset' => '540',
  'X-YouTube-Time-Zone' => 'Asia/Tokyo',
  'X-YouTube-Ad-Signals' => 'dt=1702689386579&flash=0&frm&u_tz=540&u_his=3&u_h=768&u_w=1366&u_ah=736&u_aw=1366&u_cd=24&bc=31&bih=619&biw=866&brdim=0%2C0%2C0%2C0%2C1366%2C0%2C1366%2C704%2C866%2C619&vis=1&wgl=true&ca_type=image',
  'Origin' => 'https://charts.youtube.com',
  'Alt-Used' => 'charts.youtube.com',
  'Connection' => 'keep-alive',
  'Referer' => 'https://charts.youtube.com/charts/TopSongs/jp/weekly',
  'Cookie' => 'VISITOR_INFO1_LIVE=jmq1xL2lehs; PREF=tz=Asia.Tokyo; YSC=kld_YupIO84; VISITOR_PRIVACY_METADATA=CgJKUBIEGgAgFQ%3D%3D',
  'Sec-Fetch-Dest' => 'empty',
  'Sec-Fetch-Mode' => 'cors',
  'Sec-Fetch-Site' => 'same-origin',
  'TE' => 'trailers'
}

data = {
  'context' => {
    'client' => {
      'clientName' => 'WEB_MUSIC_ANALYTICS',
      'clientVersion' => '2.0',
      'hl' => 'ja',
      'gl' => 'JP',
      'experimentIds' => [],
      'experimentsToken' => '',
      'theme' => 'MUSIC'
    },
    'capabilities' => {},
    'request' => {
      'internalExperimentFlags' => []
    }
  },
  'browseId' => 'FEmusic_analytics_charts_home',
  'query' => 'perspective=CHART_DETAILS&chart_params_country_code=jp&chart_params_chart_type=TRACKS&chart_params_period_type=WEEKLY'
}

response = http.post(url.path, data.to_json, headers)

date = Time.now.strftime('%Y%m%d')

File.write("#{tmp_dir}/source_#{date}.json", response.body)
