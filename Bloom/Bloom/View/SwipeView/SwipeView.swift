import SwiftUI
import SwiftData

struct SwipeView: View {
    // MARK: - SwiftData用
    @Environment(\.modelContext) private var context
    @Query private var swipeFriendElement: [SwipeFriendElement]
    
    @ObservedObject var swipeViewModel = SwipeViewModel()
    @State var showingCard: [CardModel] = []
    @State var offset: CGFloat? = .zero
    
    let iconSize = UIScreen.main.bounds.width / 14
    @State var cardId: Int = 0

    var body: some View {
        NavigationStack {
            VStack {
                // TODO: - このVStackいらない
                VStack {
                    // 広告
                    NavigationLink {
                        PranWebView().toolbar(.hidden, for: .tabBar)
                    } label: {
                        AdvertisementView()
                    }

                    Spacer()
                }

                SwipeCardsStack(showingCard: $showingCard)
            }
            .navigationBarTitle("スワイプしよう！", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize)
                        .foregroundStyle(Color.white)
                        .onTapGesture {
                            swipeViewModel.deleteAllSwipeFriendElement(context: context)
                        }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        FilterView()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: iconSize)
                            .foregroundStyle(Color.white)
                    }
                }
            }
        }
        .accentColor(Color.white)
        .onChange(of: swipeViewModel.friendProfiles.count) {
            if swipeViewModel.fetchedUidCount == swipeViewModel.friendProfiles.count {
                
                print("swipeViewModel.friendProfiles.count: \(swipeViewModel.friendProfiles.count)")
                cardId = swipeFriendElement.count
                
                for profile in swipeViewModel.friendProfiles {
                    print("データを保存して、Viewにも表示")
                    // SwiftDataに保存
                    swipeViewModel.addSwipeFriendElement(
                        context: context,
                        swipeFriendElement: SwipeFriendElement(profile: profile.toMyProfileElement())
                    )
                    showingCard.append(CardModel(id: cardId, profile: profile))
                    cardId += 1
                }
                print("追加後のSwiftDataの数: \(swipeFriendElement.count)個")
            }
        }
        .onAppear {
            // 自分のプロフィール取得
            swipeViewModel.fetchMyProfile()
            showingCard.removeAll()
            print("swipeViewModel.friendProfiles.count: \(swipeViewModel.friendProfiles.count)")
            print("初期データ数: \(swipeFriendElement.count)個")
            if swipeFriendElement.count >= 10 {
                cardId = swipeFriendElement.count
                for friendElement in swipeFriendElement {
                    showingCard.append(CardModel(
                        id: cardId,
                        profile: friendElement.profile.toProfileElement()
                    ))
                    cardId += 1
                }
            } else if !swipeFriendElement.isEmpty && swipeFriendElement.count < 10 {
                cardId = swipeFriendElement.count
                
                for friendElement in swipeFriendElement {
                    showingCard.append(CardModel(
                        id: cardId,
                        profile: friendElement.profile.toProfileElement()
                    ))
                    cardId += 1
                }
                
                // データ取得
                swipeViewModel.fetchSignInUser()
            } else { //データ空
                // データ取得
                swipeViewModel.fetchSignInUser()
            }
        }
    }
}

enum FilterPath {
    case filterPath
    case addressPath
    case birthPath
    case introductionPath
}

struct CardModel: Identifiable {
    var id: Int
    let profile: ProfileElement
    var isLike: Bool? = nil
    var offset: CGSize = .zero // 各カードのオフセットを追加
}

#Preview {
    SwipeView()
}
