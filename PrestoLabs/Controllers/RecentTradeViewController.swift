//
//  RecentTradeViewController.swift
//  PrestoLabs
//
//  Created by tzh .
//

import UIKit
/**
 `RecentTradeViewController` is a view controller that displays a list of recent trade data. It inherits from `AppViewController` and implements the necessary methods and protocols to manage the collection view displaying recent trade information.

 Use this view controller to show recent trade data in a user-friendly format. It includes features such as connecting to a WebSocket for live updates, handling connection errors, and displaying trade information in a collection view.

 ## Usage
 1. Initialize an instance of `RecentTradeViewController` by providing a topic and a `WebSocketConnection` instance.
 2. Implement the `RecentTradeViewModelDelegate` methods to handle data updates, connection errors, and disconnections.
 3. Set up the collection view to display recent trade data by implementing the `UICollectionViewDataSource` and `UICollectionViewDelegateFlowLayout` methods.

 ### Example
 ```swift
 let topic = "trade:XBTUSD"
 let webSocketConnection = WebSocketConnection.shared
 let recentTradeVC = RecentTradeViewController(topic: topic, webSocketConnection: webSocketConnection)
 navigationController?.pushViewController(recentTradeVC, animated: true)
Note: This class is intended to be used as a part of a larger application and should be embedded within a navigation controller for proper navigation.
*/


class RecentTradeViewController: AppViewController {
    private var viewModel: RecentTradeViewModel!
    /**
        A UICollectionView instance that displays a list of recent trade items in a structured layout.
        
        The collection view is initialized with a custom layout configuration to provide a seamless presentation of recent trade data. It is responsible for rendering trade cells and responding to user interactions such as scrolling and selection.
        
        - Note: Ensure that the `collectionView` is properly added to the view hierarchy and configured using appropriate constraints.
        
        - SeeAlso: `RecentTradCollectionViewCell`
        */
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true

        collectionView.register(RecentTradCollectionViewCell.self, forCellWithReuseIdentifier: "RecentTradCollectionViewCell")
        return collectionView
    }()
    /**
        Initializes a `RecentTradeViewController` instance with the provided topic and WebSocket connection.
        
        - Parameters:
          - topic: The topic to subscribe to for receiving recent trade data.
          - webSocketConnection: The WebSocket connection instance used for communication with the server.
        */
    required init(topic: String!,webSocketConnection: WebSocketConnection) {
        self.viewModel = RecentTradeViewModel(topic: topic, webSocketConnection: webSocketConnection)
        super.init(nibName: nil, bundle: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the collection view to display recent trade data
        self.setupCollectionView()
        // Set up the data source and connection for receiving recent trade updates
        self.viewModel.setPublisherData()
        // Set up the header for displaying column titles
        self.setUpHeader(t1Str: "Price(USD)", t2Str: "Qty", t3Str: "Time")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.delegate = self
        // Start loading and establish WebSocket connection
        viewModel.connectWebSocket()

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        // Unsubscribe and clean up WebSocket connection
        self.viewModel.unSubScribe()
        super.viewWillDisappear(animated)
    }
    // MARK: - Collection View Setup

    private func setupCollectionView() {
        self.startLoading()
        view.addSubview(collectionView)
        let guide = self.view.safeAreaLayoutGuide

            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 50),
                collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor)
            ])
            
        }
    // MARK: - Error Handling

    private func handleWebSocketConnectionError(_ error: Error) {
        self.present(title: "Connection Error", message: "Connection Error")
    }
   
}
// MARK: - RecentTradeViewModelDelegate

extension RecentTradeViewController: RecentTradeViewModelDelegate {
    func reloadData() {
        DispatchQueue.main.async {
            self.stopLoading()
            self.collectionView.reloadData()

        }
    }
    func notifyConnectionError(msg: String) {
        DispatchQueue.main.async {
            self.present(title: "Connection Error", message: msg)

        }

    }
    func didDisconnect(msg: String) {
        DispatchQueue.main.async {
            self.present(title: "Do you want to Reconnect", message: msg, customAction: UIAlertAction(title: "Try Again", style: .default, handler: { [weak self] _ in // Avoid Retain Cycles:
                guard let self = self else { return }
                self.startLoading()
                self.viewModel.connectWebSocket()
            }))
        }
         
    }
}
// MARK: - UICollectionViewDataSource and UICollectionViewDelegateFlowLayout

extension RecentTradeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.tradeCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentTradCollectionViewCell", for: indexPath) as! RecentTradCollectionViewCell
        let trade = viewModel.getTrade(for: indexPath)
        cell.configure(trade: trade)
        return cell

    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width - 20, height: 40) // Adjust height as needed
    }
}






