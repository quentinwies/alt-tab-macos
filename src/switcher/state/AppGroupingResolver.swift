import Foundation

/// Another window of the grouped app than the one being focused.
struct GroupSibling: Equatable {
    let id: String
    let lastFocusOrder: Int
    let isMinimized: Bool
    let isInactiveTab: Bool
    let isOnVisibleSpace: Bool
}

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

    /// The siblings to raise before the focused window, least recently focused first, so the app's own
    /// window order survives and the focused window, raised last, lands on top.
    static func raiseOrder(_ siblings: [GroupSibling]) -> [String] {
        siblings.filter { !$0.isMinimized && !$0.isInactiveTab && $0.isOnVisibleSpace }
            .sorted { $0.lastFocusOrder > $1.lastFocusOrder }
            .map { $0.id }
    }
}
