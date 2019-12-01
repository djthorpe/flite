# Go parameters
GOCMD=go
GOINSTALL=$(GOCMD) install
GOTEST=$(GOCMD) test
GOCLEAN=$(GOCMD) clean

# PKG_CONFIG_PATH
PKG_CONFIG_PATH="/opt/flite/pkgconfig"

test:
	PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) $(GOTEST) -v ./flite

clean: 
	$(GOCLEAN)