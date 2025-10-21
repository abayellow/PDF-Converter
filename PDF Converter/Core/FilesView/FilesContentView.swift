//
//  FilesView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct FilesContentView: View {
    @State private var showPicker = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                CustomNavigationBar(title: "Converter")
                ChoosePhotoView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            CustomTabBar {
                showPicker.toggle()
            }
        }
        .sheet(isPresented: $showPicker) {
            // Здесь можешь вставить свой image picker или другое окно
            Text("Добавление файла...")
                .font(.title)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    FilesContentView()
}


