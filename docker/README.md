Perl on Alpine with many popular CPAN libs that I find myself using frequently, including:

Data::Serializer IO::Socket::IP IO::Socket::SSL XML::Simple Net::Telnet AnyEvent::RabbitMQ Mojo::JSON Mojo::UserAgent Crypt::Cipher::AES IO::Pty Digest::SHA Net::LDAPS Crypt::CBC Crypt::OpenSSL::AES

... image is a base for creating custom compiled Perl binaries within small Alpine containers. Using App::Packer::PAR and Alpine it’s possible to create very small Docker images suitable for some Perl based microservices. 

The testme.sh file shows a working example pulling from this repository, it creates an 11MB container image that runs a pre compiled Perl program using the Text::Table CPAN mod.
