global With Sharing class BarcodeControllerLightning {    
   
    public BarcodeControllerLightning(String BarcdHeight, String BarWidth){ 
        
        if(BarcdHeight == null || BarcdHeight == ''){
            BarcdHeight = '40';
        } 
        if(BarWidth == null || BarWidth == ''){
            BarWidth = '4';
        } 
    }
   
    public BarcodeControllerLightning(){ 
    }
    
    public static String BrcdCanvas;
    public static String errormessage='Value doesn\'t match barcode type';
    @AuraEnabled
    public static String brcodeImage(String Brcd, String BarcdType, String BarcdHeight, String BarWidth, Boolean brcdValHide){        
        drawBarcode(Brcd, BarcdType, BarcdHeight, BarWidth, brcdValHide);
        if(BrcdCanvas == null){ return errormessage;}
        else return BrcdCanvas;   
    }
    
    public BarcodeControllerLightning(ApexPages.StandardController controller){
        /*'inside BarcodeControllerLightning constructor'*/
    }
    
    @auraEnabled
    public static String drawBarcode(String Brcd, String BarcdType, String BarcdHeight, String BarWidth, Boolean brcdValHide){
       
        IBarcodeLightning brcdObj = BarcodeFactoryLightning.createBarcodeObject(BarcdType);
        if(brcdObj != null && brcdObj.isValid(Brcd)){
            if(BarcdHeight == null || BarcdHeight == '') BarcdHeight = '40'; 
            if(BarWidth == null || BarWidth == '') BarWidth = '4';
            BrcdCanvas = brcdObj.drawBarcode(Brcd, BarcdHeight, BarWidth, brcdValHide);
        }
        return null;
    }   
}