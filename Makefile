#
# Makefile
# ajdiaz, 2016-02-07 09:19
#

SRCDIR=src
OUTBIN=potion


all:
	@cat $(SRCDIR)/* > $(OUTBIN)
	@echo 'main "$$@"' >> $(OUTBIN)
	@chmod 755 $(OUTBIN)
	@ls -l $(OUTBIN)

clean:
	rm -f $(OUTBIN)
# vim:ft=make
#
