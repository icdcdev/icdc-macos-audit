# icdc-macos-audit
Repository to save scripts that audit macOS security configurations

## Steps ##

First you need to install Homebrew, type this in your terminal, then press enter and follow the instructions

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Then you need to install the following dependencies:

```bash
brew install blueutil jq
```

Finally, you need to run this command

```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
```