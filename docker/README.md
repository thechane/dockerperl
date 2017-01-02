#perl/docker

Docker files that allow for the pp compilation of Perl scripts so they can be imported into Alpine Linux containers using Docker.

The testme.sh file shows a working example pulling from this repository, it creates an 11MB container image that runs a pre compiled Perl program using the Text::Table CPAN mod.
In practice this can be used to build Perl based applications that can be scaled easily with Docker.
