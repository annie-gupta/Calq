import UIKit
import CoreData

class OverviewController:  ViewController, UIScrollViewDelegate {

    @IBOutlet weak var halfyearChart: CalqYearBarChartView!
    @IBOutlet weak var barChart: BarChart!
    @IBOutlet weak var timeChart: LineChart!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pointChart: CircularProgressView!
    @IBOutlet weak var gradeChart: CircularProgressView!
    
    var settings: AppSettings?
    typealias ChartEntry = (Double, Double)
    typealias ChartEntrySet = (UIColor, [ChartEntry])
    var maxDataLineChart: [Double] = [0.0]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        update()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        self.navigationItem.title = "Übersicht"
        update()
        
        scrollView.delegate = self
        scrollView.isDirectionalLockEnabled = false
              
        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
        rect = rect.union(view.frame)}
        self.scrollView.contentSize = contentRect.size
        
        let size =  CGSize(width: self.view.frame.width, height: scrollView.contentSize.height + 300)
        scrollView.contentSize = size
        
        if #available(iOS 15.0, *) {
            let appearence =  UITabBarAppearance()
            appearence.configureWithDefaultBackground()
            self.tabBarController?.tabBar.scrollEdgeAppearance = appearence
        }
    }
    
    func update() {
        self.settings = Util.getSettings()
        
        barChart.drawChart(Util.getAllSubjects())
        if(Util.getAllSubjects().count != 0){
            barChart.drawAverageLine(Util.generalAverage())
        }
        
        halfyearChart.drawChart()
        
        let grade = String(format: "%.2f",Util.grade(number: Util.generalAverage()))
        let subjects = Util.getAllSubjects()
        
        if (subjects.count > 0){
            let blocks = Util.generateBlockOne() + Util.generateBlockTwo()
            let blockGrade = Util.grade(number: Double(blocks * 15 / 900))
            
            gradeChart.setprogress(blocks/900, .accentColor, String(blockGrade), "⌀")
            pointChart.setprogress(Util.generalAverage()/15, .accentColor, String(format: "%.2f",Util.generalAverage()), grade)
        } else {
            gradeChart.setprogress(0.0, .accentColor, "0", "6.0")
            pointChart.setprogress(0.0, .accentColor, "0", "0.0")
        }
        
        timeChart.lineWidth = 1.0
        timeChart.drawPoints = false
        var DataAr: [ChartEntrySet] = []
        
        for sub in Util.getAllSubjects(){
            let color = settings!.colorfulCharts ? Util.getPastelColorByIndex(sub.name!) :
            UIColor.init(hexString: sub.color!)
            DataAr.append( ChartEntrySet(color, getChartData(sub))  )
        }
        
        timeChart.drawChart(self.maxDataLineChart.sorted(by: {$0 > $1})[0])
        for data in DataAr {
            timeChart.addDataSet(data.1, data.0)
        }
    }
    
    func getChartData(_ sub: UserSubject) -> [ChartEntry]{
        let tests =  sub.subjecttests!.allObjects as! [UserTest]
        if(tests.count == 0){return  []}
        
        let maxDate = (tests.sorted(by: {$0.date!.timeIntervalSince1970 > $1.date!.timeIntervalSince1970})[0].date?.timeIntervalSince1970)! / 1000
        let minDate = (tests.sorted(by: {$0.date!.timeIntervalSince1970 < $1.date!.timeIntervalSince1970})[0].date?.timeIntervalSince1970)! / 1000
        
        var arr: [ChartEntry] = []
        for test in tests {
            let x =  (test.date!.timeIntervalSince1970 / 1000) - minDate
            arr.append((Double(x), Double(test.grade)))
        }
        self.maxDataLineChart.append(maxDate - minDate)

        return arr.sorted(by: {$0.0 > $1.0})
    }
}
