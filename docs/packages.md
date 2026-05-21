# Published packages

Container images built from this repo are published to
[GitHub Container Registry](https://ghcr.io) and surfaced under
[huukhanh/pub-pkg](https://github.com/huukhanh/pub-pkg) — a public hub
that aggregates packages from many of `huukhanh`'s repos in one place.

## Naming convention

```
ghcr.io/huukhanh/<source-repo>-<component>:<tag>
```

| Piece            | Meaning                                                                                        | Example       |
|------------------|------------------------------------------------------------------------------------------------|---------------|
| `<source-repo>`  | Slug of the GitHub repo the image is built from. Hyphens, not slashes — image names disallow `/` past the namespace boundary. | `mager`       |
| `<component>`    | Short noun for which artifact inside the repo this is. Use a single word when possible.       | `agent`       |
| `<tag>`          | `latest`, `main`, a short commit sha, or a release version stripped of its `agent-v` / `v` prefix. | `0.3.0`       |

Putting them together — this repo's agent image:

```
ghcr.io/huukhanh/mager-agent:latest
ghcr.io/huukhanh/mager-agent:0.3.0
ghcr.io/huukhanh/mager-agent:sha-1a2b3c4
```

## Why the `pub-pkg` repo?

GHCR scopes packages to a user/org, not to a repo. Two pieces wire the
package into a repo's "Packages" sidebar:

1. The OCI label `org.opencontainers.image.source` in the Dockerfile,
   pointing at `https://github.com/huukhanh/pub-pkg`.
2. The matching label re-applied by `docker/metadata-action` in the
   publish workflow so the actual pushed manifest carries it (the
   in-Dockerfile label gets overwritten by buildx when labels are passed
   on the command line).

The build itself still runs from the source repo's workflow — only the
"this package lives in repo X" link points at `pub-pkg`.

## Adding a new package to `pub-pkg`

1. Pick a name following the convention above.
2. Add a `Dockerfile` to the source repo with the OCI labels
   (`title`, `description`, `source=https://github.com/huukhanh/pub-pkg`,
   `licenses`).
3. Add a publish workflow (copy `.github/workflows/agent-image.yml` as a
   starting point; change `IMAGE_NAME` and the `paths:` filter).
4. After the first successful push, open the package's settings on GHCR
   and flip **Change package visibility → Public**. New packages default
   to private even when the source repo is public.
5. Pin a release tag from the source repo (`agent-v0.3.0`, etc.) to cut
   the first stable version.

## Currently published

| Image                              | Source                                          | Architectures           |
|------------------------------------|-------------------------------------------------|-------------------------|
| `ghcr.io/huukhanh/mager-agent`     | [`huukhanh/mager`](https://github.com/huukhanh/mager) → `agent/` | `linux/amd64`, `linux/arm64` |
