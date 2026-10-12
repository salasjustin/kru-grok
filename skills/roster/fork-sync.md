# fork-sync — bring this fork current with upstream kru

This repo is the Grok Bot fork of upstream `ap-justin/kru` (the `upstream` remote). `README.md` → *Version* names the upstream version last synced. Run after an upstream release, or when that marker is behind upstream `VERSION`.

1. `git fetch upstream && git show upstream/main:VERSION`. Stop if it equals the synced marker.
2. On a branch named `sync-kru-X.Y.Z`, have a headless delegate port the upstream changes into this fork's layout, following `GROK.md`. Rewrite anything that depends on another host's hooks or tools into this fork's conventions.
3. Run `bash scripts/verify.sh` (and `scripts/smoke.sh` for behavior changes). Review the diff yourself.
4. Bump this fork's `VERSION` minor (it keeps its own semver line, ahead of upstream). Set the `ROSTER.md` header to match, and rewrite the `README.md` version line keeping its shape: `` `VERSION` is the single version (plain semver, `<new>` = upstream `X.Y.Z` plus … ``, so `verify.sh` still matches it.
5. Ship it with `release.md`.
