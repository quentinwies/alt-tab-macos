import XCTest

/// Pins per-app window grouping: which apps collapse to one tile, and which are listed for raising all
/// their windows. Groups: A isListed · B showsOneTile.
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
}
