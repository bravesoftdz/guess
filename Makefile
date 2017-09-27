.POSIX:

.PHONY: all clean fpc gpc install update-po

.SUFFIXES:
.SUFFIXES: .mo .o .pas .po .pot $(EXEEXT)

SHELL = /bin/sh

# The ?= operator isn't POSIX, but it is portable
CPDIR ?= cp -rf
FIND ?= find
RM ?= rm -fv
RMDIR ?= rm -fr

PREFIX ?= /usr
DATADIR ?= $(PREFIX)/share
bindir = $(PREFIX)/bin

# If you change this, also change DomainDir in guess.pas
LOCALEDIR ?= $(DATADIR)/locale

# Set to .exe for Windows, OS/2, etc.
EXEEXT ?=

all guess$(EXEEXT): update-po
	$(PC) $(PFLAGS) -oguess$(EXEEXT) guess.pas

gpc:
	$(MAKE) PC=gpc PFLAGS="--automake $(PFLAGS)"

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

update-po:
	for po in po/*.po; \
	do \
		mo=$$(echo $$po | sed -e 's/\.po$$/.mo/'); \
		msgmerge -Uq $$po po/guess.pot; \
		msgfmt -o $$mo $$po; \
	done
