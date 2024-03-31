import Foundation
import FirebaseAuth
import FirebaseFirestore

class ChatDataModel: ObservableObject {
    var userDataModel = UserDataModel()
    private var db = Firestore.firestore()
    let countCollectionName = "newMessageCount"
    /// コレクションの名称
    private let collectionName = "chatRoom"
    
    /// チャットを追加
    func addMessage(chatPartnerProfile: ProfileElement, message: String) {
        // 自分のUid取得
        var uid: String = ""
        
        let user = Auth.auth().currentUser
        
        if let user {
            uid = user.uid
        }
        
        guard let roomID = fetchRoomID(chatPartnerProfile: chatPartnerProfile) else { return }
        
        userDataModel.fetchProfileWithoutImages(uid: uid, completion: { [weak self] profile, error in
                guard let self = self else { return }
                
                if let profile = profile, error == nil {
                    let userName = profile.userName
                    let message = MessageElement(
                        uid: uid,
                        roomID: roomID,
                        isNewMessage: true,
                        name: userName,
                        message: message,
                        createAt: Date()
                    )
                    
                    do {
                        let docmentRef = self.db.collection("chatRoom").document(roomID).collection("messages").document()
                        try docmentRef.setData(from: message)
                    } catch {
                        print(error.localizedDescription)
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
    }
    
    /// 全てのメッセージ取得
    func fetchAllMessages(chatPartnerProfile: ProfileElement) async -> [MessageElement] {
        var allMessages: [MessageElement] = []
        guard let roomID = fetchRoomID(chatPartnerProfile: chatPartnerProfile) else { return allMessages }
        
        do {
            // `messages`サブコレクションからメッセージを取得
            let querySnapshot = try await db.collection(collectionName).document(roomID).collection("messages").order(by: "createAt", descending: false).getDocuments()
            
            let messages = querySnapshot.documents.compactMap { document in
                try? document.data(as: MessageElement.self)
            }
            
            allMessages = messages
        } catch {
            print("fetchMessages error: \(error.localizedDescription)")
        }
        
        return allMessages
    }
    
    /// lastMessage取得
    func fetchLastMessages(allMessages: [MessageElement]) -> MessageElement? {
        if let lastMessage = allMessages.last {
            return lastMessage
        }
        return nil
    }
    
    /// 新規メッセージの数を取得
    func countNewMessage(allMessages: [MessageElement], friend: ProfileElement) -> Int {
        let newMessageCount = allMessages.filter { message in
            message.isNewMessage == true && message.uid == friend.id
        }.count
        
        return newMessageCount
    }
    
    /// roomID取得メソッド
    func fetchRoomID(chatPartnerProfile: ProfileElement) -> String? {
        // 自分のUid取得
        var uid: String = ""
        let user = Auth.auth().currentUser
        if let user {
            uid = user.uid
        }
        
        // 相手のUid取得
        guard let chatPartnerUid = chatPartnerProfile.id else { return nil }
        
        // roomID作成
        let roomID = [uid, chatPartnerUid].sorted().joined(separator: "-")
        
        return roomID
    }
}
