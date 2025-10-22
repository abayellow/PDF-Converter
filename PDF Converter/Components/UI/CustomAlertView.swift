//
//  PDFNameAlert.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//


import SwiftUI

struct CustomAlertView: View {
    //    var title: String
    @Binding var text: String
    var placeholder: String = ""
    var onCancel: () -> Void
    var onSave: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 5) {
                HStack(spacing: 8) {
                    Text("Save PDF")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Image(.pdf)
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    
                }
                .padding(8)
                .cornerRadius(8)
                
                Text("Enter file name")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                HStack {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    
                    Button(action: onSave) {
                        Text("Save")
                            .bold()
                            .foregroundColor(text.isEmpty ? .gray : .blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .disabled(text.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
            .transition(.scale.combined(with: .opacity))
            .animation(.spring(), value: text)
        }
    }
}

#Preview {
    CustomAlertView(
        text: .constant(""),
        onCancel: {},
        onSave: {}
    )
}
