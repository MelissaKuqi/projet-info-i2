//
//  Document.swift
//  Test-TMPL-OPenGL
//
//  Created by MBookAdmin on 19/02/2017.
//  Copyright © 2017 MBookAdmin. All rights reserved
//

import Cocoa

class Document: NSDocument {

    // MARK: --- déclaration des propriétés de l'objet Document
    
    private var données = [Float]()
    var latticeparameter : Double = 0.0
    var step = [Int]()
    var atome = [[String]]()
    var tableau = [[[Double]]]()
    var Na : Int = 0 // création de 2 variables vides pour le dénombrement des atomes
    var Nb : Int = 0
    
    override init() {
        super.init()
        Swift.print(#function, self.className)
        // MARK: --- initialisation des propriétés de l'objet
        
        données = [ 0.0, 1.1, 2.2, 3.3, 4.4, 5.5 ] // valeurs arbitraires

    }
    
    //
    // méthode appelée par l'option Open... du menu File de l'application exécutée
    //
    override func read(from monURL: URL, ofType nomType: String) throws {
        
        NSLog("%@ %@", self.className, #function)
        
        // affiche le nom de type du fichier sélectionné par l'utilisateur
        NSLog("%@", nomType)
        
        if nomType == "Fichier Output" { // extensions acceptées : .txt, xyz
            Swift.print("URL:",monURL)
            var uneURL = monURL // copie dans var pour pouvoir la modifier
            uneURL.deleteLastPathComponent()
            uneURL.appendPathComponent("TRAJEC_short.xyz")
            Swift.print(">>>",uneURL)
                        
            let str = try String(contentsOf: uneURL)
            var scanDataAtomes = Scanner(string:str)
            var monScanner = Scanner() // création d'un scanner vide
            do {
                let chaineFichier = try String(contentsOf: monURL)
                // à décommenter pour tester le contenu de la variable
                //Swift.print(chaineFichier)
                monScanner = Scanner(string: chaineFichier)
            } catch {
                NSLog("Erreur lecture fichier output ")
                throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
            }
        
            Swift.print("Nous sommes passés ici")
            // ******************************************
            // suite des opérations : parcours du scanner
            // ******************************************
            let cellule_str = monScanner.scanUpToString("CONSTANT(a.u.):") //permet d'acceder au lattice parameter
            let cellule1_str = monScanner.scanUpToCharacters(from: CharacterSet.whitespaces)!
            
            latticeparameter = monScanner.scanDouble()!
            while !scanDataAtomes.isAtEnd { //boucle qui lit et stocke toutes les données du fichier xyz
                let nombre = scanDataAtomes.scanInt()!
                Swift.print("Le nombre total d'atomes est : ",nombre)
                let ligne2 = scanDataAtomes.scanUpToString("STEP:")
                let ligne_2 = scanDataAtomes.scanUpToCharacters(from: CharacterSet.whitespaces)!
                var sstep = scanDataAtomes.scanInt()!
                step.append(sstep)
                var atome2=[String]()
                var conf = [[Double]]()
                for i in 1..<nombre + 1 {
                    var aatome = scanDataAtomes.scanUpToCharacters(from: CharacterSet.whitespaces)!
                    atome2.append(aatome)
                    var x = scanDataAtomes.scanDouble()!
                    var y = scanDataAtomes.scanDouble()!
                    var z = scanDataAtomes.scanDouble()!
                    
                    conf.append([x,y,z])
                
                }
                atome.append(atome2)
                tableau.append(conf)
            }
            
            Swift.print("il y a ", tableau.count, "tableaux")
            // calcul du Na et Nb
            for j in 0..<atome[0].count {
                if atome[0][j] == "Se" {
                        Nb+=1
                    } else {
                        Na+=1
                }
                }
            Swift.print("Le nombre d'atomes Ge est : ",Na, " et le nombre d'atomes de Se est :",Nb)
            
    calcule()
   
    // appel à la méthode calcul pour réaliser des opérations à partir des données lues (si nécessaire)
    }
    }
    
   func calcule() {
        
        let latticeparameter1 = latticeparameter*0.529177249 //conversion en angstrom
        Swift.print("Le paramètre de cellule est : ",latticeparameter1, "Angström")
        let volume = pow(latticeparameter1,3)
        Swift.print("Le volume de la cellule est : ",volume,"Angström^3")
        Swift.print("STEP : ",step)
        Swift.print(atome)
        // séparation distincte des 3 tableaux
        for i in 0..<tableau.count {
            for j in 0..<tableau[0].count {
                Swift.print(tableau[i][j], terminator : "")
            }
            Swift.print()
        }
//détermination des r
        // Swift.print("TESTS",atome[0].count,tableau[0].count)
        // interaction Ge-Ge et Ge-Se
         for i in 0...atome[0].count-2{
            var tabcase = [Int]()
            for j in i+1...atome[0].count-1{
                if atome[0][i] == "Ge" {
                    Swift.print(atome[0][i])
                    Swift.print(atome[0][j])
                    if atome[0][j] == "Ge" {
                        Nb = Na
                    Swift.print("Le Nb est",Nb)
                    }
                    var x1 = tableau[0][i][0]
                    var x2 = tableau[0][j][0]
                    var y1 = tableau[0][i][1]
                    var y2 = tableau[0][j][1]
                    var z1 = tableau[0][i][2]
                    var z2 = tableau[0][j][2]
                    var r = sqrt(pow(x1-x2,2) + pow(y1-y2,2) + pow(z1-z2,2))
                    Swift.print(">>>>>>>>>>>>>r=",r)
                    var k = Int(r/0.01)
                    Swift.print("La partie entière de la distance divisee par l'épaisseur de couche est", k)
                    tabcase[k]+= 1
                    let V_r = 4 * Double.pi * (r*r) * 0.01
                    Swift.print("V_r =",V_r)
                    let rho_glob = Double(Nb)/volume
                    Swift.print("rho_glob =", rho_glob)
                    //var rho_r = 1/V_r * 1/Na *
            }
            }
            }
          Swift.print(tabcase)
          // interaction Se-Se
          for i in 0...atome[0].count-2{
            var tabcase = [Int]()
            for j in i+1...atome[0].count-1{
                if atome[0][i] == "Se" {
                    Swift.print(atome[0][i])
                    
                    if atome[0][j] == "Se" {
                        Swift.print(atome[0][j])
                        var x1 = tableau[0][i][0]
                        var x2 = tableau[0][j][0]
                        var y1 = tableau[0][i][1]
                        var y2 = tableau[0][j][1]
                        var z1 = tableau[0][i][2]
                        var z2 = tableau[0][j][2]
                        Na = Nb
                        var r = sqrt(pow(x1-x2,2) + pow(y1-y2,2) + pow(z1-z2,2))
                        Swift.print(">>>>>>>>>>>>>r=",r)
                        var k = Int(r/0.01)
                        Swift.print("La partie entière de la distance divisee par l'épaisseur de couche est", k)
                        let V_r = 4 * Double.pi * (r*r) * 0.01
                        tabcase[k]+= 1
                        Swift.print("V_r =",V_r)
                        let rho_glob = Double(Nb)/volume
                        Swift.print("rho_glob =", rho_glob)
                        //var rho_r = 1/V_r * 1/Na *
                        
            }
            }
            }
            }
    Swift.print(#function)
    }
    override func data(ofType typeName: String) throws -> Data {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func windowControllerDidLoadNib(_ aController: NSWindowController) {
        NSLog("%@", #function)
        super.windowControllerDidLoadNib(aController)
    }
    
    override func awakeFromNib() { }
    
    override var windowNibName: NSNib.Name? {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return NSNib.Name("Document")
    }

    // MARK: --- déclarations des méthodes additionnelles de l'objet Document

    // pour l'échange de données entre l'objet Document et l'openGLView
    func getUneDonnée(Numéro: Int) -> Float? {
        
        if Numéro >= 0 && Numéro < données.count {
            return données[Numéro]
        } else {
            return nil
        }
    }

}


