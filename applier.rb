require 'json'

input_path, changes_path, output_path = ARGV

def in_memory_json_load(filepath)
  JSON.parse(File.open(filepath).read)
end

class InMemoryAddToPlaylist
  def self.apply(input_info, song_id, playlist_id)
    song = input_info["songs"].find{|song| song_id == song["id"]}
    playlist = input_info["playlists"].find{|playlist| playlist_id == playlist["id"]}
    if song.nil? || playlist.nil?
      puts "Add song to playlist: Song or playlist doesn't exist. Song ID: #{song_id}, playlist ID: #{playlist_id}"
      return input_info
    end

    playlist["song_ids"] = playlist["song_ids"].push(song_id).uniq
    input_info
  end
end

class InMemoryAddPlaylistToUser
  def self.apply(input_info, user_id, playlist)
    user = input_info["users"].find{|user| user_id == user["id"]}

    if user.nil?
      puts "Add playlist to user: User doesn't exist. User ID: #{user_id}"
      return input_info
    end

    new_id = (input_info["playlists"].last["id"].to_i + 1).to_s
    input_info["playlists"].push({
      "id": new_id,
      "owner_id": user_id,
      "song_ids": playlist["song_ids"]
    })
    input_info
  end
end

class InMemoryPlaylistRemover
  def self.apply(input_info, playlist_id)
    input_info["playlists"].filter {|playlist| playlist_id != playlist["id"] }
  end
end

class InMemoryChangesApplier
  def self.create_output(input_path, changes_path, output_path)
    # as this is unscaled, we can make the changes in memory
    input_info = in_memory_json_load(input_path)
    changes = in_memory_json_load(changes_path)
    output_file = File.open(output_path, 'w')

    output_info = changes.inject(input_info) do |acc, change|
      case change["operation"]
      when "add_song_to_playlist"
        InMemoryAddToPlaylist.apply(acc, change["song_id"], change["playlist_id"])
      when "add_playlist_to_user"
        InMemoryAddPlaylistToUser.apply(acc, change["user_id"], change["playlist"])
      when "remove_playlist"
        InMemoryPlaylistRemover.apply(acc, change["playlist_id"])
      else
        raise "Unknown operation"
      end
    end

    output_file.write(output_info.to_json)
  end
end

InMemoryChangesApplier.create_output(input_path, changes_path, output_path)
