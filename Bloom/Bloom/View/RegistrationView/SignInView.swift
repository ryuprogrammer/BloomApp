import SwiftUI

struct SignInView: View {
    @Binding var isShowSheet: Bool
    var body: some View {
        ZStack {
            Color.pink.opacity(0.8)
                .ignoresSafeArea(.all)
            
            VStack {
                Spacer()
                
                Image("logoWhite")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                
                Text("Bloom")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Button {
                    self.isShowSheet.toggle()
                } label: {
                    Text("サインインする")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.pink.opacity(0.8))
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .padding()
                }
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var isShowSheet: Bool = false
        var body: some View {
            SignInView(isShowSheet: $isShowSheet)
        }
    }
    
    return PreviewView()
}
