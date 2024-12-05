//
//  DocumentPages.swift
//  iphoneapp
//
//  Created by mac on 12/3/24.
//
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct DocumentPages: View {
    var userDocument:UserDocument
    
    var body: some View {
        NavigationView {
            WebView(url: URL(string: userDocument.url)!)
                .navigationTitle(userDocument.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DocumentPages(userDocument:.termCondition)
}

struct DocumentItem{
    let title : String
    let url : String
}

enum UserDocument{
    case termCondition,userPrivacy
    
    var title:String{
        switch self {
        case .termCondition:
            return "이용약관"
        case .userPrivacy:
            return "개인정보 이용방침"
        }
    }
    var url:String{
        switch self {
        case .termCondition:
            return "https://burningrank-9f378.web.app/termcondition.html"
        case .userPrivacy:
            return "https://burningrank-9f378.web.app/userprivacy.html"
        }
    }
}
