# Where to find flite
PREFIX="/opt"
PKG_CONFIG_PATH="/opt/flite/pkgconfig"

# Go parameters
GOCMD=go
GOINSTALL=$(GOCMD) install
GOTEST=$(GOCMD) test
GOCLEAN=$(GOCMD) clean

all: distbuild test

distbuild:
	install -d $(PREFIX) -m 0775
	scripts/install-flite.sh -p $(PREFIX)

test:
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) $(GOTEST) -v ./flite

clean: 
	$(GOCLEAN)