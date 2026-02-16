.DEFAULT_GOAL := help

REPO_DIR := $(CURDIR)
REPO_TONES := $(CURDIR)/tones
CLAUDE_DIR := $(HOME)/.claude
CLAUDE_TONES := $(HOME)/.claude/tones
CLAUDE_SKILLS := $(HOME)/.claude/skills
CLAUDE_SCRIPTS := $(HOME)/.claude/scripts
SETTINGS := $(HOME)/.claude/settings.json

.PHONY: help install-tone uninstall-tone install-tones uninstall-tones list \
        install-hook uninstall-hook install-tone-skill install-create-skill \
        install-all update uninstall status

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
	@echo "  update                Pull latest and show update report"
	@echo "  uninstall             Remove everything installed by this repo"
	@echo "  status                Show current installation status"
	@echo "  help                  Show this help message"

install-tone:
ifndef TONE
	$(error TONE is required. Usage: make install-tone TONE=name)
endif
	@if [ ! -f "$(REPO_TONES)/$(TONE).md" ]; then \
		echo "Error: tone '$(TONE)' not found in $(REPO_TONES)/"; \
		exit 1; \
	fi
	@mkdir -p "$(CLAUDE_TONES)"
	@ln -sf "$(REPO_TONES)/$(TONE).md" "$(CLAUDE_TONES)/$(TONE).md"
	@echo "Installed tone: $(TONE)"

uninstall-tone:
ifndef TONE
	$(error TONE is required. Usage: make uninstall-tone TONE=name)
endif
	@if [ -L "$(CLAUDE_TONES)/$(TONE).md" ]; then \
		target=$$(readlink "$(CLAUDE_TONES)/$(TONE).md"); \
		case "$$target" in \
			$(REPO_TONES)/*) \
				rm "$(CLAUDE_TONES)/$(TONE).md"; \
				echo "Uninstalled tone: $(TONE)"; \
				;; \
			*) \
				echo "Skipped: $(TONE) is not managed by this repo"; \
				;; \
		esac; \
	else \
		echo "Tone '$(TONE)' is not installed as a symlink"; \
	fi

install-tones:
	@mkdir -p "$(CLAUDE_TONES)"
	@count=0; \
	for f in $(REPO_TONES)/*.md; do \
		[ -f "$$f" ] || continue; \
		name=$$(basename "$$f" .md); \
		ln -sf "$$f" "$(CLAUDE_TONES)/$$name.md"; \
		echo "  Installed: $$name"; \
		count=$$((count + 1)); \
	done; \
	echo "Installed $$count tone(s)"

uninstall-tones:
	@count=0; \
	if [ -d "$(CLAUDE_TONES)" ]; then \
		for f in $(CLAUDE_TONES)/*.md; do \
			[ -f "$$f" ] || continue; \
			if [ -L "$$f" ]; then \
				target=$$(readlink "$$f"); \
				case "$$target" in \
					$(REPO_TONES)/*) \
						rm "$$f"; \
						echo "  Removed: $$(basename "$$f" .md)"; \
						count=$$((count + 1)); \
						;; \
				esac; \
			fi; \
		done; \
	fi; \
	echo "Uninstalled $$count tone(s)"

list:
	@printf "%-20s %-12s %s\n" "Tone" "Status" "Source"
	@printf "%-20s %-12s %s\n" "----" "------" "------"
	@installed=0; available=0; local=0; modified=0; \
	seen=""; \
	for f in $(REPO_TONES)/*.md; do \
		[ -f "$$f" ] || continue; \
		name=$$(basename "$$f" .md); \
		seen="$$seen $$name"; \
		if [ -L "$(CLAUDE_TONES)/$$name.md" ]; then \
			target=$$(readlink "$(CLAUDE_TONES)/$$name.md"); \
			if [ "$$target" = "$$f" ]; then \
				printf "%-20s %-12s %s\n" "$$name" "installed" "$$f"; \
				installed=$$((installed + 1)); \
			else \
				printf "%-20s %-12s %s\n" "$$name" "modified" "$$target"; \
				modified=$$((modified + 1)); \
			fi; \
		else \
			printf "%-20s %-12s %s\n" "$$name" "available" "$$f"; \
			available=$$((available + 1)); \
		fi; \
	done; \
	if [ -d "$(CLAUDE_TONES)" ]; then \
		for f in $(CLAUDE_TONES)/*.md; do \
			[ -f "$$f" ] || continue; \
			name=$$(basename "$$f" .md); \
			is_seen=0; \
			for s in $$seen; do \
				if [ "$$s" = "$$name" ]; then is_seen=1; break; fi; \
			done; \
			if [ "$$is_seen" = "0" ]; then \
				if [ -L "$$f" ]; then \
					target=$$(readlink "$$f"); \
					case "$$target" in \
						$(REPO_TONES)/*) ;; \
						*) \
							printf "%-20s %-12s %s\n" "$$name" "local" "$$target"; \
							local=$$((local + 1)); \
							;; \
					esac; \
				else \
					printf "%-20s %-12s %s\n" "$$name" "local" "$(CLAUDE_TONES)/$$name.md"; \
					local=$$((local + 1)); \
				fi; \
			fi; \
		done; \
	fi; \
	echo ""; \
	printf "Installed: %d | Available: %d | Modified: %d | Local: %d\n" \
		"$$installed" "$$available" "$$modified" "$$local"

install-hook:
	@mkdir -p "$(CLAUDE_SCRIPTS)"
	@ln -sf "$(REPO_DIR)/scripts/rotate-tone.sh" "$(CLAUDE_SCRIPTS)/rotate-tone.sh"
	@chmod +x "$(CLAUDE_SCRIPTS)/rotate-tone.sh"
	@mkdir -p "$(CLAUDE_DIR)"
	@if [ ! -f "$(SETTINGS)" ]; then \
		echo '{}' > "$(SETTINGS)"; \
	fi
	@hook_cmd="$$HOME/.claude/scripts/rotate-tone.sh"; \
	has_hook=$$(jq -r \
		--arg cmd "$$hook_cmd" \
		'.hooks.SessionStart // [] | map(.hooks // [] | map(select(.type == "command" and .command == $$cmd))) | flatten | length' \
		"$(SETTINGS)" 2>/dev/null || echo "0"); \
	if [ "$$has_hook" != "0" ] && [ "$$has_hook" != "" ]; then \
		echo "Hook already installed"; \
	else \
		jq --arg cmd "$$hook_cmd" \
			'.hooks.SessionStart = ((.hooks.SessionStart // []) + [{"hooks": [{"type": "command", "command": $$cmd}]}])' \
			"$(SETTINGS)" > "$(SETTINGS).tmp" && mv "$(SETTINGS).tmp" "$(SETTINGS)"; \
		echo "Installed SessionStart hook"; \
	fi

uninstall-hook:
	@if [ -f "$(SETTINGS)" ]; then \
		hook_cmd="$$HOME/.claude/scripts/rotate-tone.sh"; \
		jq --arg cmd "$$hook_cmd" \
			'if .hooks.SessionStart then .hooks.SessionStart = [.hooks.SessionStart[] | select(.hooks | map(select(.type == "command" and .command == $$cmd)) | length == 0)] else . end | if .hooks.SessionStart == [] then del(.hooks.SessionStart) else . end | if .hooks == {} then del(.hooks) else . end' \
			"$(SETTINGS)" > "$(SETTINGS).tmp" && mv "$(SETTINGS).tmp" "$(SETTINGS)"; \
		echo "Removed SessionStart hook from settings"; \
	fi
	@if [ -L "$(CLAUDE_SCRIPTS)/rotate-tone.sh" ]; then \
		target=$$(readlink "$(CLAUDE_SCRIPTS)/rotate-tone.sh"); \
		case "$$target" in \
			$(REPO_DIR)/*) \
				rm "$(CLAUDE_SCRIPTS)/rotate-tone.sh"; \
				echo "Removed rotate-tone.sh symlink"; \
				;; \
			*) \
				echo "Skipped: rotate-tone.sh is not managed by this repo"; \
				;; \
		esac; \
	fi

install-tone-skill:
	@mkdir -p "$(CLAUDE_SKILLS)/tone"
	@ln -sf "$(REPO_DIR)/skills/tone/SKILL.md" "$(CLAUDE_SKILLS)/tone/SKILL.md"
	@echo "Installed /tone skill"

install-create-skill:
	@mkdir -p "$(CLAUDE_SKILLS)/create-tone"
	@ln -sf "$(REPO_DIR)/skills/create-tone/SKILL.md" "$(CLAUDE_SKILLS)/create-tone/SKILL.md"
	@echo "Installed /create-tone skill"

install-all: install-tones install-hook install-tone-skill install-create-skill
	@echo "All components installed"

update:
	@git -C "$(REPO_DIR)" pull
	@echo ""
	@printf "%-20s %-12s\n" "Tone" "Status"
	@printf "%-20s %-12s\n" "----" "------"
	@new=0; installed=0; local=0; \
	seen=""; \
	for f in $(REPO_TONES)/*.md; do \
		[ -f "$$f" ] || continue; \
		name=$$(basename "$$f" .md); \
		seen="$$seen $$name"; \
		if [ -L "$(CLAUDE_TONES)/$$name.md" ]; then \
			target=$$(readlink "$(CLAUDE_TONES)/$$name.md"); \
			if [ "$$target" = "$$f" ]; then \
				printf "%-20s %-12s\n" "$$name" "installed"; \
				installed=$$((installed + 1)); \
			else \
				printf "%-20s %-12s\n" "$$name" "installed"; \
				installed=$$((installed + 1)); \
			fi; \
		else \
			printf "%-20s %-12s\n" "$$name" "NEW"; \
			new=$$((new + 1)); \
		fi; \
	done; \
	if [ -d "$(CLAUDE_TONES)" ]; then \
		for f in $(CLAUDE_TONES)/*.md; do \
			[ -f "$$f" ] || continue; \
			name=$$(basename "$$f" .md); \
			is_seen=0; \
			for s in $$seen; do \
				if [ "$$s" = "$$name" ]; then is_seen=1; break; fi; \
			done; \
			if [ "$$is_seen" = "0" ]; then \
				printf "%-20s %-12s\n" "$$name" "local"; \
				local=$$((local + 1)); \
			fi; \
		done; \
	fi; \
	echo ""; \
	printf "New: %d | Installed: %d | Local: %d\n" "$$new" "$$installed" "$$local"; \
	if [ "$$new" -gt 0 ]; then \
		echo ""; \
		echo "Run 'make install-tones' to install new tones."; \
	fi

uninstall: uninstall-tones uninstall-hook
	@if [ -L "$(CLAUDE_SKILLS)/tone/SKILL.md" ]; then \
		target=$$(readlink "$(CLAUDE_SKILLS)/tone/SKILL.md"); \
		case "$$target" in \
			$(REPO_DIR)/*) \
				rm "$(CLAUDE_SKILLS)/tone/SKILL.md"; \
				echo "Removed /tone skill"; \
				;; \
		esac; \
	fi
	@if [ -L "$(CLAUDE_SKILLS)/create-tone/SKILL.md" ]; then \
		target=$$(readlink "$(CLAUDE_SKILLS)/create-tone/SKILL.md"); \
		case "$$target" in \
			$(REPO_DIR)/*) \
				rm "$(CLAUDE_SKILLS)/create-tone/SKILL.md"; \
				echo "Removed /create-tone skill"; \
				;; \
		esac; \
	fi
	@echo "Uninstall complete"

status:
	@echo "claude-tones status"
	@echo "==================="
	@installed=0; local=0; \
	if [ -d "$(CLAUDE_TONES)" ]; then \
		for f in $(CLAUDE_TONES)/*.md; do \
			[ -f "$$f" ] || continue; \
			if [ -L "$$f" ]; then \
				target=$$(readlink "$$f"); \
				case "$$target" in \
					$(REPO_TONES)/*) installed=$$((installed + 1)) ;; \
					*) local=$$((local + 1)) ;; \
				esac; \
			else \
				local=$$((local + 1)); \
			fi; \
		done; \
	fi; \
	echo "Tones installed: $$installed"; \
	echo "Tones local:     $$local"
	@if [ -f "$(SETTINGS)" ]; then \
		hook_cmd="$$HOME/.claude/scripts/rotate-tone.sh"; \
		has_hook=$$(jq -r \
			--arg cmd "$$hook_cmd" \
			'.hooks.SessionStart // [] | map(.hooks // [] | map(select(.type == "command" and .command == $$cmd))) | flatten | length' \
			"$(SETTINGS)" 2>/dev/null || echo "0"); \
		if [ "$$has_hook" != "0" ] && [ "$$has_hook" != "" ]; then \
			echo "Hook:            installed"; \
		else \
			echo "Hook:            not installed"; \
		fi; \
	else \
		echo "Hook:            not installed"; \
	fi
	@if [ -L "$(CLAUDE_SKILLS)/tone/SKILL.md" ]; then \
		target=$$(readlink "$(CLAUDE_SKILLS)/tone/SKILL.md"); \
		case "$$target" in \
			$(REPO_DIR)/*) echo "/tone skill:     installed" ;; \
			*) echo "/tone skill:     not installed" ;; \
		esac; \
	else \
		echo "/tone skill:     not installed"; \
	fi
	@if [ -L "$(CLAUDE_SKILLS)/create-tone/SKILL.md" ]; then \
		target=$$(readlink "$(CLAUDE_SKILLS)/create-tone/SKILL.md"); \
		case "$$target" in \
			$(REPO_DIR)/*) echo "/create-tone skill: installed" ;; \
			*) echo "/create-tone skill: not installed" ;; \
		esac; \
	else \
		echo "/create-tone skill: not installed"; \
	fi
