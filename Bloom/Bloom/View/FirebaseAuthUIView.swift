import SwiftUI
import FirebaseAuthUI
import FirebaseOAuthUI
import FirebaseGoogleAuthUI
//import FirebaseFacebookAuthUI
//import FirebasePhoneAuthUI

struct FirebaseAuthUIView: UIViewControllerRepresentable {
    // アプリの利用規約とプライバシーポリシーURLを設定
    let termsOfServiceURL = URL(string: "https://yourapp.com/terms")
    let privacyPolicyURL = URL(string: "https://yourapp.com/privacy")

    func makeUIViewController(context: Context) -> UINavigationController {
        guard let authUI = FUIAuth.defaultAuthUI() else {
            fatalError("Firebase Auth UIを初期化できませんでした。")
        }
        
        // サポートするログインプロバイダーを設定
        authUI.providers = [
            FUIGoogleAuth(authUI: authUI),
            FUIOAuth.appleAuthProvider()
        ]
        
        // アプリアイコンの設定
        let authViewController = authUI.authViewController()
        
        // 利用規約とプライバシーポリシーのリンクを設定
        authUI.tosurl = termsOfServiceURL
        authUI.privacyPolicyURL = privacyPolicyURL
        
        return authViewController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // この関数内での特別な更新は必要ありません。
    }
}
