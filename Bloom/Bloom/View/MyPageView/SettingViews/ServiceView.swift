import SwiftUI

struct ServiceView: View {
    let loadFileDataModel = LoadFileDataModel()
    @State var explanation = ""
    var body: some View {
        ScrollView {
            Text(explanation)
                .padding()
        }
        .navigationBarTitle("利用規約", displayMode: .inline)
        .onAppear {
            Task {
                explanation = await loadFileDataModel.readFile(fileCase: .service)
            }
        }
    }
}

#Preview {
    ServiceView()
}
