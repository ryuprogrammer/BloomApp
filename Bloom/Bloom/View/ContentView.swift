import SwiftUI

struct ContentView: View {
    @ObservedObject var authenticationManager = AuthenticationManager()
    @State private var isShowSheet = false

    var body: some View {
            VStack {
                if authenticationManager.accountStatus == .none {
                    SignInView(isShowSheet: $isShowSheet)
                } else if authenticationManager.accountStatus == .existsNoProfile || authenticationManager.accountStatus == .mismatchID {
                    // Profileは存在してないのでProfile作成
                    RegistrationView()
                } else if authenticationManager.accountStatus == .valid {
                    // 正常にアカウントがある
                    HomeView()
                } else if authenticationManager.accountStatus == .stopAccount {
                    // アカウント停止
                    AccountStopView()
                }
            }
            .sheet(isPresented: $isShowSheet) {
                FirebaseAuthUIView()
            }
        }
}

#Preview {
    ContentView()
}
