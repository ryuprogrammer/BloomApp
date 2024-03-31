import Foundation
import FirebaseFirestore
import FirebaseAuth

class MessageViewModel: ObservableObject {
    let userDataModel = UserDataModel()
    let chatDataModel = ChatDataModel()
    let loadFileDataModel = LoadFileDataModel()
    @Published var messages: [MessageElement] = []
    
    private var lister: ListenerRegistration?
    let db = Firestore.firestore()
    /// コレクションの名称
    private let collectionName = "chatRoom"
    
    /// roomID取得メソッド
    func fetchRoomID(chatPartnerProfile: ProfileElement) -> String? {
        return chatDataModel.fetchRoomID(chatPartnerProfile: chatPartnerProfile)
    }
    
    /// 全てのメッセージを既読に更新
    func changeMessage(chatPartnerProfile: ProfileElement) async {
        guard let partnerUid = chatPartnerProfile.id else { return }
        
        guard let roomID = fetchRoomID(chatPartnerProfile: chatPartnerProfile) else { return }
        
        // 対象のメッセージをクエリで取得
            let querySnapshot = try? await db.collection(collectionName).document(roomID)
                                                .collection("messages")
                                                .whereField("uid", isEqualTo: partnerUid)
                                                .whereField("isNewMessage", isEqualTo: true)
                                                .getDocuments()
        
        // 各メッセージを既読に更新
            guard let documents = querySnapshot?.documents else { return }
            for document in documents {
                let docRef = db.collection(collectionName).document(roomID).collection("messages").document(document.documentID)
                do {
                    try await docRef.updateData(["isNewMessage": false])
                } catch {
                    print("Error updating document: \(error)")
                }
            }
    }
    
    /// 最初に全てのmessagesを取得
    func fetchMessages(chatPartnerProfile: ProfileElement) async {
        DispatchQueue.main.async {
            self.messages.removeAll()
        }
        guard let roomID = fetchRoomID(chatPartnerProfile: chatPartnerProfile) else { return }
        
        do {
            // `messages`サブコレクションからメッセージを取得
            let querySnapshot = try await db.collection(collectionName).document(roomID).collection("messages").order(by: "createAt", descending: false).getDocuments()
            
            DispatchQueue.main.async {
                self.messages = querySnapshot.documents.compactMap { document in
                    try? document.data(as: MessageElement.self)
                }
            }
        } catch {
            print("fetchMessages error: \(error.localizedDescription)")
        }
    }
    
    /// roomIDを指定してmessagesをリアルタイムで更新
    func fetchRoomIDMessages(chatPartnerProfile: ProfileElement) {
        guard let roomID = fetchRoomID(chatPartnerProfile: chatPartnerProfile) else { return }
        // 以前のリスナーを削除
        lister?.remove()
        
        // 新しいクエリとリスナーの設定
        lister = db.collection(collectionName).document(roomID).collection("messages")
            .order(by: "createAt", descending: false) // 日付順に並び替え
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    print("Error fetching documents: Query snapshot is nil")
                    return
                }
                
                // 取得したドキュメントの変更を処理
                querySnapshot.documentChanges.forEach { change in
                    if change.type == .added || change.type == .modified {
                        do {
                            let message = try change.document.data(as: MessageElement.self)
                            if change.type == .added {
                                self.messages.append(message)
                            } else if let index = self.messages.firstIndex(where: { $0.id == message.id }) {
                                self.messages[index] = message
                            }
                        } catch {
                            print("Error decoding message: \(error.localizedDescription)")
                        }
                    }
                }
            }
    }

    /// ブロックや通報（友達のステータスを変更）
    func changeFriendStatus(
        state: FriendStatus,
        friendProfile: ProfileElement
    ) {
        userDataModel.addFriendsToList(state: state, friendProfile: friendProfile) { error in
            if let error = error {
                print("error addFriendsToList: \(error.localizedDescription)")
            }
        }
    }

    deinit {
        lister?.remove()
    }
    
    func addMessage(chatPartnerProfile: ProfileElement, message: String) {
        chatDataModel.addMessage(
            chatPartnerProfile: chatPartnerProfile,
            message: message
        )
    }

    // MARK: - ファイル読み込み系
    /// 文章にNGワードが含まれているかチェック
    func isCoutainNGWord(message: String) -> Bool {
        guard let ngWords = loadFileDataModel.loadCsvFile(fileName: "NGWordList") else { return false }

        for ngWord in ngWords {
            if message.localizedCaseInsensitiveContains(ngWord) {
                print("含まれている")
                return true
            } else {
                print("\(ngWord)は含まれていない")
            }
        }
        return false
    }
}
