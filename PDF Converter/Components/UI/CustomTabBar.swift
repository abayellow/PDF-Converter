//
//  CustomTabBar.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct CustomTabBar: View {
    var action: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(height: 70)
                .shadow(color: .black.opacity(0.1), radius: 6, y: -2)
                .ignoresSafeArea(edges: .bottom)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    action()
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(24)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                    .scaleEffect(1.0)
            }
            .offset(y: -25)
        }
    }
}

#Preview {
    CustomTabBar(action: {})
}
