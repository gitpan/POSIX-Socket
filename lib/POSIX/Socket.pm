package POSIX::Socket;

use 5.006;
use strict;
use Exporter 'import';
our @ISA = qw(Exporter);
our @EXPORT = qw(_socket _close _connect _fcntl _bind _recv _send _sendto _getsockname);
our $VERSION = '0.01';

require XSLoader;
XSLoader::load('POSIX::Socket', $VERSION);

1;
