SHELL   =  /bin/bash
TSDIR   ?= $(CURDIR)/tree-sitter-tablegen
TESTDIR ?= $(TSDIR)/test

all:
	@

dev: $(TSDIR)
$(TSDIR):
	@git clone --depth=1 https://github.com/Flakebi/tree-sitter-tablegen
	@printf "\e[1m\e[31mNote\e[22m npm build can take a while\e[0m;" >&2
	@cd $(TSDIR) &&                                        \
		npm --loglevel=warn --progress=true install && \
		npm run build

.PHONY: parse-% all clean distclean
parse-%:
	cd $(TSDIR) && npx tree-sitter parse $(TESTDIR)/$(subst parse-,,$@)

clean:
	$(RM) -r *~

distclean: clean
	$(RM) -rf $$(git ls-files --others --ignored --exclude-standard)
