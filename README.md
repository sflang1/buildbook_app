# Applier changes

This project contains a Ruby script that performs a list of changes defined in a file in JSON format (usually called `changes.json`), to an input file and writes the changed input in a new output file.

The changes JSON should be an array whose elements represent each one an operation. An operation looks like this:

```
{
  "operation": "add_song_to_playlist",
  "song_id": "3",
  "playlist_id": "2"
},
```
The `operation` key can be only one of the following supported ones:

### Supported operations
#### Add song to playlist
__Operation name__: `add_song_to_playlist`

It adds a certain song to a defined playlist. You need to provide as arguments the `song_id` and the `playlist_id`, and they both need to exist in the input file.

#### Add playlist to a user
__Operation name__: `add_playlist_to_user`
It creates a new playlist and assigns it to a user. The expected arguments are like this:

```
{
  "operation": "add_playlist_to_user",
  "playlist": {
    "song_ids": ["3", "8", "6"]
  },
  "user_id": "5"
}
```

#### Remove playlist
__Operation name__: `remove_playlist`
It removes an existing playlist. The only required argument is `playlist_id`

## Running the project
The project was built and executed with Ruby 2.7.6, as stated in the `.ruby-version` file. There are two ways to run the project: `ruby applier.rb PATH_TO_INPUT_FILE PATH_TO_CHANGES_JSON PATH_OF_OUTPUT_JSON` or a custom script also included, that can be called like this
```
chmod u+x changes_applier
./changes_applier PATH_TO_INPUT_FILE PATH_TO_CHANGES_JSON PATH_OF_OUTPUT_JSON
```

## Scaling considerations
This version of the project is meant to be used with small input and change files, given that the files are read and parsed to JSON and stored in memory. For working with larger files, some suggested strategies are:

* Do not read the file all at once and load it into memory. Instead, try reading the file by batches.
* It is possible to reduce to a minimum expression each one of the previous operations after defining the expected behavior for some cases. This means, if there is an operation to remove a playlist, all further operations regarding this playlist may be ignored. At the same time, instead of adding a song to a playlist each time there is a `add_song_to_playlist`, you can group multiple of this calls for the same playlist.
* It is possible to process first the changes file, and store in memory which IDs need to be altered. Next, you can read the input file just once looking for this stored values, and finally, each time you perform a change, write it directly to the output file, so you wouldn't need to store it in memory, as done in the current solution.

## Design considerations
There were two important design considerations I had to take for completing this project.
1. __What should the structure of the changes file be?__ As there was no supplied changes file, I could choose freely what it's structure should be. I picked JSON because the spotify.json is already in JSON format and introducing YML or XML or any other information exchange format might introduce unnecesary complexity. Then, I decided that the information should be stored as an array of possible changes. This way, in the scaled up version, you could be able to parse a single change easily usnig tools like a regex or a Context-free Grammar. Finally, in the sake of removing unneeded complexity, I only added the operation name and the required parameters as attributes for each change.
2. __How files are read and written?__ Due to the small size of both the input and changes file, I decided that it was okay to read the complete file and store its contents in memory. Then, operations described by changes are performed on this in-memory information, and the result is written into a output file.

## Time spent
Thinking about a design that might allow future scalability and easy test creation was the most time-consuming part of the challenge. I decided to go with classes because you can easily create unit tests for them. Also, if needed, it is possible to change the class that performs the creation to a scaled up version by just changing it to a new to be implemented class. In summary, developing the solution as is took sometimes between 1 hour and 2 hours.
