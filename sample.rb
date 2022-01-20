<table class="table table-bordered">
    <thead>
        <tr>
          <th>ID</th>
          <th>Title</th>
          <th>Artist</th>
          <th>Genre</th>
          <th>Section</th>
          <th>Key</th>
          <th>Chord</th>
        </tr>
    </thead>
    <tbody>
      <% @songs.each do |song| %>
        <% song.chords.each do |chord| %>
          <tr>
            <td><%= song.id %></td>
            <td><%= song.title %></td>
            <td><%= song.artist %></td>
            <td><%= song.genre %></td>
            <td><%= chord.section_numbar %></td>
            <td><%= chord.key %></td>
            <td><%= chord.content %></td>
          </tr>
        <% end %>
      <% end %>
    </tbody> 
  </table>
  
  
  
  <%= f.select :key, [
                [" ", ""], ["C", "C"], ["Cm", "Cm"], ["C#", "C#"], ["C#m", "C#m"], ["D♭", "D♭"], ["D♭m", "D♭m"], ["D", "D"], ["Dm", "Dm"], ["D#", "D#"], ["D#m", "D#m"], ["E♭", "E♭"], ["E♭m", "E♭m"], ["E", "E"], ["Em", "Em"],
                ["E#", "E#"], ["E#m", "E#m"], ["F", "F"], ["Fm", "Fm"], ["F#", "F#"], ["F#m", "F#m"], ["G♭", "G♭"], ["G♭m", "G♭m"], ["G", "G"], ["Gm", "Gm"], ["G#", "G#"], ["G#m", "G#m"], ["A♭", "A♭"], ["A♭m", "A♭m"],
                ["A", "A"], ["Am", "Am"], ["A#", "A#"], ["A#m", "A#m"], ["B♭", "B♭"], ["B♭m", "B♭m"], ["B", "B"], ["Bm", "Bm"]], class: "form-control" %>