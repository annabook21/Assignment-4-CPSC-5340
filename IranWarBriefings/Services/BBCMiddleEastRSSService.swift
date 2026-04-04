import Foundation

struct BBCMiddleEastRSSService: NewsFetching {
    private static let feedURL = URL(string: "https://feeds.bbci.co.uk/news/world/middle_east/rss.xml")!
    private static let userAgent = "IranWarBriefings/1.0"
    private static let sourceLabel = "BBC News · Middle East"

    func fetchBriefings() async throws -> [Briefing] {
        var request = URLRequest(url: Self.feedURL)
        request.setValue(Self.userAgent, forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200 ... 299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let parsed = try RSSFeedParser.parseItems(from: data)
        return parsed.map { Briefing(rssItem: $0, sourceLabel: Self.sourceLabel) }
    }
}
