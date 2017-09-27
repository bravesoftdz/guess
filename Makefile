.POSIX:

.PHONY: all clean install update-po
.SUFFIXES: .mo .o .pas .po .pot $(EXEEXT)

SHELL = /bin/sh

# The ?= operator isn't POSIX, but it is portable
CPDIR ?= cp -rf
FIND ?= find
RM ?= rm -fv
RMDIR ?= rm -fr

# For Free Pascal:
PC ?= fpc
PCFLAGS ?=

# For GNU Pascal:
# PC ?= gpc
# PCFLAGS ?= --automake --extended-syntax -DSUPPORTS_ISO_10206 -lintl

PREFIX ?= /usr
DATADIR ?= $(PREFIX)/share
bindir = $(PREFIX)/bin

# If you change this, also change DomainDir in guess.pas
LOCALEDIR ?= $(DATADIR)/locale

# Set to .exe for Windows, OS/2, etc.
EXEEXT ?=

all guess$(EXEEXT): update-po
	$(PC) $(PCFLAGS) -oguess$(EXEEXT) guess.pas

clean:
	# A bit convoluted, but we never know what file names a compiler might make
	$(RM) $$($(FIND) -name '*.mo' -o -name '*.o' -o -name '*~' -o -name 'guess$(EXEEXT)')

install: all
	install -m 755 guess $(bindir)
	for po in po/*.po; \
	do \
		lang=$$(echo $$po | sed -e 's/po\/\([^\.]\+\)\.po$$/\1/g'); \
		install -d -m 755 $(LOCALEDIR)/$$lang/LC_MESSAGES; \
		install -m 644 po/$$lang.mo $(LOCALEDIR)/$$lang/LC_MESSAGES/guess.mo; \
	done

po/guess.pot: guess.pas
	xgettext -LJavaScript -o $@ $<

update-po: po/guess.pot
	for po in po/*.po; \
	do \
		$(MAKE) $$(echo $$po | sed -e 's/\.po$$/.mo/'); \
	done

.po.mo: po/guess.pot
	msgmerge -Uq $< po/guess.pot
	msgfmt -o $@ $<
