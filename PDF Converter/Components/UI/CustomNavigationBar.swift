//
//  CustomNavigationBar.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//


import SwiftUI

struct CustomNavigationBar: View {
    var title: String
    var subtitile: String

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(#colorLiteral(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)),
                                            Color(#colorLiteral(red: 0.0, green: 0.56, blue: 1.0, alpha: 1.0))]), 
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitile)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.leading, 16)

                Spacer()
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20)
            .padding(.bottom, 10)
        }
        .frame(height: (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20) + 60)
    }
}


#Preview {
    CustomNavigationBar(title: "Image Converter", subtitile: "Convert photos to PDF")
}
