import XCTest

/// Pins per-app window grouping: which apps collapse to one tile, and which are listed for raising all
/// their windows. Groups: A isListed · B showsOneTile · C raiseOrder.
final class AppGroupingResolverTests: XCTestCase {
    private let finder = "com.apple.finder"
    private let preview = "com.apple.Preview"
    private let chrome = "com.google.Chrome"

    // MARK: - A. isListed

    func testListedBundleIdMatches() {
        XCTAssertTrue(AppGroupingResolver.isListed(finder, groupedBundleIds: [finder]))
    }

    func testUnlistedBundleIdDoesNotMatch() {
        XCTAssertFalse(AppGroupingResolver.isListed(chrome, groupedBundleIds: [finder]))
    }

    func testBundleIdPrefixMatches() {
        XCTAssertTrue(AppGroupingResolver.isListed(finder, groupedBundleIds: ["com.apple."]))
        XCTAssertTrue(AppGroupingResolver.isListed(preview, groupedBundleIds: ["com.apple."]))
    }

    func testEmptyEntryNeverMatches() {
        XCTAssertFalse(AppGroupingResolver.isListed(finder, groupedBundleIds: [""]))
    }

    func testNilBundleIdNeverMatches() {
        XCTAssertFalse(AppGroupingResolver.isListed(nil, groupedBundleIds: [finder]))
    }

    // MARK: - B. showsOneTile

    func testListedAppShowsOneTile() {
        XCTAssertTrue(AppGroupingResolver.showsOneTile(finder, oneWindowPerApp: false, groupedBundleIds: [finder, preview]))
    }

    func testUnlistedAppKeepsAllTiles() {
        XCTAssertFalse(AppGroupingResolver.showsOneTile(chrome, oneWindowPerApp: false, groupedBundleIds: [finder, preview]))
    }

    func testGlobalModeGroupsEveryApp() {
        XCTAssertTrue(AppGroupingResolver.showsOneTile(chrome, oneWindowPerApp: true, groupedBundleIds: [finder]))
        XCTAssertTrue(AppGroupingResolver.showsOneTile(nil, oneWindowPerApp: true, groupedBundleIds: []))
    }

    // MARK: - C. raiseOrder

    private func sibling(_ id: String, focus: Int, minimized: Bool = false, tab: Bool = false,
                         visible: Bool = true) -> GroupSibling {
        GroupSibling(id: id, lastFocusOrder: focus, isMinimized: minimized, isInactiveTab: tab, isOnVisibleSpace: visible)
    }

    func testSiblingsRaiseLeastRecentFirst() {
        XCTAssertEqual(AppGroupingResolver.raiseOrder([sibling("recent", focus: 1), sibling("old", focus: 5),
            sibling("middle", focus: 3)]), ["old", "middle", "recent"])
    }

    func testMinimizedSiblingStaysInDock() {
        XCTAssertEqual(AppGroupingResolver.raiseOrder([sibling("a", focus: 1), sibling("min", focus: 2, minimized: true)]), ["a"])
    }

    func testInactiveTabIsNotRaised() {
        XCTAssertEqual(AppGroupingResolver.raiseOrder([sibling("a", focus: 1), sibling("tab", focus: 2, tab: true)]), ["a"])
    }

    func testSiblingOnOtherSpaceIsNotRaised() {
        XCTAssertEqual(AppGroupingResolver.raiseOrder([sibling("a", focus: 1), sibling("far", focus: 2, visible: false)]), ["a"])
    }
}
