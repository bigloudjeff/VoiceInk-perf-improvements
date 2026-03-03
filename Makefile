# Define a directory for dependencies in the user's home folder
DEPS_DIR := $(HOME)/VoiceInk-Dependencies
WHISPER_CPP_DIR := $(DEPS_DIR)/whisper.cpp
FRAMEWORK_PATH := $(WHISPER_CPP_DIR)/build-apple/whisper.xcframework

.PHONY: all clean whisper setup build local check healthcheck help dev run test stamp

# Default target
all: check build

# Development workflow
dev: build run

# Prerequisites
check:
	@echo "Checking prerequisites..."
	@command -v git >/dev/null 2>&1 || { echo "git is not installed"; exit 1; }
	@command -v xcodebuild >/dev/null 2>&1 || { echo "xcodebuild is not installed (need Xcode)"; exit 1; }
	@command -v swift >/dev/null 2>&1 || { echo "swift is not installed"; exit 1; }
	@echo "Prerequisites OK"

healthcheck: check

# Build process
whisper:
	@mkdir -p $(DEPS_DIR)
	@if [ ! -d "$(FRAMEWORK_PATH)" ]; then \
		echo "Building whisper.xcframework in $(DEPS_DIR)..."; \
		if [ ! -d "$(WHISPER_CPP_DIR)" ]; then \
			git clone https://github.com/ggerganov/whisper.cpp.git $(WHISPER_CPP_DIR); \
		else \
			(cd $(WHISPER_CPP_DIR) && git pull); \
		fi; \
		cd $(WHISPER_CPP_DIR) && ./build-xcframework.sh; \
	else \
		echo "whisper.xcframework already built in $(DEPS_DIR), skipping build"; \
	fi

setup: whisper
	@echo "Whisper framework is ready at $(FRAMEWORK_PATH)"
	@echo "Please ensure your Xcode project references the framework from this new location."

build: setup stamp
	xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug CODE_SIGN_IDENTITY="" build

# Increment build number and stamp build date into BuildInfo.swift
stamp:
	@# Increment CURRENT_PROJECT_VERSION in project.pbxproj (main target only, first 2 occurrences)
	@CURRENT=$$(grep -m1 'CURRENT_PROJECT_VERSION = [0-9]' VoiceInk.xcodeproj/project.pbxproj | sed 's/[^0-9]//g') && \
	NEXT=$$((CURRENT + 1)) && \
	awk -v old="$$CURRENT" -v new="$$NEXT" 'BEGIN{count=0} /CURRENT_PROJECT_VERSION = [0-9]/ && count < 2 {sub("CURRENT_PROJECT_VERSION = "old, "CURRENT_PROJECT_VERSION = "new); count++} {print}' VoiceInk.xcodeproj/project.pbxproj > VoiceInk.xcodeproj/project.pbxproj.tmp && \
	mv VoiceInk.xcodeproj/project.pbxproj.tmp VoiceInk.xcodeproj/project.pbxproj && \
	echo "Build number: $$CURRENT -> $$NEXT"
	@# Stamp build date into BuildInfo.swift
	@BUILD_DATE=$$(date '+%Y-%m-%d %H:%M:%S') && \
	sed -i '' "s/static let buildDate = \".*\"/static let buildDate = \"$$BUILD_DATE\"/" VoiceInk/BuildInfo.swift && \
	echo "Build date: $$BUILD_DATE"

# Build for local use without Apple Developer certificate
local: check setup stamp
	@echo "Building VoiceInk for local use (no Apple Developer certificate required)..."
	xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug \
		-xcconfig LocalBuild.xcconfig \
		CODE_SIGN_ENTITLEMENTS=$(CURDIR)/VoiceInk/VoiceInk.local.entitlements \
		SWIFT_ACTIVE_COMPILATION_CONDITIONS='$$(inherited) LOCAL_BUILD' \
		build
	@APP_PATH=$$(find "$$HOME/Library/Developer/Xcode/DerivedData" -name "VoiceInk.app" -path "*/Debug/*" -type d | head -1) && \
	if [ -n "$$APP_PATH" ]; then \
		echo "Copying VoiceInk.app to ~/Downloads..."; \
		rm -rf "$$HOME/Downloads/VoiceInk.app"; \
		ditto "$$APP_PATH" "$$HOME/Downloads/VoiceInk.app"; \
		xattr -cr "$$HOME/Downloads/VoiceInk.app"; \
		echo ""; \
		echo "Build complete! App saved to: ~/Downloads/VoiceInk.app"; \
		echo "Run with: open ~/Downloads/VoiceInk.app"; \
		echo ""; \
		echo "Limitations of local builds:"; \
		echo "  - No iCloud dictionary sync"; \
		echo "  - No automatic updates (pull new code and rebuild to update)"; \
	else \
		echo "Error: Could not find built VoiceInk.app in DerivedData."; \
		exit 1; \
	fi

# Run unit tests
test: check setup
	@echo "Running VoiceInk unit tests..."
	xcodebuild test -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug \
		-xcconfig LocalBuild.xcconfig \
		CODE_SIGN_ENTITLEMENTS=$(CURDIR)/VoiceInk/VoiceInk.local.entitlements \
		SWIFT_ACTIVE_COMPILATION_CONDITIONS='$$(inherited) LOCAL_BUILD' \
		-destination 'platform=macOS' \
		-only-testing:VoiceInkTests

# Run application
run:
	@if [ -d "$$HOME/Downloads/VoiceInk.app" ]; then \
		echo "Opening ~/Downloads/VoiceInk.app..."; \
		open "$$HOME/Downloads/VoiceInk.app"; \
	else \
		echo "Looking for VoiceInk.app in DerivedData..."; \
		APP_PATH=$$(find "$$HOME/Library/Developer/Xcode/DerivedData" -name "VoiceInk.app" -type d | head -1) && \
		if [ -n "$$APP_PATH" ]; then \
			echo "Found app at: $$APP_PATH"; \
			open "$$APP_PATH"; \
		else \
			echo "VoiceInk.app not found. Please run 'make build' or 'make local' first."; \
			exit 1; \
		fi; \
	fi

# Cleanup
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(DEPS_DIR)
	@echo "Clean complete"

# Help
help:
	@echo "Available targets:"
	@echo "  check/healthcheck  Check if required CLI tools are installed"
	@echo "  whisper            Clone and build whisper.cpp XCFramework"
	@echo "  setup              Copy whisper XCFramework to VoiceInk project"
	@echo "  build              Build the VoiceInk Xcode project"
	@echo "  local              Build for local use (no Apple Developer certificate needed)"
	@echo "  run                Launch the built VoiceInk app"
	@echo "  test               Run unit tests"
	@echo "  dev                Build and run the app (for development)"
	@echo "  all                Run full build process (default)"
	@echo "  clean              Remove build artifacts"
	@echo "  help               Show this help message"