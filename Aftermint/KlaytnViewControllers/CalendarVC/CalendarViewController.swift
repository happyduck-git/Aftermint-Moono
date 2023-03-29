//
//  CalendarViewController.swift
//  Aftermint
//
//  Created by Platfarm on 2023/02/07.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import FSCalendar
import Pulley

class CalendarViewController: UIViewController {
    
    struct Dependency {
        let reactor: () -> CalendarViewReactor
        let bottomSheetVC: BenefitTabBottomViewController
    }
    
    private var bottomSheetVC: BenefitTabBottomViewController
    
    var disposeBag: DisposeBag = DisposeBag()
    var calendarHeightConstraint: NSLayoutConstraint?
    
    //MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = AftermintColor.backgroundNavy
        scrollView.showsVerticalScrollIndicator = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var leftBar: UIBarButtonItem = {
        let image: UIImage? = UIImage(named: "back")?.withRenderingMode(.alwaysOriginal)
        let buttonItem: UIBarButtonItem = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: nil)
        return buttonItem
    }()
    
    
    private lazy var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.scope = .week
        calendar.backgroundColor = AftermintColor.backgroundNavy
        calendar.appearance.headerTitleColor = .white
        calendar.appearance.weekdayTextColor = AftermintColor.lightGrey
        calendar.appearance.todayColor = AftermintColor.titleBlue
        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.titleDefaultColor = AftermintColor.lightGrey
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "YYYY.M"
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 14, weight: .heavy)
        calendar.appearance.headerTitleAlignment = .left
        calendar.translatesAutoresizingMaskIntoConstraints = false
        return calendar
    }()
    
    private lazy var toggleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "calendar_button_down"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var todayBenefit: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "today_benefit")
        imageView.contentMode = .scaleAspectFill
        
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        imageView.addGestureRecognizer(gesture)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var todayEvent: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "today_event")
        imageView.contentMode = .scaleAspectFill
        
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        imageView.addGestureRecognizer(gesture)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK: - Init
    init(reactor: CalendarViewReactor,
         bottomSheetVC: BenefitTabBottomViewController) {
        self.bottomSheetVC = bottomSheetVC
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.delegate = self
        calendar.dataSource = self
        self.calendar = calendar
        
        setUI()
        setLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.parent?.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        navigationBarSetup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Set up UI & Layout
    private func setUI() {
        view.backgroundColor = AftermintColor.backgroundNavy

        view.addSubview(scrollView)
        scrollView.addSubview(calendar)
        scrollView.addSubview(toggleButton)
        scrollView.addSubview(todayBenefit)
        scrollView.addSubview(todayEvent)
    }
    
    private func setLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            calendar.topAnchor.constraint(equalTo: scrollView.topAnchor),
            calendar.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            toggleButton.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 10.0),
            toggleButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            toggleButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10),
            toggleButton.heightAnchor.constraint(equalToConstant: 50),
            
            todayBenefit.topAnchor.constraint(equalTo: toggleButton.bottomAnchor),
            todayBenefit.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            todayBenefit.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            
            todayEvent.topAnchor.constraint(equalTo: todayBenefit.bottomAnchor),
            todayEvent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            todayEvent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            todayEvent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            
        ])
        
        calendarHeightConstraint = calendar.heightAnchor.constraint(equalToConstant: 300)
        calendarHeightConstraint?.isActive = true
    }
    
    private func navigationBarSetup() {
        
        self.parent?.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
        
        /* Left bar item */
        leftBar.customView?.isUserInteractionEnabled = true
        self.parent?.tabBarController?.navigationItem.leftBarButtonItem = leftBar
        self.parent?.tabBarController?.navigationItem.title = "캘린더"
        self.parent?.tabBarController?.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(ciColor: .white)]
        
        /* Right bar item */
        self.parent?.tabBarController?.navigationItem.rightBarButtonItems = nil
        
    }
    
    //MARK: - Methods
    private func backToPreviousVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    private func tapToEventVC() {
        
        // Temporarily deactivated
        /*
        let eventDetailVC: EventDetailViewController = EventDetailViewController()
        let pulleyVC = PulleyViewController(contentViewController: eventDetailVC, drawerViewController: bottomSheetVC)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(pulleyVC, animated: true)
         */
    }
    
    private func tapToUtilityVC() {
        // Temporarily deactivated
        /*
        let utilityDetailVC: UtilityDetailViewController = UtilityDetailViewController()
        bottomSheetVC.configure(image: "claim")
        let pulleyVC = PulleyViewController(contentViewController: utilityDetailVC, drawerViewController: bottomSheetVC)
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(pulleyVC, animated: true)
         */
    }
    
    
}

extension CalendarViewController: View {
    
    func bind(reactor: CalendarViewReactor) {
        bindAction(with: reactor)
        bindState(with: reactor)
    }
    
    private func bindState(with reactor: CalendarViewReactor) {
        
        reactor.state.map { $0.isToggle }
            .distinctUntilChanged()
            .subscribe { [weak self] isToggle in
                guard let `self` = self else { return }
                if self.calendar.scope == .month {
                    self.calendar.setScope(.week, animated: true)
                    self.toggleButton.setImage(UIImage(named: "calendar_button_down"), for: .normal)
                } else {
                    self.calendar.setScope(.month, animated: true)
                    self.toggleButton.setImage(UIImage(named: "calendar_button_up"), for: .normal)
                }
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isBack }
        .distinctUntilChanged()
        .subscribe { [weak self] back in
            guard let `self` = self else { return }
            self.backToPreviousVC()
        }
        .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isBenefitTapped }
            .distinctUntilChanged()
            .subscribe { [weak self] isBenefitTapped in
                guard let `self` = self else { return }
                self.tapToEventVC()
            }
            .disposed(by: self.disposeBag)
        
        reactor.state.map { $0.isUtilityTapped }
            .distinctUntilChanged()
            .subscribe { [weak self] isUtilityTapped in
                guard let `self` = self else { return }
                self.tapToUtilityVC()
            }
            .disposed(by: self.disposeBag)
        
    }
    
    private func bindAction(with reactor: CalendarViewReactor) {
        
        self.toggleButton.rx.tap
            .map { Reactor.Action.tapToggleButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
  
        self.leftBar.rx.tap
            .map { Reactor.Action.tapBackButton }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.todayBenefit.gestureRecognizers?[0].rx.event
            .map { _ in Reactor.Action.tapUtilityImage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
        self.todayEvent.gestureRecognizers?[0].rx.event
            .map { _ in Reactor.Action.tapEventImage }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint?.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return AftermintColor.titleBlue
    }
    
    
}

