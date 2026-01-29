.PHONY: validate install uninstall reinstall check-upstream help

MARKETPLACE := sdd-plugin-development
PLUGIN := sdd@$(MARKETPLACE)

validate:
	claude plugin validate ./
	claude plugin validate ./sdd/

install:
	@# Add or update marketplace
	@if claude plugin marketplace add ./ 2>&1 | grep -q "already installed"; then \
		echo "Updating marketplace..."; \
		claude plugin marketplace update $(MARKETPLACE); \
	else \
		echo "Marketplace added."; \
	fi
	@# Install or reinstall plugin
	@if claude plugin list 2>/dev/null | grep -q "$(PLUGIN)"; then \
		echo "Plugin already installed, reinstalling..."; \
		claude plugin rm $(PLUGIN) 2>/dev/null || true; \
	fi
	claude plugin install $(PLUGIN)

uninstall:
	@echo "Removing plugin..."
	@claude plugin rm $(PLUGIN) 2>/dev/null || echo "Plugin not installed"
	@echo "Removing marketplace..."
	@claude plugin marketplace rm $(MARKETPLACE) 2>/dev/null || echo "Marketplace not installed"

reinstall: uninstall install

check-upstream:
	cd sdd && ./scripts/check-upstream-changes.sh

help:
	@echo "Available targets:"
	@echo "  validate       - Validate plugin manifests"
	@echo "  install        - Install plugin (adds marketplace, installs/updates plugin)"
	@echo "  uninstall      - Remove plugin and marketplace"
	@echo "  reinstall      - Full uninstall and reinstall"
	@echo "  check-upstream - Check for upstream superpowers changes"
