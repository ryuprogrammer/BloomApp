import Foundation
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AuthenticationManager: ObservableObject {
    private var handle: AuthStateDidChangeListenerHandle?
    let userDataModel = UserDataModel()
    let userDefaultsDataModel = UserDefaultsDataModel()
    @Published var accountStatus: AccountStatus = .none
    private var db = Firestore.firestore()
    // アカウントが停止する通報数
    let accountStopReportLimit = 20

    init() {
        checkAccountStatus()
        Task {
            await checkReportMyAccount()
        }
    }
    
    deinit {
        // ここで認証状態の変化の監視を解除する
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            accountStatus = .none
        } catch {
            print("Error")
        }
    }
    
    func deleteUser() {
        let user = Auth.auth().currentUser
        
        if let user {
            user.delete { error in
                if let error = error {
                    print("error: \(error.localizedDescription)")
                } else {
                    print("Account deleted")
                    self.accountStatus = .none
                }
            }
        }
    }
    
    func checkAccountStatus() {
        if let _ = userDefaultsDataModel.fetchMyProfile() {
            print("userDefaultsにデータある！！！！！！！")
            // プロフィールある
            self.accountStatus = .valid
        } else { // userDefaultsにはプロフィールない
            print("userDefaultsにはプロフィールない")
            // 既存のリスナーがあれば削除
            if let handle = handle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
            
            // ここで認証状態の変化を監視する（リスナー）
            handle = Auth.auth().addStateDidChangeListener { (auth, user) in
                print("auth: \(auth)")
                
                if let user = user {
                    print("Sign-in")
                    print("user: \(user.uid)")
                    self.accountStatus = .existsNoProfile
                    
                    // profileが存在するか判定
                    self.userDataModel.fetchProfileWithoutImages(uid: user.uid, completion: { profile, error in
                        if let _ = profile, error == nil {
                            print("アカウントは存在！！！！！！！")
                            // アカウントが正常に存在する
                            self.accountStatus = .valid
                            // userDefaultsにもアカウントを追加
                            self.addProfileToDevice()
                        } else if let error = error {
                            self.accountStatus = .existsNoProfile
                            print("Error fetching profiles: \(error.localizedDescription)")
                        }
                    })
                } else {
                    print("Sign-out")
                    print("サインイン画面を表示")
                    self.accountStatus = .none
                }
            }
        }
    }

    /// 自分が通報されているかチェック（Limitに達していたらアカウント停止にする）
    func checkReportMyAccount() async {
        // UIDを取得
        guard let uid = userDataModel.fetchUid() else { return }

        do {
            let reportedCountSnapshot = try await db.collection("friends").document(uid).collection("friendList").whereField("status", isEqualTo: FriendStatus.reportByFriend.rawValue).getDocuments()
            let reportedCount = reportedCountSnapshot.documents.count

            if reportedCount >= accountStopReportLimit {
                // アカウントを停止する処理を実行
                self.accountStatus = .stopAccount
            }
        } catch {
            print("エラーが発生しました: \(error)")
        }
    }

    // firebaseのプロフィールをuserDefaultsに追加
    func addProfileToDevice() {
        guard let uid = userDataModel.fetchUid() else { return }

        /// uidを指定して、プロフィールを1つ取得 （画像データまで取得）
        userDataModel.fetchProfile(uid: uid) { profile, error in
            if let profile = profile, error == nil {
                // userDefaultsにprofile追加
                self.userDefaultsDataModel.addMyProfile(myProfile: profile)
            } else if let error = error {
                print("error: addProfileToDevice()")
                print(error.localizedDescription)
            }
        }
    }
}
