//
//  ChoosePhotoView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct ChoosePhotoView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Choose Photo")
                .font(.title2.bold())
                .foregroundColor(.blue)
            
            Text("You can either choose from Photos or Files.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            HStack(spacing: 40) {
                ChooseCellView(image: .apple, title: "Photos")
                ChooseCellView(image: .files, title: "Files")
            }
        }
        .padding()
    }
}

//Subview

struct ChooseCellView: View {
    var image: ImageResource
    var title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.accentColor)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .frame(width: 100, height: 100)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .shadow(radius: 1)
    }
}

#Preview {
    ChoosePhotoView()
}
