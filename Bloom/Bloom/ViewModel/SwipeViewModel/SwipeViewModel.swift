import Foundation
import SwiftData
import FirebaseFirestore

class SwipeViewModel: ObservableObject {
    let swiftDataModel = SwiftDataModel()
    private var userDataModel = UserDataModel()
    @Published private(set) var friendProfiles: [ProfileElement] = []
    @Published var fetchedUidCount: Int = 0
    let db = Firestore.firestore()
    private let collectionName = "profiles"
    private let fetchProfilesLimit: Int = 10

    let userDefaultsDataModel = UserDefaultsDataModel()
    // 自分のプロフィール: 共通の趣味、距離を算出するために使用
    @Published var myProfile: ProfileElement? = nil

    /// UserDefaultsから自分のプロフィール取得
    func fetchMyProfile() {
        if let profile = userDefaultsDataModel.fetchMyProfile() {
            myProfile = ProfileElement(
                userName: profile.userName,
                introduction: profile.introduction,
                birth: profile.birth,
                gender: profile.gender,
                address: profile.address,
                grade: profile.grade,
                hobby: profile.hobby,
                location: profile.location,
                profession: profile.profession,
                profileImages: profile.profileImages,
                homeImage: profile.homeImage,
                point: profile.point
            )
        } else {
            print("error: fetchMyProfile")
        }
    }

    /// friendsをListtに追加: ライクしたりできるお
    func addFriendsToList(
        state: FriendStatus,
        friendProfile: ProfileElement
    ) {
        userDataModel.addFriendsToList(state: state, friendProfile: friendProfile) { error in
            if let error = error {
                print("error addFriendsToList: \(error.localizedDescription)")
            }
        }
    }
    
    /// SignInUser取得メソッド
    func fetchSignInUser() {
        friendProfiles.removeAll()
        
        userDataModel.fetchProfileUids(limit: fetchProfilesLimit) { uids, error in
            guard let uids = uids, error == nil else {
                print("Error fetching document IDs: \(error?.localizedDescription ?? "")")
                return
            }
            
            self.fetchedUidCount = uids.count
            
            for uid in uids {
                print("uid: \(uid)")
                self.userDataModel.fetchProfile(uid: uid) { profile, error in
                    if let profile = profile {
                        print("追加するプロフィール名前: \(profile.userName)")
                        self.friendProfiles.append(profile)
                    } else if let error = error {
                        print("Error fetching profiles: \(error.localizedDescription)")
                    } else {
                        print("fetchProfile error")
                    }
                }
            }
        }
    }
    
    ///  SwipeFriendElementの追加（１つ）
    func addSwipeFriendElement(
        context: ModelContext,
        swipeFriendElement: SwipeFriendElement
    ) {
        swiftDataModel.addSwipeFriendElement(
            context: context,
            swipeFriendElement: swipeFriendElement
        )
    }
    
    /// SwipeFriendElementの削除（１つ）
    func deleteSwipeFriendElement(
        context: ModelContext,
        swipeFriendElement: SwipeFriendElement
    ) {
        swiftDataModel.deleteSwipeFriendElement(
            context: context,
            swipeFriendElement: swipeFriendElement
        )
    }
    
    /// SwipeFriendElementの削除（全て）
    func deleteAllSwipeFriendElement(
        context: ModelContext
    ) {
        swiftDataModel.deleteAllSwipeFriendElement(
            context: context
        )
    }

    /// uid取得
    func fetchUid() -> String? {
        return userDataModel.fetchUid()
    }
}
