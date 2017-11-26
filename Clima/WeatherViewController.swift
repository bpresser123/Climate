
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
import MediaPlayer


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate, ChangeMusicDelegate {
    
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
    
    //MARK: - Local Music Values
    /***************************************************************/
    
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    var currentPlaylist = ""
    var currentCity = ""
    var weatherType: Int?
    var audioSource: Bool = true
    //var musicSource: MusicSourceType = .LocalMusic
    
    //MARK: - Spotify Values
    /***************************************************************/
    
    var spotifyURL = "https://api.spotify.com/v1/users/bp123/playlists?offset=10"
    let spotifyKey = "BQDyQlU7-kTGxXjUoUlEpnkBiGjwWjWLsjNSX-td4kcLxPBwYQTbWA8jeNVab_pW8w46XmW7tTZRfylDiQW6jK1_ObM9Z3sSTHCJn7Kz2t2fG8YULBvZt9nH_NkDmjY9NR0s_TuiMtRwt7tfgWcjFu5D3IdUPmuV0yDCL3C4UgmB__W7AGpkVjvJCW0t39wmqS9qvU7-B5RNcm3c4x3lKfD1qnaEXhvvfrSVGX7fGylC0VZq7-lA"
    
    typealias JSONStandard = [String : AnyObject]
    var names = [String]()
 
    //MARK: - viewDidLoad
    /***************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
    
    time = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(WeatherViewController.dateAndTime), userInfo: nil, repeats: true)
    
    //  callAlamoSpotify(url: spotifyURL)
    }
    
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
        weatherDataModel.condition = 800 //json["weather"][0]["id"].intValue
        weatherType = weatherDataModel.condition
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
         
        print("\nThis is for \(weatherDataModel.city).")
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
          print("No Spotify yet..")
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
    
    //MARK: - Spotify Methods
    /***************************************************************/
        
    //    func spotify(weather: Int) {
    //
    //    }

    //    func callAlamoSpotify(url: String) {
    //        Alamofire.request(url).responseJSON(completionHandler: {
    //            response in
    //
    //            self.parseSpotifyData(JSONData: response.data!)
    //        })
    //
    //    }
    //
    //    func parseSpotifyData(JSONData : Data) {
    //
    //      do {
    //        let readableJSON = try JSONSerialization.jsonObject(with: JSONData, options: .mutableContainers) as! JSONStandard
    //        if let playlists = readableJSON["playlists"] as? JSONStandard {
    //          if let items = playlists["items"] {
    //            for i in 0..< items.count {
    //              let item = items[i] as! JSONStandard
    //
    //              let name = item["name"] as! String
    //
    //              names.append(name)
    //
    //            }
    //          }
    //        }
    //
    //      print(readableJSON as Any)
    //
    //      }
    //      catch {
    //        print(error)
    //      }
    //    }
    //
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return names.count
    //    }
    
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
    
    //MARK: - Music Controls
    /***************************************************************/
    
    @IBAction func playButton(_ sender: UIButton){
        self.playMusic(playlist: self.currentPlaylist)
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        musicPlayer.stop()
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        musicPlayer.skipToNextItem()
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
    
    func playMusic(playlist: String) {
        musicPlayer.stop()
        
        let query = MPMediaQuery()
        let predicate = MPMediaPropertyPredicate(value: playlist, forProperty: MPMediaPlaylistPropertyName)
        
        query.addFilterPredicate(predicate)
        
        musicPlayer.setQueue(with: query)
        musicPlayer.shuffleMode = .songs
        //  let currentSong = MPMediaItemPropertyTitle
        //  nowPlaying.text = currentSong
        musicPlayer.play()
        
    }
    
    @IBOutlet weak var nowPlaying: UILabel!
    
    func didSetAudio(sourceType: Bool) {
        self.audioSource = sourceType
    }
    
}




