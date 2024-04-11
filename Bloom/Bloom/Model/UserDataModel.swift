import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserDataModel {
    /// コレクションの名称
    private let collectionName = "profiles"
    let friendCollectionName = "friends"
    let friendListCollectionName = "friendList"
    private var db = Firestore.firestore()
    private let storage = Storage.storage()
    // アカウントが停止する通報数
    let accountStopReportLimit = 20

    /// 自分が通報されているかチェック（Limitに達していたらアカウント停止にする）
    func checkReportMyAccount() async {
        // UIDを取得
        guard let uid = fetchUid() else { return }

        let reportedCount = await db.collection("friends").document(uid).collection("friendList").whereField("status", isEqualTo: FriendStatus.likeByMe).count.accessibilityElementCount()

        print("通報回数！！！！！！: \(reportedCount)")

        if reportedCount >= accountStopReportLimit {

        }
    }

    /// 友達関係を指定して、リアルタイム監視: トークしてる人を取得したり
    func listenFriends(friendStatus: FriendStatus, completion: @escaping ([FriendsElement]?, Error?) -> Void) -> ListenerRegistration? {

        guard let uid = fetchUid() else {
            return nil
        }

        let listener = db.collection(friendCollectionName).document(uid).collection(friendListCollectionName).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            var friendsElements: [FriendsElement] = []

            if let querySnapshot = querySnapshot {
                for documentChange in querySnapshot.documentChanges {
                    if documentChange.type == .added {
                        do {
                            let friendsElement = try documentChange.document.data(as: FriendsElement.self)
                            if friendsElement.status == friendStatus {
                                friendsElements.append(friendsElement)
                            }
                        } catch {
                            completion(nil, error)
                        }
                    }
                }
            }
            completion(friendsElements, nil)
        }
        return listener
    }

    /// リアルタイム監視: 全てのUser
    func listenProfiles(completion: @escaping ([ProfileElement]?, Error?) -> Void) -> ListenerRegistration {
        let listener = db.collection(collectionName).addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            var profiles: [ProfileElement] = []

            if let querySnapshot = querySnapshot {
                for documentChange in querySnapshot.documentChanges {
                    if documentChange.type == .added {
                        do {
                            let profile = try documentChange.document.data(as: ProfileElement.self)
                            profiles.append(profile)
                        } catch {
                            completion(nil, error)
                        }
                    }
                }
            }
            completion(profiles, nil)
        }
        return listener
    }

    /// uid取得メソッド
    func fetchUid() -> String? {
        var uid: String?
        let user = Auth.auth().currentUser

        if let user {
            uid = user.uid
        }

        return uid
    }

    /// friends追加・更新メソッド: ライクとかした時のメソッド
    func addFriendsToList(
        state: FriendStatus,
        friendProfile: ProfileElement,
        completion: @escaping (Error?) -> Void
    ) {
        // UIDを取得
        guard let uid = fetchUid() else { return }
        // 自分のRef
        let myDocumentRef = db.collection(friendCollectionName).document(uid).collection(friendListCollectionName)

        guard let friendUid = friendProfile.id else { return }
        // 相手のRef
        let friendDocmentRef = db.collection(friendCollectionName).document(friendUid).collection(friendListCollectionName)

        // 相手のデータ
        let friendUidAndState: FriendsElement = FriendsElement(
            friendUid: friendUid,
            status: state
        )

        let myUidAndStatus: FriendsElement = FriendsElement(
            friendUid: uid,
            status: state
        )

        // 自分のRefに保存
        if state != .reportByFriend {
            // Firestoreに保存するために、Codableオブジェクトを辞書に変換
            do {
                try myDocumentRef.document(friendUid).setData(from: friendUidAndState) { error in
                    if let error = error {
                        // エラー処理
                        completion(error)
                    } else {
                        // 成功した場合、nilをコールバックに渡す
                        completion(nil)
                    }
                }
            } catch let error {
                completion(error)
            }
        }

        // 相手のRefに保存
        if state != .unLikeByMe { // この時だけ相手のRefにはデータを追加しない.
            // Firestoreに保存するために、Codableオブジェクトを辞書に変換
            do {
                try friendDocmentRef.document(uid).setData(from: myUidAndStatus) { error in
                    if let error = error {
                        // エラー処理
                        completion(error)
                    } else {
                        // 成功した場合、nilをコールバックに渡す
                        completion(nil)
                    }
                }
            } catch let error {
                completion(error)
            }
        }
    }

    /// Profile追加メソッド（更新も可能）
    func addProfile(profile: ProfileElement, completion: @escaping (Error?) -> Void) {
        // UIDを取得
        guard let uid = fetchUid() else { return }

        // Firestoreに保存するデータを辞書形式で用意
        let firestoreData: [String: Any] = [
            "userName": profile.userName,
            "introduction": profile.introduction as Any,
            "birth": profile.birth,
            "gender": profile.gender.rawValue,
            "address": profile.address,
            "grade": profile.grade,
            "hobby": profile.hobby,
            "location": profile.location as Any,
            "profession": profile.profession as Any,
            "point": profile.point
        ]

        // 指定したUIDを持つドキュメントにデータを追加（または更新）
        db.collection(collectionName).document(uid).setData(firestoreData) { error in
            guard error == nil else {
                completion(error)
                return
            }

            // Firebase Storageにプロファイル画像をアップロード
            let storageRef = self.storage.reference()

            // profileImagesのアップロード
            for (index, imageData) in profile.profileImages.enumerated() {
                let imageRef = storageRef.child("profileImages/\(uid)/image\(index).jpg")
                imageRef.putData(imageData, metadata: nil) { metadata, error in
                    guard error == nil else {
                        completion(error)
                        return
                    }
                }
            }

            // homeImageのアップロード
            let homeImageRef = storageRef.child("homeImages/\(uid)/home.jpg")
            homeImageRef.putData(profile.homeImage, metadata: nil) { metadata, error in
                guard error == nil else {
                    completion(error)
                    return
                }
            }

            // すべてのアップロードが完了したことをコールバック
            completion(nil)
        }
    }

    /// ProfileのprofileImagesを全削除（profileImagesを更新する前に削除する）
    func deleteProfileImages(deleteImageCount: Int, completion: @escaping (Error?) -> Void) async {
        // UIDを取得
        guard let uid = fetchUid() else { return }

        let storageRef = self.storage.reference()

        for index in 0..<deleteImageCount {
            let deleteRef = storageRef.child("profileImages/\(uid)/image\(index).jpg")
            do {
                try await deleteRef.delete()
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }

    /// FriendStatus（Userの関係値）を指定してUidを取得
    func fetchProfileWithFriendStatus(friendStatus: FriendStatus, completion: @escaping ([String]?, Error?) -> Void) {
        // UIDを取得
        guard let uid = fetchUid() else { return }

        db.collection("friends").document(uid).collection("friendList").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            var documentIDs: [String] = []

            if let querySnapshot = querySnapshot {
                print("documents.count: \(querySnapshot.documents.count)")
                for docment in querySnapshot.documents {
                    let data = docment.data()
                    print("data: \(data)")

                    guard let friendUid = data["friendUid"] as? String else {
                        print("エラー: friendUid")
                        continue
                    }

                    guard let statusString = data["status"] as? String else {
                        print("エラー: statusString")
                        continue
                    }

                    guard let status = FriendStatus(rawValue: statusString) else {
                        print("エラー: status")
                        continue
                    }

                    if status == friendStatus {
                        documentIDs.append(friendUid)
                    }
                }
            }

            completion(documentIDs, nil)
        }
    }

    /// SignInUserのUidを全て取得
    func fetchProfileAllUids(completion: @escaping ([String]?, Error?) -> Void) {
        let db = Firestore.firestore()

        db.collection("profiles").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            let documentIDs = querySnapshot?.documents.map { $0.documentID }
            completion(documentIDs, nil)
        }
    }

    /// SignInUserのuidを数を指定して取得
    func fetchProfileUids(limit: Int, completion: @escaping ([String]?, Error?) -> Void) {
        let db = Firestore.firestore()

        // TODO: - ここでフィルターかける
        db.collection("profiles").limit(to: limit).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            let documentIDs = querySnapshot?.documents.map { $0.documentID }
            completion(documentIDs, nil)
        }
    }

    /// uidを指定して、プロフィールを１つ取得 （画像データは含まない）
    func fetchProfileWithoutImages(uid: String, completion: @escaping (ProfileElement?, Error?) -> Void) {
        let db = Firestore.firestore()

        db.collection("profiles").document(uid).getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                completion(nil, NSError(domain: "ProfileError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found."]))
                return
            }

            // nilを許容するデータたち
            var introduction: String? = nil
            var location: Location? = nil
            var profession: String? = nil

            if let introductionData = data["introduction"] as? String? {
                introduction = introductionData
            }
            if let locationData = data["location"] as? Location? {
                location = locationData
            }
            if let professionData = data["profession"] as? String? {
                profession = professionData
            }

            guard let userName = data["userName"] as? String,
                  let birth = data["birth"] as? String,
                  let genderRaw = data["gender"] as? String,
                  let gender = Gender(rawValue: genderRaw),
                  let address = data["address"] as? String,
                  let grade = data["grade"] as? Int,
                  let hobby = data["hobby"] as? [String],
                  let point = data["point"] as? Int else {
                completion(nil, NSError(domain: "DataError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Data format error."]))
                return
            }

            let profile = ProfileElement(userName: userName, introduction: introduction, birth: birth, gender: gender, address: address, grade: grade, hobby: hobby, location: location, profession: profession, profileImages: [], homeImage: Data(), point: point)
            completion(profile, nil)
        }
    }


    /// uidを指定して、プロフィールを1つ取得 （画像データまで取得）
    func fetchProfile(uid: String, completion: @escaping (ProfileElement?, Error?) -> Void) {
        db.collection("profiles").document(uid).getDocument { document, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                completion(nil, NSError(domain: "ProfileError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Profile not found."]))
                return
            }

            // nilを許容するデータたち
            var introduction: String? = nil
            var location: Location? = nil
            var profession: String? = nil

            if let introductionData = data["introduction"] as? String? {
                introduction = introductionData
            }
            if let locationData = data["location"] as? Location? {
                location = locationData
            }
            if let professionData = data["profession"] as? String? {
                profession = professionData
            }

            guard let userName = data["userName"] as? String,
                  let birth = data["birth"] as? String,
                  let genderRaw = data["gender"] as? String,
                  let gender = Gender(rawValue: genderRaw),
                  let address = data["address"] as? String,
                  let grade = data["grade"] as? Int,
                  let hobby = data["hobby"] as? [String],
                  let point = data["point"] as? Int else {
                completion(nil, NSError(domain: "DataError", code: 100, userInfo: [NSLocalizedDescriptionKey: "Data format error."]))
                return
            }

            // プロファイル画像とホーム画像のパスを準備
            let storageRef = self.storage.reference()
            let profileImagesRef = storageRef.child("profileImages/\(uid)")
            let homeImageRef = storageRef.child("homeImages/\(uid)/home.jpg")

            // ホーム画像をダウンロード
            homeImageRef.getData(maxSize: 10 * 1024 * 1024) { homeImageData, error in
                guard let homeImageData = homeImageData, error == nil else {
                    completion(nil, error)
                    return
                }

                // プロファイル画像のダウンロード
                profileImagesRef.listAll { (result, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }

                    let group = DispatchGroup()
                    var profileImagesData = [Data]()

                    guard let result = result else { return }

                    for item in result.items {
                        group.enter()
                        item.getData(maxSize: 10 * 1024 * 1024) { data, error in
                            defer { group.leave() }

                            if let data = data, error == nil {
                                profileImagesData.append(data)
                            }
                        }
                    }

                    group.notify(queue: .main) {
                        // すべてのプロファイル画像がダウンロードされた後に実行
                        let profile = ProfileElement(userName: userName, introduction: introduction, birth: birth, gender: gender, address: address, grade: grade, hobby: hobby, location: location, profession: profession, profileImages: profileImagesData, homeImage: homeImageData, point: point)

                        completion(profile, nil)
                    }
                }
            }
        }
    }

}
