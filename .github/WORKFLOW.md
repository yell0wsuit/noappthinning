# GitHub Actions Workflow

This repository includes a GitHub Actions workflow that automatically builds and releases `.deb` packages for the NoAppThinning tweak.

## Workflow Triggers

1. **Tag Push**: When a tag matching `v*` is pushed (e.g., `v1.3`, `v2.0`)
   - Builds the package
   - Creates a GitHub release
   - Uploads the `.deb` file to the release

2. **Pull Request**: On PRs to main/master branches
   - Builds the package to test changes
   - Uploads artifact for testing

3. **Manual Dispatch**: Can be triggered manually from the Actions tab

## Creating a Release

To create a new release:

1. Update the version in `layout/DEBIAN/control`
2. Commit your changes
3. Create and push a tag:
   ```bash
   git tag v1.3
   git push origin v1.3
   ```
4. The workflow will automatically build and create a release

## Build Process

The workflow:
1. Sets up Ubuntu environment with necessary dependencies
2. Installs THEOS with recursive submodules
3. Downloads iOS SDKs
4. Builds the package using `make package FINALPACKAGE=1`
5. Uploads the resulting `.deb` file

## Dependencies Installed

- git, make, fakeroot, rsync, curl, unzip, build-essential
- clang, perl, python3
- ldid (for code signing, with fallback installation)

## Troubleshooting

If the build fails:
1. Check the Actions logs for detailed error messages
2. Ensure `layout/DEBIAN/control` has correct syntax
3. Verify all source files are properly committed
4. Check that THEOS makefiles can find all dependencies

## Local Testing

You can test the build locally before pushing:
```bash
# Install THEOS first
export THEOS=/path/to/theos
make clean
make package
```