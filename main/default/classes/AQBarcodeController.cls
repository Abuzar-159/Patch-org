global with sharing class AQBarcodeController {
  public String Brcd{get; set;}
  public String Height{get; set;}
  public String Width{get; set;}
  public String BarcdType{get; set;}
  public String BrcdCanvas{get; set;}
  public String BarcdHeight{get; set;}
  public String BarWidth{get; set;}
  //-----------------------------------------------
    public String SObjectParentId{get; set; }
    public String correctionLevel{get;set; } 
    //public String BarcdType{get; set; }
    public boolean brcdValHide {get; set; }
   
    //-----------------------------------------------

  private AQBarcodeFactory m_factObj;
    //private BarcodeFactory m_factObj1;//for EAN8 barcode
  
  public AQBarcodeController(){
  try{
      if(BarcdHeight == null || BarcdHeight == '') BarcdHeight = '40';      if(BarWidth == null || BarWidth == '') BarWidth = '4';
      
       
    m_factObj = AQBarcodeFactory.createFactoryObject(); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
  }
  public String getBrcodeImage(){
      try{
            BrcdCanvas=null;
            drawBarcode();
            if(BrcdCanvas == null) { return 'Value doesn\'t match barcode type';} else return BrcdCanvas;}catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
  }
  
  public PageReference drawBarcode(){
      
          try{
              AQBarcode brcdObj = m_factObj.createBarcodeObject(BarcdType);
              if(brcdObj != null && brcdObj.isValid(Brcd)){
                  if(BarcdHeight == null || BarcdHeight == ''){ BarcdHeight = '40'; }   if(BarWidth == null || BarWidth == '') BarWidth = '4';
                  BrcdCanvas = brcdObj.drawBarcode(Brcd, BarcdHeight);}} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
      
  }
    
    //----------------------------------------------------------------------------------
    public Component.Apex.IncludeScript getJQueryMin() {
        
        Component.Apex.IncludeScript jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.Barcode2D, \'Barcode2D/js/jquery-1.6.2.min.js\')}';
        return jsScript;
    }
    
    public Component.Apex.IncludeScript getBCMathMin() {
        
        Component.Apex.IncludeScript jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.Barcode2D, \'Barcode2D/js/pdf417/bcmath-min.js\')}';
        return jsScript;
    } 
    
    public Component.Apex.IncludeScript getPDF417Min() {
        
        Component.Apex.IncludeScript jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.Barcode2D, \'Barcode2D/js/pdf417/pdf417-min.js\')}';
        return jsScript;
    }
    
    public Component.Apex.IncludeScript getQRJScript() {
        
        Component.Apex.IncludeScript jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.Barcode2D, \'Barcode2D/js/qr/Qrcode.js\')}';
        return jsScript;
    }
    
    public Component.Apex.IncludeScript getJQRScript() {
        
        Component.Apex.IncludeScript jsScript = new Component.Apex.IncludeScript();
            jsScript.expressions.value = '{!URLFOR($Resource.Barcode2D, \'Barcode2D/js/qr/jqueryQrcode.js\')}';
        return jsScript;
    }
    
    public String getQRCSS(){
        return '{!URLFOR($Resource.Barcode2D, \'Barcode2D/css/Qrcode.css\')}';
    } 
    //----------------------------------------------------------------------------------
   

}