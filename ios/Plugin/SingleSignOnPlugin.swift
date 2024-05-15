import Foundation
import Capacitor
import SafariServices
import AuthenticationServices

typealias JSObject = [String:Any]
@objc(SingleSignOnPlugin)
public class SingleSignOnPlugin: CAPPlugin, ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.webView!.window!
    }
    
    private var session: ASWebAuthenticationSession?

    @objc func authenticate(_ call: CAPPluginCall) {
        guard let url = URL(string: call.getString("url") ?? "") else {
            call.reject("invalid url")
            return
        }
        
        guard let redirectUri = URL(string: call.getString("redirectUri") ?? ""),
              let host = redirectUri.host
              else {
            call.reject("invalid redirect uri")
            return
        }
        
        if #available(iOS 17.4, *) {
            let session = ASWebAuthenticationSession.init(url: url, callback: .https(host: host, path: redirectUri.path)) { url, error in
                if (error != nil) {
                    call.reject("")
                }
                else {
                    var response = JSObject()
                    response["url"] = url?.absoluteString
                    call.resolve(response)
                }
            }
            session.presentationContextProvider = self
            DispatchQueue.main.async {
                session.start()
            }
            self.session = session
        } else {
            // Fallback on earlier versions
            call.reject("Needs iOS >= 17.4")
        }
    }
}
