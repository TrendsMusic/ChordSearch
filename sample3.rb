(add9)?(-9)?(+9)?(11)?(+11)?(13)?(-13)?(omit3)?(omit5)?


def chord_calculate (chords)
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
end

def delete_symbol_root(str)
    conversions = {
      "dim"=>"","aug"=>"","sus4"=>"","sus2"=>"","M7"=>"","7"=>"","6"=>"","♭5"=>"",
      "add9"=>"","♭9"=>"","#9"=>"", "9"=>"", "add11"=>"","#11"=>"","♭11"=>"",
      "11"=>"","add13"=>"","♭13"=>"","13"=>"","omit3"=>"","omit5"=>"","m"=>""
    }.freeze
    str.gsub(/[#{conversions.keys}]/, conversions)
end

def delete_symbol_ambi(str)
    conversions = {
      "M7"=>"","7"=>"","6"=>"","♭5"=>"",
      "add9"=>"","♭9"=>"","#9"=>"", "9"=>"", "add11"=>"","#11"=>"","♭11"=>"",
      "11"=>"","add13"=>"","♭13"=>"","13"=>"","omit3"=>"","omit5"=>"","m"=>""
    }.freeze
    str.gsub(/[#{conversions.keys}]/, conversions)
end





def replace_degree_cymbols_C(str)
  conversions = {
    'C' => 'Ⅰ', 'D' => 'Ⅱ', 'E' => 'Ⅲ', 'F' => 'Ⅳ', 'G' => 'Ⅴ',
    'A' => 'Ⅵ', 'B' => 'Ⅶ'
  }.freeze
  str.gsub(/[#{conversions.keys}]/, conversions)
end

def replace_degree_cymbols_Cup(str)
  conversions = {
    'C'=>'Ⅰ♭','C#' => 'Ⅰ', 'D' => 'Ⅱ♭',
    'D#' => 'Ⅱ', 'E#' => 'Ⅲ', 'F#' => 'Ⅳ', 'G#' => 'Ⅴ',
    'A#' => 'Ⅵ', 'B#' => 'Ⅶ'
  }.freeze
  str.gsub(/[#{conversions.keys}]/, conversions)
end

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
  str = str.gsub("B","Ⅵ♭")
  str = str.gsub("C","Ⅶ")
end

def self.replace_degree_cymbols_Edown(str)
  str = str.gsub("E♭","Ⅰ")
  str = str.gsub("E","Ⅰ#")
  str = str.gsub("F","Ⅱ")
  str = str.gsub("G♭","Ⅲ")
  str = str.gsub("G","Ⅲ#")
  str = str.gsub("A♭","Ⅳ")
  str = str.gsub("A","Ⅳ#")
  str = str.gsub("B♭","Ⅴ")
  str = str.gsub("B","Ⅴ#")
  str = str.gsub("C","Ⅵ")
  str = str.gsub("D♭","Ⅶ")
  str = str.gsub("D","D")
end


def self.replace_degree_cymbols_Fup(str)
  str = str.gsub("F#","Ⅰ")
  str = str.gsub("F","Ⅰ♭")
  str = str.gsub("G#","Ⅱ")
  str = str.gsub("G","Ⅱ♭")
  str = str.gsub("A#","Ⅲ")
  str = str.gsub("A","Ⅲ♭")
  str = str.gsub("B#","Ⅳ")
  str = str.gsub("B","Ⅳ♭")
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
  str = str.gsub("C","Ⅳ")
  str = str.gsub("D♭","Ⅴ")
  str = str.gsub("D","Ⅴ#")
  str = str.gsub("E♭","Ⅵ")
  str = str.gsub("E","Ⅵ#")
  str = str.gsub("F","Ⅶ")
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
  str = str.gsub("F#","Ⅶ")
  str = str.gsub("F","Ⅵ♭")
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