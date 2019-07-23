OUTDIR=/game-files/build

mkdir -p $OUTDIR/linux
mkdir -p $OUTDIR/windows
mkdir -p $OUTDIR/macos

# build for mac
godot --path /game-files/ --export 'Mac OSX' $OUTDIR/macos/game.app
mv $OUTDIR/macos/game.app $OUTDIR/macos/game-macos.zip

godot --path /game-files/ --export 'Linux/X11' $OUTDIR/linux/game-linux.zip

godot --path /game-files/ --export 'Windows Desktop' $OUTDIR/windows/game-win64.zip

cd $OUTDIR/macos && mv game-macos.zip ..

cd $OUTDIR/linux && zip game-linux.zip game-linux* && mv game-linux.zip .. && rm game-linux*

cd $OUTDIR/windows && zip game-win64.zip game-win64.* && mv game-win64.zip .. && rm game-win64.*
