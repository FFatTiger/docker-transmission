# Transmission Docker Build with Long Filename Fix

A Docker implementation of the long filename fix for Transmission, based on the solution provided by [@chrdev](https://github.com/chrdev) in [transmission/transmission#122](https://github.com/transmission/transmission/issues/122#issuecomment-2401583834).

## Build Instructions

1. Initialize and update submodules:
```bash
git submodule update --init --recursive
```

2. Build the Docker image:
```bash
docker build -t transmission .
```

## Acknowledgments

Special thanks to [@chrdev](https://github.com/chrdev) for providing the solution to fix the long filename issue that has been affecting Transmission for many years.

Additional thanks to [@ppenguin](https://github.com/ppenguin) for their support in this project.

## Related Issues

- [transmission/transmission#122](https://github.com/transmission/transmission/issues/122) - Original issue discussing the "filename too long" problem

