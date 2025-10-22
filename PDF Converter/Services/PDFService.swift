//
//  PDFService.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//

import UIKit
import CoreGraphics

struct PDFService {
    
    static func createPDF(from images: [UIImage], name: String) -> URL? {
        let fileName = "\(name).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        UIGraphicsBeginPDFContextToFile(tempURL.path, .zero, nil)
        for image in images {
            let pageRect = CGRect(origin: .zero, size: image.size)
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            image.draw(in: pageRect)
        }
        UIGraphicsEndPDFContext()
        return tempURL
    }

    static func mergePDFs(first: URL, second: URL, outputName: String) -> URL? {
        let mergedURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(outputName).pdf")
        guard let firstPDF = CGPDFDocument(first as CFURL),
              let secondPDF = CGPDFDocument(second as CFURL) else { return nil }

        UIGraphicsBeginPDFContextToFile(mergedURL.path, .zero, nil)
        [firstPDF, secondPDF].forEach { pdf in
            for i in 1...pdf.numberOfPages {
                guard let page = pdf.page(at: i) else { continue }
                let pageRect = page.getBoxRect(.mediaBox)
                UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
                UIGraphicsGetCurrentContext()?.drawPDFPage(page)
            }
        }
        UIGraphicsEndPDFContext()
        return mergedURL
    }

    static func createPDFFromFiles(urls: [URL], name: String) -> URL? {
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).pdf")
        UIGraphicsBeginPDFContextToFile(outputURL.path, .zero, nil)

        for fileURL in urls {
            let ext = fileURL.pathExtension.lowercased()
            
            if ["jpg","jpeg","png","heic"].contains(ext),
               let image = UIImage(contentsOfFile: fileURL.path) {
                let pageRect = CGRect(origin: .zero, size: image.size)
                UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
                image.draw(in: pageRect)
            } else if ext == "pdf",
                      let pdf = CGPDFDocument(fileURL as CFURL) {
                for i in 1...pdf.numberOfPages {
                    guard let page = pdf.page(at: i) else { continue }
                    let pageRect = page.getBoxRect(.mediaBox)
                    UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
                    UIGraphicsGetCurrentContext()?.drawPDFPage(page)
                }
            } else if ["txt","rtf"].contains(ext) {
                do {
                    let text = try String(contentsOf: fileURL, encoding: .utf8)
                    let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
                    UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
                    let style = NSMutableParagraphStyle()
                    style.lineBreakMode = .byWordWrapping
                    let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 14), .paragraphStyle: style]
                    text.draw(in: CGRect(x: 40, y: 40, width: 515, height: 762), withAttributes: attrs)
                } catch { print(error) }
            }
        }

        UIGraphicsEndPDFContext()
        return outputURL
    }
    
    static func generatePreview(from pdfURL: URL, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        guard let pdf = CGPDFDocument(pdfURL as CFURL),
              let page = pdf.page(at: 1) else {
            return UIImage(systemName: "doc.richtext.fill") ?? UIImage()
        }

        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fill(CGRect(origin: .zero, size: size))

            let scaleX = size.width / pageRect.width
            let scaleY = size.height / pageRect.height
            ctx.cgContext.scaleBy(x: scaleX, y: scaleY)
            ctx.cgContext.drawPDFPage(page)
        }

        return img
    }
}
