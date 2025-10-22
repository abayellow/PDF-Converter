//
//  WelcomeView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 23.10.2025.
//

import SwiftUI

struct WelcomeView: View {
    @State private var animateLogo = false
    @State private var navigateToMain = false
    
    var body: some View {
        ZStack {
            
            if navigateToMain {
                // Основной экран
                FilesContentView()
            } else {
                VStack(spacing: 20) {
                    Spacer()
                    
                    // App Icon
                    Image(.pdf) // имя твоей иконки
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .scaleEffect(animateLogo ? 1.1 : 0.8)
                        .animation(
                            .easeOut(duration: 1.0),
                            value: animateLogo
                        )
                    
                    // Animated Label
                    Text("PDF Converter")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .opacity(animateLogo ? 1 : 0)
                        .offset(y: animateLogo ? 0 : 20)
                        .animation(.easeOut(duration: 1.0), value: animateLogo)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            animateLogo = true
            
            // Автопереход через 2 секунды
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut) {
                    navigateToMain = true
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
}
