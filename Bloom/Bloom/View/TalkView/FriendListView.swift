import SwiftUI
import SwiftData

struct FriendListView: View {
    @Environment(\.modelContext) private var context
    @Query private var friendListRowElement: [FriendListRowElement]
    
    @ObservedObject var friendListViewModel = FriendListViewModel()
    @State var talkFriendProfiles: [ProfileElement] = []
    @State var matchFriendProfiles: [ProfileElement] = []
    // MARK: - UI用サイズ指定
    let iconSize = UIScreen.main.bounds.width / 14
    let homeImageSize = UIScreen.main.bounds.width / 6
    
    var body: some View {
        NavigationStack {
            VStack {
                Section {
                    if !talkFriendProfiles.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(talkFriendProfiles, id: \.id) { profile in
                                    DataImage(dataImage: profile.homeImage)
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: homeImageSize, height: homeImageSize)
                                        .clipShape(Circle())
                                }
                            }
                            .padding()
                        }
                    } else {
                        Text("まだマッチした友達がいないよ。。")
                            .padding()
                    }
                } header: {
                    HStack {
                        Text("マッチした友達")
                            .foregroundStyle(Color.gray)
                            .padding([.leading, .top])
                        
                        Spacer()
                    }
                    .frame(height: 20)
                }
                
                Section {
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(friendListRowElement, id: \.id) { rowElement in
                            NavigationLink(
                                destination: MessageView(
                                    chatPartnerProfile: rowElement.profile.toProfileElement()
                                )
                                .toolbar(.hidden, for: .tabBar)
                            ) {
                                FriendListRowView(
                                    friendListRowElement: rowElement
                                )
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("トーク")
                            .foregroundStyle(Color.gray)
                            .padding(.leading)
                        
                        Spacer()
                    }
                    .frame(height: 20)
                }
            }
            .navigationBarTitle("話しかけてみよう！", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        friendListViewModel.deleteTalkFriendElement(context: context)
                    } label: {
                        Text("友達全消し")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize)
                        .foregroundStyle(Color.white)
                }
            }
        }
        .accentColor(Color.white)
        .onChange(of: friendListViewModel.matchedFriendList.count) {
            print("onChange確認")
            let checkingFriends = friendListViewModel.matchedFriendList
            
            // SwiftDataに存在するか確認
            for checkingFriend in checkingFriends {
                guard let checkId = checkingFriend.id else { return }
                // SwiftDataにデータが存在しない
                if friendListRowElement.filter({ $0.profile.id == checkId }).isEmpty {
                    Task {
                        // friendListRowElement取得
                        guard let friendListRowElement = await friendListViewModel.fetchFriendListRowElement(talkFriend: checkingFriend) else { return }
                        // swiftDataに追加
                        friendListViewModel.addFriendListRowElement(
                            context: context,
                            friendListRowElement: friendListRowElement
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    FriendListView()
}
