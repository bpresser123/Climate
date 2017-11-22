
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MediaPlayer


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate, ChangeMusicDelegate {
    
    
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    var currentPlaylist = ""
    var currentCity = ""
    var weatherType: Int?
    //var localAudio = true
    var audioSource: Bool?
    
    //var musicSource: MusicSourceType = .LocalMusic
    
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    @IBOutlet weak var nowPlaying: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
        
    }
    
//    func setAudioType() {
//      setAudio
//    }
    
    //MARK: - Privacy
    /***************************************************************/
    
    //    func Auth(pass: Int) {
    //
    //        if #available(iOS 9.3, *) {
    //            MPMediaLibrary.requestAuthorization { (status) in
    //
    //            if status == .authorized {
    //
    //                musicType(weather: pass)
    //            }
    //
    //            else {
    //                  // Fallback on earlier versions
    //            }
    //            
    //        }
    //    }
    
    //MARK: - Play Music
    /***************************************************************/
    
    @IBAction func playButton(_ sender: UIButton){
        self.playMusic(playlist: self.currentPlaylist)
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        musicPlayer.stop()
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        
        if audioSource == true {
        print("Local")
        musicPlayer.skipToPreviousItem()
        }
        else {
        print("No Spotify yet..")
        musicPlayer.skipToPreviousItem()
        }

    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        musicPlayer.skipToNextItem()
    }
    
    func playMusic(playlist: String) {
        musicPlayer.stop()
        
        let query = MPMediaQuery()
        let predicate = MPMediaPropertyPredicate(value: playlist, forProperty: MPMediaPlaylistPropertyName)
        
        query.addFilterPredicate(predicate)
        
        musicPlayer.setQueue(with: query)
        musicPlayer.shuffleMode = .songs
//        let currentSong = MPMediaItemPropertyTitle
//        nowPlaying.text = currentSong
        musicPlayer.play()
        
    }
    
    
    @IBAction func refreshWeather(_ sender: UIButton) {
        viewDidLoad()
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
        weatherDataModel.condition = 800 //json["weather"][0]["id"].intValue
        weatherType = weatherDataModel.condition
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
            
        print("This is for \(weatherDataModel.city).")
        
        //musicType(weather: weatherType!)
        
        musicSource()
     
        }
        else {
          cityLabel.text = "Weather Unavaiable"
        }
    }
    
    func musicSource() {
        if audioSource == true {
          localMusic(weather: weatherType!)
        }
        else {
            print("No Spotify yet..")
        }
    }
    
    //MARK: - Music Type
    /***************************************************************/
    
    func localMusic(weather: Int) {
        
        switch (weather) {
        
        case 0...300 :
            currentPlaylist = "Rainy"
            playMusic(playlist: self.currentPlaylist)
            
        case 700...800 :
            currentPlaylist = "Sunny"
            playMusic(playlist: self.currentPlaylist)
        
        default :
            print("musicType fail")
            
        }
    }
    
    func spotify(weather: Int) {
        
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
            
            // print(params)
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
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
        }
    }
    
    func didSetAudio(sourceType: Bool) {
        self.audioSource = sourceType
    }

//    enum MusicSourceType {
//        
//        switch source {
//        case LocalMusic :
//          self.setAudio = true
//        case Spotify :
//          self.setAudio = false
//        }
//    }

}




