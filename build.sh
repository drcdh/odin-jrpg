pushd game/textures
convert -crop 16x16 _menu.png PNG32:_menu_%d.png
mv _menu_0.png menu_topleft.png
mv _menu_1.png menu_topcenter.png
mv _menu_2.png menu_topright.png
mv _menu_3.png menu_centerleft.png
mv _menu_4.png menu_center.png
mv _menu_5.png menu_centerright.png
mv _menu_6.png menu_bottomleft.png
mv _menu_7.png menu_bottomcenter.png
mv _menu_8.png menu_bottomright.png
popd
pushd game
odin run atlas-builder/
python data/generate_font.py
python data/process_baddies.py
python data/process_skills.py
python data/process_tiled.py
popd
type -p odinfmt && odinfmt -w .
odin build . -vet
