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