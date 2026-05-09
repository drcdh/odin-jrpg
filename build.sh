pushd game
odin run atlas-builder/
python data/process.py
popd
type -p odinfmt && odinfmt -w .
odin build . -vet
