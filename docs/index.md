
# lua-csnappy

---

## Overview

lua-csnappy is a binding of the __csnappy__ library
which implements the Google's Snappy (de)compressor.

Snappy uses a [LZ77](http://en.wikipedia.org/wiki/LZ77_and_LZ78)-type
algorithm with a fixed, byte-oriented encoding.

## References

The __csnappy__ library is available
at <http://github.com/zeevt/csnappy>.

The specification and the original C++ implementation of Snappy are available
at <https://google.github.io/snappy/>.

## Status

lua-csnappy is in beta stage.

It's developed for Lua 5.1, 5.2 & 5.3.

## Download

lua-csnappy source can be downloaded from
[GitHub](http://github.com/fperrad/lua-csnappy/releases/).

## Installation

lua-csnappy is available via LuaRocks:

```sh
luarocks install lua-csnappy
```

or manually, with:

```sh
make install
```

## Test

The test suite requires the module
[lua-TestMore](http://fperrad.github.io/lua-TestMore/).

    make test

## Copyright and License

Copyright &copy; 2012-2018 Fran&ccedil;ois Perrad
[![OpenHUB](http://www.openhub.net/accounts/4780/widgets/account_rank.gif)](http://www.openhub.net/accounts/4780?ref=Rank)
[![LinkedIn](http://www.linkedin.com/img/webpromo/btn_liprofile_blue_80x15.gif)](http://www.linkedin.com/in/fperrad)

This library is licensed under the terms of the BSD license,
like csnappy & Snappy.
