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




 return[root1_rate, root1b_rate, root1up_rate, root2_rate, root2b_rate,root2up_rate,root3_rate,root3_rate,root3up_rate,root4_rate,root4b_rate,root4up_rate,root5_rate,root5b_rate,root5up_rate,root6_rate,root6b_rate,root6up_rate,root7_rate,root7b_rate,root7up_rate,
        
        root1try_rate,root1m_rate,root1_b5_rate,root1dim_rate,root1aug_rate,root1sus4_rate,root1sus2_rate,
        root1btry_rate,root1bm_rate,root1b_b5_rate,root1bdim_rate,root1baug_rate,root1bsus4_rate,root1bsus2_rate,
        root1uptry_rate,root1upm_rate,root1up_b5_rate,root1updim_rate,root1upaug_rate,root1upsus4_rate,root1upsus2_rate,
        
        root2try_rate,root2m_rate,root2_b5_rate,root2dim_rate,root2aug_rate,root2sus4_rate,root2sus2_rate,
        root2btry_rate,root2bm_rate,root2b_b5_rate,root2bdim_rate,root2baug_rate,root2bsus4_rate,root2bsus2_rate,
        root2uptry_rate,root2upm_rate,root2up_b5_rate,root2updim_rate,root2upaug_rate,root2upsus4_rate,root2upsus2_rate,
        
        root3try_rate,root3m_rate,root3_b5_rate,root3dim_rate,root3aug_rate,root3sus4_rate,root3sus2_rate,
        root3btry_rate,root3bm_rate,root3b_b5_rate,root3bdim_rate,root3baug_rate,root3bsus4_rate,root3bsus2_rate,
        root3uptry_rate,root3upm_rate,root3up_b5_rate,root3updim_rate,root3upaug_rate,root3upsus4_rate,root3upsus2_rate,
  
        root4try_rate,root4m_rate,root4_b5_rate,root4dim_rate,root4aug_rate,root4sus4_rate,root4sus2_rate,
        root4btry_rate,root4bm_rate,root4b_b5_rate,root4bdim_rate,root4baug_rate,root4bsus4_rate,root4bsus2_rate,
        root4uptry_rate,root4upm_rate,root4up_b5_rate,root4updim_rate,root4upaug_rate,root4upsus4_rate,root4upsus2_rate,
        
        root5try_rate,root5m_rate,root5_b5_rate,root5dim_rate,root5aug_rate,root5sus4_rate,root5sus2_rate,
        root5btry_rate,root5bm_rate,root5b_b5_rate,root5bdim_rate,root5baug_rate,root5bsus4_rate,root5bsus2_rate,
        root5uptry_rate,root5upm_rate,root5up_b5_rate,root5updim_rate,root5upaug_rate,root5upsus4_rate,root5upsus2_rate,
        
        root6try_rate,root6m_rate,root6_b5_rate,root6dim_rate,root6aug_rate,root6sus4_rate,root6sus2_rate,
        root6btry_rate,root6bm_rate,root6b_b5_rate,root6bdim_rate,root6baug_rate,root6bsus4_rate,root6bsus2_rate,
        root6uptry_rate,root6upm_rate,root6up_b5_rate,root6updim_rate,root6upaug_rate,root6upsus4_rate,root6upsus2_rate,
        
        root7try_rate,root7m_rate,root7_b5_rate,root7dim_rate,root7aug_rate,root7sus4_rate,root7sus2_rate,
        root7btry_rate,root7bm_rate,root7b_b5_rate,root7bdim_rate,root7baug_rate,root7bsus4_rate,root7bsus2_rate,
        root7uptry_rate,root7upm_rate,root7up_b5_rate,root7updim_rate,root7upaug_rate,root7upsus4_rate,root7upsus2_rate
        
        
  ["Ⅰ","Ⅰm","Ⅰm♭5","Ⅰdim","Ⅰaug","Ⅰsus4","Ⅰsus2",
  "Ⅰ♭","Ⅰm♭","Ⅰ♭m♭5","Ⅰ♭dim","Ⅰ♭aug","Ⅰ♭sus4","Ⅰ♭sus2",
  "Ⅰ#","Ⅰ#m","Ⅰ#m♭5","Ⅰ#dim","Ⅰ#aug","Ⅰ#sus4","Ⅰ#sus2",
  "Ⅱ","Ⅱm","Ⅱm♭5","Ⅱdim","Ⅱaug","Ⅱsus4","Ⅱsus2",
  "Ⅱ♭","Ⅱ♭m","Ⅱ♭m♭5","Ⅱ♭dim","Ⅱ♭aug","Ⅱ♭sus4","Ⅱ♭sus2",
  "Ⅱ#","Ⅱ#m","Ⅱ#m♭5","Ⅱ#dim","Ⅱ#aug","Ⅱ#sus4","Ⅱ#sus2",
  "Ⅲ","Ⅲm","Ⅲm♭5","Ⅲdim","Ⅲaug","Ⅲsus4","Ⅲsus2",
  "Ⅲ♭","Ⅲ♭m","Ⅲ♭m♭5","Ⅲ♭dim","Ⅲ♭aug","Ⅲ♭sus4","Ⅲ♭sus2",
  "Ⅲ#","Ⅲ#m","Ⅲ#m♭5","Ⅲ#dim","Ⅲ#aug","Ⅲ#sus4","Ⅲ#sus2",
  "Ⅳ","Ⅳm","Ⅳm♭5","Ⅳdim","Ⅳaug","Ⅳsus4","Ⅳsus2",
  "Ⅳ♭","Ⅳ♭m","Ⅳ♭m♭5","Ⅳ♭dim","Ⅳ♭aug","Ⅳ♭sus4","Ⅳ♭sus2",
  "Ⅳ#","Ⅳ#m","Ⅳ#m♭5","Ⅳ#dim","Ⅳ#aug","Ⅳ#sus4","Ⅳ#sus2",
  "Ⅴ","Ⅴm","Ⅴm♭5","Ⅴdim","Ⅴaug","Ⅴsus4","Ⅴsus2",
  "Ⅴ♭","Ⅴ♭m","Ⅴ♭m♭5","Ⅴ♭dim","Ⅴ♭aug","Ⅴ♭sus4","Ⅴ♭sus2",
  "Ⅴ#","Ⅴ#m","Ⅴ#m♭5","Ⅴ#dim","Ⅴ#aug","Ⅴ#sus4","Ⅴ#sus2",
  "Ⅵ","Ⅵm","Ⅵm♭5","Ⅵdim","Ⅵaug","Ⅵsus4","Ⅵsus2",
  "Ⅵ♭","Ⅵ♭m","Ⅵ♭m♭5","Ⅵ♭dim","Ⅵ♭aug","Ⅵ♭sus4","Ⅵ♭sus2",
  "Ⅵ#","Ⅵ#m","Ⅵ#m♭5","Ⅵ#dim","Ⅵ#aug","Ⅵ#sus4","Ⅵ#sus2",
  "Ⅶ","Ⅶm","Ⅶm♭5","Ⅶdim","Ⅶaug","Ⅶsus4","Ⅶsus2",
  "Ⅶ♭","Ⅶ♭m","Ⅶ♭m♭5","Ⅶ♭dim","Ⅶ♭aug","Ⅶ♭sus4","Ⅶ♭sus2",
  "Ⅶ#","Ⅶ#m","Ⅶ#m♭5","Ⅶ#dim","Ⅶ#aug","Ⅶ#sus4","Ⅶ#sus2"
  ]

root_rate_data = {"I":root1_rate, "Ⅰ♭":root1b_rate, "Ⅰ#":root1up_rate, "Ⅱ":root2_rate,"Ⅱ♭":root2b_rate,"Ⅱ#":root2up_rate,"Ⅲ":root3_rate,"Ⅲ♭":root3b_rate,"Ⅲ#":root3up_rate,"Ⅳ":root4_rate,"Ⅳ♭":root4b_rate,
"Ⅳ#":root4up_rate,"Ⅴ":root5_rate,"Ⅴ♭":root5b_rate,"Ⅴ#":root5up_rate,"Ⅵ":root6_rate,"Ⅵ♭":root6b_rate,"Ⅵ#":root6up_rate,"Ⅶ":root7_rate,"Ⅶ♭":root7b_rate,"Ⅶ#":root7up_rate}


  ambi_rate_data = [
    ["Ⅰ","Ⅰm","Ⅰm♭5","Ⅰdim","Ⅰaug","Ⅰsus4","Ⅰsus2",
      "Ⅰ♭","Ⅰm♭","Ⅰ♭m♭5","Ⅰ♭dim","Ⅰ♭aug","Ⅰ♭sus4","Ⅰ♭sus2",
      "Ⅰ#","Ⅰ#m","Ⅰ#m♭5","Ⅰ#dim","Ⅰ#aug","Ⅰ#sus4","Ⅰ#sus2",
      "Ⅱ","Ⅱm","Ⅱm♭5","Ⅱdim","Ⅱaug","Ⅱsus4","Ⅱsus2",
      "Ⅱ♭","Ⅱ♭m","Ⅱ♭m♭5","Ⅱ♭dim","Ⅱ♭aug","Ⅱ♭sus4","Ⅱ♭sus2",
      "Ⅱ#","Ⅱ#m","Ⅱ#m♭5","Ⅱ#dim","Ⅱ#aug","Ⅱ#sus4","Ⅱ#sus2",
      "Ⅲ","Ⅲm","Ⅲm♭5","Ⅲdim","Ⅲaug","Ⅲsus4","Ⅲsus2",
      "Ⅲ♭","Ⅲ♭m","Ⅲ♭m♭5","Ⅲ♭dim","Ⅲ♭aug","Ⅲ♭sus4","Ⅲ♭sus2",
      "Ⅲ#","Ⅲ#m","Ⅲ#m♭5","Ⅲ#dim","Ⅲ#aug","Ⅲ#sus4","Ⅲ#sus2",
      "Ⅳ","Ⅳm","Ⅳm♭5","Ⅳdim","Ⅳaug","Ⅳsus4","Ⅳsus2",
      "Ⅳ♭","Ⅳ♭m","Ⅳ♭m♭5","Ⅳ♭dim","Ⅳ♭aug","Ⅳ♭sus4","Ⅳ♭sus2",
      "Ⅳ#","Ⅳ#m","Ⅳ#m♭5","Ⅳ#dim","Ⅳ#aug","Ⅳ#sus4","Ⅳ#sus2",
      "Ⅴ","Ⅴm","Ⅴm♭5","Ⅴdim","Ⅴaug","Ⅴsus4","Ⅴsus2",
      "Ⅴ♭","Ⅴ♭m","Ⅴ♭m♭5","Ⅴ♭dim","Ⅴ♭aug","Ⅴ♭sus4","Ⅴ♭sus2",
      "Ⅴ#","Ⅴ#m","Ⅴ#m♭5","Ⅴ#dim","Ⅴ#aug","Ⅴ#sus4","Ⅴ#sus2",
      "Ⅵ","Ⅵm","Ⅵm♭5","Ⅵdim","Ⅵaug","Ⅵsus4","Ⅵsus2",
      "Ⅵ♭","Ⅵ♭m","Ⅵ♭m♭5","Ⅵ♭dim","Ⅵ♭aug","Ⅵ♭sus4","Ⅵ♭sus2",
      "Ⅵ#","Ⅵ#m","Ⅵ#m♭5","Ⅵ#dim","Ⅵ#aug","Ⅵ#sus4","Ⅵ#sus2",
      "Ⅶ","Ⅶm","Ⅶm♭5","Ⅶdim","Ⅶaug","Ⅶsus4","Ⅶsus2",
      "Ⅶ♭","Ⅶ♭m","Ⅶ♭m♭5","Ⅶ♭dim","Ⅶ♭aug","Ⅶ♭sus4","Ⅶ♭sus2",
      "Ⅶ#","Ⅶ#m","Ⅶ#m♭5","Ⅶ#dim","Ⅶ#aug","Ⅶ#sus4","Ⅶ#sus2"],
      
    [ root1try_rate,root1m_rate,root1_b5_rate,root1dim_rate,root1aug_rate,root1sus4_rate,root1sus2_rate,
      root1btry_rate,root1bm_rate,root1b_b5_rate,root1bdim_rate,root1baug_rate,root1bsus4_rate,root1bsus2_rate,
      root1uptry_rate,root1upm_rate,root1up_b5_rate,root1updim_rate,root1upaug_rate,root1upsus4_rate,root1upsus2_rate,
      
      root2try_rate,root2m_rate,root2_b5_rate,root2dim_rate,root2aug_rate,root2sus4_rate,root2sus2_rate,
      root2btry_rate,root2bm_rate,root2b_b5_rate,root2bdim_rate,root2baug_rate,root2bsus4_rate,root2bsus2_rate,
      root2uptry_rate,root2upm_rate,root2up_b5_rate,root2updim_rate,root2upaug_rate,root2upsus4_rate,root2upsus2_rate,
      
      root3try_rate,root3m_rate,root3_b5_rate,root3dim_rate,root3aug_rate,root3sus4_rate,root3sus2_rate,
      root3btry_rate,root3bm_rate,root3b_b5_rate,root3bdim_rate,root3baug_rate,root3bsus4_rate,root3bsus2_rate,
      root3uptry_rate,root3upm_rate,root3up_b5_rate,root3updim_rate,root3upaug_rate,root3upsus4_rate,root3upsus2_rate,

      root4try_rate,root4m_rate,root4_b5_rate,root4dim_rate,root4aug_rate,root4sus4_rate,root4sus2_rate,
      root4btry_rate,root4bm_rate,root4b_b5_rate,root4bdim_rate,root4baug_rate,root4bsus4_rate,root4bsus2_rate,
      root4uptry_rate,root4upm_rate,root4up_b5_rate,root4updim_rate,root4upaug_rate,root4upsus4_rate,root4upsus2_rate,
      
      root5try_rate,root5m_rate,root5_b5_rate,root5dim_rate,root5aug_rate,root5sus4_rate,root5sus2_rate,
      root5btry_rate,root5bm_rate,root5b_b5_rate,root5bdim_rate,root5baug_rate,root5bsus4_rate,root5bsus2_rate,
      root5uptry_rate,root5upm_rate,root5up_b5_rate,root5updim_rate,root5upaug_rate,root5upsus4_rate,root5upsus2_rate,
      
      root6try_rate,root6m_rate,root6_b5_rate,root6dim_rate,root6aug_rate,root6sus4_rate,root6sus2_rate,
      root6btry_rate,root6bm_rate,root6b_b5_rate,root6bdim_rate,root6baug_rate,root6bsus4_rate,root6bsus2_rate,
      root6uptry_rate,root6upm_rate,root6up_b5_rate,root6updim_rate,root6upaug_rate,root6upsus4_rate,root6upsus2_rate,
      
      root7try_rate,root7m_rate,root7_b5_rate,root7dim_rate,root7aug_rate,root7sus4_rate,root7sus2_rate,
      root7btry_rate,root7bm_rate,root7b_b5_rate,root7bdim_rate,root7baug_rate,root7bsus4_rate,root7bsus2_rate,
      root7uptry_rate,root7upm_rate,root7up_b5_rate,root7updim_rate,root7upaug_rate,root7upsus4_rate,root7upsus2_rate
      ]
                  ]
                  
  ambi_rate_data = {"Ⅰ":root1try_rate,"Ⅰm":root1m_rate,"Ⅰm♭5":root1_b5_rate,"Ⅰdim":root1dim_rate,"Ⅰaug":root1aug_rate,"Ⅰsus4":root1sus4_rate,"Ⅰsus2":root1sus2_rate,
                    "Ⅰ♭":root1btry_rate,"Ⅰm♭":root1bm_rate,"Ⅰ♭m♭5":root1b_b5_rate,"Ⅰ♭dim":root1bdim_rate,"Ⅰ♭aug":root1baug_rate,"Ⅰ♭sus4":root1bsus4_rate,"Ⅰ♭sus2":root1bsus2_rate,
                    "Ⅰ#":root1uptry_rate,"Ⅰ#m":root1upm_rate,"Ⅰ#m♭5":root1up_b5_rate,"Ⅰ#dim":root1updim_rate,"Ⅰ#aug":root1upaug_rate,"Ⅰ#sus4":root1upsus4_rate,"Ⅰ#sus2":root1upsus2_rate,
                    "Ⅱ":root2try_rate,"Ⅱm":root2m_rate,"Ⅱm♭5":root2_b5_rate,"Ⅱdim":root2dim_rate:,"Ⅱaug":root2aug_rate,"Ⅱsus4":root2sus4_rate,"Ⅱsus2":root2sus2_rate,
                    "Ⅱ♭":root2btry_rate,"Ⅱ♭m":root2bm_rate,"Ⅱ♭m♭5":root2b_b5_rate,"Ⅱ♭dim":root2bdim_rate,"Ⅱ♭aug":root2baug_rate,"Ⅱ♭sus4":root2bsus4_rate,"Ⅱ♭sus2":root2bsus2_rate,
                    "Ⅱ#":root2uptry_rate,"Ⅱ#m":root2upm_rate,"Ⅱ#m♭5":root2up_b5_rate,"Ⅱ#dim":root2updim_rate,"Ⅱ#aug":root2upaug_rate,"Ⅱ#sus4":root2upsus4_rate,"Ⅱ#sus2":root2upsus2_rate,
                    "Ⅲ":root3try_rate,"Ⅲm":root3m_rate,"Ⅲm♭5":root3_b5_rate,"Ⅲdim":root3dim_rate,"Ⅲaug":root3aug_rate,"Ⅲsus4":root3sus4_rate,"Ⅲsus2":root3sus2_rate,
                    "Ⅲ♭":root3btry_rate,"Ⅲ♭m":root3bm_rate,"Ⅲ♭m♭5":root3b_b5_rate,"Ⅲ♭dim":root3bdim_rate,"Ⅲ♭aug":root3baug_rates,"Ⅲ♭sus4":root3bsus4_rate,"Ⅲ♭sus2":root3bsus2_rate,
                    "Ⅲ#":root3uptry_rate,"Ⅲ#m":root3upm_rate,"Ⅲ#m♭5":root3up_b5_rate,"Ⅲ#dim":root3updim_rate,"Ⅲ#aug":root3upaug_rate,"Ⅲ#sus4":root3upsus4_rate,"Ⅲ#sus2":root3upsus2_rate,
                    "Ⅳ":root4try_rate,"Ⅳm":root4m_rate,"Ⅳm♭5":root4_b5_rate,"Ⅳdim":root4dim_rate,"Ⅳaug":root4aug_rate,"Ⅳsus4":root4sus4_rate,"Ⅳsus2":root4sus2_rate,
                    "Ⅳ♭":root4btry_rate,"Ⅳ♭m":root4bm_rate,"Ⅳ♭m♭5":root4b_b5_rate,"Ⅳ♭dim":root4bdim_rate,"Ⅳ♭aug":root4baug_rate,"Ⅳ♭sus4":root4bsus4_rate,"Ⅳ♭sus2":root4bsus2_rate,,
                    "Ⅳ#":root4uptry_rate,"Ⅳ#m":root4upm_rate,"Ⅳ#m♭5":root4up_b5_rate,"Ⅳ#dim":root4updim_rate,"Ⅳ#aug":root4upaug_rate,"Ⅳ#sus4":root4upsus4_rate,"Ⅳ#sus2":root4upsus2_rate,
                    "Ⅴ":root5try_rate,"Ⅴm":root5m_rate,"Ⅴm♭5":root5_b5_rate,"Ⅴdim":root5dim_rate,"Ⅴaug":root5aug_rate,"Ⅴsus4":root5sus4_rate,"Ⅴsus2":root5sus2_rate,
                    "Ⅴ♭":root5btry_rate,"Ⅴ♭m":root5bm_rate,"Ⅴ♭m♭5":root5b_b5_rate,"Ⅴ♭dim":root5bdim_rate,"Ⅴ♭aug":root5baug_rate,"Ⅴ♭sus4":root5bsus4_rate,"Ⅴ♭sus2":root5bsus2_rate,
                    "Ⅴ#":root5uptry_rate,"Ⅴ#m":root5upm_rate,"Ⅴ#m♭5":root5up_b5_rate,"Ⅴ#dim":root5updim_rate,"Ⅴ#aug":root5upaug_rate,"Ⅴ#sus4":root5upsus4_rate,"Ⅴ#sus2":root5upsus2_rate,
                    "Ⅵ":root6try_rate,"Ⅵm":root6m_rate,"Ⅵm♭5":root6_b5_rate,"Ⅵdim":root6dim_rate,"Ⅵaug":root6sus4_rate,"Ⅵsus4":root6sus4_rate,"Ⅵsus2":root6sus2_rate,
                    "Ⅵ♭":root6btry_rate,"Ⅵ♭m":root6bm_rate,"Ⅵ♭m♭5":root6b_b5_rate,"Ⅵ♭dim":root6bdim_rate,"Ⅵ♭aug":root6baug_rate,"Ⅵ♭sus4":root6bsus4_rate,"Ⅵ♭sus2":root6bsus2_rate,
                    "Ⅵ#":root6uptry_rate,"Ⅵ#m":root6upm_rate,"Ⅵ#m♭5":root6up_b5_rate,"Ⅵ#dim":root6updim_rate,"Ⅵ#aug":root6upaug_rate,"Ⅵ#sus4":root6upsus4_rate,"Ⅵ#sus2":root6upsus2_rate,
                    "Ⅶ":root7try_rate,"Ⅶm":root7m_rate,"Ⅶm♭5":root7_b5_rate,"Ⅶdim":root7dim_rate,"Ⅶaug":root7aug_rate,"Ⅶsus4":root7sus4_rate,"Ⅶsus2":root7sus2_rate,
                    "Ⅶ♭":root7btry_rate,"Ⅶ♭m":root7bm_rate,"Ⅶ♭m♭5":root7b_b5_rate,"Ⅶ♭dim":root7bdim_rate,"Ⅶ♭aug":root7baug_rate,"Ⅶ♭sus4":root7bsus4_rate,"Ⅶ♭sus2":root7bsus2_rate,
                    "Ⅶ#":root7uptry_rate,"Ⅶ#m":root7upm_rate,"Ⅶ#m♭5":root7up_b5_rate,"Ⅶ#dim":root7updim_rate,"Ⅶ#aug":root7upaug_rate,"Ⅶ#sus4":root7upsus4_rate,"Ⅶ#sus2":root7upsus2_rate,
  }
      
      