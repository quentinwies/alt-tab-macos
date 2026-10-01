# AppGroupingResolver — Specs

## Summary

Per-app window grouping. The user lists apps in the Exceptions tab with **Group windows** on
(`ExceptionEntry.groupWindows`). A listed app shows as one tile in the switcher, like the global
"Show one window per app" mode but for that app only. Selecting the tile raises all of the app's
windows, with the represented window on top and key, as macOS app switching (⌘⇥) does.

- `isListed` — the app has a grouping entry. Matching is a bundle-id prefix, identical to
  `ExceptionMatcher`: an entry applies iff its bundle id is non-empty and is a prefix of the app's.
  An app without a bundle id never matches.
- `showsOneTile` — the switcher collapses this app's windows into one tile: the global
  "Show one window per app" mode is on, or the app is listed.

The representative tile is picked by `ApplicationRepresentativeResolver` (see `WindowOrderResolverSpecs.md`),
so a grouped app and the global mode pick the same window.

## Behavior & edge cases

- Only listed apps raise all their windows on focus. The global "one window per app" mode keeps raising the
  representative window only.
- Grouping applies to windows which passed the filters; a hidden or filtered window stays hidden.

## Test scenarios

Mirrors `AppGroupingResolverTests.swift` 1:1.

### A. isListed
- **testListedBundleIdMatches** — Finder listed → Finder matches.
- **testUnlistedBundleIdDoesNotMatch** — Finder listed → Chrome does not match.
- **testBundleIdPrefixMatches** — `com.apple.` listed → Finder and Preview match.
- **testEmptyEntryNeverMatches** — an empty listed bundle id matches nothing.
- **testNilBundleIdNeverMatches** — an app without bundle id never matches.

### B. showsOneTile
- **testListedAppShowsOneTile** — listed app, global mode off → one tile.
- **testUnlistedAppKeepsAllTiles** — unlisted app, global mode off → one tile per window.
- **testGlobalModeGroupsEveryApp** — global mode on → every app, listed or not, shows one tile.
