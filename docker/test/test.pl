#!/usr/bin/env perl
use strict;
use warnings;
use Term::Caca;
my $caca = Term::Caca->new;
$caca->text( [5, 5], "HELLO WORLD!");
$caca->refresh;
sleep 3;