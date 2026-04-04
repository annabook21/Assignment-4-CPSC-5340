import Foundation

protocol NewsFetching: Sendable {
    func fetchBriefings() async throws -> [Briefing]
}
