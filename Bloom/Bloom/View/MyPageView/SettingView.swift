import SwiftUI

struct SettingView: View {
    @Binding var path: [MyPagePath]
    var body: some View {
        List {
            Section {
                Button(action: {
                    path.append(.pathPrivacy)
                }, label: {
                    NavigationRow(rowString: "お知らせ")
                })
                Button(action: {
                    path.append(.pathPrivacy)
                }, label: {
                    NavigationRow(rowString: "プライバシーポリシー")
                })
                Button(action: {
                    path.append(.pathService)
                }, label: {
                    NavigationRow(rowString: "利用規約")
                })
            } header: {
                Text("アプリ情報")
            }

            Section {
                Button {
                    path.append(.pathForm)
                } label: {
                    NavigationRow(rowString: "友達リスト")
                }
                Button {
                    path.append(.pathForm)
                } label: {
                    NavigationRow(rowString: "ブロックリスト")
                }
            } header: {
                Text("友達")
            }

            Section {
                Button {
                    path.append(.pathForm)
                } label: {
                    NavigationRow(rowString: "お問い合わせ")
                }
            } header: {
                Text("お問い合わせ")
            }

            Section {
                Button {
                    path.append(.pathPranWeb)
                } label: {
                    NavigationRow(rowString: "プラン")
                }
                Button {
                    path.append(.pathDeleteAccount)
                } label: {
                    NavigationRow(rowString: "退会")
                }
            } header: {
                Text("個人情報")
            }
        }
        .navigationBarTitle("設定", displayMode: .inline)
    }
}

struct NavigationRow: View {
    let rowString: String
    let iconSize = UIScreen.main.bounds.width / 30
    var body: some View {
        HStack {
            Text(rowString)
                .foregroundStyle(Color.black)

            Spacer()

            Image(systemName: "chevron.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(Color.gray)
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var path: [MyPagePath] = []
        var body: some View {
            SettingView(path: $path)
        }
    }

    return PreviewView()
}
