# Swift Environment Setup

Swift exercises in this repository **do not use Nix**. You need to install Swift manually on your system.

## Why Not Nix?

Swift's toolchain on Linux has fundamental incompatibilities with Nix's isolation model (specifically, missing `libIndexStore.so` in nixpkgs). Rather than maintain complex workarounds, we follow the pragmatic approach: use Swift as its creators intended.

## Installation

### macOS

Swift comes pre-installed with Xcode Command Line Tools:

```bash
xcode-select --install
```

Or install via Homebrew:

```bash
brew install swift
```

### Linux

#### Ubuntu/Debian

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install \
  binutils \
  git \
  gnupg2 \
  libc6-dev \
  libcurl4-openssl-dev \
  libedit2 \
  libgcc-9-dev \
  libpython3.8 \
  libsqlite3-0 \
  libstdc++-9-dev \
  libxml2-dev \
  libz3-dev \
  pkg-config \
  tzdata \
  unzip \
  zlib1g-dev

# Download and install Swift
wget https://download.swift.org/swift-5.10.1-release/ubuntu2204/swift-5.10.1-RELEASE/swift-5.10.1-RELEASE-ubuntu22.04.tar.gz
tar xzf swift-5.10.1-RELEASE-ubuntu22.04.tar.gz
sudo mv swift-5.10.1-RELEASE-ubuntu22.04 /usr/share/swift
echo 'export PATH=/usr/share/swift/usr/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

#### Arch Linux

```bash
yay -S swift-bin
# or
pacman -S swift
```

### Verify Installation

```bash
swift --version
# Should output: Swift version 5.x.x
```

## Usage

### Test a specific project

```bash
cd swift
just test hello-world
```

Or manually:

```bash
cd swift/hello-world
swift test
```

### Test all Swift projects

```bash
cd swift
just test-all
```

## Links

- [Swift.org Downloads](https://swift.org/download/)
- [Swift on Linux Guide](https://swift.org/getting-started/#on-linux)

