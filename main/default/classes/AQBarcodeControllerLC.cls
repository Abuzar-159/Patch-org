global With Sharing Class AQBarcodeControllerLC { 
    
    @AuraEnabled
    global static String getAll(String BarcdHeight, String BarcdType, String Brcd, String Height, String Width){
        try{
            AQBarcodeFactory m_factObj = AQBarcodeFactory.createFactoryObject();
            AQBarcode brcdObj = m_factObj.createBarcodeObject(BarcdType);
            if(brcdObj != null && brcdObj.isValid(Brcd)){
                if(BarcdHeight == null || BarcdHeight == ''){
                  BarcdHeight = '40';
                } 
                String BrcdCanvas = brcdObj.drawBarcode(Brcd, BarcdHeight);
                return BrcdCanvas; }} catch(exception ex){} return '';
    }
}