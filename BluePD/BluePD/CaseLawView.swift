import SwiftUI

struct CaseLawView: View {
    private let caseLawURL = URL(string: "https://caselaw.findlaw.com/")!

    var body: some View {
        NavigationStack {
            SafariWebView(url: caseLawURL)
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Case Law")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CaseLawView()
}
