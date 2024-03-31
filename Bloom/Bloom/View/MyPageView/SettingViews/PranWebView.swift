import SwiftUI

struct PranWebView: View {
    // 課金ボタンは常にtrue
    @State var isValid: Bool = true
    var body: some View {
        ZStack {
            Color.webPink

            VStack {
                if let urlString = URL(string: "https://bloom-price.my.canva.site/bloom") {
                    WebView(url: urlString)
                }
            }
            .ignoresSafeArea(.all)

            VStack {
                Spacer()
                ButtonView(title: "VIPプランに変更", imageName: "heart.fill", isValid: $isValid) {
                    // 課金
                }
            }
        }
        .navigationBarTitle("料金プラン", displayMode: .inline)
    }
}

#Preview {
    PranWebView()
}
