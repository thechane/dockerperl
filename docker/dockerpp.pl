#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;

my ($help, $DEBUG, $OPT_outputpath, $OPT_complete, $OPT_modfile, $OPT_modlist, $OPT_giturl, $OPT_gitpath, $OPT_gitfile, $OPT_gitbranch, $OPT_apkextrafile, $OPT_apkextra, $OPT_image);
my @perlMods;
my @apkExtras;

GetOptions(
	'help' 				=> \$help,
	# regular option
    'debug!'   			=> \$DEBUG,
    'outputpath=s'		=> \$OPT_outputpath,
    'image=s'			=> \$OPT_image,
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
$script --outputpath		The location of where the dockerfile.dock will go along with the compiled alpine perl script (defaults to /tmp)
$script --image				What image name to append should --complete be selected
$script --complete			will also build a basic docker image with the new perl file as the entry point
$script --modfile			points to a file that has a line by line cpan mods
$script --modlist			comma separated list of CPAN mods
$script --giturl			URL of where the git repository can be found
$script --gitpath			Path to the dir where your perl file is kept on git
$script --gitfile			Name of the perl file you wish to compile
$script --gitbranch			git branch (default = master)
$script --apkextrafile		file showing any alpine packages you require, line by line
$script --apkextra			commar separated list of alpine packages that might be needed

---------------------------------------------------------
		          	Valid  Examples
---------------------------------------------------------

$script --complete --modlist=Text::Table --gitpath=/docker/test --gitfile=test.pl --image=test --giturl=https://github.com/thechane/perl.git
docker run thechane/perlcompiler/test

---------------------------------------------------------
		          	Notes
---------------------------------------------------------

Still need to implement some sanity checks

-----------------------------------------------------------------------

$script questions/comments should be addressed to stu\@roadtrip2001.net

-----------------------------------------------------------------------
END
	exit;
}

die "giturl, gitpath and gitfile are required options" unless $OPT_giturl && $OPT_gitpath && $OPT_gitfile;
die "--image is required option when --complete is used" if $OPT_complete && ! $OPT_image;
##CHECK DOCKER IS INSTALLED HERE AND MAKE SURE VERSION IS GOOD
$OPT_gitbranch = 'master' unless $OPT_gitbranch;
$OPT_outputpath = '/tmp' unless $OPT_outputpath;
$OPT_outputpath = $OPT_outputpath . '/' . time . '_thechanePerlCompiler';
mkdir($OPT_outputpath) || die "Unable to create tmp folder $OPT_outputpath : $!";

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
$PPMODS = '-M ' . $PPMODS if $PPMODS;
my $APKEXTRA = join(' ', @apkExtras);

##create docker files
open(my $fh, "<", "./perlcompiler.dock") || die "Unable to load dockerfile template : $!";
open(my $dfh, ">", "$OPT_outputpath/perlcompiler.dock") || die "Unable to write to $OPT_outputpath/perlcompiler.dock : $!";
foreach my $line (<$fh>) {
	$line =~ s/APKEXTRA/$APKEXTRA/g;
	$line =~ s/PERLMODS/$PERLMODS/g;
	$line =~ s/GITURL/$OPT_giturl/g;
	$line =~ s/GITPATH/$OPT_gitpath/g;
	$line =~ s/GITFILE/$OPT_gitfile/g;
	$line =~ s/GITBRANCH/$OPT_gitbranch/g;
	$line =~ s/PPMODS/$PPMODS/g;
	print $dfh $line;
	print $line if $DEBUG;
}
close $fh;
close $dfh;
print "\n" if $DEBUG;

##Build compiler
my $FATALERROR;
my @fatals = ("SOMETHING_REALLY_BAD", "SOMETHINGELSE_REALLY_BAD");
sub catchError {
	my $error = shift;
	return 1 if grep(/$error/,@fatals);
	return undef;
}
open(my $docker,"docker build --no-cache -t thechane/perlcompiler:local -f $OPT_outputpath/perlcompiler.dock $OPT_outputpath |") || die "Failed to execute docker build : $!\n";
while ( <$docker> ) {
#	if (/(SOMESORTOFERROR|SOMEOTHERSORTOFERROR)/) {
#		$FATALERROR = catchError($1);
#		last if $FATALERROR;
#	}
	print;
}
close $docker;

##TEST HERE TO SEE IF BUILD WAS SUCCESSFULL

##Copy file out of container
open($docker, "docker run --rm -v $OPT_outputpath:/mntvol thechane/perlcompiler:local cp /root/$OPT_gitfile /mntvol |") || die "Failed to execute docker build : $!\n";
while ( <$docker> ) { print; }
close $docker;

##Create new compiled.dock template
open($fh, "<", "./compiled.dock") || die "Unable to load dockerfile template : $!";
open($dfh, ">", "$OPT_outputpath/dockerfile.dock") || die "Unable to write to $OPT_outputpath/dockerfile.dock : $!";
foreach my $line (<$fh>) {
	$line =~ s/APKEXTRA/$APKEXTRA/g;
	$line =~ s/GITFILE/$OPT_gitfile/g;
	print $dfh $line;
	print $line if $DEBUG;
}
close $fh;
close $dfh;

if ($OPT_complete) {
	print "Building Docker image tagged as $OPT_image\n";
	open($docker, "docker build --no-cache -t thechane/perlcompiler/$OPT_image -f $OPT_outputpath/dockerfile.dock $OPT_outputpath |") || die "Failed to execute docker final build : $!\n";
	while ( <$docker> ) { print; }
	close $docker;
}

print "\n\n  ** COMPLETE **\n\n";
print "Check out the files in $OPT_outputpath\n";