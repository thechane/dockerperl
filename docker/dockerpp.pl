#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
use File::HomeDir;
use Term::ReadKey;
use Getopt::Long;

my ($help, $DEBUG, $OPT_outputpath, $OPT_complete, $OPT_modfile, $OPT_modlist, $OPT_giturl, $OPT_gitpath, $OPT_gitfile, $OPT_gitbranch, $OPT_apkextrafile, $OPT_apkextra);
my @perlMods;
my @apkExtras;
my $tmpFolder = '/tmp/' . time . '_thechanePerlCompiler';

GetOptions(
	'help' 				=> \$help,
	# regular option
    'DEBUG!'   			=> \$DEBUG,
    'outputpath=s'		=> \$OPT_outputpath,
    'complete!'			=> \$OPT_complete,
    'modfile=s'			=> \$OPT_modfile,
    'modlist=s'			=> \$OPT_modlist,
    'giturl=s'			=> \$OPT_giturl,
    'gitpath=s'			=> \$OPT_gitpath,
    'gitfile=s'			=> \$OPT_gitfile,
    'gitbranch=s'		=> \$OPT_gitbranch,
    'apkextra=s'		=> \$OPT_apkextra,
    'apkextrafile=s'	=> \$OPT_apkextrafile
);


if ($help) {
	my $script = $0;
	$script =~ s/\\/\//g;
	my @S = split( /\//, $script );
	$script = $S[$#S];
	my $Version = 1.0;
	open MORE, '|more' or die "unable to start pager";
	print MORE <<END;
Script Version is : $Version

$script can be used to create a compiled perl application docker image

Usage :
$script --help		: This message

---------------------------------------------------------
                   $script Help
---------------------------------------------------------
$script --outputpath
$script --complete
$script --modfile
$script --modlist
$script --giturl
$script --gitpath
$script --gitfile
$script --gitbranch
$script --apkextrafile
$script --apkextra

---------------------------------------------------------
		          	Valid  Examples
---------------------------------------------------------



---------------------------------------------------------
		          	Notes
---------------------------------------------------------


-----------------------------------------------------------------------

$script questions/comments should be addressed to stu\@roadtrip2001.net

-----------------------------------------------------------------------
END
	exit;
}

die "outputpath, giturl, gitpath and gitfile are required options" unless $OPT_outputpath && $OPT_giturl && $OPT_gitpath && $OPT_gitfile;
##CHECK DOCKER IS INSTALLED HERE AND MAKE SURE VERSION IS GOOD
$OPT_gitbranch = 'master' unless $OPT_gitbranch;
mkdir($tmpFolder) || die "Unable to create tmp folder $tmpFolder : $!";

##format CPAN mod data and any extra APKs
sub sanityCheckMod {
	#Mutley, do something
}
sub sanityCheckApk {
	#Mutley, do something
}
if ($OPT_modfile) {
	open(my $fh, "<", $OPT_modfile) || die "Unable to open $OPT_modfile : $!";
	foreach (<$fh>) {
		sanityCheckMod($_);
		push(@perlMods, $_);
	}
	close $fh;
}
if ($OPT_modlist) {
	foreach (split(/,/,$OPT_modlist)) {
		sanityCheckMod($_);
		push(@perlMods, $_);
	}
}
if ($OPT_apkextrafile) {
	open(my $fh, "<", $OPT_apkextrafile) || die "Unable to open $OPT_apkextrafile : $!";
	foreach (<$fh>) {
		sanityCheckApk($_);
		push(@apkExtras, $_);
	}
	close $fh;
}
if ($OPT_apkextra) {
	foreach (split(/,/,$OPT_apkextra)) {
		sanityCheckApk($_);
		push(@apkExtras, $_);
	}
}
my $PERLMODS = join(' ', @perlMods);
my $PPMODS = join(' -M ', @perlMods);
my $APKEXTRA = join(' ', @apkExtras);

##create docker files
open(my $fh, "<", "./perlcompiler.dock") || die "Unable to load dockerfile template : $!";
open(my $dfh, ">", "$tmpFolder/perlcompiler.dock") || die "Unable to write to $tmpFolder/perlcompiler.dock : $!";
foreach my $line (<$fh>) {
	$line =~ s/APKEXTRA/$APKEXTRA/;
	$line =~ s/PERLMODS/$PERLMODS/;
	$line =~ s/GITURL/$OPT_giturl/;
	$line =~ s/GITPATH/$OPT_gitpath/;
	$line =~ s/GITFILE/$OPT_gitfile/;
	$line =~ s/PPMODS/$PPMODS/;
	print $dfh $line;
}
close $fh;
close $dfh;

##Build and compile compiler
my $FATALERROR;
my @fatals = ("SOMETHING_REALLY_BAD", "SOMETHINGELSE_REALLY_BAD");
sub catchError {
	my $error = shift;
	return 1 if grep(/$error/,@fatals);
	return undef;
}
open(my $docker,"docker build --build-arg CACHEBUST=$(date +%s) -t thechane/perlcompiler -f $tmpFolder/perlcompiler.dock $tmpFolder |") || die "Failed to execute docker build : $!\n";
while ( <$docker> ) {
#	if (/(SOMESORTOFERROR|SOMEOTHERSORTOFERROR)/) {
#		$FATALERROR = catchError($1);
#		last if $FATALERROR;
#	}
	print;
}
close $docker;
rmdir $tmpFolder unless $DEBUG;

##TEST HERE TO SEE IF BUILD WAS SUCCESSFULL

##Copy file out of container
open($docker, "docker run --rm -v $OPT_outputpath:/mntvol thechane/perlcompiler cp /root/$OPT_gitfile /mntvol |") || die "Failed to execute docker build : $!\n";
while ( <$docker> ) { print; }
close $docker;

##Create new compiled.dock template
open($fh, "<", "./compiled.dock") || die "Unable to load dockerfile template : $!";
open($dfh, ">", "$OPT_outputpath/dockerfile.dock") || die "Unable to write to $OPT_outputpath/dockerfile.dock : $!";
foreach my $line (<$fh>) {
	$line =~ s/APKEXTRA/$APKEXTRA/;
	$line =~ s/GITFILE/$OPT_gitfile/;
	print $dfh $line;
}
close $fh;
close $dfh;

if ($OPT_complete) {
	open($docker, "docker build -t thechane/perlcompiled -f $OPT_outputpath/dockerfile.dock |") || die "Failed to execute docker final build : $!\n";
	while ( <$docker> ) { print; }
	close $docker;
}

