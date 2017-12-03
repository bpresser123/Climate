
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MediaPlayer


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate, ChangeMusicDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate {
    
    //MARK: - Weather Outlets/Values
    /***************************************************************/
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    //MARK: - Date/Time Values
    /***************************************************************/
    
    var hour: Int?
    var minutes: Int?
    var seconds: Int?
    var day: Int?
    var month: Int?
    var year: Int?
    var time = Timer()
    var sliderTime = Timer()
    
    //MARK: - Local Music Values
    /***************************************************************/
    
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    var currentPlaylist = ""
    var currentCity = ""
    var weatherType: Int?
    var audioSource: Bool = true {
        didSet {
          musicSource()
        }
    }
    
    //var musicSource: MusicSourceType = .LocalMusic
    
    //MARK: - Spotify Values
    /***************************************************************/
    
    var spotifyURL = "https://api.spotify.com/v1/users/bp123/playlists?offset=10"
    let spotifyKey = "BQDyQlU7-kTGxXjUoUlEpnkBiGjwWjWLsjNSX-td4kcLxPBwYQTbWA8jeNVab_pW8w46XmW7tTZRfylDiQW6jK1_ObM9Z3sSTHCJn7Kz2t2fG8YULBvZt9nH_NkDmjY9NR0s_TuiMtRwt7tfgWcjFu5D3IdUPmuV0yDCL3C4UgmB__W7AGpkVjvJCW0t39wmqS9qvU7-B5RNcm3c4x3lKfD1qnaEXhvvfrSVGX7fGylC0VZq7-lA"
    
    typealias JSONStandard = [String : AnyObject]
    var names = [String]()
    
    var auth = SPTAuth.defaultInstance()!
    var session:SPTSession!
    var player: SPTAudioStreamingController?
    var loginUrl: URL?
 
    //MARK: - viewDidLoad
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    time = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WeatherViewController.dateAndTime), userInfo: nil, repeats: true)
        
    sliderTime = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(WeatherViewController.updateSlider), userInfo: nil, repeats: true)

    UIApplication.shared.beginReceivingRemoteControlEvents()
        
    let myVolumeView = MPVolumeView(frame: mpVolumeViewParentView.bounds)
    mpVolumeViewParentView.backgroundColor = UIColor.clear
    mpVolumeViewParentView.addSubview(myVolumeView)
        
    setup()
    NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
    
    //slider.maximumValue = Float(musicPlayer.duration)
    //callAlamoSpotify(url: spotifyURL)
    }
    
    //MARK: - Spotify Login
    /***************************************************************/
    
    func updateAfterFirstLogin () {
        
        spotifyLoginBtn.isHidden = true
        let userDefaults = UserDefaults.standard
        
        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
            
            let sessionDataObj = sessionObj as! Data
            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
            
            self.session = firstTimeSession
            initializaPlayer(authSession: session)
            self.spotifyLoginBtn.isHidden = true
            // self.loadingLabel.isHidden = false
          }
        
        }
    
    func initializaPlayer(authSession:SPTSession){
        if self.player == nil {
            
            self.player = SPTAudioStreamingController.sharedInstance()
            self.player!.playbackDelegate = self as SPTAudioStreamingPlaybackDelegate
            self.player!.delegate = self as SPTAudioStreamingDelegate
            try! player?.start(withClientId: auth.clientID)
            self.player!.login(withAccessToken: authSession.accessToken)
            
        }
        
    }
    
    func setup() {
        SPTAuth.defaultInstance().clientID = "5f52d115f7254baeafb00380ddc51703"
        SPTAuth.defaultInstance().redirectURL = URL(string: "Climate://returnAfterLogin")
        SPTAuth.defaultInstance().requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
        loginUrl = SPTAuth.defaultInstance().spotifyAppAuthenticationURL()
        
    }
        
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        // after a user authenticates a session, the SPTAudioStreamingController is then initialized and this method called
        print("logged in")
        self.player?.playSpotifyURI("spotify:track:7Cg3F9ZsZ2TYUnlza49NYh", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if (error != nil) {
                print("playing!")
            }
        })
    }

    @IBOutlet weak var spotifyLoginBtn: UIButton!
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        if UIApplication.shared.openURL(loginUrl!) {
            if auth.canHandle(auth.redirectURL) {
                // To do - build in error handling
            }
        }
    }
    
    
    //MARK: - Privacy/Preferences
    /***************************************************************/
    
//        func Auth(pass: Int) {
//    
//            if #available(iOS 9.3, *) {
//                MPMediaLibrary.requestAuthorization { (status) in
//    
//                if status == .authorized {
//                    self.musicSource()
//                }
//    
//                else {
//                    self.musicPlayer.stop()
//                }
//              }
//    
//          }
//        }

    
    //MARK: - Refresh Weather
    /***************************************************************/
    
    @IBAction func refreshWeather(_ sender: UIButton) {
        viewDidLoad()
    }
    
    //MARK: - Date/Time
    /***************************************************************/
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func dateAndTime() {
        
    let time = DateFormatter()
    let date =  DateFormatter()
    
    time.timeStyle = .medium
    date.dateStyle = .full
        
    timeLabel.text = time.string(from: Date())
    dateLabel.text = date.string(from: Date())
        
//    let dateTwo = Date()
//    let calendar = Calendar.current
        
//    hour = calendar.component(.hour, from: date)
//    minutes = calendar.component(.minute, from: date)
//    seconds = calendar.component(.second, from: date)
//  
//    day = calendar.component(.day, from: date)
//    month = calendar.component(.month, from: date)
//    year = calendar.component(.year, from: date)
//        
//      let formatter = DateFormatter()
//      formatter.dateStyle = .full
//      formatter.timeStyle = .full
        
//    print("\nTime: \(hour ?? 0):\(minutes ?? 0)\n")
//    print("Date: \(month ?? 0)/\(day ?? 0)/\(year ?? 0)\n")
        
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            //print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            print(params)
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    func getWeatherData (url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            
            response in
            if response.result.isSuccess {
                print("Success!!")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connections Issues"
            }
        }
        
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/

    func updateWeatherData (json: JSON) {
        
        if let tempResult = json["main"]["temp"].double {
        
        weatherDataModel.temperature = Int(1.8 * Double(tempResult - 273)) + 32
        weatherDataModel.city = json["name"].stringValue
        currentCity = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherType = weatherDataModel.condition
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
         
        print("\nThis weather data is for \(weatherDataModel.city).")
        //  musicType(weather: weatherType!)
        dateAndTime()
        musicSource()
     
        }
        else {
          cityLabel.text = "Weather Unavaiable"
        }
    }
    
    //MARK: - Music Source
    /***************************************************************/
    
    func musicSource() {
        if audioSource == true {
          localMusic(weather: weatherType!)
        }
        else {
          musicPlayer.stop()
          print("Spotify is unavailable..")
        }
    }
    
    //    enum MusicSourceType {
    //
    //        switch source {
    //
    //        case LocalMusic :
    //          self.setAudio = true
    //
    //        case Spotify :
    //          self.setAudio = false
    //
    //        }
    //    }
    
    //MARK: - Local Music Methods
    /***************************************************************/
    
    func localMusic(weather: Int) {
        
        switch (weather) {
        
        case 0...600, 772...799, 900...903, 905...1000 :
            currentPlaylist = "Rainy"
            playMusic(playlist: self.currentPlaylist)
            
        case 800, 904 :
            currentPlaylist = "Sunny"
            playMusic(playlist: self.currentPlaylist)
        
        case 601...700, 903 :
            currentPlaylist = "Snowy"
            playMusic(playlist: self.currentPlaylist)
        
        case 701...771, 801...804 :
            currentPlaylist = "Cloudy"
            playMusic(playlist: self.currentPlaylist)
            
        default :
            print("musicType fail")
            
        }
    }
    
    //MARK: - Spotify Methods
    /***************************************************************/
        
        func spotify(weather: Int) {
    
          //callAlamoSpotify(url: SpotifyURL)
        }

        func callAlamoSpotify(url: String) {
            
            Alamofire.request(url, method: .get, parameters: nil, headers: ["Authorization": "BQDiJBlf9dmU0n5nwmizx0AJ0JR_q-yFJQw7HjUc12kFBlGDJt1sOqNh6vrZ7BJfo2gzCgqghJgZa8KYqXxjNfFH3mdsbRer3_NzAKMHOI4QEHPHBQakOjWkbJ3wz9kt1hKUe1UjTZH6tDazb23-cYCS"]).response { (response) in
               self.parseSpotifyData(JSONData: response.data!)
            }
//            Alamofire.request(url).responseJSON(completionHandler: {
//                response in
//    
//                self.parseSpotifyData(JSONData: response.data!)
//            })
    
        }
    
        func parseSpotifyData(JSONData : Data) {
    
          do {
            let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
//            if let playlists = readableJSON["playlists"] as? JSONStandard {
//                
//              if let items = playlists["items"] as? Array {
//                for i in 0..< items.count {
//                    
//                  let item = items[i] as! JSONStandard
//    
//                  let name = item["name"] as! String
//    
//                  names.append(name)
//    
//                }
//              }
//            }
    
          print(readableJSON as Any)
    
          }
          catch {
            print(error)
          }
        }
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return names.count
        }
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func userEnteredANewCityName(city: String) {
        print(city)
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            destinationVC.musicChangeDelegate = self
        }
    }
    
    //MARK: - Music Controls
    /***************************************************************/
    
    @IBAction func playButton(_ sender: UIButton){
        
        musicPlayer.stop()
        if audioSource == true {
            print("Local Music")
            self.playMusic(playlist: self.currentPlaylist)
        }
        else {
            print("Spotify is unavailable..")
        }
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        musicPlayer.stop()
        if audioSource == true {
            print("Local Music")
            musicPlayer.stop()
        }
        else {
            print("Spotify is unavailable..")
        }
        
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        
        if audioSource == true {
            print("Local Music")
            musicPlayer.skipToNextItem()
        }
        else {
            print("Spotify is unavailable..")
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        
        if audioSource == true {
            print("Local Music")
            musicPlayer.skipToPreviousItem()
        }
        else {
            print("Spotify is unavailable..")
        }
        
    }
    
    func playMusic(playlist: String) {
        musicPlayer.stop()
        
        let query = MPMediaQuery()
        let predicate = MPMediaPropertyPredicate(value: playlist, forProperty: MPMediaPlaylistPropertyName)
        
        query.addFilterPredicate(predicate)
        
        musicPlayer.setQueue(with: query)
        musicPlayer.shuffleMode = .songs
    
        musicPlayer.play()
        //nowPlaying.text = String(describing: self.musicPlayer.nowPlayingItem)
        print(nowPlaying.text!)
        
    }
    
    
    @IBOutlet weak var slider: UISlider!
    
    @IBAction func songTimeSlider(_ sender: Any) {
        
        musicPlayer.stop()
        musicPlayer.currentPlaybackTime = TimeInterval(slider.value)
        musicPlayer.prepareToPlay()
        musicPlayer.play()
        
    }
    
    func updateSlider() {
      slider.value = Float(musicPlayer.currentPlaybackTime)
    }
   
    @IBOutlet weak var mpVolumeViewParentView: UIView!
    
    @IBOutlet weak var nowPlaying: UILabel!
    
    func didSetAudio(sourceType: Bool) {
        self.audioSource = sourceType
    }
    
}




