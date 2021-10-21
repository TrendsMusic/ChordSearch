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
      section_numbar = row[3]
      key = row[4]
      content = row[5].gsub(/\s/, '') if (row[5] != nil)
      #度数変換
      if (key == "C"|| key == "Cm")
        content = replace_degree_cymbols_C(content)
        
      elsif (key == "C#"|| key == "C#m")
        content = replace_degree_cymbols_Cup(content)
        
      elsif (key == "D♭"|| key == "D♭m")
        content = replace_degree_cymbols_Ddown(content)
        
      elsif (key == "D"|| key == "Dm")
        content = replace_degree_cymbols_D(content)  
        
      elsif (key == "D#"|| key == "D#m")
        content = replace_degree_cymbols_Dup(content)
        
      elsif (key == "E♭"|| key == "E♭m")
        content = replace_degree_cymbols_Edown(content)  
        
      elsif (key == "E"|| key == "Em")
        content = replace_degree_cymbols_E(content)
        
      elsif (key == "F"|| key == "Fm")
        content = replace_degree_cymbols_F(content)
        
      elsif (key == "F#"|| key == "F#m")
        content = replace_degree_cymbols_Fup(content)
        
      elsif (key == "G♭"|| key == "G♭m")
        content = replace_degree_cymbols_Gdown(content)
        
      elsif (key == "G"|| key == "Gm")
        content = replace_degree_cymbols_G(content)  
        
      elsif (key == "G#"|| key == "G#m")
        content = replace_degree_cymbols_Gup(content)
        
      elsif (key == "A♭"|| key == "A♭m")
        content = replace_degree_cymbols_Adown(content)
        
      elsif (key == "A"|| key == "Am")
        content = replace_degree_cymbols_A(content)  
      
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
          chord_ambi << chord
        end
        # ここから特定コード検索
        chords = chord.with_content_regexp(chord_toSearch).pluck(:content)
        chords_root = chord_root.select{|x| x.include?("#{chord_toSearch_root}")}
        chords_ambi = chord_ambi.select{|x| x.include?("#{chord_toSearch_ambi}")}
    end
    return [songs, chords, chords_root, chords_ambi, chord_toSearch, chord_toSearch_root, chord_toSearch_ambi]
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
    str = str.gsub("F#","Ⅲ")
    str = str.gsub("F","Ⅲ♭")
    str = str.gsub("G#","Ⅳ")
    str = str.gsub("G","Ⅳ♭")
    str = str.gsub("A#","V")
    str = str.gsub("A","Ⅴ♭")
    str = str.gsub("B#","Ⅵ")
    str = str.gsub("B","Ⅵ♭")
    str = str.gsub("C#","Ⅶ")
    str = str.gsub("C","Ⅵ♭")
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
    str = str.gsub("E","Ⅵ♭")
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
    str = str.gsub("F","Ⅵ♭♭")
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
    return chord
  end
  
  #進行率計算
  def chord_calculate (chords)
   #進行したコードを度数ごとに分類化
   root1 = chords.select{|x| x.include?("Ⅰ")} 
   root2 = chords.select{|x| x.include?("Ⅱ")} 
   root3 = chords.select{|x| x.include?("Ⅲ")} 
   root4 = chords.select{|x| x.include?("Ⅳ")} 
   root5 = chords.select{|x| x.include?("Ⅴ")}
   root6 = chords.select{|x| x.include?("Ⅵ")} 
   root7 = chords.select{|x| x.include?("Ⅶ")} 
   root1b = chords.select{|x| x.include?("Ⅰ♭")}
   root2b = chords.select{|x| x.include?("Ⅱ♭")}
   root3b = chords.select{|x| x.include?("Ⅲ♭")}
   root4b = chords.select{|x| x.include?("Ⅳ♭")}
   root5b = chords.select{|x| x.include?("Ⅴ♭")}
   root6b = chords.select{|x| x.include?("Ⅵ♭")}
   root7b = chords.select{|x| x.include?("Ⅶ♭")}
   #進行率の計算
   #binding.pry
   #root1_rate = (((root1.size)-(root1b.size))/chords.size).to_f*100).round(2)
  end
  
end
