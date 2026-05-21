public With Sharing Class BarcodeFactory {
    private static BarcodeFactory factObj;
    
    //singlton implimentation
    private BarcodeFactory(){
        // make constructor hidden
    }
    
    public static BarcodeFactory createFactoryObject(){
        if(factObj == null){
            factObj = new BarcodeFactory();
        }
        return factObj;
    }
    
    public IBarcode createBarcodeObject(String brcdType){
        if(BrcdType.equalsIgnoreCase('code39')){
            return new Code39Controller();
        }else if(BrcdType.equalsIgnoreCase('code128')){
            return new Code128Controller();
        }else if(BrcdType.equalsIgnoreCase('ean13')){
            return new Ean13Controller();
        }/*else if(BrcdType.equalsIgnoreCase('ean8')){
            return new Ean8Controller();
        } */  
        return null;
    }
    
    

}