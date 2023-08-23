//
//  OrderBookViewController.swift
//
//  Created by tzh .
//

import UIKit


/**
 A view controller responsible for displaying the order book data through a collection view. It manages the user interface for showing buy and sell orders with corresponding quantities and prices. The `OrderBookViewController` is tightly integrated with the `OrderBookViewModel` to fetch and display real-time order book updates using a WebSocket connection.

 This view controller inherits from `AppViewController` and conforms to the `OrderBookViewModelDelegate`, `UICollectionViewDataSource`, and `UICollectionViewDelegateFlowLayout` protocols.

 The `OrderBookViewController` provides the following functionality:
 - Displaying the order book data in a two-section collection view: buy orders and sell orders.
 - Handling WebSocket connection errors, disconnections, and reconnections.
 - Loading and presenting order book data using a `UICollectionView`.

 Use this view controller as a child of a parent view controller or in a navigation stack to provide users with a seamless experience for viewing and interacting with real-time order book data.
 */
class OrderBookViewController: AppViewController {
    // MARK: - Properties

    private var viewModel: OrderBookViewModel!

    private lazy var collectionView: UICollectionView = {
        // Set up the collection view with layout and other properties
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        // Configure layout properties...
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceVertical = true
        // Configure collection view properties...
        collectionView.register(OrderBookCell.self, forCellWithReuseIdentifier: "OrderBookCell")
        return collectionView
    }()
   
    // MARK: - Initialization

    required init(topic: String!,  webSocketConnection: WebSocketConnection) {
        self.viewModel = OrderBookViewModel(topic: topic, webSocketConnection: webSocketConnection)
        super.init(nibName: nil, bundle: nil)

    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up header and collection view
        self.setUpHeader(t1Str: "Qty", t2Str: "Price(USD)", t3Str: "Qty")
        self.setupCollectionView()
        // Set up viewModel's data source
        self.viewModel.setPublisherData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Start loading and establish WebSocket connection
        self.startLoading()
        viewModel.delegate = self
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
                // Set up constraints for the collection view
                collectionView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 60),
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
// MARK: - OrderBookViewModelDelegate

extension OrderBookViewController: OrderBookViewModelDelegate {
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

extension OrderBookViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 2
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.buyOrderCount

            } else {
                return viewModel.sellOrderCount

        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderBookCell", for: indexPath) as! OrderBookCell
        
        if let orderBookItem = viewModel.orderBookItem(for: indexPath) {
            cell.configure(orderBookItem: orderBookItem)

        }
        return cell

    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 // Two columns, adjust as needed
        return CGSize(width: width, height: 40) // Adjust height as needed
    }
}






