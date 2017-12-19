
import UIKit

protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

protocol ChangeMusicDelegate {
    func didSetAudio(sourceType: Bool)
}

protocol spotifyDelegate {
    func initializaPlayer(authSession: SPTSession)
}

class ChangeCityViewController: UIViewController {
    
    var auth = SPTAuth.defaultInstance()!
    var session: SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
    
    var SpotStaus: Bool?

    let defaults:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeCityViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
        
        if let value = UserDefaults.standard.value(forKey: "segOnOff") {
            
            let selectedIndex = value as! Int
            segSwitch.selectedSegmentIndex = selectedIndex
            
        }
        
        if let spot = UserDefaults.standard.object(forKey: "loggedIn") as? Bool {
            SpotStaus = spot
        }
        
        if SpotStaus == true {
            self.spotifyLoginBtn.isHidden = true
        }
        
    }
    
    //MARK: - Delegates
    /***************************************************************/

    var delegate: ChangeCityDelegate?
    var musicChangeDelegate: ChangeMusicDelegate?
    var spotifyDelegate: spotifyDelegate?

    //MARK: - Change Location Outlets/Actions
    /***************************************************************/
    
    @IBOutlet weak var changeCityTextField: UITextField!
    
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredANewCityName(city: cityName)
        
        self.dismiss(animated: true, completion: nil)
    }
        
    //MARK: - Music Source Switch
    /***************************************************************/
    @IBOutlet weak var segSwitch: UISegmentedControl!
    
    @IBAction func segmentedValueChange(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            musicChangeDelegate?.didSetAudio(sourceType: true)
            print("true")
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "segOnOff")
        }
            
        else if sender.selectedSegmentIndex == 1 {
            musicChangeDelegate?.didSetAudio(sourceType: false)
            print("false")
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: "segOnOff")
        }
        
    }
        
    //MARK: - Back Button
    /***************************************************************/
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Spotify Login
    /***************************************************************/
        
    func setup () {
        let redirectURL = "Climate://returnAfterLogin"
        let clientID = "5f52d115f7254baeafb00380ddc51703"
        auth.redirectURL = URL(string: redirectURL)
        auth.clientID = "5f52d115f7254baeafb00380ddc51703"
        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = auth.spotifyWebAuthenticationURL()
        
    }
    
    func updateAfterFirstLogin () {
        
        spotifyLoginBtn.isHidden = true
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            self.spotifyLoginBtn.isHidden = true
            
            UserDefaults.standard.set(true, forKey: "loggedIn")
            
            spotifyDelegate?.initializaPlayer(authSession: session)
            // self.loadingLabel.isHidden = false
        }
        
    }
    
    @IBOutlet weak var spotifyLoginBtn: UIButton!
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if UIApplication.shared.openURL(loginUrl!) {
            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling
            }
        }
    }
   
}
