## Motivation

[SquashFS](https://www.kernel.org/doc/html/latest/filesystems/squashfs.html) images are a popular way to store file trees for a variety of good reasons. They are for example used for package distribution in [Snapcraft](https://snapcraft.io) and [AppImage](https://appimage.org). But while both of those package/app managers push package updates as SquashFS deltas, SquashFS images were never created with binary deltas in mind.

Namely, the content of SquashFS images is virtually always compressed, so even a small change in the underlying content can lead to quite a different image. Meaning a relatively large delta.

This repo is an exploration of a better approach, which - while working with the exact same SquashFS images - can generate and apply "true" deltas that relfect changes to the underlying file content. In real-world package examples, this empirically leads to deltas that are between 45% and 98% smaller than the "naive" deltas taken between two separate SquashFS images.

## Usage

The two bash scripts, `generate_delta.sh` and `apply_delta.sh` have syntax that is equivalent to `xdelta3 -e -s` and `xdelta3 -d -s` respectively. Namely:
```
generate_delta.sh <file_A> <file_B> <output_delta_file>
```
and
```
apply_delta.sh <file_A> <delta_file> <output_file_B>
```

## Under-the-hood, and prerequisites
The scripts are basically one-liners that explot the "pseudo file" functionality in `squashfs-tools`. Pseudo files are files that can be converted to and from SquashFS images, and contain the decoded/decompressed content of the respective image. Full-fledged pseudo file functionality was introduced in `squashfs-tools` version 4.5, so **you need to make sure you are running a version of that's sufficiently new** (check with `mksquashfs -version`). `xdelta3` is also required in order to actually generate/apply the deltas.

## Misc
The SquashFS file generated by `apply_delta.sh` uses the same parameters as `snapcraft` for generating `snap` files (i.e. `xz` compression, no fragment packing).

While `generate_delta.sh` is a one-liner that pipes all content, `apply_delta.sh` actually generates a temporary file which is subsequently packed into the final SquashFS image (before being deleted). The latter is necessary since `mksquashfs` currently requires a seekable file and cannot take piped input. I've created [an issue](https://github.com/plougher/squashfs-tools/issues/178) to allow a piped input in this scenario also (hopefully possible given that tar input can be piped in)
