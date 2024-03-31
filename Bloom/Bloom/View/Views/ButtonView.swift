import SwiftUI

struct ButtonView: View {
    let title: String
    let imageName: String?
    @Binding var isValid: Bool
    var action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                if isValid {
                    Color.main
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .clipShape(Capsule())
                        .padding(.horizontal)
                } else {
                    Color(UIColor.lightGray)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .clipShape(Capsule())
                        .padding(.horizontal)
                }

                HStack {
                    if let imageName {
                        Image(systemName: imageName)
                            .resizable()
                            .frame(width: 25, height: 25)
                            .aspectRatio(contentMode: .fill)
                            .foregroundStyle(Color.white)
                            .padding(.trailing, 5)
                    }

                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                }
            }
        }
        .disabled(!isValid)
    }
}

#Preview {
    struct PreviewView: View {
        @State var isValid: Bool = true
        let action: () -> Void = {}
        var body: some View {
            ButtonView(
                title: "ボタン",
                imageName: "magnifyingglass",
                isValid: $isValid,
                action: action
            )
        }
    }

    return PreviewView()
}
