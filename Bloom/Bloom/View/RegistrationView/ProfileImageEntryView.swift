import SwiftUI
import PhotosUI

struct ProfileImageEntryView: View {
    let explanationText = ExplanationText()
    @State var selectedItems: [PhotosPickerItem] = []
    @State var uiImages: [UIImage] = []
    @Binding var profileImages: [Data]
    @Binding var registrationState: RegistrationState
    @State var isPhotoValid: Bool = false
    let maxSelectionCount: Int = 6
    let minSelectionCount: Int = 2
    // 画面横幅取得→写真の横幅と縦幅に利用
    let imageWidth = UIScreen.main.bounds.width / 3 - 13
    let imageHeight = UIScreen.main.bounds.height / 5
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    Text(explanationText.photoEntryDescription)
                        .font(.title3)
                        .padding()
                    
                    HStack {
                        ForEach(0..<3) { number in
                            if number == uiImages.count { // 写真が0枚の時
                                PhotosPicker(
                                    selection: $selectedItems,
                                    maxSelectionCount: maxSelectionCount,
                                    selectionBehavior: .ordered,
                                    matching: .images
                                ) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.pink.opacity(0.5))
                                            .strokeBorder(Color.black, lineWidth: 3)
                                            .frame(width: imageWidth, height: imageHeight)
                                        
                                        Image(systemName: "plus")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundStyle(Color.white)
                                    }
                                }
                            } else if uiImages.count > number { // 写真がある時
                                ZStack {
                                    Image(uiImage: uiImages[number])
                                        .resizable()
                                        .frame(width: imageWidth, height: imageHeight)
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                    
                                    // 削除ボタン
                                    Image(systemName: "minus.circle")
                                        .resizable()
                                        .frame(width: 26, height: 26)
                                        .foregroundStyle(Color.white)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: imageWidth/2-8, y: -imageHeight/2+5)
                                        .onTapGesture {
                                            selectedItems.remove(at: number)
                                        }
                                }
                            } else { // 写真がないフレーム
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.black, lineWidth: 3)
                                    .frame(width: imageWidth, height: imageHeight)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    HStack {
                        ForEach(3..<6) { number in
                            if number == uiImages.count { // 写真が0枚の時
                                PhotosPicker(
                                    selection: $selectedItems,
                                    maxSelectionCount: maxSelectionCount,
                                    selectionBehavior: .ordered,
                                    matching: .images
                                ) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.pink.opacity(0.5))
                                            .strokeBorder(Color.black, lineWidth: 3)
                                            .frame(width: imageWidth, height: imageHeight)
                                        
                                        Image(systemName: "plus")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundStyle(Color.white)
                                    }
                                }
                            } else if uiImages.count > number { // 写真がある時
                                ZStack {
                                    Image(uiImage: uiImages[number])
                                        .resizable()
                                        .frame(width: imageWidth, height: imageHeight)
                                        .aspectRatio(contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                    
                                    // 削除ボタン
                                    Image(systemName: "minus.circle")
                                        .resizable()
                                        .frame(width: 26, height: 26)
                                        .foregroundStyle(Color.white)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: imageWidth/2-8, y: -imageHeight/2+5)
                                        .onTapGesture {
                                            selectedItems.remove(at: number)
                                        }
                                }
                            } else { // 写真がないフレーム
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.black, lineWidth: 3)
                                    .frame(width: imageWidth, height: imageHeight)
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        
                        if uiImages.count == maxSelectionCount {
                            PhotosPicker(
                                selection: $selectedItems,
                                maxSelectionCount: maxSelectionCount,
                                selectionBehavior: .ordered,
                                matching: .images
                            ) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("写真を選び直す")
                                }
                            }
                            .padding()
                        }
                    }
                    
                    if !isPhotoValid {
                        Text(explanationText.photoEntryError)
                            .foregroundStyle(Color.red)
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    
                    Spacer()
                }
                .navigationBarTitle("プロフィール写真", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            registrationState = .address
                        }, label: {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(Color.black)
                        })
                    }
                }
                .onChange(of: selectedItems) {
                    Task {
                        uiImages.removeAll()
                        for item in selectedItems {
                            guard let data = try await item.loadTransferable(type: Data.self) else { continue }
                            guard let uiImage = UIImage(data: data) else { continue }
                            uiImages.append(uiImage)
                            
                            if let imageData = uiImage.jpegData(compressionQuality: 0.1) {
                                profileImages.append(imageData)
                            }
                        }
                        
                        if uiImages.count >= minSelectionCount {
                            isPhotoValid = true
                        } else {
                            isPhotoValid = false
                        }
                    }
                }
            }
            
            VStack {
                Spacer()
                
                Button(action: {
                    withAnimation {
                        registrationState = .homeImage
                    }
                }, label: {
                    Text("次へ")
                        .font(.title2)
                        .foregroundStyle(Color.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(isPhotoValid ? Color.pink.opacity(0.8) : Color(UIColor.lightGray))
                        .clipShape(Capsule())
                        .padding()
                })
                .disabled(!isPhotoValid)
            }
        }
        .onAppear {
            if uiImages.count >= minSelectionCount {
                isPhotoValid = true
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var images: [Data] = []
        @State var registrationState: RegistrationState = .noting
        var body: some View {
            ProfileImageEntryView(profileImages: $images, registrationState: $registrationState)
        }
    }
    
    return PreviewView()
}
