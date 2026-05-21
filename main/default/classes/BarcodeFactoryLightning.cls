public With Sharing class BarcodeFactoryLightning {
  private static BarcodeFactoryLightning factObj;
  
  //singlton implimentation
  private BarcodeFactoryLightning(){
    // make constructor hidden
  }
  
  @AuraEnabled
  public static BarcodeFactoryLightning createFactoryObject(){
    if(factObj == null){
      factObj = new BarcodeFactoryLightning();
    }
    return factObj;
  }  
 
    @AuraEnabled
  public static IBarcodeLightning createBarcodeObject(String BarcdType){    
    if(BarcdType.equalsIgnoreCase('code39')){
      return new Code39ControllerLightning();
    }else if(BarcdType.equalsIgnoreCase('code128')){
      return new Code128ControllerLightning();
    }else if(BarcdType.equalsIgnoreCase('ean13')){
      return new Ean13ControllerLightning();
    }else if(BarcdType.equalsIgnoreCase('ean8')){
      return new Ean8ControllerLightning();      
    }
    return null;
  }  
}