import Foundation
import FirebaseFirestore
import SwiftData

class FriendListViewModel: ObservableObject {
    let swiftDataModel = SwiftDataModel()
    
    private var chatDataModel = ChatDataModel()
    private var userDataModel = UserDataModel()
    private var lister: ListenerRegistration?
    @Published var newMessageCount: Int = 0
    @Published private(set) var matchedFriendList: [ProfileElement] = []
    /// コレクションの名称
    private let collectionName = "chatRoom"
    let mostLongStringNumber: Int = 16
    
    init() {
        lister = userDataModel.listenFriends(friendStatus: .likeByMe) { [weak self] (friendStatus, error) in
            if let friendStatus {
                for friendData in friendStatus {
                    guard let friends = self?.matchedFriendList else { return }
                    for friend in friends {
                        if friend.id != friendData.friendUid {
                            // ここで友達のデータを取得
                            self?.userDataModel.fetchProfile(uid: friendData.friendUid) { profile, error in
                                guard let profile = profile else { return }
                                self?.matchedFriendList.append(profile)
                                print("プロフィール取得: userName: \(profile.userName)")
                            }
                        }
                    }
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// FriendListRowElementを取得(一人分)
    func fetchFriendListRowElement(talkFriend: ProfileElement) async -> FriendListRowElement? {
        
        let allMessages = await chatDataModel.fetchAllMessages(chatPartnerProfile: talkFriend)
        let lastMessage = chatDataModel.fetchLastMessages(allMessages: allMessages)
        let newMessageCount = chatDataModel.countNewMessage(allMessages: allMessages, friend: talkFriend)
        
        guard let id = talkFriend.id else { return nil }
        
        let profileElement = MyProfileElement(
            id: id,
            userName: talkFriend.userName,
            introduction: talkFriend.introduction,
            birth: talkFriend.birth,
            gender: talkFriend.gender,
            address: talkFriend.address,
            grade: talkFriend.grade,
            hobby: talkFriend.hobby,
            location: talkFriend.location,
            profession: talkFriend.profession,
            profileImages: talkFriend.profileImages,
            homeImage: talkFriend.homeImage,
            point: talkFriend.point
        )
        
        let friendListRowElement = FriendListRowElement(
            profile: profileElement,
            lastMessage: lastMessage?.message,
            newMessageCount: newMessageCount,
            createAt: lastMessage?.createAt
        )
        
        return friendListRowElement
    }
    
    /// トークしてる友達の分、FriendListRowElementを取得
    func fetchFriendListRowElement(talkFriends: [ProfileElement]) async -> [FriendListRowElement] {
        var friendListRowElements: [FriendListRowElement] = []
        
        for friend in talkFriends {
            let allMessages = await chatDataModel.fetchAllMessages(chatPartnerProfile: friend)
            let lastMessage = chatDataModel.fetchLastMessages(allMessages: allMessages)
            let newMessageCount = chatDataModel.countNewMessage(allMessages: allMessages, friend: friend)
            
            guard let id = friend.id else { return friendListRowElements }
            
            let profileElement = MyProfileElement(
                id: id,
                userName: friend.userName,
                introduction: friend.introduction,
                birth: friend.birth,
                gender: friend.gender,
                address: friend.address,
                grade: friend.grade,
                hobby: friend.hobby,
                location: friend.location,
                profession: friend.profession,
                profileImages: friend.profileImages,
                homeImage: friend.homeImage,
                point: friend.point
            )
            
            let friendListRowElement = FriendListRowElement(
                profile: profileElement,
                lastMessage: lastMessage?.message,
                newMessageCount: newMessageCount,
                createAt: lastMessage?.createAt
            )
            
            friendListRowElements.append(friendListRowElement)
        }
        
        return friendListRowElements
    }
    
    /// マッチした友達を取得
    func fetchMatchedFriendList() {
        matchedFriendList.removeAll()
        
        // マッチした友達のUidを取得
        userDataModel.fetchProfileWithFriendStatus(friendStatus: .likeByMe) { matchedFriendUids, error in
            guard let uids = matchedFriendUids, error == nil else {
                print("Error fetching matchedFriendUids: \(error?.localizedDescription ?? "")")
                return
            }
            
            // マッチした友達の数だけプロフィール取得
            for uid in uids {
                print("マッチした友達のUid: \(uid)")
                self.userDataModel.fetchProfile(uid: uid) { profile, error in
                    guard let profile = profile else { return }
                    self.matchedFriendList.append(profile)
                    print("マッチした友達の名前: \(profile.userName)")
                }
            }
        }
        
        print("matchedFriendList.count: \(matchedFriendList.count)")
    }
    
    /// 全ての未読メッセージ数の取得
    func fetchNewMessageCountAll(chatPartnerProfile: ProfileElement) async {
        let db = Firestore.firestore()
        
        guard let roomID = fetchRoomID(chatPartnerProfile: chatPartnerProfile) else { return }

        do {
            // `messages`サブコレクションからメッセージを取得
            let querySnapshot = try await db.collection(collectionName).document(roomID).collection("messages").getDocuments()

            // UIの更新はメインスレッドで行う
            DispatchQueue.main.async {
                self.newMessageCount = 0
                
                let messages = querySnapshot.documents.compactMap { document in
                    try? document.data(as: MessageElement.self)
                }
                
                self.newMessageCount = messages.filter { message in
                    message.isNewMessage == true && message.name == chatPartnerProfile.userName
                }.count
            }
        } catch {
            print("fetchMessages error: \(error.localizedDescription)")
        }
    }
    
    /// roomID取得メソッド
    func fetchRoomID(chatPartnerProfile: ProfileElement) -> String? {
        return chatDataModel.fetchRoomID(chatPartnerProfile: chatPartnerProfile)
    }
    
    /// TalkFriendElementの追加（１つ）
    func addFriendListRowElement(
        context: ModelContext,
        friendListRowElement: FriendListRowElement
    ) {
        swiftDataModel.addFriendListRowElement(
            context: context,
            friendListRowElement: friendListRowElement
        )
    }
    
    /// TalkFriendElementの全削除
    func deleteTalkFriendElement(
        context: ModelContext
    ) {
        swiftDataModel.deleteTalkFriendElement(context: context)
    }
}
