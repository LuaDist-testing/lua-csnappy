#!/usr/bin/env lua

require 'Test.More'

plan(23)

local snappy = require 'snappy'

error_like(function () snappy.compress(snappy) end,
           "bad argument #1 to 'compress' %(string expected, got table%)",
           "bad argument")

error_like(function () snappy.decompress(snappy) end,
           "bad argument #1 to 'decompress' %(string expected, got table%)",
           "bad argument")

error_like(function () snappy.decompress '' end,
           "snappy: bad header",
           "bad header")

error_like(function () snappy.decompress 'malformed' end,
           "snappy: malformed data",
           "malformed data")

local input = ''
local compressed = snappy.compress(input)
type_ok(compressed, 'string', "empty string")
is(#compressed, 1)
local decompressed = snappy.decompress(compressed)
is(decompressed, input)

local len = 1
for _ = 0, 15 do
    input = string.rep('0', len)
    compressed = snappy.compress(input)
    decompressed = snappy.decompress(compressed)
    is(decompressed, input, "length: " .. tostring(len))
    len = len * 3
end
