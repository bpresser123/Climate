
import UIKit


protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

protocol ChangeMusicDelegate {
    func didSetAudio(sourceType: Bool)
}

class ChangeCityViewController: UIViewController {

    var delegate: ChangeCityDelegate?
    var musicChangeDelegate: ChangeMusicDelegate?
    
    
    @IBOutlet weak var changeCityTextField: UITextField!

    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        
        let cityName = changeCityTextField.text!
        
        delegate?.userEnteredANewCityName(city: cityName)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var seg: UISegmentedControl!
    
    @IBAction func segValueChange(_ sender: Any) {
        if seg.selectedSegmentIndex == 0 {
            musicChangeDelegate?.didSetAudio(sourceType: true)
        }
        else if seg.selectedSegmentIndex == 1 {
            musicChangeDelegate?.didSetAudio(sourceType: false)
        }
    }
//    func selectedSegment(_: selectedIndex) {
//        switch selectedIndex {
//            
//        case 0 :
//            musicChangeDelegate?.didSetAudio(sourceType: true)
//        case 1 :
//            musicChangeDelegate?.didSetAudio(sourceType: false)
//        }
//        
//        if selectedSegment().index == 0 {
//          musicChangeDelegate?.didSetAudio(sourceType: .LocalMusic)
//       }
//
//    }
    
}
