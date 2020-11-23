# Summary

This is a Dockerfile which adds Tensorflow and Pytorch. Typical usage for this Dockerfile is to be built off either `minimal-notebook-cpu` or `minimal-notebook-gpu`, depending on whether GPU support is desired. This provides a common notebook setup for both CPU and GPU paths, ensuring they're synced as much as possible. The upstream image is defined during `docker build` via `--build-arg BASE_CONTAINER`.

## CI

For CI, see `.github/workflows/build-cpu.yml` and `.github/workflows/build-gpu.yml`. They leverage the `.github/workflows/build_push.sh` wrapper for tagging, pushing and caching all at once.