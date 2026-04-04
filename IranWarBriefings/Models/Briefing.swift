import Foundation

struct Briefing: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let summary: String
    let sourceLabel: String
    let publishedAt: Date
    let url: URL?
}
