import SwiftUI

struct AgePickerView: View {
    @Binding var minAge: Int
    @Binding var maxAge: Int
    @Binding var isShowing: Bool

    let pickerWidth = UIScreen.main.bounds.width / 3
    let pickerHeight = UIScreen.main.bounds.height / 4

    var body: some View {
        VStack {
            Divider()
            Button(action: {
                withAnimation(.linear) {
                    self.isShowing = false
                }
            }) {
                HStack {
                    Spacer()
                    Text("閉じる")
                        .foregroundStyle(Color.blue)
                        .padding(.horizontal, 16)
                }
            }
            .padding(3)
            Divider()

            HStack {
                Picker(selection: $minAge, label: Text("")) {
                    ForEach((18..<50), id: \.self) {
                        Text("\($0)")
                            .tag($0)
                    }
                }
                .frame(width: pickerWidth)
                .pickerStyle(.wheel)
                .labelsHidden()

                Text("〜")

                Picker(selection: $maxAge, label: Text("")) {
                    ForEach((18..<50), id: \.self) {
                        Text("\($0)")
                            .tag($0)
                    }
                }
                .frame(width: pickerWidth)
                .pickerStyle(.wheel)
                .labelsHidden()
            }
        }
        .frame(height: pickerHeight)
        .background(Color.white)
        .onChange(of: maxAge) {
            if maxAge <= minAge {
                withAnimation {
                    minAge = maxAge - 1
                }
            }
        }
        .onChange(of: minAge) {
            if minAge >= maxAge {
                withAnimation {
                    maxAge = minAge + 1
                }
            }
        }
    }
}

#Preview {
    struct PreviewView: View {
        @State var minAge: Int = 18
        @State var maxAge: Int = 22
        @State var isShowing: Bool = true

        var body: some View {
            AgePickerView(minAge: $minAge, maxAge: $maxAge, isShowing: $isShowing)
        }
    }

    return PreviewView()
}
