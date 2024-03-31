import SwiftUI

struct PrivacyView: View {
    let loadFileDataModel = LoadFileDataModel()
    @State var explanation = ""
    var body: some View {
        ScrollView {
            Text(explanation)
                .padding()
        }
        .navigationBarTitle("プライバシーポリシー", displayMode: .inline)
        .onAppear {
            Task {
                explanation = await loadFileDataModel.readFile(fileCase: .privacy)
            }
        }
    }
}

#Preview {
    PrivacyView()
}
