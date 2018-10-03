//
//  ViewController.swift
//  Pipeline
//
//  Created by Charles Martin Reed on 10/2/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import Cocoa
import MetalKit

//MARK:- Renderer Properties
var renderer: Renderer?

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let metalView = view as? MTKView else {
            fatalError("metal view not set up in storyboard")
        }
        
        // initialize the renderer
        renderer = Renderer(metalView: metalView)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

