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
            Color.blue
                .ignoresSafeArea(edges: .top)
            
            HStack {
                VStack(alignment: .leading, spacing: 2) { // выравниваем по левому краю
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    Text("Convert photos to PDF")
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white)
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
    CustomNavigationBar(title: "Image Converter")
}
