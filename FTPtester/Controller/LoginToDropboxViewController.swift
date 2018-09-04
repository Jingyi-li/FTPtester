//
//  LoginToDropboxViewController.swift
//  FTPtester
//
//  Created by Jingyi LI on 3/9/18.
//  Copyright © 2018 Jingyi LI. All rights reserved.
//

import UIKit
import OAuthSwift
import FilesProvider
import SwiftyJSON

class LoginToDropboxViewController: UIViewController {
    
    
    var oauthswift: OAuthSwift?
    var dropboxFilesProvider: DropboxFileProvider?

//    @IBOutlet weak var view: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        doOAuthDropbox()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //    dropbox APP Key :doOAuthDropbox APP secret:2ks03t1tsvnkhys
    
    
    @IBAction func backToMainboardButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func auth(_ sender: Any) {
        doOAuthDropbox()
    }
    
    //    dropbox APP Key :m2vun8jkvk85shq APP secret:2ks03t1tsvnkhys
    func doOAuthDropbox(){
        
        let oauthswift = OAuth2Swift(consumerKey: "m2vun8jkvk85shq",
                                     consumerSecret: "2ks03t1tsvnkhys",
                                     authorizeUrl: "https://www.dropbox.com/oauth2/authorize",
                                     accessTokenUrl: "https://api.dropbox.com/1/oauth2/token",
                                     responseType: "token")
        
        self.oauthswift = oauthswift
        
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        

        let _ = oauthswift.authorize(withCallbackURL: URL(string: "FTPtester://oauth-callback/dropbox")!,
//        let _ = oauthswift.authorize(withCallbackURL: nil,
                            scope: "", state:"",
                            success: { credential, response, parameters in
//                                let urlcredential = URLCredential(user: user ?? "anonymous", password: credential.oauthToken, persistence: .permanent)
                                print(credential.oauthToken)
//                                print(parameters[account_id])
                                // TODO: Save credential in keychain
                                // TODO: Create Dropbox provider using urlcredential
        }, failure: { error in
            print(error.localizedDescription)
        }
        )
        
    }
    
    
    
    
//
//    oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauth)
//    _ = oauth.authorize(withCallbackURL: URL(string: "\(appScheme)://oauth-callback/dropbox")!,
//    scope: "", state:"DROPBOX",
//    success: { credential, response, parameters in
//    let urlcredential = URLCredential(user: user ?? "anonymous", password: credential.oauthToken, persistence: .permanent)
//    // TODO: Save credential in keychain
//    // TODO: Create Dropbox provider using urlcredential
//    }, failure: { error in
//    print(error.localizedDescription)
//    }
//    )
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
