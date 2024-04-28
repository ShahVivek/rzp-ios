//
//  WebVC.swift
//  CricBuddy
//
//  Created by Vivek Shah on 26/03/24.
//

import UIKit
import WebKit

class WebVC: UIViewController, WKUIDelegate, WKNavigationDelegate, UINavigationControllerDelegate, WKScriptMessageHandler  {
    
    @IBOutlet weak var viewWebViewContainer: UIView!
    @IBOutlet weak var viewLoading: UIView!
    var webViewSite: WKWebView!
    var webViews: [WKWebView] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent // Light content for light status bar style on dark background
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
      if let messageBody = message.body as? [AnyHashable:Any]{
          debugPrint("messageBody ", messageBody)
      }
    }
    
    // MARK: View Controller Life Cycle
    override func loadView() {
        super.loadView()
        self.view.layoutIfNeeded()
        self.addWebView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugPrint("viewDidLoad WebView", String.timestamp())
        webViewSite.uiDelegate = self
        webViewSite.navigationDelegate = self
        setURL()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webViewSite.uiDelegate = nil
        webViewSite.navigationDelegate = nil
    }
    
    // MARK: Private Methods
    func addWebView() {
        let config = WKWebViewConfiguration()
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        let guide = view.safeAreaLayoutGuide
        let height = guide.layoutFrame.size.height
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.filter({ $0.isKeyWindow }).first {
            let topPadding = window.safeAreaInsets.top
            let bottomPadding = window.safeAreaInsets.bottom
            webViewSite = WKWebView(frame: CGRect.init(x: 0, y: 0, width: viewWebViewContainer.frame.width, height: height - topPadding - bottomPadding ), configuration: config)
        }
        self.viewWebViewContainer.addSubview(webViewSite)
        webViewSite.configuration.userContentController.add(self, name: "PaymentJSBridge")
    }
    
    func setURL() {
        if ReachablityManager.isReachable() {
            let baseURL = "https://rzp-fe.onrender.com/"
            let urlToLoad: URL = URL(string:baseURL)!
            let urlReq: URLRequest = URLRequest(url:urlToLoad)
            //            DispatchQueue.main.async {
            self.webViewSite?.load(urlReq)
            //            }
            webViewSite.allowsBackForwardNavigationGestures = true
            //            self.view.makeToast("\(urlStr)", duration: 10.0, position: .top)
        } else {
            let controller = UIAlertController(title: "No Internet Detected", message: "App requires an Internet connection", preferredStyle: .alert)
            let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
                self.setURL()
            })
            controller.addAction(retry)
            present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: WebView Delegate Methods for child view
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            if shouldOpenInBrowser(url) {
                debugPrint("should open in browser")
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return nil;
            }
        }
        if navigationAction.targetFrame == nil {
            let popupWebView = WKWebView(frame: .zero, configuration: configuration)
            popupWebView.navigationDelegate = self
            popupWebView.uiDelegate = self
            popupWebView.configuration.userContentController.add(self, name: "PaymentJSBridge")
            webViewSite.addSubview(popupWebView)
            popupWebView.translatesAutoresizingMaskIntoConstraints = false
            let heightConstraint = popupWebView.heightAnchor.constraint(equalTo: webViewSite.heightAnchor, multiplier: 0.7)
            heightConstraint.priority = .defaultHigh
            NSLayoutConstraint.activate([
                popupWebView.topAnchor.constraint(equalTo: webViewSite.topAnchor),
                heightConstraint,
                popupWebView.leadingAnchor.constraint(equalTo: webViewSite.leadingAnchor),
                popupWebView.trailingAnchor.constraint(equalTo: webViewSite.trailingAnchor)
            ])
            popupWebView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
            self.webViews.append(popupWebView)
            return popupWebView
        }
        return nil
    }
    func webViewDidClose(_ webView: WKWebView) {
        if (self.webViews.count > 0) {
            let indexLast = self.webViews.count - 1
            let webviewLast = self.webViews[indexLast]
            webviewLast.removeObserver(self, forKeyPath: "URL");
            webviewLast.removeFromSuperview()
            self.webViews.remove(at: indexLast);
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = change?[NSKeyValueChangeKey.newKey] {
            let urlString = "\(key)"
            if urlString.contains("api.razorpay") && urlString.contains("callback") {
                print("urlString \(urlString)")
                if urlString.contains("status=failed") || urlString.contains("status=authorized") {
//                    let indexLast = self.webViews.count - 1
//                    let webviewLast = self.webViews[indexLast]
//                    webviewLast.removeObserver(self, forKeyPath: "URL");
//                    webviewLast.removeFromSuperview()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                        self.webViews.remove(at: indexLast);
//                    }
                }
            }
        }
    }
    
    // MARK: WebView Delegate Methods
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil,preferredStyle: .alert);
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) {
            _ in completionHandler()}
        );
        self.present(alertController, animated: true, completion: {});
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Failed to load webpage: \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView,   prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust));
    }
    
    func webView(_: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
        if !ReachablityManager.isReachable() {
            //            self.view.makeToast("Please check your internet connection.", duration: 3.0, position: .top)
        }
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        debugPrint("didCommit", String.timestamp())
        viewLoading.isHidden = true
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint("didFinish", String.timestamp())
        //This function is called when the webview finishes navigating to the webpage.
        //We use this to send data to the webview when it's loaded.
        viewLoading.isHidden = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            // The link is intended to open in a new window/tab, Open the link in the system browser
            if let url = navigationAction.request.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        }
        if let url = navigationAction.request.url, navigationAction.navigationType == .linkActivated {
            // Check if the URL should be opened in the external browser
            if shouldOpenInBrowser(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func shouldOpenInBrowser(_ url: URL) -> Bool {
        let urlString = url.absoluteString;
        return urlString.contains("google.com") || urlString.contains("map")
    }
}
