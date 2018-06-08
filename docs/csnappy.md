
# snappy

---

# Reference

### compress( data )

Accept a string data and returns a compressed string or throws an error.

### decompress( data )

Accept a string data and returns a decompressed string or throws an error.

# Examples

```lua
local snappy = require 'snappy'

local compressed = snappy.compress(some_input)
local decompressed = snappy.decompress(compressed)
```
