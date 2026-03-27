import SwiftUI

struct ContentView: View {
    @AppStorage("hasAcceptedDisclaimer") private var hasAcceptedDisclaimer: Bool = false

    var body: some View {
        MainTabView()
            .sheet(isPresented: .constant(!hasAcceptedDisclaimer)) {
                FirstLaunchDisclaimerView()
                    .interactiveDismissDisabled(true)
            }
    }
}
