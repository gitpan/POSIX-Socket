# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
BEGIN { plan tests => 1 };
use bytes;
use strict;
use Socket;
use POSIX::Socket;

sub sendto_test($$) {
  my ($msg, $flags) = @_;
  my $buf;
  my $rd;
  my $wr;

  $rd=_socket(AF_INET, SOCK_DGRAM, 0) or die "socket: $!\n";
  $wr=_socket(AF_INET, SOCK_DGRAM, 0) or die "socket: $!\n";

  my $addr = sockaddr_in(0, inet_aton("127.0.0.1"));
  my $bind_rv=_bind($rd, $addr);

  my $addr2;
  _getsockname($rd, $addr2);
  my ($port, $ip) = unpack_sockaddr_in($addr2);
  $ip = inet_ntoa($ip);
  die "_getsockname fail!" unless $ip eq "127.0.0.1";

  my $ret_val1 = _sendto($wr, $msg, $flags, $addr2);
  my $ret_val2 = _recv($rd, $buf, 8192, 0);

  _close ($rd);
  _close ($wr);

  return (($ret_val1 == $ret_val2) and ($buf eq $msg));
}

# 1
ok(sendto_test("fooba"."\0"."rbaz", 0), "plain sendto emulation");


