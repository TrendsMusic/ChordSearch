
#Ⅰ,Ⅱ,Ⅲ,Ⅳ,Ⅴ,Ⅵ,Ⅶ
chords = Chord.with_content_regexp('Ⅰ').pluck(:content)
def getnextchords(chords)
    nextchords = []
    chords.each do |chord|
        if chord == nil
            return [nil, 0]
        else
          nextchords << chord.scan(/Ⅰ([Ⅰ-Ⅶ](♭|#)?(M|m)?(dim)?(aug)?(7)?(-5)?(9)?(11)?(on[Ⅰ-Ⅶ](♭|#)?)?)/)[0][0]
        end
    end
    return [nextchords, nextchords.length]
    
end

chords,count = getnextchords(chords)

p chords
p count