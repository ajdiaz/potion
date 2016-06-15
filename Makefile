#
# Makefile
# ajdiaz, 2016-02-07 09:19
#

SRCDIR=src
LIBDIR=src/lib
OUTBIN=./potion
REQUIREMENTS=./requirements.txt


all:
	find $(SRCDIR) -type f -exec cat {} \; > $(OUTBIN)
	@while read line; do \
		echo "std::installed '$$line' || " \
			   "err::trace '$$line is required but not found'" >> $(OUTBIN); \
	done <$(REQUIREMENTS)
	@echo 'main "$$@"' >> $(OUTBIN)
	@chmod 755 $(OUTBIN)
	@ls -l $(OUTBIN)

test: all
	$(OUTBIN) run -a test/artifacts -s test/test.secrets ./test/test.potion

clean:
	rm -f $(OUTBIN)
# vim:ft=make
#
