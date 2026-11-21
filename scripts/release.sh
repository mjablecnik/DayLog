#!/bin/bash
#
# Raises the version, writes the Changelog and tags the release.
#
# Usage: scripts/release.sh <version>      e.g. 1.0.0 or 1.0.0-dev.0
#
# It sets `version:` in pubspec.yaml (the one source of the version; the build
# number after `+` is kept), prepends a section to CHANGELOG.md made of the
# commits since the previous tag, commits both as `chore: bump version to
# <version>` and creates the annotated tag `v<version>` on that commit.
# Nothing is pushed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
cd "${PROJECT_ROOT}"

VERSION="${1:-}"
SEMVER='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z.-]+)?$'
if [[ ! "${VERSION}" =~ ${SEMVER} ]]; then
	echo "release.sh: '${VERSION}' is not a semantic version (MAJOR.MINOR.PATCH[-pre-release])" >&2
	exit 1
fi
if [[ -n "$(git status --porcelain)" ]]; then
	echo "release.sh: the working tree is not clean; commit or stash first" >&2
	exit 1
fi
if git rev-parse -q --verify "refs/tags/v${VERSION}" >/dev/null; then
	echo "release.sh: the tag v${VERSION} already exists" >&2
	exit 1
fi

if PREVIOUS="$(git describe --tags --abbrev=0 2>/dev/null)"; then
	RANGE="${PREVIOUS}..HEAD"
else
	RANGE="HEAD"
fi

FEATURES=""
FIXES=""
OTHER=""
while IFS= read -r subject; do
	[[ -z "${subject}" ]] && continue
	[[ "${subject}" =~ ^chore:\ bump\ version ]] && continue
	if [[ "${subject}" =~ ^feat(\(([^\)]*)\))?(\!)?:\ (.*)$ ]]; then
		FEATURES+="- ${BASH_REMATCH[4]}${BASH_REMATCH[2]:+ (${BASH_REMATCH[2]})}"$'\n'
	elif [[ "${subject}" =~ ^fix(\(([^\)]*)\))?(\!)?:\ (.*)$ ]]; then
		FIXES+="- ${BASH_REMATCH[4]}${BASH_REMATCH[2]:+ (${BASH_REMATCH[2]})}"$'\n'
	else
		OTHER+="- ${subject}"$'\n'
	fi
done < <(git log --format='%s' "${RANGE}")

SECTION="## [${VERSION}] - $(date +%Y-%m-%d)"$'\n'
[[ -n "${FEATURES}" ]] && SECTION+=$'\n'"### Features"$'\n\n'"${FEATURES}"
[[ -n "${FIXES}" ]] && SECTION+=$'\n'"### Fixes"$'\n\n'"${FIXES}"
[[ -n "${OTHER}" ]] && SECTION+=$'\n'"### Other"$'\n\n'"${OTHER}"

if ! grep -q '^## \[Unreleased\]' CHANGELOG.md; then
	echo "release.sh: CHANGELOG.md has no '## [Unreleased]' section" >&2
	exit 1
fi

# Insert the new section right after the Unreleased heading, which stays empty.
SECTION_FILE="$(mktemp)"
TMP="$(mktemp)"
printf '%s\n' "${SECTION}" >"${SECTION_FILE}"
awk -v section_file="${SECTION_FILE}" '
	{ print }
	/^## \[Unreleased\]/ && !done {
		print ""
		while ((getline line < section_file) > 0) print line
		done = 1
	}
' CHANGELOG.md >"${TMP}"
mv "${TMP}" CHANGELOG.md
rm -f "${SECTION_FILE}"

BUILD="$(sed -n 's/^version: [^+]*+\(.*\)$/\1/p' pubspec.yaml)"
if [[ -n "${BUILD}" ]]; then
	sed -i.bak "s/^version: .*/version: ${VERSION}+${BUILD}/" pubspec.yaml
else
	sed -i.bak "s/^version: .*/version: ${VERSION}/" pubspec.yaml
fi
rm -f pubspec.yaml.bak

git add CHANGELOG.md pubspec.yaml
git commit -q -m "chore: bump version to ${VERSION}"
git tag -a "v${VERSION}" -m "Release ${VERSION}"
echo "release.sh: released ${VERSION} (tag v${VERSION}); nothing was pushed"
