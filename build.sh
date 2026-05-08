pushd game
odin run atlas-builder/
python data/process.py
popd
odinfmt -w .
odin build . -vet
