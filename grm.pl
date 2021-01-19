mkdir "grm", 0755;


open f, "< issa-basic.g" or die $!;
open f, "> src/issa-basic.y" or die $!;
open f, "> src/issa-basic.l" or die $!;

while(<f>) {
	next if /^#/;
	next if /^\s*$/;

	push(@R, ), next if /^%/;

	
}