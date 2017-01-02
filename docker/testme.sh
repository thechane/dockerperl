./dockerpp.pl --complete --modlist=Text::Table --gitpath=/docker/test --gitfile=test.pl --image=test --giturl=https://github.com/thechane/perl.git
docker run thechane/perlcompiler/test
#./dockerpp.pl --complete --outputpath=/tmp --modlist=Term::Caca --apkextra=libcaca --gitpath=/test --gitfile=test.pl