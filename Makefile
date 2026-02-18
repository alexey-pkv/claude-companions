.DEFAULT_GOAL := help

SCRIPTS := $(CURDIR)/scripts/unix

.PHONY: help install-tone uninstall-tone install-tones uninstall-tones list \
        install-hook uninstall-hook install-tone-skill install-create-skill \
        install-all uninstall status

help:
	@echo "claude-tones - Manage Claude Code personality tones"
	@echo ""
	@echo "Usage: make <target> [TONE=name]"
	@echo ""
	@echo "Targets:"
	@echo "  install-tone TONE=x   Install a single tone by name"
	@echo "  uninstall-tone TONE=x Uninstall a single tone by name"
	@echo "  install-tones         Install all tones from this repo"
	@echo "  uninstall-tones       Uninstall all tones managed by this repo"
	@echo "  list                  Show all tones and their status"
	@echo "  install-hook          Install the SessionStart rotation hook"
	@echo "  uninstall-hook        Remove the SessionStart rotation hook"
	@echo "  install-tone-skill    Install the /tone skill"
	@echo "  install-create-skill  Install the /create-tone skill"
	@echo "  install-all           Install tones, hook, and skills"
	@echo "  uninstall             Remove everything installed by this repo"
	@echo "  status                Show current installation status"
	@echo "  help                  Show this help message"

install-tone:
ifndef TONE
	$(error TONE is required. Usage: make install-tone TONE=name)
endif
	@$(SCRIPTS)/install-tone.sh "$(TONE)"

uninstall-tone:
ifndef TONE
	$(error TONE is required. Usage: make uninstall-tone TONE=name)
endif
	@$(SCRIPTS)/uninstall-tone.sh "$(TONE)"

install-tones:
	@$(SCRIPTS)/install-tone.sh --all

uninstall-tones:
	@$(SCRIPTS)/uninstall-tone.sh --all

list:
	@$(SCRIPTS)/list.sh

install-hook:
	@$(SCRIPTS)/install-hook.sh

uninstall-hook:
	@$(SCRIPTS)/uninstall-hook.sh

install-tone-skill:
	@$(SCRIPTS)/install-skill.sh "/tone" "tone"

install-create-skill:
	@$(SCRIPTS)/install-skill.sh "/create-tone" "create-tone"

install-all: install-tones install-hook install-tone-skill install-create-skill
	@echo "All components installed"

uninstall: uninstall-tones uninstall-hook
	@$(SCRIPTS)/uninstall-skill.sh "/tone" "tone"
	@$(SCRIPTS)/uninstall-skill.sh "/create-tone" "create-tone"
	@echo "Uninstall complete"

status:
	@$(SCRIPTS)/status.sh
