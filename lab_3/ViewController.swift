import UIKit
import CoreMotion

class ViewController: UIViewController  {
    
    let motionModel = MotionModel()

    // MARK: =====UI Outlets=====
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    
    
    
    // MARK: =====UI Lifecycle=====
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.motionModel.delegate = self
        
        self.motionModel.startActivityMonitoring()
        self.motionModel.startPedometerMonitoring()
        
        view.addSubview(stepsTodayLabel)
        view.addSubview(stepsYesterdayLabel)
                
        setupLayout()
        fetchAndDisplaySteps()
    }


    


}

extension ViewController: MotionDelegate{
    // MARK: =====Motion Delegate Methods=====
    
    func activityUpdated(activity:CMMotionActivity){
        
        self.activityLabel.text = "🚶: \(activity.walking), 🏃: \(activity.running), 🧘‍♀️: \(activity.stationary), 💃: \(activity.unknown), 🚴‍♂️: \(activity.cycling),  🚗: \(activity.automotive)"
    }
    
    func setupLayout() {
        // Add constraints for labels
        stepsTodayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stepsTodayLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
            
        stepsYesterdayLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stepsYesterdayLabel.topAnchor.constraint(equalTo: stepsTodayLabel.bottomAnchor, constant: 20).isActive = true
    }
    
    func pedometerUpdated(pedData:CMPedometerData){

        // display the output directly on the phone
        DispatchQueue.main.async {
            // this goes into the large gray area on view
            //self.debugLabel.text = "\(pedData.description)"
            
            // this updates the progress bar with number of steps, assuming 100 is the maximum for the steps
            
            self.progressBar.progress = pedData.numberOfSteps.floatValue / 100
        }
    }
    
    func fetchAndDisplaySteps() {
        motionModel.fetchStepsForToday()
        motionModel.fetchStepsForYesterday()
            
        // Delay to allow time for steps to be fetched
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.stepsTodayLabel.text = "Steps Today: \(self.motionModel.stepsToday)"
            self.stepsYesterdayLabel.text = "Steps Yesterday: \(self.motionModel.stepsYesterday)"
            
            // Print to console
            print("Steps Today: \(self.motionModel.stepsToday)")
            print("Steps Yesterday: \(self.motionModel.stepsYesterday)")
        }
        
    
    }
    
    
}

