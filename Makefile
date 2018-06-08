
version_pl := \
use strict; \
use warnings; \
while (<>) { \
    next unless m{(\d\.\d\.\d)}; \
    print $$1; \
};

LUA     := lua
VERSION := $(shell perl -e '$(version_pl)' < lsnappy.c)
TARBALL := lua-csnappy-$(VERSION).tar.gz
REV     := 1

LUAVER  := 5.3
PREFIX  := /usr/local
DPREFIX := $(DESTDIR)$(PREFIX)
LIBDIR  := $(DPREFIX)/lib/lua/$(LUAVER)
INSTALL := install

INCS    := -I /usr/include/lua$(LUAVER)
DEFS    :=
WARN    := -Wall -pedantic
CFLAGS  := $(INCS) $(DEFS) $(WARN) -O2 -fPIC $(GCOVFLAGS)
LDFLAGS := -shared

all: snappy.so

csnappy/csnappy_compress.c csnappy/csnappy_decompress.c:
	git submodule update --init

lsnappy.o: csnappy/csnappy_compress.c csnappy/csnappy_decompress.c

snappy.so: lsnappy.o
	$(CC) $(LDFLAGS) -o $@ $<

install:
	$(INSTALL) -m 755 -D snappy.so          $(LIBDIR)/snappy.so

uninstall:
	rm -f $(LIBDIR)/snappy.so

manifest_pl := \
use strict; \
use warnings; \
my @files = qw{ \
    MANIFEST \
    csnappy/csnappy.h \
    csnappy/csnappy_compat.h \
    csnappy/csnappy_internal.h \
    csnappy/csnappy_internal_userspace.h \
    csnappy/csnappy_compress.c \
    csnappy/csnappy_decompress.c \
}; \
while (<>) { \
    chomp; \
    next if m{^\.}; \
    next if m{^debian/}; \
    next if m{^rockspec/}; \
    next if m{^csnappy$$}; \
    push @files, $$_; \
} \
print join qq{\n}, sort @files;

rockspec_pl := \
use strict; \
use warnings; \
use Digest::MD5; \
open my $$FH, q{<}, q{$(TARBALL)} \
    or die qq{Cannot open $(TARBALL) ($$!)}; \
binmode $$FH; \
my %config = ( \
    version => q{$(VERSION)}, \
    rev     => q{$(REV)}, \
    md5     => Digest::MD5->new->addfile($$FH)->hexdigest(), \
); \
close $$FH; \
while (<>) { \
    s{@(\w+)@}{$$config{$$1}}g; \
    print; \
}

version:
	@echo $(VERSION)

CHANGES:
	perl -i.bak -pe "s{^$(VERSION).*}{q{$(VERSION)  }.localtime()}e" CHANGES

tag:
	git tag -a -m 'tag release $(VERSION)' $(VERSION)

MANIFEST:
	git ls-files | perl -e '$(manifest_pl)' > MANIFEST

$(TARBALL): MANIFEST
	[ -d lua-csnappy-$(VERSION) ] || ln -s . lua-csnappy-$(VERSION)
	perl -ne 'print qq{lua-csnappy-$(VERSION)/$$_};' MANIFEST | \
	    tar -zc -T - -f $(TARBALL)
	rm lua-csnappy-$(VERSION)

dist: $(TARBALL)

rockspec: $(TARBALL)
	perl -e '$(rockspec_pl)' rockspec.in > rockspec/lua-csnappy-$(VERSION)-$(REV).rockspec

rock:
	luarocks pack rockspec/lua-csnappy-$(VERSION)-$(REV).rockspec

deb:
	echo "lua-csnappy ($(shell git describe --dirty)) unstable; urgency=medium" >  debian/changelog
	echo ""                         >> debian/changelog
	echo "  * UNRELEASED"           >> debian/changelog
	echo ""                         >> debian/changelog
	echo " -- $(shell git config --get user.name) <$(shell git config --get user.email)>  $(shell date -R)" >> debian/changelog
	fakeroot debian/rules clean binary

check: test

test:
	prove --exec=$(LUA) ./test/*.t

luacheck:
	luacheck --std=min --config .test.luacheckrc test/*.t

coveralls:
	rm -f luacov.stats.out luacov.report.out
	-prove --exec="$(LUA) -lluacov" ./test/*.t
	coveralls -b . -r . -e luarocks -e csnappy --dump c.report.json
	luacov-coveralls -j c.report.json -v -e /HERE/ -e %.t$

README.html: README.md
	Markdown.pl README.md > README.html

gh-pages:
	mkdocs gh-deploy --clean

clean:
	rm -f MANIFEST *.so *.o *.bak README.html

realclean: clean

.PHONY: test rockspec deb CHANGES

