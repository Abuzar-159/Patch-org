public With Sharing Class BarcodeController {
    public String Brcd{get; set;}
    public String Height{get; set;}
    public String Width{get; set;}
    public String BrcdType{get; set;}
    public String BrcdCanvas{get; set;}
    private BarcodeFactory m_factObj;
    
    public BarcodeController(){
        try{
        m_factObj = BarcodeFactory.createFactoryObject();} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
    }
    public String getBrcodeImage(){
        try{
            //BrcdCanvas=null;
            drawBarcode(); return BrcdCanvas;
            //if(BrcdCanvas == null) { return 'Value doesn\'t match barcode type';}
            //else return BrcdCanvas;
        }catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
            
    }
    
    public PageReference drawBarcode(){
        try{
        IBarcode brcdObj = m_factObj.createBarcodeObject(BrcdType);
        if(brcdObj != null && brcdObj.isValid(Brcd)){ }} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        return null;
    }
    
    
}