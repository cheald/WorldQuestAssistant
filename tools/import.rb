require 'yaml'
require 'open-uri'

UA = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36'
WORLD_QUEST_TYPES = %w"111 112 110 136 109"

def get_quests_table(query, type)
  data = open("http://www.wowhead.com/quests/name:#{query}/type:#{type}", 'User-Agent' => UA).read
  y = YAML.load data.match(Regexp.new("Listview\\((.*?)\\);", Regexp::MULTILINE))[1]
  y["data"].sort_by {|q| q["name"] }.map {|q| "[#{q["id"]}] = true,".ljust(20) + "-- #{q["name"]}" }.join("\n")
end

puts get_quests_table "WANTED", WORLD_QUEST_TYPES.join(":")
puts get_quests_table "DANGER", WORLD_QUEST_TYPES.join(":")
