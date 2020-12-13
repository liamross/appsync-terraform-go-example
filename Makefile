help: ## Prints out all make commands and their actions
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: clean ## Build Go binaries
	@echo \\nGenerating function binaries...
	@mkdir bin
	@for function in `ls functions`; do \
		GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bin/$$function functions/$$function/main.go ; \
		echo "  -> Generated: bin/$$function" ; \
	done

clean: ## Removes build directories
	@echo \\nRemoving build files...
	@rm -rf ./bin
	@echo "  -> Removed: ./bin"
	@rm -rf ./zip
	@echo "  -> Removed: ./zip"
