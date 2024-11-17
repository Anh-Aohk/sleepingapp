import UIKit
import AVFoundation

class AnimationVC: UIViewController {
    
    // MARK: - Properties
    var imgIndex: Int = 1
    var timer: Timer!
    var timer2: Timer!
    var isAnimating: Bool = false
    var audioPlayer: AVAudioPlayer!
    var isSoundOn: Bool = false
    var soundName: String = "-----"
    var count: Int = 0
    var timerCounting: Bool = false
    var redValue = CGFloat(drand48())
    var greenValue = CGFloat(drand48())
    var blueValue = CGFloat(drand48())
    var count2: Int = 0
    
    // MARK: - Outlets
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var lblSheepCount: UILabel!
    @IBOutlet weak var btnClickCount: UIButton!
    @IBOutlet weak var imgGoodnight: UIImageView!
    @IBOutlet weak var btnToggleAnimation: UIButton!
    @IBOutlet weak var btnResetAnimation: UIButton!
    @IBOutlet weak var swToggleSound: UISwitch!
    @IBOutlet weak var lblSoundName: UILabel!
    
    // MARK: - Actions
    @IBAction func changeToNextImage(_ sender: UIButton) {
        if (imgIndex <= 1) {
            imgIndex = 37
        } else {
            imgIndex -= 1
        }
        updateImage()
    }
    @IBAction func sheepCount(_ sender: UIButton) {
        count2 += 1
        print("Sheep Count: \(count2)")
        lblSheepCount.text = "Sheep Count: \(count2)"
        self.btnClickCount.tintColor = .init(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
    
    @IBAction func toggleAnimation(_ sender: UIButton) {
        if (isAnimating) {
            isAnimating = false
            btnToggleAnimation.tintColor = .systemBlue
            btnToggleAnimation.setTitle("ANIMATE", for: .normal)
            pauseAnimation()
            btnResetAnimation.isHidden = true
            timerCounting = false
            timer.invalidate()
            
        } else {
            isAnimating = true
            btnToggleAnimation.tintColor = .systemRed
            btnToggleAnimation.setTitle("PAUSE", for: .normal)
            startAnimation()
            btnResetAnimation.isHidden = false
            timerCounting = true
            timer2 = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func resetAnimation() {
        self.count = 0
        count2 = 0
        lblSheepCount.text = "Sheep Count: _"
        timer2.invalidate()
        timer.invalidate()
        lblSoundName.text = soundName
        pauseAnimation()
        imgIndex = 1
        updateImage()
        isAnimating = true
        toggleAnimation(btnToggleAnimation)
        isSoundOn = true
        swToggleSound.isOn = isSoundOn
        prepareAudioPlayer()
        timerLabel.text = "00 : 00 : 00"
    }
    
    @IBAction func toggleSound(_ sender: UISwitch) {
        if (isSoundOn) {
            isSoundOn = false
            audioPlayer?.stop()
        } else {
            isSoundOn = true
            if audioPlayer == nil {
                prepareAudioPlayer()
            }
            audioPlayer?.play()
        }
        swToggleSound.isOn = isSoundOn
    }
    
    // MARK: - Helper Methods
    func updateImage() {
        print("goodnight-images/goodnight\(imgIndex)")
        imgGoodnight.image = UIImage(named: "goodnight-images/goodnight\(imgIndex)")
    }
    @objc func timerCounter() -> Void
    {
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        timerLabel.text = timeString
    }
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)
    {
        return ((seconds / 3600), ((seconds % 3600) / 60),((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds : Int) -> String
    {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.12, target: self, selector: #selector(self.changeToNextImage(_:)), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if (timer != nil) {
            timer.invalidate()
        }
        if (timer2 != nil) {
            timer2.invalidate()
        }
    }
    
    func startAnimation() {
        startTimer()
        if (isSoundOn) {
            audioPlayer?.play()
        }
        updateImage()
    }
    
    func pauseAnimation() {
        stopTimer()
        audioPlayer?.stop()
    }
    
    func prepareAudioPlayer() {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")
        else {
            print("Music file is not found!")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.numberOfLoops = -1
            audioPlayer.prepareToPlay()
            print("\(soundName) will be played!")
        } catch {
            print("Error initializing AVAudioPlayer: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Unwind Segue
    
    // Challenge 1: Hiệu chỉnh để khi người dùng click vào nút "Select This Sound" thì sẽ được quay về (unwind back) AnimationVC.
    // Challenge 4: Xử lý thông tin trong IBAction unwind... tương ứng để có thể đọc được giá trị của biến selectedSound trong SoundSelectionVC và hiển thị ra màn hình giá trị tương ứng.
    // Challenge 5: Cập nhật và play file âm thanh tương ứng.
    
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.btnToggleAnimation.tintColor = .systemGreen
        imgIndex = 1
        isSoundOn = true
        swToggleSound?.isOn = isSoundOn
        updateImage()
        lblSoundName.text = soundName
        prepareAudioPlayer()
        print(lblSheepCount.text!)
        print(btnClickCount.titleLabel!.text!)
    }
    
    @IBAction func unwindtoAnimationVC(_ unwindSegue: UIStoryboardSegue) {
        let sourceViewController = unwindSegue.source as! SoundSelectionVC
        if let selectedSound = sourceViewController.selectedSound {
            soundName = selectedSound
            lblSoundName.text = soundName
            prepareAudioPlayer()
            if isSoundOn {
                audioPlayer.play()
            }
        }
    }
    
    
}
