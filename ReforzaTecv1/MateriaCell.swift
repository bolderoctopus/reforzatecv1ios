//
//  CustomTableViewCell.swift
//  ReforzaTecv1
//
//  Created by Omar Rico on 7/17/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

protocol BtnBorrarMateriaDelegate : class {
    func eliminarMateria (_ materia: MateriaCell)
}

class MateriaCell: UITableViewCell {
    var referenciaCD : Materia?
    weak var delegate:BtnBorrarMateriaDelegate?
    var cellExists : Bool = false
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var detailsView: UIView! {
        didSet {
            detailsView?.isHidden = true
            detailsView?.alpha = 0
        }
    }
    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var VersionLabel: UILabel!
    @IBOutlet weak var descripcionTextView: UITextView!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var heighConts: NSLayoutConstraint!
    
    var indicadorDeDescarga: UIActivityIndicatorView!
    var estaDescargando: Bool? {
        didSet{
            indicarDescarga(estaDescargando)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       self.selectionStyle = UITableViewCellSelectionStyle.none
        
    }
    
    func animate(duration : Double, c: @escaping () -> Void) {        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModePaced, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: duration, animations: {
                //esto evita que una celda sin descripcion se expanda, pero, aunque no tenga descripcion estaria bien que se expanda un poco
                //if  !self.descripcionTextView.text.isEmpty {
                self.detailsView.isHidden = !self.detailsView.isHidden
                //}
                if self.detailsView.alpha == 1 {
                    self.nombreLabel.numberOfLines = 1
                    self.detailsView.alpha = 0.5
                    self.heighConts.constant = 80
                }else {
                    self.nombreLabel.numberOfLines = 0
                    self.nombreLabel.sizeToFit()
                    let constante = self.nombreLabel.frame.size.height
//                    print("valor de la constante \(constante)")
                    self.heighConts.constant = constante
                    
                    self.detailsView.alpha = 1
                    
                }
            })
            
        }, completion: { (finished : Bool) in
            //print("Animation completed")
            c()
            
        })
    }
    
    func indicarDescarga(_ estamosDescargando: Bool?) {
        if let cierto = estaDescargando{
            if cierto{
                indicadorDeDescarga = UIActivityIndicatorView.init(frame: openButton.frame)
                indicadorDeDescarga.alpha  = 0
                indicadorDeDescarga.color = UIColor.black
                indicadorDeDescarga.startAnimating()
                titleView.addSubview(indicadorDeDescarga)
                UIView.animate(withDuration: 0.4, animations: {
                    self.openButton.alpha = 0
                    self.indicadorDeDescarga.alpha = 1
                })
            }else{
                UIView.animate(withDuration: 0.4, animations: {
                    self.openButton.alpha = 1
                    self.indicadorDeDescarga.alpha = 0
                })
                titleView.willRemoveSubview(indicadorDeDescarga)
            }
        }
    }
    
    
    @IBAction func removeMateria(_ sender: Any) {
       // print("\(nombreLabel.text!) is goiong to be deleted")
        delegate?.eliminarMateria(self)
        
    }
    
}


