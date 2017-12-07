
import UIKit

protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

protocol ChangeMusicDelegate {
    func didSetAudio(sourceType: Bool)
}

class ChangeCityViewController: UIViewController {
    
    let defaults:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let value = UserDefaults.standard.value(forKey: "segOnOff") {
            
            let selectedIndex = value as! Int
            segSwitch.selectedSegmentIndex = selectedIndex
            
          }
        
        }
    
    //MARK: - Delegates
    /***************************************************************/

    var delegate: ChangeCityDelegate?
    var musicChangeDelegate: ChangeMusicDelegate?

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
    
    //MARK: - Back Buttons
    /***************************************************************/
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
   
}
