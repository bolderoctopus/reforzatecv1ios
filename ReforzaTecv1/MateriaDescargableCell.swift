//
//  MateriaDescargableCell.swift
//  ReforzaTecv1
//
//  Created by Delfin: Verano Científico on 21/07/17.
//  Copyright © 2017 TecUruapan. All rights reserved.
//

import UIKit

//Para que al presionar el boton de la vista de esta clase, se llame la funcion de descargar en 
//MateriasDsponiblesViewController y se descargue
protocol BtnMateriaDelegate : class {
    func btnDescargarDelegate (_ row : MateriaDescargableCell)
}

//tienen dentro un MateriaObj
//clase donde pongo todo lo de la materia para mostrar junto
//con ese MateriaObj inicializo coredata si se guarda
//Deveria renombrar esta clase a algo mejor,
class MateriaDescargableCell: UITableViewCell {
        //deberia lelvar un objeto tipo Materia?
    var objMateria : MateriaStruct?//borrar? no, representacion de la materia antes de ser descargada
    weak var delegate :BtnMateriaDelegate?
    
    var cellExists : Bool = false
    //let touchThing = UILongPressGestureRecognizer(target: self, action: #selector(MateriasDisponiblesViewController.cellOpened(sender:)))
    
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var detailsView: UIView! {
        didSet {
            detailsView?.isHidden = true
            detailsView?.alpha = 0
        }
    }
    @IBOutlet weak var descripcionTextView: UITextView!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var heightCons: NSLayoutConstraint!

    @IBOutlet weak var nombreLabel: UILabel!
    @IBOutlet weak var VersionLabel: UILabel!
    
    var indicadorDeDescarga: UIActivityIndicatorView!
    var estamosDescargando: Bool!{
        didSet{
            indicarDescarga(estamosDescargando)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.none        
    }
 
    @IBAction func descargar(_ sender: Any) {
        delegate?.btnDescargarDelegate(self)
    }
    
    func indicarDescarga(_ estamosDescargando: Bool) {
        if estamosDescargando == false{
            titleView.willRemoveSubview(indicadorDeDescarga)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.downButton.alpha = 1
                self.indicadorDeDescarga.alpha = 0
            })
            return
        }
        
        if(indicadorDeDescarga == nil){
            indicadorDeDescarga = UIActivityIndicatorView.init(frame: downButton.frame)
            indicadorDeDescarga.alpha  = 0
            indicadorDeDescarga.color = UIColor.black
            indicadorDeDescarga.startAnimating()
            titleView.addSubview(indicadorDeDescarga)
            
            UIView.animate(withDuration: 0.4, animations: {
                self.downButton.alpha = 0
                self.indicadorDeDescarga.alpha = 1
            })
        }

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
                    self.heightCons.constant = 80
                }else {
                    self.nombreLabel.numberOfLines = 0
                    self.nombreLabel.sizeToFit()
                    let constante = self.nombreLabel.frame.size.height
//                    print("valor de la constante \(constante)")
                    self.heightCons.constant = constante
                    
                    self.detailsView.alpha = 1
                    
                }
            })
            
        }, completion: { (finished : Bool) in
            //print("Animation completed")
            c()
            
        })
    }

   
    
}
