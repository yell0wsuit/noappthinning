# NoAppThinning
Cydia tweak to disable App Store app thinning. This means that all architectures available for an app will be included when downloading it from the App Store. <strong>Warning</strong>: this will increase download size!

No settings to configure and no respring needed. Tested on iOS 11+ and compatible with both rooted and rootless jailbreaks, including iPhone 7+ devices.

## Compatibility
- iOS 11 and later
- iPhone 7+ and newer devices (arm64, arm64e support)
- Both rooted and rootless jailbreaks

## Installation
You can install the `.deb` manually or get it at this Cydia repo: https://n3d1117.github.io

### Download Latest Release
Pre-built `.deb` packages are automatically generated and available in the [Releases](https://github.com/yell0wsuit/noappthinning/releases) section.

## Building
This project uses THEOS for building. GitHub Actions automatically builds and releases `.deb` packages when tags are pushed.

### Local Build
If you want to build locally:
1. Install THEOS following the [official guide](https://github.com/theos/theos/wiki/Installation)
2. Clone this repository
3. Run `make package`

### Automated Builds
- **Pull Requests**: Automatically builds to test changes
- **Tagged Releases**: Creates releases with `.deb` files when tags matching `v*` are pushed
- **Manual**: Can be triggered manually from the Actions tab

## Credits
Credits: [level3tjg](https://twitter.com/level3tjg)
