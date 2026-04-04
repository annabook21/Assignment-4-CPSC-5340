import SwiftUI

struct BriefingDetailView: View {
    let briefing: Briefing

    var body: some View {
        List {
            Section {
                Text(briefing.title)
                    .font(.headline)
            }

            Section("Summary") {
                Text(briefing.summary)
            }

            Section {
                LabeledContent("Source", value: briefing.sourceLabel)
                LabeledContent("Date") {
                    Text(briefing.publishedAt, format: .dateTime.month().day().year())
                }
            }

            if let url = briefing.url {
                Section {
                    Link(destination: url) {
                        Label("Read on BBC", systemImage: "safari")
                    }
                }
            }
        }
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        BriefingDetailView(
            briefing: Briefing(
                id: "preview",
                title: "Sample headline",
                summary: "Short summary pulled from the RSS description field.",
                sourceLabel: "BBC News · Middle East",
                publishedAt: .now,
                url: URL(string: "https://www.bbc.com/news")
            )
        )
    }
}
