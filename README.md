# RadioD
*aka "radio daemon"*

It's a bash script that allows you to listen to your favorite radio stations completly in the background.

Change volume, stations, pause and resume using simple commands.

## Building

`nix build` if you are using Nix.  
If not, then you have to manually put `mpv`, `socat` etc. into the correct placeholders, named `%mpv%` and `%socat%`.

## Configuration

Currently the list of stations is kept directly in the source code, at the top of the code. It's a list of bash commands that return a path to the stream of the radio station.
So something like `yt-dlp -g https://www.youtube.com/watch?v=dQw4w9WgXcQ` should work as well.

## Usage

Run `radiod daemon` as a service and then use `radiod up`, `radiod down`, `radiod next` etc.  
DON'T RUN IT AS ROOT!

### Example i3 config
```
exec --no-startup-id radiod daemon
bindsym $mod+F9  exec --no-startup-id radiod next
bindsym $mod+F10 exec --no-startup-id radiod down
bindsym $mod+F11 exec --no-startup-id radiod toggle
bindsym $mod+F12 exec --no-startup-id radiod up
```

### Commands:
 - `up` - raise volume
 - `down` - lower volume
 - `next` - next station
 - `pause` - stop playing
 - `resume` - resume playing
 - `toggle` - toggle pause/resume

## Things that would be nice to have but whatever
 - Loading a list of the stations from a config file
 - Better resuming (so it works more like "muting the audio". Now it really pauses and resumes the audio stream)
 - Show notification of currently playing song
