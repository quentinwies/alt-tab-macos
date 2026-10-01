import Foundation

/// Decides which apps the switcher collapses to a single tile, and which of those raise all their windows
/// when selected. See `AppGroupingResolverSpecs.md`.
enum AppGroupingResolver {
    /// An app is listed iff a non-empty grouped bundle-id is a prefix of its bundle id (same gate as
    /// `ExceptionMatcher`). nil bundle-id never matches.
    static func isListed(_ bundleIdentifier: String?, groupedBundleIds: [String]) -> Bool {
        guard let id = bundleIdentifier else { return false }
        return groupedBundleIds.contains { !$0.isEmpty && id.hasPrefix($0) }
    }

    static func showsOneTile(_ bundleIdentifier: String?, oneWindowPerApp: Bool, groupedBundleIds: [String]) -> Bool {
        oneWindowPerApp || isListed(bundleIdentifier, groupedBundleIds: groupedBundleIds)
    }
}
