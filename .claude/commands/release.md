Create a new release for this repository by following these steps:

1. Determine the next version by reading the latest version from `ChangeLog.adoc` and incrementing the minor version (e.g. 1.14.0 → 1.15.0). Use today's date for the release date.

2. Update `ChangeLog.adoc`: add a new version section at the top (after the `= Changelog` heading) summarising all changes since the previous release.

3. Update all version references in `README.adoc` and `CLAUDE.md`: replace every occurrence of the previous version tag with the new version tag (e.g. `@v1.14.0` → `@v1.15.0`).

4. Stage the changed files (`ChangeLog.adoc`, `README.adoc`, `CLAUDE.md`) and commit with the message:
   `chore: update ChangeLog, README and CLAUDE.md for vX.Y.Z release`

5. Create a git tag `vX.Y.Z`, push the `main` branch and the tag to origin.

6. Create a GitHub release using `gh release create vX.Y.Z` with a title `vX.Y.Z` and release notes matching the new ChangeLog section.
