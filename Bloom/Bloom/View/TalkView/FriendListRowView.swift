import SwiftUI
import SwiftData

struct FriendListRowView: View {
    @Environment(\.modelContext) private var context
    @Query private var talkFriendElement: [FriendListRowElement]
    
    let friendListRowElement: FriendListRowElement
    @ObservedObject var friendListViewModel = FriendListViewModel()
    @ObservedObject var messageVM = MessageViewModel()
    @State var newMessageCount: Int = 0
    @State var lastMessage: String = "メッセージをはじめよう！"
    let mostLongStringNumber: Int = 16
    
    // 画面横幅取得→写真の横幅と縦幅に利用
    let imageSize = UIScreen.main.bounds.width / 6
    let viewHeight = UIScreen.main.bounds.height / 10

    var body: some View {
        HStack {
            DataImage(dataImage: friendListRowElement.profile.homeImage)
                .aspectRatio(contentMode: .fill)
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
                .padding(.horizontal, 8)
            
            VStack(alignment: .leading) {
                Spacer()
                
                HStack(alignment: .bottom) {
                    Text(friendListRowElement.profile.userName)
                        .foregroundStyle(Color.black)
                        .font(.title)
                        .fontWeight(.semibold)
                    
                    Text(friendListRowElement.profile.birth.toAge() + "・" + friendListRowElement.profile.address)
                        .foregroundStyle(Color.black)
                        .font(.title3)
                }
                
                Spacer()
                
                Text(friendListRowElement.lastMessage ?? lastMessage)
                    .font(.callout)
                    .foregroundStyle(Color.gray)
                    .lineLimit(1)
                
                Spacer()
            }
            
            Spacer()
            
            // 新規メッセージの数
            if newMessageCount != 0 {
                Text(String(newMessageCount))
                    .font(.title3)
                    .frame(width: 30, height: 30)
                    .foregroundStyle(Color.white)
                    .background(Color.pink.opacity(0.8))
                    .clipShape(Circle())
                    .padding(.horizontal)
            }
        }
        .frame(height: viewHeight)
        .onChange(of: messageVM.messages) {
            // プロフィールをキャスト
            let profile = friendListRowElement.profile.toProfileElement()
            
            newMessageCount = friendListViewModel.newMessageCount
            if let lastMessage = messageVM.messages.last {
                // SwiftDataをprofileを指定して更新
                let upDateIndex = talkFriendElement.firstIndex { $0.profile.id == profile.id }
                guard let upDateIndex else { return }
                talkFriendElement[upDateIndex].lastMessage = lastMessage.message
                try? context.save()
            }
        }
        .onAppear {
            // プロフィールをキャスト
            let profile = friendListRowElement.profile.toProfileElement()
            
            // RoomIDを指定して、メッセージを取得: リアルタイム監視スタート
            messageVM.fetchRoomIDMessages(chatPartnerProfile: profile)
            // 新規メッセージの数を取得
            newMessageCount = friendListViewModel.newMessageCount
        }
    }
}

#Preview {
    VStack {
        FriendListRowView(
            friendListRowElement: FriendListRowElement(
                profile: mockMyProfileData,
                lastMessage: "最新メッセージ",
                newMessageCount: 5,
                createAt: Date()
            )
        )
        
        FriendListRowView(
            friendListRowElement: FriendListRowElement(
                profile: mockMyProfileData,
                lastMessage: "最新メッセージ",
                newMessageCount: 5,
                createAt: Date()
            )
        )
    }
}
