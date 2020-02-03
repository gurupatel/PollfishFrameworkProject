//
//  PollfishWebView.swift
//  SampleProjectSwift
//
//  Created by Gaurang Patel on 01/02/20.
//  Copyright © 2020 Pollfish. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import AdSupport

public protocol PollfishWebViewDelegate {
    
    /* Delegate for Init */
    func panelOpened()
    func panelClosed(param1: String, param2: String, param3: String)

    /* Delegates for WebView */
    func webViewFinishLoadingSuccessfully()
    func webViewFinishLoadingFailed()
}

public class PollfishWebView: UIView, WKNavigationDelegate {

    public var delegate: PollfishWebViewDelegate?

    enum Direction: Int {
        case FromLeft = 0
        case FromRight = 1
    }

    @IBInspectable var direction : Int = 1
    @IBInspectable var delay :Double = 0.5
    @IBInspectable var duration :Double = 1.0

    public var lastOrientation:UIDeviceOrientation!
    public var indicator: UIActivityIndicatorView!
    public var contentView: UIView!
    public var webView: WKWebView!
    public var linkStr: String = ""
    public var param1: String = ""
    public var param2: String = ""
    public var param3: String = "PARAM 3"
    public var param4: String = "PARAM 4"
    public var param5: String = "PARAM 5"
                
    // MARK: - Initializing
    override public init(frame: CGRect) {
         super.init(frame: frame)
                        
        pollfishInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - pollfishInit
    public func pollfishInit() {
                 
        lastOrientation = UIDevice.current.orientation
        
        if Reachability.isConnectedToNetwork() {
            //print("Internet Connection Available!")
            
            /* Yes, you are connected, do your stuffs */

            /* Adding content view */
            self.addContentView()

            /* Adding animation to view */
            self.layoutSubviews()

            /* Adding web view */
            self.addWebView()
            
            /* Adding close button */
            self.addCloseButton()
            
            /* Adding advertising id label */
            self.addIDFALabel()
            
            /* Adding top param label */
            self.addTopParamLabel()

            /* Adding bottom param label */
            self.addBottomParamLabel()

            /* Panel opened callback */
            delegate?.panelOpened()

        } else {
            //print("Internet Connection not Available!")
            
            /* NO Internet, Check connection first */
            
            let alertController = UIAlertController(title: "Oops!", message: "Looks like your internet connection is down. Kindly check if you have a stable internet connection.", preferredStyle: .alert)
             
            let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) -> Void in
                 // Do something based on the user tapping this action button
             
                 // Notice that we get an instance of the UIAlertAction that was tapped if we need it
             })
             
             alertController.addAction(OKAction)
            
            Helper.getTopViewController()?.present(alertController, animated: true, completion: nil)
        }
        
        /* Notifier for device orientation */
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification,
                                               object: nil,
                                               queue: nil,
                                               using:rotateApp)
    }

    // MARK: - Add Content View
    public func addContentView() {

        /* Contect view in which all subViews are adding */
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        contentView.autoresizingMask = []
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.alpha = 0.0
        contentView.backgroundColor = .clear
        self.addSubview(contentView)
        
        /* Adding gray layer on content view */
        let grayLayer = UIView(frame: contentView.frame)
        grayLayer.alpha = 0.3
        grayLayer.backgroundColor = .black
        contentView.addSubview(grayLayer)
    }
    
    // MARK: - addCloseButton
    public func addCloseButton() {

        let closeButton = UIButton()
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.darkGray, for: .normal)
        closeButton.frame = CGRect(x: 0, y: 30, width: 50, height: 50)
        closeButton.backgroundColor = .clear
        closeButton.addTarget(self, action: #selector(self.closeBtnClicked), for: .touchUpInside)
        self.contentView.addSubview(closeButton)
    }
    
    // MARK: - IB Actions
    @objc public func closeBtnClicked(_ sender: Any) {

        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {

            /* Panel Closed callback */
            self.delegate?.panelClosed(param1: self.param3, param2: self.param4, param3: self.param5)

            self.initialSetup()
        })
    }

    // MARK: - addWebView
    public func addWebView() {
                    
        /* Removing black spaces from the link, if any */
        let urlNew:String = linkStr.replacingOccurrences(of: " ", with: "%20")
        
        let url = NSURL (string: urlNew)

        if (url != nil) {

            let request = URLRequest(url: url! as URL)

            /* Create our preferences on how the web page should be loaded */
            let preferences = WKPreferences()
            preferences.javaScriptEnabled = true
            
            /* Create a configuration for our preferences */
            let configuration = WKWebViewConfiguration()
            configuration.preferences = preferences
            
            /* Now instantiate the web view */
            webView = WKWebView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), configuration: configuration)
            
            let currentOrientation = UIDevice.current.orientation

            if currentOrientation.isLandscape { //Landscape orientations
            
                webView.frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            }

            webView.frame.size.height = webView.frame.size.height
            webView.navigationDelegate = self
            webView.load(request)
            contentView.addSubview(webView)
        }
        
        /* Adding loader */
        self.addIndicator()
    }
    
    // MARK: - addIndicator
    public func addIndicator() {
    
        /* Adding UIActivityIndicatorView to view */
        indicator = Helper.createUIActivityIndicatorView()
        indicator.center = webView.center

        webView.addSubview(indicator)
        webView.bringSubviewToFront(indicator)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        indicator.startAnimating()
    }
    
    // MARK: - removeIndicator
    public func removeIndicator() {

        indicator.stopAnimating()
    }
    
    // MARK: - addTopParamLabel
    public func addTopParamLabel() {
        
        /* Adding UILable to show Advertising ID on center of the view */
        let lblTopParam = Helper.createUILabel(frame: CGRect (x: 0, y: 40, width: contentView.frame.size.width, height: 20), font: .boldSystemFont(ofSize: 18), bgColor: .clear, txtColor: .orange)
        lblTopParam.text = param1
        lblTopParam.textAlignment = .center
        contentView.addSubview(lblTopParam)
    }

    // MARK: - addBottomParamLabel
    public func addBottomParamLabel() {
        
        /* Adding UILable to show Advertising ID on center of the view */
        let lblBottomParam = Helper.createUILabel(frame: CGRect (x: 0, y: UIScreen.main.bounds.size.height - 40, width: contentView.frame.size.width, height: 20), font: .boldSystemFont(ofSize: 18), bgColor: .clear, txtColor: .orange)
        lblBottomParam.text = param2
        lblBottomParam.textAlignment = .center
        contentView.addSubview(lblBottomParam)
    }

    // MARK: - addIDFALabel
    public func addIDFALabel() {
        
        /* Adding UILable to show Advertising ID on center of the view */
        let lblIDFA = Helper.createUILabel(frame: CGRect (x: 0, y: 0, width: contentView.frame.size.width, height: 20), font: .boldSystemFont(ofSize: 16), bgColor: .clear, txtColor: .orange)
        lblIDFA.center = contentView.center
        lblIDFA.text = self.identifierForAdvertising()
        lblIDFA.textAlignment = .center
        contentView.addSubview(lblIDFA)
    }
    
    // MARK: - Get identifierForAdvertising
    public func identifierForAdvertising() -> String? {
        // Check whether advertising tracking is enabled
        guard ASIdentifierManager.shared().isAdvertisingTrackingEnabled else {
            return nil
        }

        // Get and return IDFA
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }

    // MARK: - WebView delegate methods
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation) {
        
        //print("Finished navigating to url \(String(describing: webView.url))")
        
        /* Webview finish loading callback */
        delegate?.webViewFinishLoadingSuccessfully()
        
        /* Removing loader */
        self.removeIndicator()
    }
    
    public func webView(_ webView: WKWebView, didFailNavigation navigation: WKNavigation) {
        
        /* Webview failed loading callback */
        delegate?.webViewFinishLoadingFailed()

        /* Removing loader */
        self.removeIndicator()
    }
    
    // MARK: - Animation
    override public func layoutSubviews() {
        
        self.initialSetup()
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {
            if let superview = self.contentView {
                           if self.direction == Direction.FromLeft.rawValue {
                            self.contentView.frame.origin.x += superview.bounds.width
                           } else {
                            self.contentView.frame.origin.x -= superview.bounds.width
                           }
                
                self.contentView.alpha = 1.0

                       }
        })
    }
    
    public func initialSetup() {
        if let superview = self.contentView {
            if direction == Direction.FromLeft.rawValue {
             self.contentView.frame.origin.x -= superview.bounds.width
            } else {
                self.contentView.frame.origin.x += superview.bounds.width
            }
        }
    }
    
    // MARK: - Device Orientation methods
    
    public func rotateApp(_ notification:Notification) {

        let currentOrientation = UIDevice.current.orientation
        
        guard currentOrientation.isLandscape || currentOrientation.isPortrait else {   // we are only interested in Portrait and Landscape orientations
            return
        }

        guard currentOrientation != lastOrientation else { //remember the case of Portrait-FaceUp-Portrait? Here we make sure that in such cases we don't reload table view
            return
        }

        lastOrientation = currentOrientation
        
        if (contentView != nil) {
        
            for v in self.subviews {
        
                v.removeFromSuperview()
            }
        
            /* Panel Initialized */
            self.pollfishInit()
        }
    }
}
