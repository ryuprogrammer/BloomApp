import SwiftUI
import SwiftData

struct SwipeCardsStack: View {
    @Binding var showingCard: [CardModel]
    @ObservedObject var swipeViewModel = SwipeViewModel()
    
    // MARK: - SwiftData用
    @Environment(\.modelContext) private var context
    @Query private var swipeFriendElement: [SwipeFriendElement]
    
    var body: some View {
        ZStack {
            Text("今日のスワイプ回数が上限に達しました。")
            ForEach(Array($showingCard.enumerated()), id: \.element.id) { index, $card in
                SwipeCardView(
                    card: card,
                    myProfile: swipeViewModel.myProfile
                )
                
                    .offset(x: card.id == showingCard.first?.id ? card.offset.width : 0,
                            y: card.id == showingCard.first?.id ? card.offset.height : -CGFloat(index) * 30)
                    .scaleEffect(card.id == showingCard.first?.id ? 1 : 1 - CGFloat(index) * 0.05)
                    .rotationEffect(.degrees(Double(card.offset.width) / 20), anchor: .bottom)
                    .zIndex(-Double(card.id)) // スタックの順番を制御
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                guard let firstCard = showingCard.first,
                                      card.id == firstCard.id else { return }
                                let translation = gesture.translation
                                card.offset = translation
                                withAnimation {
                                    if abs(translation.width) > 80 {
                                        if gesture.startLocation.x < gesture.location.x {
                                            card.isLike = true
                                        } else if gesture.startLocation.x > gesture.location.x {
                                            card.isLike = false
                                        }
                                    }
                                }
                            }
                            .onEnded { gesture in
                                guard let firstCard = showingCard.first, card.id == firstCard.id else { return }
                                let translation = gesture.translation
                                withAnimation {
                                    if abs(translation.width) > 150 {
                                        if gesture.startLocation.x < gesture.location.x {
                                            swipeViewModel.addFriendsToList(state: .likeByMe, friendProfile: card.profile)
                                        } else if gesture.startLocation.x > gesture.location.x {
                                            swipeViewModel.addFriendsToList(state: .unLikeByMe, friendProfile: card.profile)
                                        }

                                        // SwiftDataからデータ削除
                                        swipeViewModel.deleteSwipeFriendElement(
                                            context: context,
                                            swipeFriendElement: SwipeFriendElement(profile: firstCard.profile.toMyProfileElement())
                                        )
                                        // 20以下になったら追加する
                                        if showingCard.count <= 10 {
                                            print("少なくなってきたから追加")
                                            swipeViewModel.fetchSignInUser()
                                        }
                                        showingCard.removeAll { $0.id == firstCard.id }
                                    } else {
                                        card.isLike = nil
                                        card.offset = .zero
                                    }
                                }
                            }
                    )
            }
        }
    }
}
