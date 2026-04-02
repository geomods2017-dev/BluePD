import SwiftUI

struct CaseLawView: View {
    var body: some View {
        NavigationStack {
            CaseLawWebView(urlString: "https://caselaw.findlaw.com/")
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle("Case Law")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    CaseLawView()
}
