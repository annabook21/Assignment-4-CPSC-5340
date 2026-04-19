import SwiftUI

struct SessionRootView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.currentUser == nil {
                AuthView(viewModel: authViewModel)
            } else {
                BriefingsListView(
                    viewModel: BriefingsListViewModel(service: BBCMiddleEastRSSService()),
                    onLogout: authViewModel.signOut
                )
            }
        }
    }
}

