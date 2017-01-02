#!/usr/bin/env perl
use strict;
use warnings;

#use Term::Caca;
#my $caca = Term::Caca->new;
#$caca->text( [5, 5], "HELLO WORLD!");
#$caca->refresh;
#sleep 3;

use Text::Table;

my $t = Text::Table->new("HELLO", "WORLD");
$t->load(
		[ '0', "A" ],
		[ '1', "B" ],
		[ '2', "C" ],
		[ '3', "D" ]
	);
print $t;