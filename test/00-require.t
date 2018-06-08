#!/usr/bin/env lua

require 'Test.More'

plan(7)

if not require_ok 'snappy' then
    BAIL_OUT "no lib"
end

local m = require 'snappy'
type_ok( m, 'table' )
is( m, package.loaded.snappy )

like( m._COPYRIGHT, 'Perrad', "_COPYRIGHT" )
like( m._DESCRIPTION, 'compressor', "_DESCRIPTION" )
type_ok( m._VERSION, 'string', "_VERSION" )
like( m._VERSION, '^%d%.%d%.%d$' )

