FROM ioribranford/godot-docker:3.1

COPY . /game-files

RUN bin/godot --path /game-files --export "Mac OSX" game.dmg
RUN bin/godot --path /game-files --export "Linux/X11" game

