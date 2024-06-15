# NAME

Sys::GetRandom::PP - pure Perl interface to getrandom(2)

# SYNOPSIS

```perl
use Sys::GetRandom::PP qw(getrandom random_bytes GRND_NONBLOCK GRND_RANDOM);
my $n = getrandom($buf, $count, $flags);
my $bytes = random_bytes($count);
```

# DESCRIPTION

This module provides a Perl interface to the [getrandom(2)](http://man.he.net/man2/getrandom) call present on
Linux and FreeBSD. It exports (on request) two functions and two constants.

It is written in pure Perl using the [syscall](https://perldoc.perl.org/perlfunc#syscall-NUMBER-LIST)
function. Otherwise it presents the same interface as [Sys::GetRandom](https://metacpan.org/pod/Sys%3A%3AGetRandom), which
is written in C.

## Functions

- getrandom SCALAR, LENGTH
- getrandom SCALAR, LENGTH, FLAGS

    Generates up to _LENGTH_ bytes of random data and stores them in _SCALAR_.
    Returns the number of random bytes generated, or `undef` on error (in which
    case `$!` is also set).

    By default, `getrandom` is equivalent to reading from `/dev/urandom` (but
    without accessing the file system or requiring the use of a file descriptor).
    If `/dev/urandom` has not been initialized yet, `getrandom` will block by
    default.

    If `/dev/urandom` has been initialized and _LENGTH_ is 256 or less,
    `getrandom` will atomically return the requested amount of random data (i.e.
    it will generate exactly _LENGTH_ bytes of data and will not be interrupted by
    a signal). For larger values of _LENGTH_ it may be interrupted by signals and
    either generate fewer random bytes than requested or fail with `$!` set to
    `EINTR`.

    The _FLAGS_ argument must be either 0 (the default value) or the bitwise OR of
    one or more of the following flags:

    - `GRND_RANDOM`

        Read from the same source as `/dev/random`, not `/dev/urandom` (the default).

    - `GRND_NONBLOCK`

        By default, `getrandom` will block if `/dev/urandom` has not been initialized
        yet or (with `GRND_RANDOM`) if there are no random bytes available in
        `/dev/random`. If the `GRND_NONBLOCK` flag is passed, it will fail
        immediately instead, returning `undef` and setting `$!` to `EAGAIN`.

- random\_bytes LENGTH

    Generates and returns a string of _LENGTH_ random bytes.

    _LENGTH_ must be between 0 and 256 (inclusive).

    This is just a wrapper around `getrandom` with default flags.

# SEE ALSO

[Sys::GetRandom](https://metacpan.org/pod/Sys%3A%3AGetRandom),
[getrandom(2)](http://man.he.net/man2/getrandom),
[h2ph](https://metacpan.org/pod/h2ph)

# AUTHOR

Lukas Mai, `<lmai at web.de>`

# COPYRIGHT & LICENSE

Copyright 2024 Lukas Mai.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See [https://dev.perl.org/licenses/](https://dev.perl.org/licenses/) for more information.
