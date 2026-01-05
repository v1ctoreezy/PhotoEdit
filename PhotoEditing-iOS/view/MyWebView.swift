import SwiftUI
import WebKit

struct MyWebView: View {
    
    var request: URLRequest
    init(request: URLRequest) {
        self.request = request
    }
    init(url: URL) {
        self.init(request: URLRequest(url: url))
    }
    
    var body: some View {
        WebViewWrapper(request: self.request)
    }
}

final class WebViewWrapper : UIViewRepresentable {
    
    var request: URLRequest
    init(request: URLRequest) {
        self.request = request
    }
    
    func makeUIView(context: Context) -> WKWebView  {
        let view = WKWebView()
        view.load(request)
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    
    }
    
}
