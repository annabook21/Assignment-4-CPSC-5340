import Foundation
import UIKit

struct ParsedRSSItem {
    var title: String = ""
    var itemDescription: String = ""
    var link: String = ""
    var guid: String = ""
    var pubDateString: String = ""
}

enum RSSFeedParser {
    private static let rfc822Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
        return formatter
    }()

    static func parseItems(from data: Data) throws -> [ParsedRSSItem] {
        let parser = XMLParser(data: data)
        let delegate = RSSParserDelegate()
        parser.delegate = delegate
        parser.shouldProcessNamespaces = false
        var ok = false
        withExtendedLifetime(delegate) {
            ok = parser.parse()
        }
        guard ok else {
            throw parser.parserError ?? URLError(.cannotParseResponse)
        }
        return delegate.items
    }

    static func parsePubDate(_ string: String) -> Date? {
        rfc822Formatter.date(from: string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

private final class RSSParserDelegate: NSObject, XMLParserDelegate {
    private(set) var items: [ParsedRSSItem] = []

    private var inItem = false
    private var currentField: String?
    private var buffer = ""
    private var working = ParsedRSSItem()

    private let trackedFields: Set<String> = ["title", "description", "link", "guid", "pubDate"]

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "item" {
            inItem = true
            working = ParsedRSSItem()
            return
        }
        guard inItem, trackedFields.contains(elementName) else { return }
        currentField = elementName
        buffer = ""
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard currentField != nil else { return }
        buffer.append(string)
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if !working.title.isEmpty, !working.link.isEmpty {
                items.append(working)
            }
            inItem = false
            return
        }
        guard inItem, elementName == currentField else { return }
        defer { currentField = nil }

        let value = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        if elementName == "title" { working.title = value }
        else if elementName == "description" { working.itemDescription = value }
        else if elementName == "link" { working.link = value }
        else if elementName == "guid" { working.guid = value }
        else if elementName == "pubDate" { working.pubDateString = value }
    }
}

extension Briefing {
    init(rssItem item: ParsedRSSItem, sourceLabel: String) {
        let summaryText = Self.plainSummary(from: item.itemDescription)
        let resolvedSummary = summaryText.isEmpty
            ? "No blurb in this feed item — open the full piece on the site."
            : summaryText

        id = item.guid.isEmpty ? item.link : item.guid
        title = item.title
        summary = resolvedSummary
        self.sourceLabel = sourceLabel
        publishedAt = RSSFeedParser.parsePubDate(item.pubDateString) ?? .now
        url = URL(string: item.link)
    }

    private static func plainSummary(from raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return "" }

        if text.contains("<") {
            if let data = text.data(using: .utf8),
               let attributed = try? NSAttributedString(
                   data: data,
                   options: [
                       .documentType: NSAttributedString.DocumentType.html,
                       .characterEncoding: String.Encoding.utf8.rawValue,
                   ],
                   documentAttributes: nil
               ) {
                text = attributed.string.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                text = text.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            }
        }

        return text
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
