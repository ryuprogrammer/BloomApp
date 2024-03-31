//
//  AccountStopView.swift
//  Bloom
//
//  Created by トム・クルーズ on 2024/03/18.
//

import SwiftUI

struct AccountStopView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.pink.opacity(0.8)
                VStack {
                    Spacer()

                    Text("アカウントが停止しました")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)

                    Spacer()

                    NavigationLink(destination: FormView()) {
                        Text("お問い合わせ")
                            .font(.title2)
                            .foregroundStyle(Color.pink)
                            .frame(height: 55)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(Capsule())
                            .padding()
                    }
                    .padding(.bottom, 60)
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    AccountStopView()
}
