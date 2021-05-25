
require "csv"
 temp_title = temp_artist = temp_genre = "" #既に登録した曲データの一時的記憶域
 song = nil #単なる初期化既に見つけたsongのための記憶場所

CSV.foreach("sample_Fujikawa.csv") do |row|
  # use row here...
  title = row[0]
  artist = row[1]
  genre = row[2]
  section_numbar = row[3]
  key = row[4]
  content = row[5].gsub(/\s/,'')
  
  if (title != nil)
      song = Song.find_or_create_by(user_id:1, title:title, artist:artist, genre:genre )
      chord = song.chords.build(section_numbar:section_numbar, content:content)
      chord.save!
      
      temp_title = title
      temp_artist = artist
      temp_genre = genre
  elsif (title == nil && artist == nil && genre == nil)
     # 確実性を期すならば
     #  song = Song.find_by(user_id: 1,title:temp_title, artist:temp_artist, genre:temp_genre )
     #  で曲を確定させておくのがよいかもしれない　#いまは既にsongがループで確定済みとしての扱い
      chord = song.chords.build(section_numbar:section_numbar, content:content)
      chord.save!
     #  逆にこの時点で temp_titleがnilであることは想定されない事態なので、エラーチェック必要？
  end
end