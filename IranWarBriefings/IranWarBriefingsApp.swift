import SwiftUI

@main
struct IranWarBriefingsApp: App {
    var body: some Scene {
        WindowGroup {
            BriefingsListView(
                viewModel: BriefingsListViewModel(
                    service: BBCMiddleEastRSSService()
                )
            )
        }
    }
}
