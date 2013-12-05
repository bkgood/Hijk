#!/usr/bin/env perl
use strict;
use Test::More;
use File::Temp ();
use File::Temp qw/ :seekable /;
use Hijk::HTTP::XS;

my $fh = File::Temp->new();
my $fd = do {
    local $/ = undef;
    my $data = "4\r\nWiki\r\n5\r\npedia\r\ne\r\n in\r\n\r\nchunks.\r\n0\r\n\r\n";

    my $msg = join(
        "\x0d\x0a",
        'HTTP/1.1 200 OK',
        'Date: Sat, 23 Nov 2013 23:10:28 GMT',
        'Last-Modified: Sat, 26 Oct 2013 19:41:47 GMT',
        'ETag: "4b9d0211dd8a2819866bccff777af225"',
        'Content-Type: text/html',
        'Server: Example',
        'Transfer-Encoding: chunked',
        '',
        $data
    );
    print $fh $msg;
    $fh->flush;
    $fh->seek(0, 0);
    fileno($fh);
};

my ($status, $body, $head) = Hijk::HTTP::XS::fetch($fd,0);


is $status, 200;
is $body, "Wikipedia in\r\n\r\nchunks.";

is_deeply $head, {
    "Date" => "Sat, 23 Nov 2013 23:10:28 GMT",
    "Last-Modified" => "Sat, 26 Oct 2013 19:41:47 GMT",
    "ETag" => '"4b9d0211dd8a2819866bccff777af225"',
    "Content-Type" => "text/html",
    "Server" => "Example",
    "Transfer-Encoding" => "chunked",
};


done_testing;
