package Sys::GetRandom::PP;
use strict;
use warnings;

use Exporter qw(import);
use Carp qw(croak);
use Sys::GetRandom::PP::_Bits ();
BEGIN {
    my $pkg = do { no strict 'refs'; \%{ __PACKAGE__ . '::' } };
    my $bits = \%Sys::GetRandom::PP::_Bits::;
    for my $sym (qw(GRND_RANDOM GRND_NONBLOCK _SYS_getrandom)) {
        $pkg->{$sym} = $bits->{$sym};
    }
}

our $VERSION = '0.05';

our @EXPORT_OK = qw(
    GRND_RANDOM
    GRND_NONBLOCK
    getrandom
    random_bytes
);

sub getrandom ($$;$) {
    if (@_ < 2 || @_ > 3) {
        croak 'Usage: ' . __PACKAGE__ . '::getrandom($buffer, $length, $flags = 0)';
    }
    my $bufref = \$_[0];
    my (undef, $length, $flags) = @_;
    $length |= 0;
    $flags |= 0;
    $$bufref .= '';
    utf8::downgrade $$bufref;
    my $dlen = $length - length $$bufref;
    $$bufref .= $dlen > 0 ? "\0" x $dlen : '';
    my $r = syscall _SYS_getrandom, $$bufref, $length, $flags;
    if ($r == -1) {
        substr($$bufref, -$dlen) = '' if $dlen > 0;
        return undef;
    }
    substr($$bufref, $r) = '';
    $r
}

sub random_bytes {
    my ($n) = @_;
    $n |= 0;
    $n >= 0 && $n <= 256
        or croak "Argument to random_bytes() must be an integer between 0 and 256, not $n";
    return '' if $n == 0;
    defined(my $r = getrandom(my $buf, $n))
        or die "Internal error: getrandom(\$buf, $n) failed: $!";
    $r == $n
        or die "Internal error: getrandom(\$buf, $n) returned $r";
    $buf
}

1
__END__

=head1 NAME

Sys::GetRandom::PP - pure Perl interface to getrandom(2)

=head1 SYNOPSIS

=for highlighter language=perl

    use Sys::GetRandom::PP qw(getrandom random_bytes GRND_NONBLOCK GRND_RANDOM);
    my $n = getrandom($buf, $count, $flags);
    my $bytes = random_bytes($count);

=head1 DESCRIPTION

This module provides a Perl interface to the L<getrandom(2)> call present on
Linux and FreeBSD. It exports (on request) two functions and two constants.

It is written in pure Perl using the L<syscall|perlfunc/syscall NUMBER, LIST>
function. Otherwise it presents the same interface as L<Sys::GetRandom>, which
is written in C.

=head2 Functions

=over

=item getrandom SCALAR, LENGTH

=item getrandom SCALAR, LENGTH, FLAGS

Generates up to I<LENGTH> bytes of random data and stores them in I<SCALAR>.
Returns the number of random bytes generated, or C<undef> on error (in which
case C<$!> is also set).

By default, C<getrandom> is equivalent to reading from F</dev/urandom> (but
without accessing the file system or requiring the use of a file descriptor).
If F</dev/urandom> has not been initialized yet, C<getrandom> will block by
default.

If F</dev/urandom> has been initialized and I<LENGTH> is 256 or less,
C<getrandom> will atomically return the requested amount of random data (i.e.
it will generate exactly I<LENGTH> bytes of data and will not be interrupted by
a signal). For larger values of I<LENGTH> it may be interrupted by signals and
either generate fewer random bytes than requested or fail with C<$!> set to
C<EINTR>.

The I<FLAGS> argument must be either 0 (the default value) or the bitwise OR of
one or more of the following flags:

=over

=item C<GRND_RANDOM>

Read from the same source as F</dev/random>, not F</dev/urandom> (the default).

=item C<GRND_NONBLOCK>

By default, C<getrandom> will block if F</dev/urandom> has not been initialized
yet or (with C<GRND_RANDOM>) if there are no random bytes available in
F</dev/random>. If the C<GRND_NONBLOCK> flag is passed, it will fail
immediately instead, returning C<undef> and setting C<$!> to C<EAGAIN>.

=back

=item random_bytes LENGTH

Generates and returns a string of I<LENGTH> random bytes.

I<LENGTH> must be between 0 and 256 (inclusive).

This is just a wrapper around C<getrandom> with default flags.

=back

=head1 SEE ALSO

L<Sys::GetRandom>,
L<getrandom(2)>,
L<h2ph>

=begin :README

=head1 INSTALLATION

To install this module, run the following commands:

=for highlighter language=sh

    perl Makefile.PL
    make
    make test
    make install

The F<syscall.h> and F<sys/random.h> headers in F</usr/include> (or at least
their Perl versions as generated by the L<h2ph> tool) must be available.

=head1 SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc Sys::GetRandom::PP

You can also look for information at:

=over

=item *

RT, CPAN's request tracker:
L<https://rt.cpan.org/Dist/Display.html?Name=Sys-GetRandom-PP>

=item *

MetaCPAN: L<https://metacpan.org/pod/Sys::GetRandom::PP>

=back

=end :README

=head1 AUTHOR

Lukas Mai, C<< <lmai at web.de> >>

=head1 COPYRIGHT & LICENSE

Copyright 2024 Lukas Mai.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<https://dev.perl.org/licenses/> for more information.
