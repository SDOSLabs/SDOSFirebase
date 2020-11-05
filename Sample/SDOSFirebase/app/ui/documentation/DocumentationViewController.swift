//
//  DocumentationViewController.swift
//
//  Copyright © 2019 SDOS. All rights reserved.
//

import UIKit
import WebKit
import SDOSFirebase

class DocumentationViewController: VIPERBaseViewController {
    
    static let GO_BACK_BUTTON_TITLE = "<"
    static let GO_FORWARD_BUTTON_TITLE = ">"
    
    @IBOutlet var viewForWebView: UIView!
    @IBOutlet var lbVersion: UILabel!
    @IBOutlet var btnGoBack: UIButton!
    @IBOutlet var btnGoForward: UIButton!
    
    lazy var webView: WKWebView = {
        var webView = WKWebView.init(frame: self.viewForWebView.bounds)
        addSubviewWithAlignedBorders(subView: webView, to: viewForWebView)
        webView.navigationDelegate = self
        if let url = URL.init(string: Cosntants.URL.documentation) {
            webView.load(URLRequest.init(url: url))
        }
        return webView
    }()
    
    var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView.init(style: .gray)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    lazy var barBtnSpinner: UIBarButtonItem = {
        let result = UIBarButtonItem.init(customView: self.spinner)
        return result
    }()
    
    lazy var barBtnReload: UIBarButtonItem = {
        var barBtnReload = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.refresh, target: self, action: #selector(reloadPage(sender:)))
        return barBtnReload
    }()

    override func firebaseScreenName() -> String? {
        return "Nueva pantalla"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadContent()
        updateBackForwardButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addSubviewWithAlignedBorders(subView: UIView, to parent: UIView) {
        parent .addSubview(subView)
        subView.translatesAutoresizingMaskIntoConstraints = false
        
        let top = NSLayoutConstraint.init(item: subView, attribute: .top, relatedBy: .equal, toItem: parent, attribute: .top, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint.init(item: subView, attribute: .trailing, relatedBy: .equal, toItem: parent, attribute: .trailing, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint.init(item: subView, attribute: .leading, relatedBy: .equal, toItem: parent, attribute: .leading, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint.init(item: subView, attribute: .bottom, relatedBy: .equal, toItem: parent, attribute: .bottom, multiplier: 1, constant: 0)
        
        parent.addConstraint(top)
        parent.addConstraint(trailing)
        parent.addConstraint(leading)
        parent.addConstraint(bottom)
        
    }
    
    func loadContent() {
        if let title = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            self.title = title
        }
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            self.lbVersion.text = "Versión \(version)"
        }
        
        btnGoBack.setTitle(DocumentationViewController.GO_BACK_BUTTON_TITLE, for: .normal)
        btnGoForward.setTitle(DocumentationViewController.GO_FORWARD_BUTTON_TITLE, for: .normal)
    }
    
    func loadInitialURL() {
        if let url = URL.init(string: Cosntants.URL.documentation) {
            webView.load(URLRequest.init(url: url))
        }
    }
    
    func updateBackForwardButtons() {
        btnGoBack.isEnabled = webView.canGoBack
        btnGoForward.isEnabled = webView.canGoForward
    }
    
    func loadActivityIndicatorForWebView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: spinner)
    }
    
    func didStartLoadingWebsite() {
        if navigationItem.rightBarButtonItem === barBtnSpinner {
           navigationItem.setRightBarButton(barBtnSpinner, animated: true)
            spinner.startAnimating()
        }
    }
    
    func didFinishLoadingWebsite() {
        spinner.stopAnimating()
        navigationItem.setRightBarButton(barBtnReload, animated: true)
    }

    @objc func reloadPage(sender: UIBarButtonItem) {
        loadInitialURL()
    }
    
    @IBAction func actionShowExample() {
        
    }
}

extension DocumentationViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        didStartLoadingWebsite()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        didStartLoadingWebsite()
        updateBackForwardButtons()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinishLoadingWebsite()
    }
    
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        updateBackForwardButtons()
    }
}
