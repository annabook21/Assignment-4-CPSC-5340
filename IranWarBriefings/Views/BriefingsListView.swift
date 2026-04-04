import SwiftUI

struct BriefingsListView: View {
    @StateObject private var viewModel: BriefingsListViewModel

    init(viewModel: @autoclosure @escaping () -> BriefingsListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.briefings.isEmpty {
                    ProgressView("Loading…")
                } else if let message = viewModel.errorMessage {
                    ContentUnavailableView(
                        "Can’t load feed",
                        systemImage: "wifi.exclamationmark",
                        description: Text(message)
                    )
                } else if viewModel.briefings.isEmpty {
                    ContentUnavailableView(
                        "Nothing here",
                        systemImage: "newspaper",
                        description: Text("Pull down to retry.")
                    )
                } else {
                    List(viewModel.briefings) { item in
                        NavigationLink(value: item) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.sourceLabel)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(item.publishedAt, style: .relative)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .navigationDestination(for: Briefing.self) { briefing in
                        BriefingDetailView(briefing: briefing)
                    }
                }
            }
            .navigationTitle("Middle East briefings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await viewModel.load() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    BriefingsListView(
        viewModel: BriefingsListViewModel(service: BBCMiddleEastRSSService())
    )
}
