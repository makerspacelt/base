#!/bin/bash


function create() {
	tpl=tpl.kicad_mod

	name="$(echo $1 | cut -d\; -f1 | tr [:upper:] [:lower:] | tr '[:space:][:punct:]' '_')"
	a1=$(echo $1 | cut -d\; -f2 | tr , .)
	a2=$(echo $1 | cut -d\; -f3 | tr , .)
	a3=$(echo $1 | cut -d\; -f4 | tr , .)
	a4=$(echo $1 | cut -d\; -f5 | tr , .)
	a5=$(echo $1 | cut -d\; -f6 | tr , .)

	w=$(echo $a2*10| bc -l)
	d=$(echo $a3*10| bc -l)
	h=$(echo $a4*10| bc -l)
	h2=$(echo 0$a5*10| bc -l)
	access=$(echo $a1*10| bc -l)

	x=$(echo $w/2 |bc -l)
	y=$(echo $d/2 |bc -l)

	dp=$(echo $d+$access |bc -l)
	dl=$(echo $d+1 |bc -l)

	wc=$(echo $w+0.5 |bc -l)
	dpc=$(echo $dp+0.5 |bc -l)

	cat $tpl \
		| sed "s/tpl/$name/g" \
		| sed "s/end 16 18/end $w $dp/" \
		| sed "s/end 16.5 18.5/end $wc $dpc/" \
		| sed "s/at 8 5) (size 16 10/at $x $y) ( size $w $d/" \
		| sed "s/at 0.5 11/at 0.5 $dl/" \
		| sed "s/8 -5 0/$x -$y $h2/" \
		| sed "s/16 10 11/$w $d $h/" \
	>${name}.kicad_mod
}

function main() {
	while IFS= read -r line; do
		echo $line
		create "$line"
	done
}
rm _*.kicad_mod
main < space-stuff.csv

