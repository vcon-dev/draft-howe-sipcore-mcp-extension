# draft-howe-sipcore-mcp-extension draft-howe-sipcore-mcp-extension-kramdown 
# 
versioned:
	@mkdir -p $@
.INTERMEDIATE: versioned/draft-howe-sipcore-mcp-extension-00.md
versioned/draft-howe-sipcore-mcp-extension-00.md: draft-howe-sipcore-mcp-extension.md | versioned
	sed -e 's/draft-howe-sipcore-mcp-extension-kramdown-date/2025-09-29/g' -e 's/draft-howe-sipcore-mcp-extension-kramdown-latest/draft-howe-sipcore-mcp-extension-kramdown-00/g' -e 's/draft-howe-sipcore-mcp-extension-kramdown-date/2025-09-29/g' -e 's/draft-howe-sipcore-mcp-extension-kramdown-latest/draft-howe-sipcore-mcp-extension-kramdown-00/g' -e 's/draft-howe-sipcore-mcp-extension-date/2025-09-29/g' -e 's/draft-howe-sipcore-mcp-extension-latest/draft-howe-sipcore-mcp-extension-00/g' -e '/^{::include [^\/]/{ s/^{::include /{::include draft-howe-sipcore-mcp-extension-00\//; }' $< >$@
	for inc in $$(sed -ne '/^{::include [^\/]/{ s/^{::include draft-howe-sipcore-mcp-extension-00\///;s/}$$//; p; }' $@); do \
	  target=draft-howe-sipcore-mcp-extension-00/$$inc; \
	  mkdir -p $$(dirname "$$target"); \
	  git show "$$tag:$$inc" >"$$target" || \
	    (echo "Attempting to make a copy of $$inc"; \
	     tmp=.; \
	     make -C "$$tmp" "$$inc" && cp "$$tmp/$$inc" "$$target"; \
	  ); \
	done
.INTERMEDIATE: versioned/draft-howe-sipcore-mcp-extension-kramdown-00.xml
versioned/draft-howe-sipcore-mcp-extension-kramdown-00.xml: draft-howe-sipcore-mcp-extension-kramdown.xml | versioned
	sed -e 's/draft-howe-sipcore-mcp-extension-kramdown-date/2025-09-29/g' -e 's/draft-howe-sipcore-mcp-extension-kramdown-latest/draft-howe-sipcore-mcp-extension-kramdown-00/g' -e 's/draft-howe-sipcore-mcp-extension-kramdown-date/2025-09-29/g' -e 's/draft-howe-sipcore-mcp-extension-kramdown-latest/draft-howe-sipcore-mcp-extension-kramdown-00/g' -e 's/draft-howe-sipcore-mcp-extension-date/2025-09-29/g' -e 's/draft-howe-sipcore-mcp-extension-latest/draft-howe-sipcore-mcp-extension-00/g' $< >$@
