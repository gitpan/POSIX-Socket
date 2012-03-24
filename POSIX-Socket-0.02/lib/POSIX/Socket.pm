package POSIX::Socket;

use 5.006;
use strict;
use Exporter 'import';
our @ISA = qw(Exporter);
our @EXPORT = qw(_socket _close _connect _fcntl _bind _recv _send _sendto _getsockname);
our $VERSION = '0.02';

require XSLoader;
XSLoader::load('POSIX::Socket', $VERSION);

1;
__END__

=head1 NAME

POSIX::Socket - Low-level perl interface to POSIX sockets

=head1 SYNOPSIS

 use POSIX::Socket
 
 my $rd=_socket(AF_INET, SOCK_DGRAM, 0) or die "socket: $!\n";
 my $wr=_socket(AF_INET, SOCK_DGRAM, 0) or die "socket: $!\n";
 
 my $addr = sockaddr_in(0, inet_aton("127.0.0.1"));
 my $bind_rv=_bind($rd, $addr);
 
 _getsockname($rd, $addr);
 my ($port, $ip) = unpack_sockaddr_in($addr);
 $ip = inet_ntoa($ip);
 die "_getsockname fail!" unless $ip eq "127.0.0.1";
 
 my $ret_val1 = _sendto($wr, $msg, $flags, $addr);
 my $ret_val2 = _recv($rd, $buf, 8192, 0);
 
 _close ($rd);
 _close ($wr);

=head1 DESCRIPTION

The primary purpose of this is to use file descriptors instead of
file handles for socket operations. File descriptors can be shared
between threads and not need dup file handles for each threads.

I hope you enjoyed it.

=head2 EXPORT

All of the above

=head1 AUTHOR

Yury Kotlyarov C<yura@cpan.org>

=head1 SEE ALSO

L<POSIX>, L<Socket>

=cut
