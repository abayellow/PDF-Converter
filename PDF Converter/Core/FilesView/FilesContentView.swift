//
//  FilesView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct FilesContentView: View {
    @State private var showSheet = false
    @State private var pdfDocuments: [PDFDocumentItem] = []
    
    @State private var showPDFNameAlert = false
    @State private var imagesToConvert: [UIImage] = []
    @State private var pdfName: String = ""
    
    @State private var pdfToMerge: PDFDocumentItem? = nil
    @State private var isSelectingMergeTarget = false
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "PDF Converter")

            if pdfDocuments.isEmpty {
                // Центрируем EmptyView по экрану
                VStack {
                    Spacer()
                    EmptyView()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.1))
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(pdfDocuments) { doc in
                            PDFView(preview: doc.preview, name: doc.name, date: doc.date)
                                .contextMenu {
                                    Button {
                                        sharePDF(doc: doc)
                                    } label: {
                                        Label("Поделиться", systemImage: "square.and.arrow.up")
                                    }

                                    Button(role: .destructive) {
                                        deletePDF(doc: doc)
                                    } label: {
                                        Label("Удалить", systemImage: "trash")
                                    }

                                    Button {
                                        selectPDFForMerge(doc: doc)
                                    } label: {
                                        Label("Объединить", systemImage: "doc.on.doc")
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.1))
            }

            CustomTabBar {
                showSheet.toggle()
            }
        }

        .background(Color.gray.opacity(0.1)) // ← серый фон для всей вьюхи
        .sheet(isPresented: $showSheet) {
            ChoosePhotoView { name, images in
                if let url = createPDF(images: images, name: name) {
                    let firstImage = images.first ?? UIImage()
                    let conversionDate = Date() // ← дата конвертации
                    pdfDocuments.append(PDFDocumentItem(name: name, url: url, preview: firstImage, date: conversionDate))
                }
                showSheet = false
            }
        }
        
        .sheet(isPresented: $isSelectingMergeTarget) {
            VStack {
                Text("Выберите документ для объединения")
                    .font(.headline)
                    .padding()
                
                ScrollView {
                    LazyVStack {
                        ForEach(pdfDocuments.filter { $0.id != pdfToMerge?.id }) { doc in
                            PDFView(preview: doc.preview, name: doc.name, date: doc.date)
                                .onTapGesture {
                                    if let first = pdfToMerge {
                                        mergePDFs(first: first, second: doc)
                                        isSelectingMergeTarget = false
                                        pdfToMerge = nil
                                    }
                                }
                        }
                    }
                    .padding()
                }
                
                Button("Отмена") {
                    isSelectingMergeTarget = false
                    pdfToMerge = nil
                }
                .padding()
            }
        }
        
        .alert(isPresented: $showPDFNameAlert) {
            Alert(title: Text("PDF Saved"), message: Text("Your PDF has been saved as \(pdfName)"), dismissButton: .default(Text("OK")))
        }
    }
    
    
    
}

#Preview {
    FilesContentView()
}


extension FilesContentView {
    private func askForPDFName() {
        let alert = UIAlertController(title: "Save PDF", message: "Enter file name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "PDF Name"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let name = alert.textFields?.first?.text, !name.isEmpty {
                pdfName = name
                if let url = createPDF(images: imagesToConvert, name: pdfName) {
                    let firstImage = imagesToConvert.first ?? UIImage()
                    pdfDocuments.append(PDFDocumentItem(name: pdfName, url: url, preview: firstImage, date: Date()))
                }
            }
        })
        
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
            .first?.rootViewController {
            window.present(alert, animated: true)
        }
        
        if let window = UIApplication.shared.windows.first {
               window.rootViewController?.overrideUserInterfaceStyle = .light // 🔑 заставляем светлую тему
               window.rootViewController?.present(alert, animated: true)
           }
    }
    
    private func createPDF(images: [UIImage], name: String) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "PDF Converter",
            kCGPDFContextAuthor: "App"
        ]
        let fileName = "\(name).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        UIGraphicsBeginPDFContextToFile(tempURL.path, .zero, pdfMetaData as [String: Any])

        for image in images {
            let pageRect = CGRect(origin: .zero, size: image.size)
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            image.draw(in: pageRect)
        }

        UIGraphicsEndPDFContext()
        return tempURL
    }
    
    
    private func sharePDF(doc: PDFDocumentItem) {
        let activityVC = UIActivityViewController(activityItems: [doc.url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
    
    private func deletePDF(doc: PDFDocumentItem) {
        if let index = pdfDocuments.firstIndex(where: { $0.id == doc.id }) {
            pdfDocuments.remove(at: index)
        }
    }
    
    private func selectPDFForMerge(doc: PDFDocumentItem) {
        pdfToMerge = doc
        isSelectingMergeTarget = true
    }
    
    private func mergePDFs(first: PDFDocumentItem, second: PDFDocumentItem) {
        guard let firstPDF = CGPDFDocument(first.url as CFURL),
              let secondPDF = CGPDFDocument(second.url as CFURL) else { return }

        let mergedName = "\(first.name) + \(second.name)"
        let mergedURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(mergedName).pdf")

        UIGraphicsBeginPDFContextToFile(mergedURL.path, .zero, nil)

        for i in 1...firstPDF.numberOfPages {
            guard let page = firstPDF.page(at: i) else { continue }
            let pageRect = page.getBoxRect(.mediaBox)
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            UIGraphicsGetCurrentContext()?.drawPDFPage(page)
        }

        for i in 1...secondPDF.numberOfPages {
            guard let page = secondPDF.page(at: i) else { continue }
            let pageRect = page.getBoxRect(.mediaBox)
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            UIGraphicsGetCurrentContext()?.drawPDFPage(page)
        }

        UIGraphicsEndPDFContext()

        // Добавляем новый документ
        let preview = first.preview // Можно улучшить, сделать миниатюру объединённых страниц
        pdfDocuments.append(PDFDocumentItem(name: mergedName, url: mergedURL, preview: preview, date: Date()))
    }
}
