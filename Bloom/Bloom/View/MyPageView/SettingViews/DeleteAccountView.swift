import SwiftUI

struct DeleteAccountView: View {
    let loadFileDataModel = LoadFileDataModel()
    let myPageViewModel = MyPageViewModel()
    @State var explanation = ""
    var body: some View {
        ScrollView {
            VStack {
                Text(explanation)
                    .padding()

                Button {
                    // ユーザーデータ削除
                    myPageViewModel.deleteUser()
                } label: {
                    Text("退会する")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.pink.opacity(0.8))
                        .clipShape(Capsule())
                        .padding()
                }
            }
        }
        .navigationBarTitle("退会", displayMode: .inline)
        .onAppear {
            Task {
                explanation = await loadFileDataModel.readFile(fileCase: .delete)
            }
        }
    }
}

#Preview {
    DeleteAccountView()
}
