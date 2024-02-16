#!/bin/bash

# run this script to generate stuff defined in ./project/.kibot.yaml file
# ./kibot.sh

set -e
uid=$(id -u)
gid=$(id -g)


function run_kibot() {
	time docker run --rm -it \
	--volume "$(pwd):/tmp/workdir" \
	--workdir "/tmp/workdir" \
	setsoft/kicad_auto:ki6.0.10_Debian \
	/bin/bash -c "groupadd -g$gid u; useradd -u$uid -g$gid -d/tmp u; su u -c 'cd project && kibot -c .kibot.yaml $*'"
}

if [ "$1" ]; then
	echo "executing kibot with params: $*"
	run_kibot $*
	exit 0
fi



# generate documentation stuff
run_kibot --out-dir ../gen/ --board main.kicad_pcb     print_sch pcb_print pcb_img_2d_front pcb_img_2d_back pcb_img_3d_front pcb_img_3d_main
run_kibot --out-dir ../gen/ --board storage.kicad_pcb  print_sch pcb_print pcb_img_2d_front pcb_img_2d_back pcb_img_3d_front pcb_img_3d_main


# generate single board fab stuff
run_kibot --skip-pre all --board main.kicad_pcb    --out-dir ../gen/main_single    ibom fab_gerbers fab_drill fab_netlist
run_kibot --skip-pre all --board storage.kicad_pcb --out-dir ../gen/storage_single ibom fab_gerbers fab_drill fab_netlist




# remove garbage changes from pdfs
sed -i '/[/]CreationDate.*$/d' ./gen/main_items.pdf
sed -i '/[/]CreationDate.*$/d' ./gen/main_floorplan.pdf
sed -i '/[/]CreationDate.*$/d' ./gen/storage_items.pdf
sed -i '/[/]CreationDate.*$/d' ./gen/storage_floorplan.pdf


# make gerber generation reproducible for git
sed -i \
	-e '/^.*TF.CreationDate.*$/d' \
	-e '/^.*G04 Created by KiCad.* date .*$/d' \
	-e '/^.*DRILL file .* date .*$/d' \
	./gen/*/*.{gbr,drl}


# move files around

# archive 

function archive() {
	dir="$(dirname "$1")"
	rm -f $1
	touch -cd 1970-01-01T00:00:00Z $dir/*
	zip -qjorX9 -n zip $1 $dir
}
archive ./gen/main_single/_prod_main.zip
archive ./gen/storage_single/_prod_storage.zip



