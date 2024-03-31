import SwiftUI

struct LikedView: View {
    @ObservedObject var swipeViewModel = SwipeViewModel()
    @State var profiles: [LikedCardModel] = []
    
    let iconSize = UIScreen.main.bounds.width / 14
    private var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 2)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach($profiles) { $card in
                        LikedCardView(card: card)
                            .offset(x: card.offset.width, y: card.offset.height)
                            .rotationEffect(.degrees(Double(card.offset.width) / 20), anchor: .bottom)
                            .zIndex(card.isDragging ? 1 : 0)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        card.offset = gesture.translation
                                        card.isDragging = true
                                        withAnimation {
                                            if abs(gesture.translation.width) > 120 {
                                                if gesture.startLocation.x < gesture.location.x {
                                                    card.isLike = true
                                                } else if gesture.startLocation.x > gesture.location.x {
                                                    card.isLike = false
                                                }
                                            }
                                        }
                                    }
                                    .onEnded { gesture in
                                        withAnimation {
                                            if abs(gesture.translation.width) > 150 {
                                                if gesture.startLocation.x < gesture.location.x {
                                                    swipeViewModel.addFriendsToList(state: .likeByMe, friendProfile: card.profile)
                                                } else if gesture.startLocation.x > gesture.location.x {
                                                    swipeViewModel.addFriendsToList(state: .unLikeByMe, friendProfile: card.profile)
                                                }
                                                profiles.removeAll { $0.id == card.id }
                                            } else {
                                                card.offset = .zero
                                            }
                                            card.isLike = nil
                                            card.isDragging = false
                                        }
                                    }
                            )
                    }
                }
            }
            .navigationBarTitle("いいねしてくれた友達", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image(systemName: "questionmark.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize)
                        .foregroundStyle(Color.white)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: iconSize)
                        .foregroundStyle(Color.white)
                }
            }
        }
        .onChange(of: swipeViewModel.friendProfiles.count) {
            profiles.removeAll()
            
            var cardId = 1
            for profile in swipeViewModel.friendProfiles {
                profiles.append(LikedCardModel(id: cardId, profile: profile))
                cardId += 1
            }
        }
    }
}

struct LikedCardModel: Identifiable {
    var id: Int
    var profile: ProfileElement
    var offset: CGSize = .zero
    var isLike: Bool? = nil
    var isDragging: Bool = false
}

#Preview {
    LikedView()
}
