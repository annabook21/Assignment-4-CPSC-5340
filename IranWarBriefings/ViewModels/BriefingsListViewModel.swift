import Foundation

@MainActor
final class BriefingsListViewModel: ObservableObject {
    @Published private(set) var briefings: [Briefing] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: NewsFetching

    init(service: NewsFetching) {
        self.service = service
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            briefings = try await service.fetchBriefings()
        } catch {
            errorMessage = error.localizedDescription
            briefings = []
        }
    }
}
