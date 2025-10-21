//
//  CustomNavigationBar.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//


import SwiftUI

struct CustomNavigationBar: View {
    var title: String
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea(edges: .top)
            HStack {
                Spacer()
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.blue)
                Spacer()
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20) // отступ сверху
            .padding(.bottom, 10)
        }
        .frame(height: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20) + 60) // динамическая высота
    }
}

#Preview {
    CustomNavigationBar(title: "Image Converter")
}

