pushd game
odin run atlas-builder/
python data/generate_font.py
python data/process_baddies.py
python data/process_items.py
python data/process_skills.py
python data/process_tiled.py
popd
type -p odinfmt && odinfmt -w .
odin build . -vet
