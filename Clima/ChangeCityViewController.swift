
import UIKit

protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

protocol ChangeMusicDelegate {
    func didSetAudio(sourceType: Bool)
}

class ChangeCityViewController: UIViewController {
    
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
    
    @IBAction func segmentedValueChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            musicChangeDelegate?.didSetAudio(sourceType: true)
            print("true")
        }
        else if sender.selectedSegmentIndex == 1 {
            musicChangeDelegate?.didSetAudio(sourceType: false)
            print("false")
        }
        
    }
//        func selectedSegment(_: selectedIndex) {
//            switch selectedIndex {
//    
//            case 0 :
//                musicChangeDelegate?.didSetAudio(sourceType: true)
//            case 1 :
//                musicChangeDelegate?.didSetAudio(sourceType: false)
//            }
    
//            if selectedSegment().index == 0 {
//              musicChangeDelegate?.didSetAudio(sourceType: .LocalMusic)
           //}
    
       // }
    
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return names.count
    //    }
    //
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
    //
    //      cell?.textLabel?.text = names[indexPath.row]
    //
    //      return cell!
    //    }
    
    //MARK: - Table View
    /***************************************************************/
    
    //  @IBOutlet weak var playlistView: UITableView!
    
    //MARK: - Back Buttons
    /***************************************************************/
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
   
}
