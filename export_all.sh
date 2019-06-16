OUTDIR=/game-files/build

mkdir -p $OUTDIR/linux
mkdir -p $OUTDIR/windows
mkdir -p $OUTDIR/macos

# build for mac
godot --path /game-files/ --export 'Mac OSX' $OUTDIR/macos/game.app
mv $OUTDIR/macos/game.app $OUTDIR/macos/game-macos.zip

godot --path /game-files/ --export 'Linux/X11' $OUTDIR/linux/game-linux

godot --path /game-files/ --export 'Windows Desktop' $OUTDIR/windows/game-win64.exe

