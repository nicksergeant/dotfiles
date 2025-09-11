.PHONY: build install clean

build:
	@zip -r fuzzy-find.alfredworkflow info.plist search.sh README.md icon.png
	@echo "✓ Built fuzzy-find.alfredworkflow"

install: build
	@open fuzzy-find.alfredworkflow
	@echo "✓ Installing workflow..."

clean:
	@rm -f fuzzy-find.alfredworkflow
	@echo "✓ Cleaned build artifacts"
