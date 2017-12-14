
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MediaPlayer
import AVFoundation
import SafariServices

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate, ChangeMusicDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate, spotifyDelegate {
    
    //MARK: - Weather Outlets/Values
    /***************************************************************/
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    var weatherType: Int?
    
    //MARK: - Date/Time Values
    /***************************************************************/
    
//    var hour: Int?
//    var minutes: Int?
//    var seconds: Int?
//    var day: Int?
//    var month: Int?
//    var year: Int?
//    var time = Timer()
    
    //MARK: - Local Music Values
    /***************************************************************/

    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    var currentPlaylist = ""
    var currentCity = ""
    var audioSource: Bool = true {
        didSet {
          musicSource()
        }
    }
    
    //var musicSource: MusicSourceType = .LocalMusic
    
    //MARK: - Spotify Values
    /***************************************************************/
    
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
    
//    time = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WeatherViewController.dateAndTime), userInfo: nil, repeats: true)
        
    var sliderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: Selector("updateSlider"), userInfo: nil, repeats: true)
        
    let myVolumeView = MPVolumeView(frame: mpVolumeViewParentView.bounds)
    mpVolumeViewParentView.backgroundColor = UIColor.clear
    mpVolumeViewParentView.addSubview(myVolumeView)
        
//    setup()
//    NotificationCenter.default.addObserver(self, selector: #selector(WeatherViewController.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
        
        
//    UIView.animate(withDuration: 12.0, delay: 1, options: ([.curveLinear, .repeat]), animations: {() -> Void in
//      self.nowPlaying.center = CGPoint(x: 0 - self.nowPlaying.bounds.size.width / 2, y: self.nowPlaying.center.y)
//    }, completion:  { _ in })

//    UIView.animate(withDuration: 12.0, delay: 1, options: ([.curveLinear, .repeat]), animations: {() -> Void in
//      self.spotifyLabel.center = CGPoint(x: 0 - self.spotifyLabel.bounds.size.width / 2, y: self.spotifyLabel.center.y)
//    }, completion:  { _ in })
        
    
//      Slider.maximumValue = Float((musicPlayer.nowPlayingItem?.playbackDuration)!)
        
    }

    //MARK: - Audio Slider
    /***************************************************************/
    
    @IBOutlet weak var Slider: UISlider!
    
    
    @IBAction func changeAudioTime(_ sender: Any) {
        musicPlayer.stop()
        musicPlayer.currentPlaybackTime = TimeInterval(Slider.value)
        musicPlayer.prepareToPlay()
        musicPlayer.play()
    }
    
    func updateSlider() {
        Slider.value = Float(musicPlayer.currentPlaybackTime)
        
    }
    
    //MARK: - Spotify Login / Initialize Player
    /***************************************************************/
    
//    func setup () {
//        let redirectURL = "Climate://returnAfterLogin"
//        let clientID = "5f52d115f7254baeafb00380ddc51703"
//        auth.redirectURL = URL(string: redirectURL)
//        auth.clientID = "5f52d115f7254baeafb00380ddc51703"
//        auth.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthPlaylistModifyPublicScope, SPTAuthPlaylistModifyPrivateScope]
//        loginUrl = auth.spotifyWebAuthenticationURL()
//        
//    }
    
//    func updateAfterFirstLogin () {
//
//        spotifyLoginBtn.isHidden = true
//        let userDefaults = UserDefaults.standard
//
//        if let sessionObj:AnyObject = userDefaults.object(forKey: "SpotifySession") as AnyObject? {
//
//            let sessionDataObj = sessionObj as! Data
//            let firstTimeSession = NSKeyedUnarchiver.unarchiveObject(with: sessionDataObj) as! SPTSession
//
//            self.session = firstTimeSession
//            initializaPlayer(authSession: session)
//            self.spotifyLoginBtn.isHidden = true
//            // self.loadingLabel.isHidden = false
//          }
//        
//        }
    
    func initializaPlayer(authSession:SPTSession){
        if player == nil {
            
            player = SPTAudioStreamingController.sharedInstance()
            player!.playbackDelegate = self
            player!.delegate = self
            try! player!.start(withClientId: auth.clientID)
            player!.login(withAccessToken: authSession.accessToken)
            
        }
        
    }
    
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {

        audioStreaming.playSpotifyURI("", startingWith: 0, startingWithPosition: 0, callback: { error in
            if (error == nil) {
                print("playing!")
            }
        
        })
   
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("isPlaying: \(isPlaying)")
        if (isPlaying) {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try! AVAudioSession.sharedInstance().setActive(true)
        } else {
            try! AVAudioSession.sharedInstance().setActive(false)
        }
        
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        print("Spotify Meta Data Changed")
        
        DispatchQueue.main.async() {
        
        if let artistName = audioStreaming.metadata.currentTrack?.artistName, let trackName = audioStreaming.metadata.currentTrack?.name {
            
            self.spotifyLabel.text = (" Artist: ") + (artistName) + (" Track: ") + (trackName)
    
            self.view.setNeedsDisplay()
            self.nowPlaying.setNeedsDisplay()
            
            print(trackName)
            
        }
            
        if let art = audioStreaming.metadata.currentTrack?.albumCoverArtURL {
            
            let url = URL(string: art)
            let data = try? Data(contentsOf: url!)
            let image: UIImage = UIImage(data: data!)!
            
            self.albumArtwork.image = image
            
            self.view.setNeedsDisplay()
            self.nowPlaying.setNeedsDisplay()
            
        }
      }
    }

//    @IBOutlet weak var spotifyLoginBtn: UIButton!
//    
//    @IBAction func loginBtnPressed(_ sender: Any) {
//        if UIApplication.shared.openURL(loginUrl!) {
//            if auth.canHandle(auth.redirectURL) {
//                // To do - build in error handling
//            }
//        }
//    }
    
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
        musicSource()
    }
    
    //MARK: - Date/Time
    /***************************************************************/
    
    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
    
    func dateAndTime() {
    let date =  DateFormatter()
    date.dateStyle = .full
    dateLabel.text = date.string(from: Date())
        
//    let time = DateFormatter()
//    time.timeStyle = .medium
//    timeLabel.text = time.string(from: Date())
////////////////////////////////////////////////

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
                print("Alamofire Weather Data Success!!")
                
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
    
    //MARK: - Weather JSON Parsing
    /***************************************************************/

    func updateWeatherData (json: JSON) {
        
        if let tempResult = json["main"]["temp"].double {
        
        weatherDataModel.temperature = Int(1.8 * Double(tempResult - 273)) + 32
        weatherDataModel.city = json["name"].stringValue
        currentCity = json["name"].stringValue
        weatherDataModel.condition = 800//json["weather"][0]["id"].intValue
        weatherType = weatherDataModel.condition
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
         
        print("\nThis weather data is for \(weatherDataModel.city).")

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
          print("Playing Local Music")
        }
        else if audioSource == false {
          musicPlayer.stop()
          spotifyStart(weather: weatherType!)
          print("Playing Spotify")
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
            spotifyLabel.text = ""
            playMusic(playlist: self.currentPlaylist)
            
        case 800, 904 :
            currentPlaylist = "Sunny"
            spotifyLabel.text = ""
            playMusic(playlist: self.currentPlaylist)
        
        case 601...700, 903 :
            currentPlaylist = "Snowy"
            spotifyLabel.text = ""
            playMusic(playlist: self.currentPlaylist)
        
        case 701...771, 801...804 :
            currentPlaylist = "Cloudy"
            spotifyLabel.text = ""
            playMusic(playlist: self.currentPlaylist)
            
        default :
            print("Local Music Fail")
            
        }
    }
    
    //MARK: - Spotify Methods
    /***************************************************************/
    
    func spotifyStart(weather: Int) {
        
        switch (weather) {
            
            case 0...600, 772...799, 900...903, 905...1000 :
                currentPlaylist = "Rainy"
                nowPlaying.text = ""
                player?.playSpotifyURI("spotify:user:1220300788:playlist:1R6PqPgAke0uFdgg5MAPjV", startingWith: 0, startingWithPosition: 0, callback: { error in
                    if (error == nil) {
                        print("playing Spotify!")
                    }
                })
            
            case 800, 904 :
                currentPlaylist = "Sunny"
                nowPlaying.text = ""
                player?.playSpotifyURI("spotify:user:1220300788:playlist:1Mty4xNtNK7EtLOzML2EKz", startingWith: 0, startingWithPosition: 0, callback: { error in
                    if (error == nil) {
                        print("playing Spotify!")
                    }
                })
                
            case 601...700, 903 :
                currentPlaylist = "Snowy"
                nowPlaying.text = ""
                player?.playSpotifyURI("spotify:user:1220300788:playlist:50uDcKIQn7rIV9tPr4UvlJ", startingWith: 0, startingWithPosition: 0, callback: { error in
                    if (error == nil) {
                        print("playing Spotify!")
                    }
                })
                
            case 701...771, 801...804 :
                currentPlaylist = "Cloudy"
                nowPlaying.text = ""
                player?.playSpotifyURI("spotify:user:1220300788:playlist:6p52ug2zJ1MQgYqcaQJ7oX", startingWith: 0, startingWithPosition: 0, callback: { error in
                    if (error == nil) {
                        print("playing Spotify!")
                    }
                })
                
            default :
                print("Spotify Fail")
                
            }
    
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
            
            destinationVC.spotifyDelegate = self
        
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
            player?.setIsPlaying(true, callback: { error in
                if (error == nil) {
                error?.localizedDescription
                }
                
                })
            print("Spotify")
        }
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        musicPlayer.stop()
        if audioSource == true {
            print("Local Music")
            musicPlayer.stop()
        }
        else {
            player?.setIsPlaying(false, callback: { error in
                if (error == nil) {
                    error?.localizedDescription
                }
            })
            print("Spotify")
        }
        
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        
        if audioSource == true {
            print("Local Music")
            musicPlayer.skipToNextItem()
        }
        else {
            player?.skipNext({ (error) in
                if error != nil {
                    error?.localizedDescription
                }
            })
            print("Spotify")
        }
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        
        if audioSource == true {
            print("Local Music")
            musicPlayer.skipToPreviousItem()
        }
        else {
            player?.skipPrevious({ (error) in
                if error != nil {
                    error?.localizedDescription
                }
            })
            print("Spotify")
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
        
        let currentItem = self.musicPlayer.nowPlayingItem;
        nowPlaying.text = currentItem?.value(forProperty: MPMediaItemPropertyArtist) as? String
        
        let size = CGSize(width: 100, height: 100)
        albumArtwork.image = currentItem?.artwork?.image(at: size)
        print(nowPlaying.text!)

    }
    
    func didSetAudio(sourceType: Bool) {
        self.audioSource = sourceType
    }
    
    @IBOutlet weak var mpVolumeViewParentView: UIView!
    
    @IBOutlet weak var nowPlaying: UILabel!
    
    @IBOutlet weak var spotifyLabel: UILabel!

    @IBOutlet weak var albumArtwork: UIImageView!
    
}




