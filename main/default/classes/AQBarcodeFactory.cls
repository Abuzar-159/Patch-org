public with sharing class AQBarcodeFactory {
  private static AQBarcodeFactory factObj;
  
  //singlton implimentation
  private AQBarcodeFactory(){
       // make constructor hidden
  }
  
  public static AQBarcodeFactory createFactoryObject(){
    if(factObj == null){
      factObj = new AQBarcodeFactory();
    }
    return factObj;
  }
  
  public AQBarcode createBarcodeObject(String BarcdType){
        if(BarcdType.equalsIgnoreCase('code39')){
            return new AQCode39Controller();
        }else if(BarcdType.equalsIgnoreCase('code128')){
            return new AQCode128Controller();
        }else if(BarcdType.equalsIgnoreCase('ean13')){
            return new AQEan13Controller();
        }else if(BarcdType.equalsIgnoreCase('ean8')){
            return new Ean8Controller();}  return null;
  }
  
  

}