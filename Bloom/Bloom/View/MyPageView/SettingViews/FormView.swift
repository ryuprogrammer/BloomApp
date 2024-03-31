import SwiftUI

struct FormView: View {
    var body: some View {
        VStack {
            if let urlString = URL(string: "https://forms.gle/bavw6nRSzrfkCz8o7") {
                WebView(url: urlString)
            }
        }
        .ignoresSafeArea(.all)
        .navigationBarTitle("お問い合わせ", displayMode: .inline)
    }
}

#Preview {
    FormView()
}
