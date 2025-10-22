//
//  PDFListView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//

import SwiftUI

//
//  PDFListView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//

import SwiftUI

struct PDFListView: View {
    var pdfDocuments: [PDFDocumentItem]
    var onShare: (PDFDocumentItem) -> Void
    var onDelete: (PDFDocumentItem) -> Void
    var onMerge: (PDFDocumentItem) -> Void
    var onOpen: (URL) -> Void   // 👈 добавили
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(pdfDocuments) { doc in
                    Button {
                        onOpen(doc.url) // 👈 обычный тап открывает PDFReaderView
                    } label: {
                        HStack(spacing: 12) {
                            Image(uiImage: doc.preview)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                                .clipped()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(doc.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(doc.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button {
                            onShare(doc)
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }

                        Button {
                            onMerge(doc)
                        } label: {
                            Label("Merge", systemImage: "link")
                        }

                        Button(role: .destructive) {
                            onDelete(doc)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    let samplePDFs = [
        PDFDocumentItem(name: "Example 1", url: URL(string: "https://example.com")!, preview: UIImage(systemName: "doc.text")!, date: Date()),
        PDFDocumentItem(name: "Example 2", url: URL(string: "https://example.com")!, preview: UIImage(systemName: "doc.text")!, date: Date())
    ]
    
    PDFListView(
        pdfDocuments: samplePDFs,
        onShare: { _ in },
        onDelete: { _ in },
        onMerge: { _ in },
        onOpen: { _ in }
    )
}

//struct PDFListView: View {
//    var pdfDocuments: [PDFDocumentItem]
//    var onShare: (PDFDocumentItem) -> Void
//    var onDelete: (PDFDocumentItem) -> Void
//    var onMerge: (PDFDocumentItem) -> Void
//    
//    
//    var body: some View {
//        ScrollView {
//            LazyVStack(spacing: 12) {
//                ForEach(pdfDocuments) { doc in
//                    PDFView(preview: doc.preview, name: doc.name, date: doc.date)
//                        .contextMenu {
//                            Button { onShare(doc) } label: { Label("Share", systemImage: "square.and.arrow.up") }
//                            Button { onMerge(doc) } label: { Label("Merge", systemImage: "doc.on.doc") }
//                            Button(role: .destructive) { onDelete(doc) } label: { Label("Delete", systemImage: "trash") }
//                        }
//                }
//                
//            }
//            .padding()
//        }
//        
//    }
//}
//
//#Preview {
//    let samplePDFs = [
//        PDFDocumentItem(name: "Example 1", url: URL(string: "https://example.com")!, preview: UIImage(named: "apple")!, date: Date()),
//        PDFDocumentItem(name: "Example 2", url: URL(string: "https://example.com")!, preview: UIImage(named: "pdf")!, date: Date()),
//        PDFDocumentItem(name: "Example 3", url: URL(string: "https://example.com")!, preview: UIImage(named: "apple")!, date: Date())
//    ]
//    
//    PDFListView(
//        pdfDocuments: samplePDFs,
//        onShare: { _ in },
//        onDelete: { _ in },
//        onMerge: { _ in }
//    )
//}
