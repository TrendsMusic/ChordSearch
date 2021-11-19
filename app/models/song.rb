class Song < ApplicationRecord
  belongs_to :user
  has_many :chords, dependent: :destroy
  accepts_nested_attributes_for :chords, allow_destroy: true
  
  #CSVファイル読み込み
  def self.import(user, file)
  require "csv"
    CSV.foreach(file.path, headers: true) do |row|
      title = row[0]
      artist = row[1]
      genre = row[2]
      genre = genre.gsub("jazz","Jazz")if (row[2] != nil)
      section_numbar = row[3]
      key = row[4]
      content = row[5].gsub(/\s/, '') if (row[5] != nil)
      #余分な文字の削除と表記の修正
      content = content.gsub("/","on")if (row[5] != nil)
      content = content.gsub("N.C.","")if (row[5] != nil)
      content = content.gsub("N.C","")if (row[5] != nil)
      content = content.gsub("maj","M")if (row[5] != nil)
      content = content.gsub("-","♭")if (row[5] != nil)
      content = content.gsub(",","")if (row[5] != nil)
      
      #度数変換
      if (key == "C"|| key == "Cm")
        content = replace_degree_cymbols_C(content)
        
      elsif (key == "C#"|| key == "C#m")
        content = replace_degree_cymbols_Cup(content)
        
      elsif (key == "D♭"|| key == "D♭m")
        content = replace_degree_cymbols_Ddown(content)
        
      elsif (key == "D"|| key == "Dm")
        content = replace_degree_cymbols_D(content)  
        
      elsif (key == "D#")
        content = content.gsub("F","E#")
        content = content.gsub("G","F##")
        content = content.gsub("C","B#")
        content = content.gsub("D","C##")
        content = replace_degree_cymbols_Dup(content)
      elsif (key == "D#m")
        content = content.gsub("F#","Ⅲ")
        content = content.gsub("F","E#")
        content = replace_degree_cymbols_Dup(content)
        
      elsif (key == "E♭"|| key == "E♭m")
        content = replace_degree_cymbols_Edown(content)  
        
      elsif (key == "E"|| key == "Em")
        content = replace_degree_cymbols_E(content)
        
      elsif (key == "F"|| key == "Fm")
        content = content.gsub("A#","B♭")
        content = replace_degree_cymbols_F(content)
        
      elsif (key == "F#"|| key == "F#m")
        content = replace_degree_cymbols_Fup(content)
        
      elsif (key == "G♭"|| key == "G♭m")
        content = replace_degree_cymbols_Gdown(content)
        
      elsif (key == "G"|| key == "Gm")
        content = replace_degree_cymbols_G(content)  
        
      elsif (key == "G#"|| key == "G#m")
        content = content.gsub("G#","Ⅰ")
        content = content.gsub("G","F##")
        content = replace_degree_cymbols_Gup(content)
        
      elsif (key == "A♭"|| key == "A♭m")
        content = replace_degree_cymbols_Adown(content)
        
      elsif (key == "A"|| key == "Am")
        content = replace_degree_cymbols_A(content)  
        
      elsif (key == "A#")
        content = replace_degree_cymbols_Aup(content) 
        
      elsif (key == "A#m")
        content = content.gsub("C#","Ⅲ")
        content = content.gsub("C","B#")
        content = content.gsub("F#","Ⅵ♭")
        content = content.gsub("F","E#")
        content = replace_degree_cymbols_Aup(content) 
        
      elsif (key == "B♭"|| key == "B♭m")
        content = replace_degree_cymbols_Bdown(content)
        
      elsif (key == "B"|| key == "Bm")
        content = replace_degree_cymbols_B(content)  
      end

        if (title != nil)
            #同じ曲が登録された場合、一度その曲を削除する
            song = user.songs.where(user_id:user.id, title:title, artist:artist, genre:genre)
            if song.present?
              song.destroy_all
            end
            #楽曲の登録
            song = user.songs.find_or_create_by(user_id:user.id, title:title, artist:artist, genre:genre)
            song.chords.find_or_create_by(section_numbar:section_numbar, content:content, key:key)
        elsif (title == nil && artist == nil &&  content != nil && section_numbar != nil)
            #カラムを補完して登録
            title = user.songs.pluck(:title).last
            artist = user.songs.pluck(:artist).last
            if (genre == nil)
            genre = user.songs.pluck(:genre).last
            end
            song = user.songs.find_or_create_by(user_id:user.id, title:title, artist:artist, genre:genre)
            if (key == nil)
              key_songs = Chord.where(song_id: song.id)
              key = key_songs.pluck(:key).last
            end 
            song.chords.find_or_create_by(section_numbar:section_numbar, content:content, key:key)
        end
    end
  end
  
  #検索するためのコードシンボルをフォームから値の受け取る
  def search_preparation(current_user,searchkey)
    #検索ワードの作成
      title = searchkey[:title]
      artist = searchkey[:artist]
      genre = searchkey[:genre]
      key = searchkey[:key]
      section_numbar = searchkey[:section_numbar]
      chord_toSearch = ""
      chord_toSearch_root = ""
      chord_toSearch_ambi = ""
      chords_input = searchkey[:chords_attributes]["0"]
      chords_input[:fields_attributes].each do |key, data|
          chord_toSearch += data[:part1] + data[:part2] + data[:part3] + data[:part4] + data[:part5]+ data[:part6]+ data[:part7]+ data[:part8]
          chord_toSearch_root += data[:part1] + data[:part2]
          chord_toSearch_ambi += data[:part1] + data[:part2] + data[:part3]
      end 
    chord_root = Array.new #根音行列
    chord_ambi = Array.new #テンション無視行列
    
    #検索ワードから合致するレコードの検索
    if (title == "") && (artist == "") && (genre == "") 
        songs = current_user.songs
        chord = Chord.where(song_id: songs.ids)
        unless (key == "" && section_numbar == "")
          chord = chord.where(key:key)
          chord = chord.where("section_numbar LIKE ?", "%#{section_numbar}%")
        end
        
        #根音, ♭, # 以外を消去した仮行列の作成
        chord.each do |chord|
          chord = chord.content
          chord = chord.gsub("dim","")
          chord = chord.gsub("aug","")
          chord = chord.gsub("sus4","")
          chord = chord.gsub("sus2","")
          chord = chord.gsub("M7","")
          chord = chord.gsub("7","")
          chord = chord.gsub("6","")
          chord = chord.gsub("♭5","")
          chord = chord.gsub("add9","")
          chord = chord.gsub("♭9","")
          chord = chord.gsub("#9","")
          chord = chord.gsub("9","")
          chord = chord.gsub("add11","")
          chord = chord.gsub("#11","")
          chord = chord.gsub("♭11","")
          chord = chord.gsub("11","")
          chord = chord.gsub("add13","")
          chord = chord.gsub("♭13","")
          chord = chord.gsub("13","")
          chord = chord.gsub("omit3","")
          chord = chord.gsub("omit5","")
          chord = chord.gsub("m","")
          chord_root << chord
        end
        #part1 ~ part3 以外を消去した仮行列の作成
        chord.each do |chord|
          chord = chord.content
          chord = chord.gsub("M7","")
          chord = chord.gsub("7","")
          chord = chord.gsub("6","")
          #chord = chord.gsub("♭5","")
          chord = chord.gsub("add9","")
          chord = chord.gsub("♭9","")
          chord = chord.gsub("#9","")
          chord = chord.gsub("9","")
          chord = chord.gsub("add11","")
          chord = chord.gsub("#11","")
          chord = chord.gsub("♭11","")
          chord = chord.gsub("11","")
          chord = chord.gsub("add13","")
          chord = chord.gsub("♭13","")
          chord = chord.gsub("13","")
          chord = chord.gsub("omit3","")
          chord = chord.gsub("omit5","")
          chord_ambi << chord
        end
        
        #ここから特定コード検索
        chords = chord.with_content_regexp(chord_toSearch).pluck(:content)
        chords_root = chord_root.select{|x| x.include?("#{chord_toSearch_root}")}
        chords_ambi = chord_ambi.select{|x| x.include?("#{chord_toSearch_ambi}")}
    else
        songs = current_user.songs.where("title like? AND artist like? AND genre like?", "%#{title}%", "%#{artist}%", "%#{genre}%")
        chord = Chord.where(song_id: songs.ids)
        unless (key == "" && section_numbar == "")
          chord = chord.where(key:key)
          chord = chord.where("section_numbar LIKE ?", "%#{section_numbar}%")
        end
         #根音, ♭, # 以外を消去した仮行列の作成
        chord.each do |chord|
          chord = chord.content
          chord = chord.gsub("dim","")
          chord = chord.gsub("aug","")
          chord = chord.gsub("sus4","")
          chord = chord.gsub("sus2","")
          chord = chord.gsub("M7","")
          chord = chord.gsub("7","")
          chord = chord.gsub("6","")
          chord = chord.gsub("♭5","")
          chord = chord.gsub("add9","")
          chord = chord.gsub("♭9","")
          chord = chord.gsub("#9","")
          chord = chord.gsub("9","")
          chord = chord.gsub("add11","")
          chord = chord.gsub("#11","")
          chord = chord.gsub("♭11","")
          chord = chord.gsub("11","")
          chord = chord.gsub("add13","")
          chord = chord.gsub("♭13","")
          chord = chord.gsub("13","")
          chord = chord.gsub("omit3","")
          chord = chord.gsub("omit5","")
          chord = chord.gsub("m","")
          chord_root << chord
        end
        #part1 ~ part3 以外を消去した仮行列の作成
        chord.each do |chord|
          chord = chord.content
          chord = chord.gsub("M7","")
          chord = chord.gsub("7","")
          chord = chord.gsub("6","")
          #chord = chord.gsub("♭5","")
          chord = chord.gsub("add9","")
          chord = chord.gsub("♭9","")
          chord = chord.gsub("#9","")
          chord = chord.gsub("9","")
          chord = chord.gsub("add11","")
          chord = chord.gsub("#11","")
          chord = chord.gsub("♭11","")
          chord = chord.gsub("11","")
          chord = chord.gsub("add13","")
          chord = chord.gsub("♭13","")
          chord = chord.gsub("13","")
          chord = chord.gsub("omit3","")
          chord = chord.gsub("omit5","")
          chord_ambi << chord
        end
        # ここから特定コード検索
        chords = chord.with_content_regexp(chord_toSearch).pluck(:content)
        chords_root = chord_root.select{|x| x.include?("#{chord_toSearch_root}")}
        chords_ambi = chord_ambi.select{|x| x.include?("#{chord_toSearch_ambi}")}
    end
    return [songs, chords, chords_root, chords_ambi, chord_toSearch, chord_toSearch_root, chord_toSearch_ambi, title, artist, genre, key, section_numbar]
  end
   
  #楽曲に対するコードの使用率を算出する まだ2つ出来てない！！
  def using_song_rate (current_user, songs, chords)
    using_songs= songs.joins(:chords).where(chords: {content: chords}).uniq
    #選択した範囲内でそのコード進行がどのくらい楽曲に採用されているか割合を算出する。
    unless songs.count == 0
      using_chord_rate = ((using_songs.length/songs.count.to_f)*100).round(2)
    else
      using_chord_rate = 0
    end
    return [using_songs, using_songs.length, using_chord_rate]
  end
  
  #楽曲に対する根音進行の使用率を算出する
  
  #選択されたコードから次/前のコードを抽出する
  def getnextchords(chords, search_chords)
      if (chords != nil)
        nextchords_000 = Array.new
        chords.each do |chord|
            if chord == nil
                return [nil, 0]
            else
              chord = chord
              nextchords_000 << chord.scan(/#{search_chords}([Ⅰ-Ⅶ](♭|#)?(m)?(dim)?(aug)?(sus4)?(sus2)?(7)?(M7)?(6)?(♭5)?(9)?(add9)?(♭9)?(#9)?(add11)?(11)?(#11)?(add13)?(13)?(♭13)?(omit3)?(omit5)?(on[Ⅰ-Ⅶ](♭|#)?)?)/)
            end
        end
        nextchords = Array.new
        nextchords_000.each do |nextchords_00|
          nextchords_00.each do |nextchords_0|
            nextchords << nextchords_0.first
          end
        end
        backchords_000 = Array.new
          chords.each do |chord|
              if chord == nil
                  return [nil, 0]
              else
                chord = chord
                backchords_000 << chord.scan(/([Ⅰ-Ⅶ](♭|#)?(m)?(dim)?(aug)?(sus4)?(sus2)?(7)?(M7)?(6)?(♭5)?(9)?(add9)?(♭9)?(#9)?(add11)?(11)?(#11)?(add13)?(13)?(♭13)?(omit3)?(omit5)?(on[Ⅰ-Ⅶ](♭|#)?)?)#{search_chords}/)
              end
          end
          backchords = Array.new
          backchords_000.each do |backchords_00|
            backchords_00.each do |backchords_0|
              backchords << backchords_0.first
            end
          end
      else
        raise "Not Found"
      end
      return[nextchords, backchords]
  end
    
  # 更新するカラムを定義する
  def self.updatable_attributes
    ["id", "title", "artist", "key", "genre", ""]
  end
  
  # コード変換
  def self.replace_degree_cymbols_C(str)
    conversions = {
      'C' => 'Ⅰ', 'D' => 'Ⅱ', 'E' => 'Ⅲ', 'F' => 'Ⅳ', 'G' => 'Ⅴ',
      'A' => 'Ⅵ', 'B' => 'Ⅶ'
    }.freeze
    str.gsub(/[#{conversions.keys}]/, conversions)
  end
  
  def self.replace_degree_cymbols_Cup(str)
    str = str.gsub("C#","Ⅰ")
    str = str.gsub("C","Ⅰ♭")
    str = str.gsub("D#","Ⅱ")
    str = str.gsub("D","Ⅱ♭")
    str = str.gsub("E#","Ⅲ")
    str = str.gsub("E","Ⅲ♭")
    str = str.gsub("F#","Ⅳ")
    str = str.gsub("F","Ⅳ♭")
    str = str.gsub("G#","Ⅴ")
    str = str.gsub("G","Ⅴ♭")
    str = str.gsub("A#","Ⅵ")
    str = str.gsub("A","Ⅵ♭")
    str = str.gsub("B#","Ⅶ")
    str = str.gsub("B","Ⅶ♭")
  end
  
  def self.replace_degree_cymbols_Ddown(str)
    str = str.gsub("D♭","Ⅰ")
    str = str.gsub("D","Ⅰ#")
    str = str.gsub("E♭","Ⅱ")
    str = str.gsub("E","Ⅱ#")
    str = str.gsub("F","Ⅲ")
    str = str.gsub("G♭","Ⅳ")
    str = str.gsub("G","Ⅳ#")
    str = str.gsub("A♭","Ⅴ")
    str = str.gsub("A","Ⅴ#")
    str = str.gsub("B♭","Ⅵ")
    str = str.gsub("B","Ⅵ#")
    str = str.gsub("C","Ⅶ")
  end
  
  def self.replace_degree_cymbols_D(str)
    conversions = {
      'D' => 'Ⅰ', 'E' => 'Ⅱ','G' => 'Ⅳ', 'A' => 'Ⅴ',
      'B' => 'Ⅵ'
    }.freeze
    str = str.gsub(/[#{conversions.keys}]/, conversions)
    str = str.gsub("F#","Ⅲ")
    str = str.gsub("F","Ⅲ♭")
    str = str.gsub("C#","Ⅶ")
    str = str.gsub("C","Ⅶ♭")
  end
  
  #ここわからん
  def self.replace_degree_cymbols_Dup(str)
    str = str.gsub("D#","Ⅰ")
    str = str.gsub("D","Ⅰ♭")
    str = str.gsub("E#","Ⅱ")
    str = str.gsub("E","Ⅱ♭")
    str = str.gsub("F##","Ⅲ")
    str = str.gsub("F#","Ⅲ♭")
    str = str.gsub("F","Ⅲ♭♭")
    str = str.gsub("G#","Ⅳ")
    str = str.gsub("G","Ⅳ♭")
    str = str.gsub("A#","V")
    str = str.gsub("A","Ⅴ♭")
    str = str.gsub("B#","Ⅵ")
    str = str.gsub("B","Ⅵ♭")
    str = str.gsub("C##","Ⅶ")
    str = str.gsub("C#","Ⅶ♭")
    str = str.gsub("C","Ⅶ♭♭")
  end
  
  def self.replace_degree_cymbols_Edown(str)
    str = str.gsub("E♭","Ⅰ")
    str = str.gsub("E","Ⅰ#")
    str = str.gsub("F","Ⅱ")
    str = str.gsub("G","Ⅲ")
    str = str.gsub("A♭","Ⅳ")
    str = str.gsub("A","Ⅳ#")
    str = str.gsub("B♭","Ⅴ")
    str = str.gsub("B","Ⅴ#")
    str = str.gsub("C","Ⅵ")
    str = str.gsub("D","Ⅶ")
  end
  
  def self.replace_degree_cymbols_E(str)
    conversions = {
      'E' => 'Ⅰ','A' => 'Ⅳ', 'B' => 'Ⅴ',
    }.freeze
    str = str.gsub(/[#{conversions.keys}]/, conversions)
    str = str.gsub("F#","Ⅱ")
    str = str.gsub("F","Ⅱ♭")
    str = str.gsub("G#","Ⅲ")
    str = str.gsub("G","Ⅲ♭")
    str = str.gsub("C#","Ⅵ")
    str = str.gsub("C","Ⅵ♭")
    str = str.gsub("D#","Ⅶ")
    str = str.gsub("D","Ⅶ♭")
  end
  
  def self.replace_degree_cymbols_F(str)
    conversions = {
      'F' => 'Ⅰ', 'G' => 'Ⅱ', 'A' => 'Ⅲ', 'C' => 'Ⅴ',
      'D' => 'Ⅵ', 'E' => 'Ⅶ'
    }.freeze
    str = str.gsub(/[#{conversions.keys}]/, conversions)
    str = str.gsub("B♭","Ⅳ")
    str = str.gsub("B","Ⅳ#")
  end
  
  def self.replace_degree_cymbols_Fup(str)
    str = str.gsub("F#","Ⅰ")
    str = str.gsub("F","Ⅰ♭")
    str = str.gsub("G#","Ⅱ")
    str = str.gsub("G","Ⅱ♭")
    str = str.gsub("A#","Ⅲ")
    str = str.gsub("A","Ⅲ♭")
    str = str.gsub("B","Ⅳ")
    str = str.gsub("C#","V")
    str = str.gsub("C","Ⅴ♭")
    str = str.gsub("D#","Ⅵ")
    str = str.gsub("D","Ⅵ♭")
    str = str.gsub("E#","Ⅶ")
    str = str.gsub("E","Ⅶ♭")
  end
  
  def self.replace_degree_cymbols_Gdown(str)
    str = str.gsub("G♭","Ⅰ")
    str = str.gsub("G","Ⅰ#")
    str = str.gsub("A♭","Ⅱ")
    str = str.gsub("A","Ⅱ#")
    str = str.gsub("B♭","Ⅲ")
    str = str.gsub("B","Ⅲ#")
    str = str.gsub("C♭","Ⅳ")
    str = str.gsub("C","Ⅳ#")
    str = str.gsub("D♭","Ⅴ")
    str = str.gsub("D","Ⅴ#")
    str = str.gsub("E♭","Ⅵ")
    str = str.gsub("E","Ⅵ#")
    str = str.gsub("F","Ⅶ")
  end
  
  def self.replace_degree_cymbols_G(str)
    conversions = {
      'G' => 'Ⅰ', 'A' => 'Ⅱ', 'B' => 'Ⅲ', 'C' => 'Ⅳ', 'D' => 'Ⅴ',
      'E' => 'Ⅵ'
    }.freeze
    str = str.gsub(/[#{conversions.keys}]/, conversions)
    str = str.gsub("F#","Ⅶ")
  end
  
  def self.replace_degree_cymbols_Gup(str)
    str = str.gsub("G#","Ⅰ")
    str = str.gsub("G","Ⅰ♭")
    str = str.gsub("A#","Ⅱ")
    str = str.gsub("A","Ⅱ♭")
    str = str.gsub("B#","Ⅲ")
    str = str.gsub("B","Ⅲ♭")
    str = str.gsub("C#","Ⅳ")
    str = str.gsub("C","Ⅳ♭")
    str = str.gsub("D#","V")
    str = str.gsub("D","Ⅴ♭")
    str = str.gsub("E#","Ⅵ")
    str = str.gsub("E","Ⅵ♭")
    str = str.gsub("F##","Ⅶ")
    str = str.gsub("F#","Ⅶ♭")
    str = str.gsub("F","Ⅶ♭♭")
  end
  
  def self.replace_degree_cymbols_Adown(str)
    str = str.gsub("A♭","Ⅰ")
    str = str.gsub("A","Ⅰ#")
    str = str.gsub("B♭","Ⅱ")
    str = str.gsub("B","Ⅱ#")
    str = str.gsub("C","Ⅲ")
    str = str.gsub("D♭","Ⅳ")
    str = str.gsub("D","Ⅳ#")
    str = str.gsub("E♭","Ⅴ")
    str = str.gsub("E","Ⅴ#")
    str = str.gsub("F","Ⅵ")
    str = str.gsub("G","Ⅶ")
  end
  
  def self.replace_degree_cymbols_A(str)
    conversions = {
      'A' => 'Ⅰ', 'B' => 'Ⅱ', 'D' => 'Ⅳ', 'E' => 'Ⅴ'
    }.freeze
    str = str.gsub(/[#{conversions.keys}]/, conversions)
    str = str.gsub("C#","Ⅲ")
    str = str.gsub("C","Ⅲ♭")
    str = str.gsub("F#","Ⅵ")
    str = str.gsub("F","Ⅵ♭")
    str = str.gsub("G#","Ⅶ")
    str = str.gsub("G","Ⅶ♭")
  end  
  
  def self.replace_degree_cymbols_Aup(str)
    str = str.gsub("A#","Ⅰ")
    str = str.gsub("A","Ⅰ♭")
    str = str.gsub("B#","Ⅱ")
    str = str.gsub("B","Ⅱ♭")
    str = str.gsub("C##","Ⅲ")
    str = str.gsub("C#","Ⅲ♭")
    str = str.gsub("C","Ⅲ♭♭")
    str = str.gsub("D#","Ⅳ")
    str = str.gsub("D","Ⅳ♭")
    str = str.gsub("E#","V")
    str = str.gsub("E","Ⅴ♭")
    str = str.gsub("F##","Ⅵ")
    str = str.gsub("F#","Ⅵ♭")
    str = str.gsub("F","Ⅵ♭♭")
    str = str.gsub("G##","Ⅶ")
    str = str.gsub("G#","Ⅶ♭")
    str = str.gsub("G","Ⅶ♭♭")
  end
  
  def self.replace_degree_cymbols_Bdown(str)
    str = str.gsub("B♭","Ⅰ")
    str = str.gsub("B","Ⅰ#")
    str = str.gsub("C","Ⅱ")
    str = str.gsub("D","Ⅲ")
    str = str.gsub("E♭","Ⅳ")
    str = str.gsub("E","Ⅳ#")
    str = str.gsub("F","Ⅴ")
    str = str.gsub("G","Ⅵ")
    str = str.gsub("A","Ⅶ")
  end
  
  def self.replace_degree_cymbols_B(str)
    conversions = {
      'B' => 'Ⅰ','E' => 'Ⅳ'
    }.freeze
    str = str.gsub(/[#{conversions.keys}]/, conversions)
    str = str.gsub("C#","Ⅱ")
    str = str.gsub("C","Ⅱ♭")
    str = str.gsub("D#","Ⅲ")
    str = str.gsub("D","Ⅲ♭")
    str = str.gsub("F#","Ⅴ")
    str = str.gsub("F","Ⅴ♭")
    str = str.gsub("G#","Ⅵ")
    str = str.gsub("G","Ⅵ♭")
    str = str.gsub("A#","Ⅶ")
    str = str.gsub("A","Ⅶ♭")
  end
  
  # 行列内の特定の記号を削除するメソッド
  def delete_symbol_root(chord)
      chord = chord.gsub("dim","")
      chord = chord.gsub("aug","")
      chord = chord.gsub("sus4","")
      chord = chord.gsub("sus2","")
      chord = chord.gsub("M7","")
      chord = chord.gsub("7","")
      chord = chord.gsub("6","")
      chord = chord.gsub("♭5","")
      chord = chord.gsub("add9","")
      chord = chord.gsub("♭9","")
      chord = chord.gsub("#9","")
      chord = chord.gsub("9","")
      chord = chord.gsub("add11","")
      chord = chord.gsub("#11","")
      chord = chord.gsub("♭11","")
      chord = chord.gsub("11","")
      chord = chord.gsub("add13","")
      chord = chord.gsub("♭13","")
      chord = chord.gsub("13","")
      chord = chord.gsub("omit3","")
      chord = chord.gsub("omit5","")
      chord = chord.gsub("m","")
    return chord
  end
  
  def delete_symbol_ambi(chord)
      chord = chord.gsub("M7","")
      chord = chord.gsub("7","")
      chord = chord.gsub("6","")
      #chord = chord.gsub("♭5","")
      chord = chord.gsub("add9","")
      chord = chord.gsub("♭9","")
      chord = chord.gsub("#9","")
      chord = chord.gsub("9","")
      chord = chord.gsub("add11","")
      chord = chord.gsub("#11","")
      chord = chord.gsub("♭11","")
      chord = chord.gsub("11","")
      chord = chord.gsub("add13","")
      chord = chord.gsub("♭13","")
      chord = chord.gsub("13","")
      chord = chord.gsub("omit3","")
      chord = chord.gsub("omit5","")
    return chord
  end
  
  #進行率計算
  def chord_calculate (chords)
   #進行したコードを度数ごとに分類化
   root1 = chords.select{|x| x.include?("Ⅰ")} 
    root1dim = root1.select{|x| x.include?("dim")} 
    root1aug = root1.select{|x| x.include?("aug")} 
    root1m = root1.select{|x| x.include?("m")}
    root1_b5 = root1.select{|x| x.include?("♭5")}
    root1sus4 = root1.select{|x| x.include?("sus4")}
    root1sus2 = root1.select{|x| x.include?("sus2")}
   
   root2 = chords.select{|x| x.include?("Ⅱ")} 
    root2dim = root2.select{|x| x.include?("dim")} 
    root2aug = root2.select{|x| x.include?("aug")} 
    root2m = root2.select{|x| x.include?("m")} 
    root2_b5 = root2.select{|x| x.include?("♭5")}
    root2sus4 = root2.select{|x| x.include?("sus4")}
    root2sus2 = root2.select{|x| x.include?("sus2")}
    
   root3 = chords.select{|x| x.include?("Ⅲ")} 
    root3dim = root3.select{|x| x.include?("dim")} 
    root3aug = root3.select{|x| x.include?("aug")} 
    root3m = root3.select{|x| x.include?("m")} 
    root3_b5 = root3.select{|x| x.include?("♭5")}
    root3sus4 = root3.select{|x| x.include?("sus4")}
    root3sus2 = root3.select{|x| x.include?("sus2")}
    
   root4 = chords.select{|x| x.include?("Ⅳ")} 
    root4dim = root4.select{|x| x.include?("dim")} 
    root4aug = root4.select{|x| x.include?("aug")} 
    root4m = root4.select{|x| x.include?("m")} 
    root4_b5 = root4.select{|x| x.include?("♭5")}
    root4sus4 = root4.select{|x| x.include?("sus4")}
    root4sus2 = root4.select{|x| x.include?("sus2")}
    
   root5 = chords.select{|x| x.include?("Ⅴ")}
    root5dim = root5.select{|x| x.include?("dim")} 
    root5aug = root5.select{|x| x.include?("aug")} 
    root5m = root5.select{|x| x.include?("m")} 
    root5_b5 = root5.select{|x| x.include?("♭5")}
    root5sus4 = root5.select{|x| x.include?("sus4")}
    root5sus2 = root5.select{|x| x.include?("sus2")}
    
    
   root6 = chords.select{|x| x.include?("Ⅵ")} 
    root6dim = root6.select{|x| x.include?("dim")} 
    root6aug = root6.select{|x| x.include?("aug")} 
    root6m = root6.select{|x| x.include?("m")} 
    root6_b5 = root6.select{|x| x.include?("♭5")}
    root6sus4 = root6.select{|x| x.include?("sus4")}
    root6sus2 = root6.select{|x| x.include?("sus2")}
    
   root7 = chords.select{|x| x.include?("Ⅶ")} 
    root7dim = root7.select{|x| x.include?("dim")} 
    root7aug = root7.select{|x| x.include?("aug")} 
    root7m = root7.select{|x| x.include?("m")}
    root7_b5 = root7.select{|x| x.include?("♭5")}
    root7sus4 = root7.select{|x| x.include?("sus4")}
    root7sus2 = root7.select{|x| x.include?("sus2")}
   
   root1b = chords.select{|x| x.include?("Ⅰ♭")}
    root1bdim = root1b.select{|x| x.include?("dim")} 
    root1baug = root1b.select{|x| x.include?("aug")} 
    root1bm = root1b.select{|x| x.include?("m")} 
    root1b_b5 = root1b.select{|x| x.include?("♭5")}
    root1bsus4 = root1b.select{|x| x.include?("sus4")}
    root1bsus2 = root1b.select{|x| x.include?("sus2")}


   root2b = chords.select{|x| x.include?("Ⅱ♭")}
    root2bdim = root2b.select{|x| x.include?("dim")} 
    root2baug = root2b.select{|x| x.include?("aug")} 
    root2bm = root2b.select{|x| x.include?("m")} 
    root2b_b5 = root2b.select{|x| x.include?("♭5")}
    root2bsus4 = root2b.select{|x| x.include?("sus4")}
    root2bsus2 = root2b.select{|x| x.include?("sus2")}  
    
    
   root3b = chords.select{|x| x.include?("Ⅲ♭")}
    root3bdim = root3b.select{|x| x.include?("dim")} 
    root3baug = root3b.select{|x| x.include?("aug")} 
    root3bm = root3b.select{|x| x.include?("m")} 
    root3b_b5 = root3b.select{|x| x.include?("♭5")}
    root3bsus4 = root3b.select{|x| x.include?("sus4")}
    root3bsus2 = root3b.select{|x| x.include?("sus2")}
    
   root4b = chords.select{|x| x.include?("Ⅳ♭")}
    root4bdim = root4b.select{|x| x.include?("dim")} 
    root4baug = root4b.select{|x| x.include?("aug")} 
    root4bm = root4b.select{|x| x.include?("m")} 
    root4b_b5 = root4b.select{|x| x.include?("♭5")}
    root4bsus4 = root4b.select{|x| x.include?("sus4")}
    root4bsus2 = root4b.select{|x| x.include?("sus2")}
    
   root5b = chords.select{|x| x.include?("Ⅴ♭")}
    root5bdim = root5b.select{|x| x.include?("dim")} 
    root5baug = root5b.select{|x| x.include?("aug")} 
    root5bm = root5b.select{|x| x.include?("m")} 
    root5b_b5 = root5b.select{|x| x.include?("♭5")}
    root5bsus4 = root5b.select{|x| x.include?("sus4")}
    root5bsus2 = root5b.select{|x| x.include?("sus2")}    
    
   root6b = chords.select{|x| x.include?("Ⅵ♭")}
    root6bdim = root6b.select{|x| x.include?("dim")} 
    root6baug = root6b.select{|x| x.include?("aug")} 
    root6bm = root6b.select{|x| x.include?("m")} 
    root6b_b5 = root6b.select{|x| x.include?("♭5")}
    root6bsus4 = root6b.select{|x| x.include?("sus4")}
    root6bsus2 = root6b.select{|x| x.include?("sus2")}
    
   root7b = chords.select{|x| x.include?("Ⅶ♭")}
    root7bdim = root7b.select{|x| x.include?("dim")} 
    root7baug = root7b.select{|x| x.include?("aug")} 
    root7bm = root7b.select{|x| x.include?("m")} 
    root7b_b5 = root7b.select{|x| x.include?("♭5")}
    root7bsus4 = root7b.select{|x| x.include?("sus4")}
    root7bsus2 = root7b.select{|x| x.include?("sus2")}
   
   root1up = chords.select{|x| x.include?("Ⅰ#")}
    root1updim = root1up.select{|x| x.include?("dim")} 
    root1upaug = root1up.select{|x| x.include?("aug")} 
    root1upm = root1up.select{|x| x.include?("m")} 
    root1up_b5 = root1up.select{|x| x.include?("♭5")}
    root1upsus4 = root1up.select{|x| x.include?("sus4")}
    root1upsus2 = root1up.select{|x| x.include?("sus2")}
    
   root2up = chords.select{|x| x.include?("Ⅱ#")}
    root2updim = root2up.select{|x| x.include?("dim")} 
    root2upaug = root2up.select{|x| x.include?("aug")} 
    root2upm = root2up.select{|x| x.include?("m")} 
    root2up_b5 = root2up.select{|x| x.include?("♭5")}
    root2upsus4 = root2up.select{|x| x.include?("sus4")}
    root2upsus2 = root2up.select{|x| x.include?("sus2")}
   
   root3up = chords.select{|x| x.include?("Ⅲ#")}
    root3updim = root3up.select{|x| x.include?("dim")} 
    root3upaug = root3up.select{|x| x.include?("aug")} 
    root3upm = root3up.select{|x| x.include?("m")} 
    root3up_b5 = root3up.select{|x| x.include?("♭5")}
    root3upsus4 = root3up.select{|x| x.include?("sus4")}
    root3upsus2 = root3up.select{|x| x.include?("sus2")}

   root4up = chords.select{|x| x.include?("Ⅳ#")}
    root4updim = root4up.select{|x| x.include?("dim")} 
    root4upaug = root4up.select{|x| x.include?("aug")} 
    root4upm = root4up.select{|x| x.include?("m")} 
    root4up_b5 = root4up.select{|x| x.include?("♭5")}
    root4upsus4 = root4up.select{|x| x.include?("sus4")}
    root4upsus2 = root4up.select{|x| x.include?("sus2")}

   root5up = chords.select{|x| x.include?("Ⅴ#")}
    root5updim = root5up.select{|x| x.include?("dim")} 
    root5upaug = root5up.select{|x| x.include?("aug")} 
    root5upm = root5up.select{|x| x.include?("m")} 
    root5up_b5 = root5up.select{|x| x.include?("♭5")}
    root5upsus4 = root5up.select{|x| x.include?("sus4")}
    root5upsus2 = root5up.select{|x| x.include?("sus2")}

   root6up = chords.select{|x| x.include?("Ⅵ#")}
    root6updim = root6up.select{|x| x.include?("dim")} 
    root6upaug = root6up.select{|x| x.include?("aug")} 
    root6upm = root6up.select{|x| x.include?("m")} 
    root6up_b5 = root6up.select{|x| x.include?("♭5")}
    root6upsus4 = root6up.select{|x| x.include?("sus4")}
    root6upsus2 = root6up.select{|x| x.include?("sus2")}
    
   root7up = chords.select{|x| x.include?("Ⅶ#")}
    root7updim = root7up.select{|x| x.include?("dim")} 
    root7upaug = root7up.select{|x| x.include?("aug")} 
    root7upm = root7up.select{|x| x.include?("m")} 
    root7up_b5 = root7up.select{|x| x.include?("♭5")}
    root7upsus4 = root7up.select{|x| x.include?("sus4")}
    root7upsus2 = root7up.select{|x| x.include?("sus2")}
    
   #進行率の計算
   chord_size = chords.size
   root1_size = root1.size
    root1dim_size  = root1dim.size
    root1aug_size  = root1aug.size
    root1m_size    = root1m.size
    root1_b5_size  = root1_b5.size
    root1sus4_size = root1sus4.size
    root1sus2_size = root1sus2.size
    
   root2_size = root2.size
    root2dim_size  = root2dim.size
    root2aug_size  = root2aug.size
    root2m_size    = root2m.size
    root2_b5_size  = root2_b5.size
    root2sus4_size = root2sus4.size
    root2sus2_size = root2sus2.size
    
   root3_size = root3.size
    root3dim_size  = root3dim.size
    root3aug_size  = root3aug.size
    root3m_size    = root3m.size
    root3_b5_size  = root3_b5.size
    root3sus4_size = root3sus4.size
    root3sus2_size = root3sus2.size
    
   root4_size = root4.size
    root4dim_size  = root4dim.size
    root4aug_size  = root4aug.size
    root4m_size    = root4m.size
    root4_b5_size  = root4_b5.size
    root4sus4_size = root4sus4.size
    root4sus2_size = root4sus2.size
    
   root5_size = root5.size
    root5dim_size  = root5dim.size
    root5aug_size  = root5aug.size
    root5m_size    = root5m.size
    root5_b5_size  = root5_b5.size
    root5sus4_size = root5sus4.size
    root5sus2_size = root5sus2.size
    
   root6_size = root6.size
    root6dim_size  = root6dim.size
    root6aug_size  = root6aug.size
    root6m_size    = root6m.size
    root6_b5_size  = root6_b5.size
    root6sus4_size = root6sus4.size
    root6sus2_size = root6sus2.size
    
   root7_size = root7.size
    root7dim_size  = root7dim.size
    root7aug_size  = root7aug.size
    root7m_size    = root7m.size
    root7_b5_size  = root7_b5.size
    root7sus4_size = root7sus4.size
    root7sus2_size = root7sus2.size
   
   root1b_size = root1b.size
    root1bdim_size  = root1bdim.size
    root1baug_size  = root1baug.size
    root1bm_size    = root1bm.size
    root1b_b5_size  = root1b_b5.size
    root1bsus4_size = root1bsus4.size
    root1bsus2_size = root1bsus2.size
    
   root2b_size = root2b.size
    root2bdim_size  = root2bdim.size
    root2baug_size  = root2baug.size
    root2bm_size    = root2bm.size
    root2b_b5_size  = root2b_b5.size
    root2bsus4_size = root2bsus4.size
    root2bsus2_size = root2bsus2.size
    
   root3b_size = root3b.size
    root3bdim_size  = root3bdim.size
    root3baug_size  = root3baug.size
    root3bm_size    = root3bm.size
    root3b_b5_size  = root3b_b5.size
    root3bsus4_size = root3bsus4.size
    root3bsus2_size = root3bsus2.size
    
   root4b_size = root4b.size
    root4bdim_size  = root4bdim.size
    root4baug_size  = root4baug.size
    root4bm_size    = root4bm.size
    root4b_b5_size  = root4b_b5.size
    root4bsus4_size = root4bsus4.size
    root4bsus2_size = root4bsus2.size
    
   root5b_size = root5b.size
    root5bdim_size  = root5bdim.size
    root5baug_size  = root5baug.size
    root5bm_size    = root5bm.size
    root5b_b5_size  = root5b_b5.size
    root5bsus4_size = root5bsus4.size
    root5bsus2_size = root5bsus2.size
    
   root6b_size = root6b.size
    root6bdim_size  = root6bdim.size
    root6baug_size  = root6baug.size
    root6bm_size    = root6bm.size
    root6b_b5_size  = root6b_b5.size
    root6bsus4_size = root6bsus4.size
    root6bsus2_size = root6bsus2.size
    
   root7b_size = root7b.size
    root7bdim_size  = root7bdim.size
    root7baug_size  = root7baug.size
    root7bm_size    = root7bm.size
    root7b_b5_size  = root7b_b5.size
    root7bsus4_size = root7bsus4.size
    root7bsus2_size = root7bsus2.size
   
   root1up_size = root1up.size
    root1updim_size  = root1updim.size
    root1upaug_size  = root1upaug.size
    root1upm_size    = root1upm.size
    root1up_b5_size  = root1up_b5.size
    root1upsus4_size = root1upsus4.size
    root1upsus2_size = root1upsus2.size
    
   root2up_size = root2up.size
    root2updim_size  = root2updim.size
    root2upaug_size  = root2upaug.size
    root2upm_size    = root2upm.size
    root2up_b5_size  = root2up_b5.size
    root2upsus4_size = root2upsus4.size
    root2upsus2_size = root2upsus2.size
    
   root3up_size = root3up.size
    root3updim_size  = root3updim.size
    root3upaug_size  = root3upaug.size
    root3upm_size    = root3upm.size
    root3up_b5_size  = root3up_b5.size
    root3upsus4_size = root3upsus4.size
    root3upsus2_size = root3upsus2.size
    
   root4up_size = root4up.size
    root4updim_size  = root4updim.size
    root4upaug_size  = root4upaug.size
    root4upm_size    = root4upm.size
    root4up_b5_size  = root4up_b5.size
    root4upsus4_size = root4upsus4.size
    root4upsus2_size = root4upsus2.size
    
   root5up_size = root5up.size
    root5updim_size  = root5updim.size
    root5upaug_size  = root5upaug.size
    root5upm_size    = root5upm.size
    root5up_b5_size  = root5up_b5.size
    root5upsus4_size = root5upsus4.size
    root5upsus2_size = root5upsus2.size
    
   root6up_size = root6up.size
    root6updim_size  = root6updim.size
    root6upaug_size  = root6upaug.size
    root6upm_size    = root6upm.size
    root6up_b5_size  = root6up_b5.size
    root6upsus4_size = root6upsus4.size
    root6upsus2_size = root6upsus2.size
    
   root7up_size = root7up.size
    root7updim_size  = root7updim.size
    root7upaug_size  = root7upaug.size
    root7upm_size    = root7upm.size
    root7up_b5_size  = root7up_b5.size
    root7upsus4_size = root7upsus4.size
    root7upsus2_size = root7upsus2.size
    
  #ルート音の進行率計算
  root1_rate = (((root1_size - root1b_size - root1up_size)/chord_size.to_f)*100).round(2)
    root1b_rate = ((root1b_size/chord_size.to_f)*100).round(2)
    root1up_rate = ((root1up_size/chord_size.to_f)*100).round(2)
    
  root2_rate = (((root2_size - root2b_size - root2up_size)/chord_size.to_f)*100).round(2)
    root2b_rate = ((root2b_size/chord_size.to_f)*100).round(2)
    root2up_rate = ((root2up_size/chord_size.to_f)*100).round(2)
    
  root3_rate = (((root3_size - root3b_size - root3up_size)/chord_size.to_f)*100).round(2)
    root3b_rate = ((root3b_size/chord_size.to_f)*100).round(2)
    root3up_rate = ((root3up_size/chord_size.to_f)*100).round(2)
    
  root4_rate = (((root4_size - root4b_size - root4up_size)/chord_size.to_f)*100).round(2)
    root4b_rate = ((root4b_size/chord_size.to_f)*100).round(2)
    root4up_rate = ((root4up_size/chord_size.to_f)*100).round(2)
    
  root5_rate = (((root5_size - root5b_size - root5up_size)/chord_size.to_f)*100).round(2)
    root5b_rate = ((root5b_size/chord_size.to_f)*100).round(2)
    root5up_rate = ((root5up_size/chord_size.to_f)*100).round(2)
    
  root6_rate = (((root6_size - root6b_size - root6up_size)/chord_size.to_f)*100).round(2)
    root6b_rate = ((root6b_size/chord_size.to_f)*100).round(2)
    root6up_rate = ((root6up_size/chord_size.to_f)*100).round(2)
  
  root7_rate = (((root7_size - root7b_size - root7up_size)/chord_size.to_f)*100).round(2)
    root7b_rate = ((root7b_size/chord_size.to_f)*100).round(2)
    root7up_rate = ((root7up_size/chord_size.to_f)*100).round(2)
  
  root_rate_data = {"I":root1_rate, "Ⅰ♭":root1b_rate, "Ⅰ#":root1up_rate, "Ⅱ":root2_rate,"Ⅱ♭":root2b_rate,"Ⅱ#":root2up_rate,"Ⅲ":root3_rate,"Ⅲ♭":root3b_rate,'Ⅲ#':root3up_rate,"Ⅳ":root4_rate,"Ⅳ♭":root4b_rate,"Ⅳ#":root4up_rate,"Ⅴ":root5_rate,"Ⅴ♭":root5b_rate,"Ⅴ#":root5up_rate,"Ⅵ":root6_rate,"Ⅵ♭":root6b_rate,"Ⅵ#":root6up_rate,"Ⅶ":root7_rate,"Ⅶ♭":root7b_rate,"Ⅶ#":root7up_rate}
  
  #3和音の進行率計算
  root1try_rate = (((root1_size - (root1aug_size - root1baug_size - root1upaug_size) - (root1m_size - root1bm_size - root1upm_size) - (root1sus4_size - root1bsus4_size - root1upsus4_size) - (root1sus2_size - root1bsus2_size - root1upsus2_size) - root1b_size - root1up_size)/chord_size.to_f)*100).round(2)
  root1dim_rate = (((root1dim_size - root1bdim_size - root1updim_size)/chord_size.to_f)*100).round(2)
  root1aug_rate = (((root1aug_size - root1baug_size - root1upaug_size)/chord_size.to_f)*100).round(2)
  root1m_rate = (((root1m_size - (root1dim_size - root1bdim_size - root1updim_size) - root1bm_size - root1upm_size - (root1_b5_size - root1b_b5_size - root1up_b5_size))/chord_size.to_f)*100).round(2)
  root1_b5_rate = (((root1_b5_size - root1b_b5_size - root1up_b5_size)/chord_size.to_f)*100).round(2)
  root1sus4_rate = (((root1sus4_size - root1bsus4_size - root1upsus4_size)/chord_size.to_f)*100).round(2)
  root1sus2_rate = (((root1sus2_size - root1bsus2_size - root1upsus2_size)/chord_size.to_f)*100).round(2)
  
  root1btry_rate = (((root1b_size - root1baug_size - root1bm_size - root1bsus2_size - root1bsus4_size)/chord_size.to_f)*100).round(2)
  root1bdim_rate = ((root1bdim_size/chord_size.to_f)*100).round(2)
  root1baug_rate = ((root1baug_size/chord_size.to_f)*100).round(2)
  root1bm_rate = (((root1bm_size - root1bdim_size)/chord_size.to_f)*100).round(2)
  root1b_b5_rate = ((root1b_b5_size/chord_size.to_f)*100).round(2)
  root1bsus4_rate = ((root1bsus4_size / chord_size.to_f)*100).round(2)
  root1bsus2_rate = ((root1bsus2_size / chord_size.to_f)*100).round(2)
  
  root1uptry_rate = (((root1up_size - root1upaug_size - root1upm_size - root1upsus2_size - root1upsus4_size)/chord_size.to_f)*100).round(2)
  root1updim_rate = ((root1updim_size/chord_size.to_f)*100).round(2)
  root1upaug_rate = ((root1upaug_size/chord_size.to_f)*100).round(2)
  root1upm_rate = (((root1upm_size - root1updim_size)/chord_size.to_f)*100).round(2)
  root1up_b5_rate = ((root1up_b5_size/chord_size.to_f)*100).round(2)
  root1upsus4_rate = ((root1upsus4_size / chord_size.to_f)*100).round(2)
  root1upsus2_rate = ((root1upsus2_size / chord_size.to_f)*100).round(2)
  
  root2try_rate = (((root2_size - (root2aug_size - root1baug_size - root2upaug_size) - (root2m_size - root2bm_size - root2upm_size) - (root2sus4_size - root2bsus4_size - root2upsus4_size) - (root2sus2_size - root2bsus2_size - root2upsus2_size) - root2b_size - root2up_size)/chord_size.to_f)*100).round(2)
  root2dim_rate = (((root2dim_size - root2bdim_size - root2updim_size)/chord_size.to_f)*100).round(2)
  root2aug_rate = (((root2aug_size - root2baug_size - root2upaug_size)/chord_size.to_f)*100).round(2)
  root2m_rate = (((root2m_size - (root2dim_size - root2bdim_size - root2updim_size) - root2bm_size - root2upm_size - (root2_b5_size - root2b_b5_size - root2up_b5_size))/chord_size.to_f)*100).round(2)
  root2_b5_rate = (((root2_b5_size - root2b_b5_size - root2up_b5_size)/chord_size.to_f)*100).round(2)
  root2sus4_rate = (((root2sus4_size - root2bsus4_size - root2upsus4_size)/chord_size.to_f)*100).round(2)
  root2sus2_rate = (((root2sus2_size - root2bsus2_size - root2upsus2_size)/chord_size.to_f)*100).round(2)

  root2try_rate = (((root2_size - root2aug_size - root2m_size - root2sus4_size- root2sus2_size - root2b_size - root2up_size)/chord_size.to_f)*100).round(2)
  root2dim_rate = (((root2dim_size - root2bdim_size - root2updim_size)/chord_size.to_f)*100).round(2)
  root2aug_rate = (((root2aug_size - root2baug_size - root2upaug_size)/chord_size.to_f)*100).round(2)
  root2m_rate = (((root2m_size - root2dim_size - root2bm_size - root2upm_size)/chord_size.to_f)*100).round(2)
  root2_b5_rate = (((root2_b5_size - root2b_b5_size - root2up_b5_size)/chord_size.to_f)*100).round(2)
  root2sus4_rate = (((root2sus4_size - root2bsus4_size - root2upsus4_size)/chord_size.to_f)*100).round(2)
  root2sus2_rate = (((root2sus2_size - root2bsus2_size - root2upsus2_size)/chord_size.to_f)*100).round(2)

  root2btry_rate = (((root2b_size - root2baug_size - root2bm_size - root2bsus2_size - root2bsus4_size)/chord_size.to_f)*100).round(2)
  root2bdim_rate = ((root2bdim_size/chord_size.to_f)*100).round(2)
  root2baug_rate = ((root2baug_size/chord_size.to_f)*100).round(2)
  root2bm_rate = (((root2bm_size - root2bdim_size)/chord_size.to_f)*100).round(2)
  root2b_b5_rate = ((root2b_b5_size/chord_size.to_f)*100).round(2)
  root2bsus4_rate = ((root2bsus4_size / chord_size.to_f)*100).round(2)
  root2bsus2_rate = ((root2bsus2_size / chord_size.to_f)*100).round(2)

  root2uptry_rate = (((root2up_size - root2upaug_size - root2upm_size - root2upsus2_size - root2upsus4_size)/chord_size.to_f)*100).round(2)
  root2updim_rate = ((root2updim_size/chord_size.to_f)*100).round(2)
  root2upaug_rate = ((root2upaug_size/chord_size.to_f)*100).round(2)
  root2upm_rate = (((root2upm_size - root2updim_size)/chord_size.to_f)*100).round(2)
  root2up_b5_rate = ((root2up_b5_size/chord_size.to_f)*100).round(2)
  root2upsus4_rate = ((root2upsus4_size / chord_size.to_f)*100).round(2)
  root2upsus2_rate = ((root2upsus2_size / chord_size.to_f)*100).round(2)

  root3try_rate = (((root3_size - (root3aug_size - root3baug_size - root3upaug_size) - (root3m_size - root3bm_size - root3upm_size) - (root3sus4_size - root3bsus4_size - root3upsus4_size) - (root3sus2_size - root3bsus2_size - root3upsus2_size) - root3b_size - root3up_size)/chord_size.to_f)*100).round(2)
  root3dim_rate = (((root3dim_size - root3bdim_size - root3updim_size)/chord_size.to_f)*100).round(2)
  root3aug_rate = (((root3aug_size - root3baug_size - root3upaug_size)/chord_size.to_f)*100).round(2)
  root3m_rate = (((root3m_size - (root3dim_size - root3bdim_size - root3updim_size) - root3bm_size - root3upm_size - (root3_b5_size - root3b_b5_size - root3up_b5_size))/chord_size.to_f)*100).round(2)
  root3_b5_rate = (((root3_b5_size - root3b_b5_size - root3up_b5_size)/chord_size.to_f)*100).round(2)
  root3sus4_rate = (((root3sus4_size - root3bsus4_size - root3upsus4_size)/chord_size.to_f)*100).round(2)
  root3sus2_rate = (((root3sus2_size - root3bsus2_size - root3upsus2_size)/chord_size.to_f)*100).round(2)

  root3btry_rate = (((root3b_size - root3baug_size - root3bm_size - root3bsus2_size - root3bsus4_size)/chord_size.to_f)*100).round(2)
  root3bdim_rate = ((root3bdim_size/chord_size.to_f)*100).round(2)
  root3baug_rate = ((root3baug_size/chord_size.to_f)*100).round(2)
  root3bm_rate = (((root3bm_size - root3bdim_size)/chord_size.to_f)*100).round(2)
  root3b_b5_rate = ((root3b_b5_size/chord_size.to_f)*100).round(2)
  root3bsus4_rate = ((root3bsus4_size / chord_size.to_f)*100).round(2)
  root3bsus2_rate = ((root3bsus2_size / chord_size.to_f)*100).round(2)

  root3uptry_rate = (((root3up_size - root3upaug_size - root3upm_size - root3upsus2_size - root3upsus4_size)/chord_size.to_f)*100).round(2)
  root3updim_rate = ((root3updim_size/chord_size.to_f)*100).round(2)
  root3upaug_rate = ((root3upaug_size/chord_size.to_f)*100).round(2)
  root3upm_rate = (((root3upm_size - root3updim_size)/chord_size.to_f)*100).round(2)
  root3up_b5_rate = ((root3up_b5_size/chord_size.to_f)*100).round(2)
  root3upsus4_rate = ((root3upsus4_size / chord_size.to_f)*100).round(2)
  root3upsus2_rate = ((root3upsus2_size / chord_size.to_f)*100).round(2)

  root4try_rate = (((root4_size - (root4aug_size - root4baug_size - root4upaug_size) - (root4m_size - root4bm_size - root4upm_size) - (root4sus4_size - root4bsus4_size - root4upsus4_size) - (root4sus2_size - root4bsus2_size - root4upsus2_size) - root4b_size - root4up_size)/chord_size.to_f)*100).round(2)
  root4dim_rate = (((root4dim_size - root4bdim_size - root4updim_size)/chord_size.to_f)*100).round(2)
  root4aug_rate = (((root4aug_size - root4baug_size - root4upaug_size)/chord_size.to_f)*100).round(2)
  root4m_rate = (((root4m_size - (root4dim_size - root4bdim_size - root4updim_size) - root4bm_size - root4upm_size - (root4_b5_size - root4b_b5_size - root4up_b5_size))/chord_size.to_f)*100).round(2)
  root4_b5_rate = (((root4_b5_size - root4b_b5_size - root4up_b5_size)/chord_size.to_f)*100).round(2)
  root4sus4_rate = (((root4sus4_size - root4bsus4_size - root4upsus4_size)/chord_size.to_f)*100).round(2)
  root4sus2_rate = (((root4sus2_size - root4bsus2_size - root4upsus2_size)/chord_size.to_f)*100).round(2)

  root4btry_rate = (((root4b_size - root4baug_size - root4bm_size - root4bsus2_size - root4bsus4_size)/chord_size.to_f)*100).round(2)
  root4bdim_rate = ((root4bdim_size/chord_size.to_f)*100).round(2)
  root4baug_rate = ((root4baug_size/chord_size.to_f)*100).round(2)
  root4bm_rate = (((root4bm_size - root4bdim_size)/chord_size.to_f)*100).round(2)
  root4b_b5_rate = ((root4b_b5_size/chord_size.to_f)*100).round(2)
  root4bsus4_rate = ((root4bsus4_size / chord_size.to_f)*100).round(2)
  root4bsus2_rate = ((root4bsus2_size / chord_size.to_f)*100).round(2)

  root4uptry_rate = (((root4up_size - root4upaug_size - root4upm_size - root4upsus2_size - root4upsus4_size)/chord_size.to_f)*100).round(2) 
  root4updim_rate = ((root4updim_size/chord_size.to_f)*100).round(2)
  root4upaug_rate = ((root4upaug_size/chord_size.to_f)*100).round(2)
  root4upm_rate = (((root4upm_size - root4updim_size)/chord_size.to_f)*100).round(2)
  root4up_b5_rate = ((root4up_b5_size/chord_size.to_f)*100).round(2)
  root4upsus4_rate = ((root4upsus4_size / chord_size.to_f)*100).round(2)
  root4upsus2_rate = ((root4upsus2_size / chord_size.to_f)*100).round(2)

  root5try_rate = (((root5_size - (root5aug_size - root5baug_size - root5upaug_size) - (root5m_size - root5bm_size - root5upm_size) - (root5sus4_size - root5bsus4_size - root5upsus4_size) - (root5sus2_size - root5bsus2_size - root5upsus2_size) - root5b_size - root5up_size)/chord_size.to_f)*100).round(2)
  root5dim_rate = (((root5dim_size - root5bdim_size - root5updim_size)/chord_size.to_f)*100).round(2)
  root5aug_rate = (((root5aug_size - root5baug_size - root5upaug_size)/chord_size.to_f)*100).round(2)
  root5m_rate = (((root5m_size - (root5dim_size - root5bdim_size - root5updim_size) - root5bm_size - root5upm_size - (root5_b5_size - root5b_b5_size - root5up_b5_size))/chord_size.to_f)*100).round(2)
  root5_b5_rate = (((root5_b5_size - root5b_b5_size - root5up_b5_size)/chord_size.to_f)*100).round(2)
  root5sus4_rate = (((root5sus4_size - root5bsus4_size - root5upsus4_size)/chord_size.to_f)*100).round(2)
  root5sus2_rate = (((root5sus2_size - root5bsus2_size - root5upsus2_size)/chord_size.to_f)*100).round(2)

  root5btry_rate = (((root5b_size - root5baug_size - root5bm_size - root5bsus2_size - root5bsus4_size)/chord_size.to_f)*100).round(2)
  root5bdim_rate = ((root5bdim_size/chord_size.to_f)*100).round(2)
  root5baug_rate = ((root5baug_size/chord_size.to_f)*100).round(2)
  root5bm_rate = (((root5bm_size - root5bdim_size)/chord_size.to_f)*100).round(2)
  root5b_b5_rate = ((root5b_b5_size/chord_size.to_f)*100).round(2)
  root5bsus4_rate = ((root5bsus4_size / chord_size.to_f)*100).round(2)
  root5bsus2_rate = ((root5bsus2_size / chord_size.to_f)*100).round(2)

  root5uptry_rate = (((root5up_size - root5upaug_size - root5upm_size - root5upsus2_size - root5upsus4_size)/chord_size.to_f)*100).round(2)
  root5updim_rate = ((root5updim_size/chord_size.to_f)*100).round(2)
  root5upaug_rate = ((root5upaug_size/chord_size.to_f)*100).round(2)
  root5upm_rate = (((root5upm_size - root5updim_size)/chord_size.to_f)*100).round(2)
  root5up_b5_rate = ((root5up_b5_size/chord_size.to_f)*100).round(2)
  root5upsus4_rate = ((root5upsus4_size / chord_size.to_f)*100).round(2)
  root5upsus2_rate = ((root5upsus2_size / chord_size.to_f)*100).round(2)
  
  root6try_rate = (((root6_size - (root6aug_size - root6baug_size - root6upaug_size) - (root6m_size - root6bm_size - root6upm_size) - (root6sus4_size - root6bsus4_size - root6upsus4_size) - (root6sus2_size - root6bsus2_size - root6upsus2_size) - root6b_size - root6up_size)/chord_size.to_f)*100).round(2)
  root6dim_rate = (((root6dim_size - root6bdim_size - root6updim_size)/chord_size.to_f)*100).round(2)
  root6aug_rate = (((root6aug_size - root6baug_size - root6upaug_size)/chord_size.to_f)*100).round(2)
  root6m_rate = (((root6m_size - (root6dim_size - root6bdim_size - root6updim_size) - root6bm_size - root6upm_size - (root6_b5_size - root6b_b5_size - root6up_b5_size))/chord_size.to_f)*100).round(2)
  root6_b5_rate = (((root6_b5_size - root6b_b5_size - root6up_b5_size)/chord_size.to_f)*100).round(2)
  root6sus4_rate = (((root6sus4_size - root6bsus4_size - root6upsus4_size)/chord_size.to_f)*100).round(2)
  root6sus2_rate = (((root6sus2_size - root6bsus2_size - root6upsus2_size)/chord_size.to_f)*100).round(2)

  root6btry_rate = (((root6b_size - root6baug_size - root6bm_size - root6bsus2_size - root6bsus4_size)/chord_size.to_f)*100).round(2) 
  root6bdim_rate = ((root6bdim_size/chord_size.to_f)*100).round(2)
  root6baug_rate = ((root6baug_size/chord_size.to_f)*100).round(2)
  root6bm_rate = (((root6bm_size - root6bdim_size)/chord_size.to_f)*100).round(2)
  root6b_b5_rate = ((root6b_b5_size/chord_size.to_f)*100).round(2)
  root6bsus4_rate = ((root6bsus4_size / chord_size.to_f)*100).round(2)
  root6bsus2_rate = ((root6bsus2_size / chord_size.to_f)*100).round(2)

  root6uptry_rate = (((root6up_size - root6upaug_size - root6upm_size - root6upsus2_size - root6upsus4_size)/chord_size.to_f)*100).round(2)
  root6updim_rate = ((root6updim_size/chord_size.to_f)*100).round(2)
  root6upaug_rate = ((root6upaug_size/chord_size.to_f)*100).round(2)
  root6upm_rate = (((root6upm_size - root6updim_size)/chord_size.to_f)*100).round(2)
  root6up_b5_rate = ((root6up_b5_size/chord_size.to_f)*100).round(2)
  root6upsus4_rate = ((root6upsus4_size / chord_size.to_f)*100).round(2)
  root6upsus2_rate = ((root6upsus2_size / chord_size.to_f)*100).round(2)
  
  root7try_rate = (((root7_size - (root7aug_size - root7baug_size - root7upaug_size) - (root7m_size - root7bm_size - root7upm_size) - (root7sus4_size - root7bsus4_size - root7upsus4_size) - (root7sus2_size - root7bsus2_size - root7upsus2_size) - root7b_size - root7up_size)/chord_size.to_f)*100).round(2)
  root7dim_rate = (((root7dim_size - root7bdim_size - root7updim_size)/chord_size.to_f)*100).round(2)
  root7aug_rate = (((root7aug_size - root7baug_size - root7upaug_size)/chord_size.to_f)*100).round(2)
  root7m_rate = (((root7m_size - (root7dim_size - root7bdim_size - root7updim_size) - root7bm_size - root7upm_size - (root7_b5_size - root7b_b5_size - root7up_b5_size))/chord_size.to_f)*100).round(2)
  root7_b5_rate = (((root7_b5_size - root7b_b5_size - root7up_b5_size)/chord_size.to_f)*100).round(2)
  root7sus4_rate = (((root7sus4_size - root7bsus4_size - root7upsus4_size)/chord_size.to_f)*100).round(2)
  root7sus2_rate = (((root7sus2_size - root7bsus2_size - root7upsus2_size)/chord_size.to_f)*100).round(2)

  root7btry_rate = (((root7b_size - root7baug_size - root7bm_size - root7bsus2_size - root7bsus4_size)/chord_size.to_f)*100).round(2)
  root7bdim_rate = ((root7bdim_size/chord_size.to_f)*100).round(2)
  root7baug_rate = ((root7baug_size/chord_size.to_f)*100).round(2)
  root7bm_rate = (((root7bm_size - root7bdim_size)/chord_size.to_f)*100).round(2)
  root7b_b5_rate = ((root7b_b5_size/chord_size.to_f)*100).round(2)
  root7bsus4_rate = ((root7bsus4_size / chord_size.to_f)*100).round(2)
  root7bsus2_rate = ((root7bsus2_size / chord_size.to_f)*100).round(2)

  root7uptry_rate = (((root7up_size - root7upaug_size - root7upm_size - root7upsus2_size - root7upsus4_size)/chord_size.to_f)*100).round(2) 
  root7updim_rate = ((root7updim_size/chord_size.to_f)*100).round(2)
  root7upaug_rate = ((root7upaug_size/chord_size.to_f)*100).round(2)
  root7upm_rate = (((root7upm_size - root7updim_size)/chord_size.to_f)*100).round(2)
  root7up_b5_rate = ((root7up_b5_size/chord_size.to_f)*100).round(2)
  root7upsus4_rate = ((root7upsus4_size / chord_size.to_f)*100).round(2)
  root7upsus2_rate = ((root7upsus2_size / chord_size.to_f)*100).round(2)
  
  ambi_rate_data = {"Ⅰ":root1try_rate,"Ⅰm":root1m_rate,"Ⅰm♭5":root1_b5_rate,"Ⅰdim":root1dim_rate,"Ⅰaug":root1aug_rate,"Ⅰsus4":root1sus4_rate,"Ⅰsus2":root1sus2_rate,
                    "Ⅰ♭":root1btry_rate,"Ⅰm♭":root1bm_rate,"Ⅰ♭m♭5":root1b_b5_rate,"Ⅰ♭dim":root1bdim_rate,"Ⅰ♭aug":root1baug_rate,"Ⅰ♭sus4":root1bsus4_rate,"Ⅰ♭sus2":root1bsus2_rate,
                    "Ⅰ#":root1uptry_rate,"Ⅰ#m":root1upm_rate,"Ⅰ#m♭5":root1up_b5_rate,"Ⅰ#dim":root1updim_rate,"Ⅰ#aug":root1upaug_rate,"Ⅰ#sus4":root1upsus4_rate,"Ⅰ#sus2":root1upsus2_rate,
                    "Ⅱ":root2try_rate, "Ⅱm":root2m_rate, "Ⅱm♭5":root2_b5_rate, "Ⅱdim":root2dim_rate,"Ⅱaug":root2aug_rate,"Ⅱsus4":root2sus4_rate,"Ⅱsus2":root2sus2_rate,
                    "Ⅱ♭":root2btry_rate,"Ⅱ♭m":root2bm_rate,"Ⅱ♭m♭5":root2b_b5_rate,"Ⅱ♭dim":root2bdim_rate,"Ⅱ♭aug":root2baug_rate,"Ⅱ♭sus4":root2bsus4_rate,"Ⅱ♭sus2":root2bsus2_rate,
                    "Ⅱ#":root2uptry_rate,"Ⅱ#m":root2upm_rate,"Ⅱ#m♭5":root2up_b5_rate,"Ⅱ#dim":root2updim_rate,"Ⅱ#aug":root2upaug_rate,"Ⅱ#sus4":root2upsus4_rate,"Ⅱ#sus2":root2upsus2_rate,
                    "Ⅲ":root3try_rate,"Ⅲm":root3m_rate,"Ⅲm♭5":root3_b5_rate,"Ⅲdim":root3dim_rate,"Ⅲaug":root3aug_rate,"Ⅲsus4":root3sus4_rate,"Ⅲsus2":root3sus2_rate,
                    "Ⅲ♭":root3btry_rate,"Ⅲ♭m":root3bm_rate,"Ⅲ♭m♭5":root3b_b5_rate,"Ⅲ♭dim":root3bdim_rate,"Ⅲ♭aug":root3baug_rate,"Ⅲ♭sus4":root3bsus4_rate,"Ⅲ♭sus2":root3bsus2_rate,
                    "Ⅲ#":root3uptry_rate,"Ⅲ#m":root3upm_rate,"Ⅲ#m♭5":root3up_b5_rate,"Ⅲ#dim":root3updim_rate,"Ⅲ#aug":root3upaug_rate,"Ⅲ#sus4":root3upsus4_rate,"Ⅲ#sus2":root3upsus2_rate,
                    "Ⅳ":root4try_rate,"Ⅳm":root4m_rate,"Ⅳm♭5":root4_b5_rate,"Ⅳdim":root4dim_rate,"Ⅳaug":root4aug_rate,"Ⅳsus4":root4sus4_rate,"Ⅳsus2":root4sus2_rate,
                    "Ⅳ♭":root4btry_rate,"Ⅳ♭m":root4bm_rate,"Ⅳ♭m♭5":root4b_b5_rate,"Ⅳ♭dim":root4bdim_rate,"Ⅳ♭aug":root4baug_rate,"Ⅳ♭sus4":root4bsus4_rate,"Ⅳ♭sus2":root4bsus2_rate,
                    "Ⅳ#":root4uptry_rate,"Ⅳ#m":root4upm_rate,"Ⅳ#m♭5":root4up_b5_rate,"Ⅳ#dim":root4updim_rate,"Ⅳ#aug":root4upaug_rate,"Ⅳ#sus4":root4upsus4_rate,"Ⅳ#sus2":root4upsus2_rate,
                    "Ⅴ":root5try_rate,"Ⅴm":root5m_rate,"Ⅴm♭5":root5_b5_rate,"Ⅴdim":root5dim_rate,"Ⅴaug":root5aug_rate,"Ⅴsus4":root5sus4_rate,"Ⅴsus2":root5sus2_rate,
                    "Ⅴ♭":root5btry_rate,"Ⅴ♭m":root5bm_rate,"Ⅴ♭m♭5":root5b_b5_rate,"Ⅴ♭dim":root5bdim_rate,"Ⅴ♭aug":root5baug_rate,"Ⅴ♭sus4":root5bsus4_rate,"Ⅴ♭sus2":root5bsus2_rate,
                    "Ⅴ#":root5uptry_rate,"Ⅴ#m":root5upm_rate,"Ⅴ#m♭5":root5up_b5_rate,"Ⅴ#dim":root5updim_rate,"Ⅴ#aug":root5upaug_rate,"Ⅴ#sus4":root5upsus4_rate,"Ⅴ#sus2":root5upsus2_rate,
                    "Ⅵ":root6try_rate,"Ⅵm":root6m_rate,"Ⅵm♭5":root6_b5_rate,"Ⅵdim":root6dim_rate,"Ⅵaug":root6sus4_rate,"Ⅵsus4":root6sus4_rate,"Ⅵsus2":root6sus2_rate,
                    "Ⅵ♭":root6btry_rate,"Ⅵ♭m":root6bm_rate,"Ⅵ♭m♭5":root6b_b5_rate,"Ⅵ♭dim":root6bdim_rate,"Ⅵ♭aug":root6baug_rate,"Ⅵ♭sus4":root6bsus4_rate,"Ⅵ♭sus2":root6bsus2_rate,
                    "Ⅵ#":root6uptry_rate,"Ⅵ#m":root6upm_rate,"Ⅵ#m♭5":root6up_b5_rate,"Ⅵ#dim":root6updim_rate,"Ⅵ#aug":root6upaug_rate,"Ⅵ#sus4":root6upsus4_rate,"Ⅵ#sus2":root6upsus2_rate,
                    "Ⅶ":root7try_rate,"Ⅶm":root7m_rate,"Ⅶm♭5":root7_b5_rate,"Ⅶdim":root7dim_rate,"Ⅶaug":root7aug_rate,"Ⅶsus4":root7sus4_rate,"Ⅶsus2":root7sus2_rate,
                    "Ⅶ♭":root7btry_rate,"Ⅶ♭m":root7bm_rate,"Ⅶ♭m♭5":root7b_b5_rate,"Ⅶ♭dim":root7bdim_rate,"Ⅶ♭aug":root7baug_rate,"Ⅶ♭sus4":root7bsus4_rate,"Ⅶ♭sus2":root7bsus2_rate,
                    "Ⅶ#":root7uptry_rate,"Ⅶ#m":root7upm_rate,"Ⅶ#m♭5":root7up_b5_rate,"Ⅶ#dim":root7updim_rate,"Ⅶ#aug":root7upaug_rate,"Ⅶ#sus4":root7upsus4_rate,"Ⅶ#sus2":root7upsus2_rate}
  return[root_rate_data,ambi_rate_data]
  end
  
end
