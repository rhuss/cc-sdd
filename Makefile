.PHONY: validate-plugin install-local-marketplace uninstall-marketplace uninstall-plugin install-plugin reinstall-plugin check-upstream help

validate-plugin:
	claude plugin validate ./
	claude plugin validate ./sdd/

install-local-marketplace:
	@output=$$(claude plugin marketplace add ./ 2>&1) || { \
		if echo "$$output" | grep -q "Marketplace '.*' is already installed"; then \
			echo "Marketplace already installed, updating..."; \
			claude plugin marketplace update sdd-plugin-development; \
		else \
			echo "$$output" >&2; \
			exit 1; \
		fi; \
	}

uninstall-marketplace: uninstall-plugin
	@echo "Removing marketplace..."
	@claude plugin marketplace rm sdd-plugin-development 2>/dev/null || echo "Marketplace not installed"

uninstall-plugin:
	@echo "Removing plugin..."
	@claude plugin rm sdd@sdd-plugin-development 2>/dev/null || echo "Plugin not installed"

install-plugin: install-local-marketplace
	claude plugin install sdd@sdd-plugin-development

reinstall-plugin: uninstall-plugin uninstall-marketplace install-local-marketplace install-plugin

check-upstream:
	cd sdd && ./scripts/check-upstream-changes.sh

help:
	@echo "Available targets:"
	@echo "  validate-plugin           - Validate plugin manifests"
	@echo "  install-local-marketplace - Add marketplace to Claude Code"
	@echo "  uninstall-marketplace     - Remove marketplace from Claude Code"
	@echo "  install-plugin            - Install plugin from local marketplace"
	@echo "  uninstall-plugin          - Remove plugin from Claude Code"
	@echo "  reinstall-plugin          - Full reinstall cycle"
	@echo "  check-upstream            - Check for upstream changes"
