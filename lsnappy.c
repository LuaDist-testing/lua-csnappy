/*
 * lua-csnappy : <http://fperrad.github.io/lua-csnappy/>
 */

#include "lua.h"
#include "lauxlib.h"

#include "csnappy/csnappy_compress.c"
#include "csnappy/csnappy_decompress.c"


static int lsnappy_compress(lua_State *L)
{
    size_t src_len;
    const char* src = luaL_checklstring(L, 1, &src_len);
    size_t dest_max = csnappy_max_compressed_length(src_len);
    char* working_memory = lua_newuserdata(L, CSNAPPY_WORKMEM_BYTES);
    char* dest = lua_newuserdata(L, dest_max);
    uint32_t dest_len;
    csnappy_compress(src, src_len, dest, &dest_len, working_memory, CSNAPPY_WORKMEM_BYTES_POWER_OF_TWO);
    lua_pushlstring(L, dest, dest_len);
    return 1;
}

static int lsnappy_decompress(lua_State *L)
{
    size_t src_len;
    uint32_t dest_len;
    const char* src = luaL_checklstring(L, 1, &src_len);
    int header_len = csnappy_get_uncompressed_length(src, (uint32_t)src_len, &dest_len);
    if (header_len != CSNAPPY_E_HEADER_BAD) {
        if (dest_len == 0) {
            lua_pushlstring(L, "", 0);
            return 1;
        }
        else {
            char* dest = lua_newuserdata(L, dest_len);
            int ret = csnappy_decompress_noheader(src + header_len, src_len - header_len, dest, &dest_len);
            switch (ret) {
                case CSNAPPY_E_OK:
                    lua_pushlstring(L, dest, dest_len);
                    return 1;
                case CSNAPPY_E_DATA_MALFORMED:
                    return luaL_error(L, "snappy: malformed data");
                case CSNAPPY_E_OUTPUT_OVERRUN:
                    return luaL_error(L, "snappy: output overrun");
                default:
                    return luaL_error(L, "snappy: error (%d)", ret);
            }
        }
    }
    return luaL_error(L, "snappy: bad header");
}


static const luaL_Reg snappy[] =
{
    { "compress",       lsnappy_compress        },
    { "decompress",     lsnappy_decompress      },
    /* placeholders */
    { "_COPYRIGHT",     NULL    },
    { "_DESCRIPTION",   NULL    },
    { "_VERSION",       NULL    },
    { NULL, NULL }
};

LUALIB_API int luaopen_snappy(lua_State *L)
{
#if LUA_VERSION_NUM >= 502
    luaL_newlib(L, snappy);
#else
    luaL_register(L, "snappy", snappy);
#endif
    lua_pushliteral (L, "Copyright (C) 2012-2018 Francois Perrad");
    lua_setfield(L, -2, "_COPYRIGHT");
    lua_pushliteral (L, "lua-csnappy: a fast compressor/decompressor");
    lua_setfield(L, -2, "_DESCRIPTION");
    lua_pushliteral (L, "0.1.5");
    lua_setfield(L, -2, "_VERSION");
    return 1;
}
