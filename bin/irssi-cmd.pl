#!/usr/bin/perl
#
# Sends a command to irssi over a unix socket created by the irssi script
# socket-interface.pl
#
# Matt Sparks, 2006-07-05
use strict;
use IO::Socket;

my $socket  = "/tmp/irssi_socket";
my $command = join(" ",@ARGV);

sub do_cmd {
    my($command)=@_;
    my $client = IO::Socket::UNIX->new(Peer => $socket,
                                       Type => SOCK_STREAM,
                                       Timeout => 10);

    $client->send("command $command");
    my $msg;
    $client->recv($msg,1024);
    return $msg;
}

do_cmd($command);
