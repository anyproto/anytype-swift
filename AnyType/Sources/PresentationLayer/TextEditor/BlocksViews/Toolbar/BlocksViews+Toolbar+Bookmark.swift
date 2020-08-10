//
//  BlocksViews+Toolbar+Bookmark.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os

fileprivate typealias Namespace = BlocksViews.Toolbar.Bookmark

private extension Logging.Categories {
    static let blocksViewsToolbarBookmark: Self = "BlocksViews.Toolbar.Bookmark"
}

// MARK: AddBlock
extension BlocksViews.Toolbar {
    enum Bookmark {}
}

// MARK: InputViewBuilder
extension Namespace {
    enum InputViewBuilder {
        static func createView(_ viewModel: ObservedObject<ViewModel>) -> UIView? {
            let controller = UIHostingController(rootView: InputView.init(model: viewModel.wrappedValue))
            let view = controller.view
            view?.backgroundColor = BlocksViews.Toolbar.Style.default.backgroundColor()
            return view
        }
    }
}

// MARK: Style
extension Namespace {
    enum Style {
        func fontSize() -> CGFloat {
            switch self {
            case .title: return 17
            case .subtitle: return 13
            case .section: return 0
            }
        }
        case title, subtitle, section
        func font() -> UIFont {
            switch self {
            case .title: return .systemFont(ofSize: self.fontSize())
            case .subtitle: return .systemFont(ofSize: self.fontSize())
            case .section: return .preferredFont(forTextStyle: .headline)
            }
        }
        func coreTextFont() -> CTFont {
            self.font() as CTFont
        }
        func foregroundColor() -> UIColor {
            switch self {
            case .title: return .black
            case .subtitle: return .init(red: 0.422, green: 0.415, blue: 0.372, alpha: 1)
            case .section: return .init(red: 0.675, green: 0.663, blue: 0.588, alpha: 1)
            }
        }
        func backgroundColor() -> UIColor {
            .white
        }
    }
}

// MARK: View
/// TODO: Refactor later.
extension Namespace {
    struct Layout {
        var webViewHeight: CGFloat = 300
    }
}

extension Namespace {
    struct InputView: View {
        @ObservedObject var model: ViewModel
        var layout: Layout = .init()
        
        var newBody: some View {
            VStack(alignment: .center) {
                WebView(viewModel: self.model.webViewModel).frame(height: self.layout.webViewHeight)
                TextField(self.model.title, text: self.$model.typingURL).textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    self.model.choose(url: self.model.typingURL)
                }) {
                    Text(self.model.buttonTitle)
                }.modifier(RoundedButtonViewModifier(style: .presentation))
                Spacer(minLength: 10)
            }.padding(10)
        }
        
        var body: some View {
            newBody
        }
    }
}

// MARK: - View / Style
extension Namespace.InputView {
    enum Style {
        case presentation
        
        enum Button {
            case presentation
            var backgroundColor: UIColor {
                .orange
            }
            var foregroundColor: UIColor {
                .white
            }
            var borderColor: UIColor {
                .orange
            }
        }
        
    }
}

// MARK: - View / RoundedButtonViewModifier
extension Namespace.InputView {
    struct RoundedButtonViewModifier: ViewModifier {
        var style: Style.Button
        func body(content: Content) -> some View { content.padding(10).background(Color(self.style.backgroundColor)).foregroundColor(Color(self.style.foregroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(Color(self.style.borderColor), lineWidth: 1)
            )
        }
    }
    struct FlexibleWidthViewModifier: ViewModifier {
        func body(content: Content) -> some View {
            content.frame(minWidth: 10, idealWidth: 10, maxWidth: nil, alignment: .center)
        }
    }
}

import WebKit
extension Namespace {
    // MARK: - View / WebView
    struct WebView: UIViewRepresentable {
        var urlType: WebUrl = .publicUrl
        // Viewmodel object
        @ObservedObject var viewModel: ViewModel
        
        // Make a coordinator to co-ordinate with WKWebView's default delegate functions
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        func makeUIView(context: Context) -> WKWebView {
            // Enable javascript in WKWebView to interact with the web app
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = false
            
            let configuration = WKWebViewConfiguration()
            // Here "iOSNative" is our interface name that we pushed to the website that is being loaded
            //        configuration.userContentController.add(self.makeCoordinator(), name: "iOSNative")
            configuration.preferences = preferences
            
            let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
            webView.navigationDelegate = context.coordinator
            webView.allowsBackForwardNavigationGestures = false
            webView.scrollView.isScrollEnabled = false
            return webView
        }
        
        func updateUIView(_ webView: WKWebView, context: Context) {
            if urlType == .localUrl {
                // Load local website
                if let url = Bundle.main.url(forResource: "LocalWebsite", withExtension: "html", subdirectory: "www") {
                    webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
                }
            } else if urlType == .publicUrl {
                // Load a public website
                if let urlString = self.viewModel.url, let url = URL(string: urlString) {
                    webView.load(URLRequest(url: url))
                }
            }
        }
        
        class Coordinator : NSObject, WKNavigationDelegate {
            var parent: WebView
            var webViewNavigationSubscriber: AnyCancellable? = nil
            
            init(_ uiWebView: WebView) {
                self.parent = uiWebView
            }
            
            deinit {
                webViewNavigationSubscriber?.cancel()
            }
            
            func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
                // Page loaded so no need to show loader anymore
                self.parent.viewModel.showLoader.send(false)
            }
            
            func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
                parent.viewModel.showLoader.send(false)
            }
            
            func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
                parent.viewModel.showLoader.send(false)
            }
            
            func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
                parent.viewModel.showLoader.send(true)
            }
            
            func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
                parent.viewModel.showLoader.send(true)
                self.webViewNavigationSubscriber = self.parent.viewModel.webViewNavigationPublisher.receive(on: RunLoop.main).sink(receiveValue: { navigation in
                    switch navigation {
                    case .backward:
                        if webView.canGoBack {
                            webView.goBack()
                        }
                    case .forward:
                        if webView.canGoForward {
                            webView.goForward()
                        }
                    }
                })
            }
            
            // This function is essential for intercepting every navigation in the webview
            func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                // Suppose you don't want your user to go a restricted site
                if let host = navigationAction.request.url?.host {
                    if host == "restricted.com" {
                        // Navigation is cancelled
                        decisionHandler(.cancel)
                        return
                    }
                }
                decisionHandler(.allow)
            }
        }
    }
}

extension Namespace.WebView {
    class ViewModel: ObservableObject {
        var webViewNavigationPublisher = PassthroughSubject<WebViewNavigation, Never>()
        var showLoader = PassthroughSubject<Bool, Never>()
        var valuePublisher = PassthroughSubject<String, Never>()
        @Published var url: String?
    }

    enum WebViewNavigation {
        case backward, forward
    }

    enum WebUrl {
        case localUrl, publicUrl
    }
}
