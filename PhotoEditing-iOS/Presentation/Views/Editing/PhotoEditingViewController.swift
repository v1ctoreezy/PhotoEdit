//
//  PhotoEditingViewController.swift
//  PhotoEditing-iOS
//
//  Created by Victor Cherkasov on 12.05.2025.
//

import UIKit
import Metal
import MetalKit
import CoreImage
import Combine
import PixelEnginePackage

class PhotoEditingViewController: UIViewController, UINavigationBarDelegate {
    private var cancelBag = Set<AnyCancellable>()
    private var viewModel: PhotoEditingViewModel
    
    lazy var mtkView: MTKView = {
        let view = MTKView()
        view.isOpaque = false
        view.enableSetNeedsDisplay = true
        view.framebufferOnly = false
        return view
    }()
    
    lazy var filtersView: UIView = {
        let view = UIView()
        return view
    }()
    
    var mainView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var controlsView: UIView = {
        let view = HostingController(
            rootView: EditingControlsView(viewModel: self.viewModel)
        ).view
        
        view?.translatesAutoresizingMaskIntoConstraints = false
        return view!
    }()
    
    var device: MTLDevice
    
    var renderer: ImageRendererImpl?
        
    init(viewModel: PhotoEditingViewModel) {
        self.device = MTLCreateSystemDefaultDevice()!
//        self.image = (CIImage(image: viewModel.currentImage)?.oriented(CIImage.mapOrientation(viewModel.currentImage.imageOrientation)))
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.renderer = ImageRendererImpl(
            metalKitView: self.mtkView,
            metalContext: MetalContext(device: self.device),
            selectedFilter: .LinearBurn
        )
        
        if let initialCIImage = viewModel.currentCIImage {
            self.renderer?.currentImage = initialCIImage
        }
        
        addNavBar()
        addMainView()
        addControllsView()
        addMTKView()
        
        subscribeToFields()
    }
}

extension PhotoEditingViewController {
    func selectFilter(_ filter: MTLCustomPhotoFilters) {
        renderer?.currentFilter = filter
    }
}

extension PhotoEditingViewController {
    private func addMainView() {
        mainView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainView)
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    private func addMTKView() {
        mtkView.device = self.device
        mtkView.translatesAutoresizingMaskIntoConstraints = false
        mainView.addSubview(mtkView)
        
        NSLayoutConstraint.activate([
            mtkView.topAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.topAnchor, constant: 40),
            mtkView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            mtkView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            mtkView.bottomAnchor.constraint(equalTo: controlsView.topAnchor)
        ])
    }
    
    private func addControllsView() {
        mainView.addSubview(controlsView)
        NSLayoutConstraint.activate([
//            controlsView.topAnchor.constraint(equalTo: mtkView.bottomAnchor),
            controlsView.heightAnchor.constraint(equalToConstant: 175),
            controlsView.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -30),
            controlsView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            controlsView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor)
        ])
    }
    
    private func addNavBar() {
        let height: CGFloat = 75
        let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        navbar.backgroundColor = UIColor.clear
        navbar.delegate = self
        
        let navItem = UINavigationItem()
        
        navItem.title = "Title"
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Left Button", style: .plain, target: self, action: nil)
        navItem.rightBarButtonItem = UIBarButtonItem(title: "Right Button", style: .plain, target: self, action: nil)
        
        navbar.items = [navItem]
        
        self.mainView.addSubview(navbar)
        navbar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            navbar.topAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.topAnchor),
            navbar.leadingAnchor.constraint(equalTo: mainView.leadingAnchor),
            navbar.trailingAnchor.constraint(equalTo: mainView.trailingAnchor),
            navbar.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

extension PhotoEditingViewController {
    private func subscribeToFields() {
        viewModel.$currentCIImage
            .sink { [weak self] currentCIImage in
                guard let self = self, let ciImage = currentCIImage else { return }
                self.renderer?.currentImage = ciImage
            }
            .store(in: &cancelBag)
    }
}
