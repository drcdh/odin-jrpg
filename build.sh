pushd game
odin run atlas-builder/
python data/process_baddies.py
python data/process_tiled.py
popd
type -p odinfmt && odinfmt -w .
odin build . -vet
