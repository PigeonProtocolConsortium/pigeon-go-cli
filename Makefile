GOOS?=linux
GOARCH?=amd64
EXT?=
APP?=pigeon-cli
NAME?=$(APP)-$(GOOS)-$(GOARCH)$(EXT)

PREFIX?=$(CURDIR)
SRC?=$(PREFIX)/project
TARGET?=$(PREFIX)/targets

ARTIFACT_TARGET?=$(TARGET)/artifacts
BUILD_TARGET?=$(TARGET)/builds
TEST_TARGET?=$(TARGET)/tests

TESTDATA?=$(SRC)/testdata
FLAGS?=

dependencies:
	cd $(SRC) && go mod download -x


$(BUILD_TARGET)/$(NAME):
	cd $(SRC) && \
	GOOS=$(GOOS) GOARCH=$(GOARCH) go build -o $(BUILD_TARGET)/$(NAME)

build-win-32: GOOS=windows
build-win-32: GOARCH=386
build-win-32: EXT=.exe
build-win-32: $(BUILD_TARGET)/$(NAME);
build-win-64: GOOS=windows
build-win-64: GOARCH=amd64
build-win-64: EXT=.exe
build-win-64: $(BUILD_TARGET)/$(NAME);
build-mac: GOOS=darwin
build-mac: GOARCH=amd64
build-mac: $(BUILD_TARGET)/$(NAME);
build-linux-32: GOOS=linux
build-linux-32: GOARCH=386
build-linux-32: $(BUILD_TARGET)/$(NAME);
build-linux-64: GOOS=linux
build-linux-64: GOARCH=amd64
build-linux-64: $(BUILD_TARGET)/$(NAME);
build-linux-arm: GOOS=linux
build-linux-arm: GOARCH=arm
build-linux-arm: $(BUILD_TARGET)/$(NAME);
build: $(BUILD_TARGET)/$(NAME);

test: clean-test
	mkdir -p $(TESTDATA)
	cd $(SRC) && \
	go test $(FLAGS) ./...

cover: FLAGS += -coverprofile=$(TEST_TARGET)/coverage.out
cover: clean-cover test
	cd $(SRC) && \
	go cover -html $(TEST_TARGET)/coverage.out -o $(TEST_TARGET)/coverage.html

vet:
	cd $(SRC) && \
	go vet -c=3 ./...

fmt:
	cd $(SRC) && \
	go fmt -x ./...

clean-artifacts:
	rm -rf $(ARTIFACT_TARGET)/*
clean-build:
	rm -rf $(BUILD_TARGET)/*
clean-cover:
	rm -rf $(TEST_TARGET)/*
clean-test:
	rm -rf $(TESTDATA)
clean: clean-build clean-test clean-cover