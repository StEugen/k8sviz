test: test-lint test-fmt test-vet test-unit
	@echo "[Running test]"

test-lint:
	@echo "[Running golint]"
	golint -set_exit_status cmd/... pkg/...

test-fmt:
	@echo "[Running gofmt]"
	if [ "$$(gofmt -l cmd/ pkg/ | wc -l)" -ne 0 ]; then \
		gofmt -d cmd/ pkg/ ;\
		false; \
	fi

test-vet:
	@echo "[Running go vet]"
	go vet `go list ./... | grep -v test/e2e`


test-unit:
	@echo "[Running unit tests]"
	go test -cover `go list ./... | grep -v test/e2e`

test-e2e: build
	@echo "[Running e2e tests]"
	./test/e2e/e2e.sh

build:
	@echo "[Build]"
	mkdir -p bin/
	CGO_ENABLED=0 GO111MODULE=on go build -ldflags '-extldflags "-static"' -o bin/k8sviz ./cmd/k8sviz
	#GO111MODULE=on go build -o bin/k8sviz ./cmd/k8sviz

release: test build test-e2e

.PHONY: test test-lint test-fmt test-vet test-unit test-e2e build release image-build image-push
