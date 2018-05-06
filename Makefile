
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

INCS    :=
DEFS    :=
WARN    := -Wall -pedantic
CFLAGS  := $(INCS) $(DEFS) $(WARN) -O2 -fPIC

LUAVER  := 5.1
PREFIX  := /usr/local
DPREFIX := $(DESTDIR)$(PREFIX)
LIBDIR  := $(DPREFIX)/lib/lua/$(LUAVER)
INSTALL := install

all: snappy.so

csnappy/csnappy_compress.c csnappy/csnappy_decompress.c:
	git submodule update --init

lsnappy.o: csnappy/csnappy_compress.c csnappy/csnappy_decompress.c

snappy.so: lsnappy.o
	$(CC) -o $@ -shared $<

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
    csnappy/csnappy_internal.h \
    csnappy/csnappy_internal_userspace.h \
    csnappy/csnappy_compress.c \
    csnappy/csnappy_decompress.c \
}; \
while (<>) { \
    chomp; \
    next if m{^\.}; \
    next if m{^doc/\.}; \
    next if m{^doc/google}; \
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

doc:
	git read-tree --prefix=doc/ -u remotes/origin/gh-pages

MANIFEST: doc
	git ls-files | perl -e '$(manifest_pl)' > MANIFEST

$(TARBALL): MANIFEST
	[ -d lua-csnappy-$(VERSION) ] || ln -s . lua-csnappy-$(VERSION)
	perl -ne 'print qq{lua-csnappy-$(VERSION)/$$_};' MANIFEST | \
	    tar -zc -T - -f $(TARBALL)
	rm lua-csnappy-$(VERSION)
	rm -rf doc
	git rm doc/*

dist: $(TARBALL)

rockspec: $(TARBALL)
	perl -e '$(rockspec_pl)' rockspec.in > rockspec/lua-csnappy-$(VERSION)-$(REV).rockspec

check: test

test:
	prove --exec=$(LUA) ./test/*.t

README.html: README.md
	Markdown.pl README.md > README.html

clean:
	rm -rf doc
	rm -f MANIFEST *.so *.o *.bak README.html

realclean: clean

.PHONY: test rockspec CHANGES

