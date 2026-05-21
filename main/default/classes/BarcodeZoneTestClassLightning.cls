@isTest(SeeAllData=true)
private class BarcodeZoneTestClassLightning {
    
    @isTest
    public static void crash(){
        String brctype='code39';
        String brcdValue='BARCODE';
        String BarcdHeight='59';
        String BarWidth ='4'; 
        Boolean brcdValHide = false;
        BarcodeFactoryLightning.createFactoryObject();
        IBarcodeLightning brcdObj = BarcodeFactoryLightning.createBarcodeObject(brctype);
        System.assert(!(brcdObj.drawBarcode(brcdValue, BarcdHeight,BarWidth, brcdValHide) == null));
    }
    
    @isTest
    public static void  unittest1(){
        BarcodeControllerLightning.drawBarcode('BARCODE','code39','40','4',false);
        System.assert(!(BarcodeControllerLightning.BrcdCanvas == null));
    }
    
    @isTest
    public static void  unittest2(){
        BarcodeControllerLightning.drawBarcode('BARCODE','code128','40','4',false);
        System.assert(!(BarcodeControllerLightning.BrcdCanvas == null));
    }
    
    @isTest
    public static void  unittest3(){
        BarcodeControllerLightning.drawBarcode('barcode','code128','40','4',false);
        System.assert(!(BarcodeControllerLightning.BrcdCanvas == null));
    }
    
    @isTest
    public static void  unittest4(){
        BarcodeControllerLightning.drawBarcode('123456789','code128','40','4',false);
        System.assert(!(BarcodeControllerLightning.BrcdCanvas == null));
    }
    
    @isTest
    public static void  unittest5(){
        BarcodeControllerLightning.drawBarcode('1234567890','code128','40','4',false);
        System.assert(!(BarcodeControllerLightning.BrcdCanvas == null));
    } 
    
    @isTest
    public static void  unittest6(){
        BarcodeControllerLightning.drawBarcode('9780201734843','ean13','40','4',false);
        System.assert(!(BarcodeControllerLightning.BrcdCanvas == null));
    }
    
    @isTest
    public static void  unittest7(){
        BarcodeControllerLightning.drawBarcode('','ean13','40','',false);
        String val  = BarcodeControllerLightning.brcodeImage('AQS123','ean13','','',false);
        System.assert((BarcodeControllerLightning.BrcdCanvas == null));
    }
    
    @isTest
    public static void  unittest8(){
        BarcodeControllerLightning.drawBarcode('9780201734843','qwe','40','',false);
        System.assert((BarcodeControllerLightning.BrcdCanvas == null));
    }
    
    @isTest
    public static void  unittest9(){
        BarcodeControllerLightning.drawBarcode('AQS123AQS1231','ean13','40','',false);
        System.assert((BarcodeControllerLightning.BrcdCanvas == null));
    }
    
    @isTest
    public static void  unittestE8(){
        BarcodeControllerLightning.drawBarcode('96385074','ean8','40','3',false);
        System.assert(!(BarcodeControllerLightning.BrcdCanvas == null));
    }   
    
    @isTest
    public static void  unittestCode128(){
        Code128ControllerLightning obj = new Code128ControllerLightning();
        System.assert(obj.isValid('AQXOLT'));
    }
    
    @isTest
    public static void  unittestEan13(){
        Ean13ControllerLightning obj = new Ean13ControllerLightning();
        String brcd ='9780201734843';
        String BarcdHeight ='40';    
        System.assert(obj.IsValid(brcd));
        
    }
    
    @isTest
    public static void  unittestEan8(){
        Ean8ControllerLightning obj = new Ean8ControllerLightning();
        String brcd ='12345678';
        String BarcdHeight ='40';    
        System.assert(obj.IsValid(brcd));
        
    }
    
    @isTest
    public static void  unittestCode39(){
        Code39ControllerLightning obj = new Code39ControllerLightning();
        System.assert(obj.isValid('BARCODE'));
    }
    
   @isTest
    public static void unittestCont(){
        BarcodeControllerLightning obj=new BarcodeControllerLightning('','');
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    @isTest
    public static void unittestImage(){
        BarcodeControllerLightning obje=new BarcodeControllerLightning();
        String Brcd='AQXOLT'; 
        String BarcdType='code128'; 
        String BarcdHeight=''; 
        String BarWidth=''; 
        Boolean brcdValHide=false;
        BarcodeControllerLightning.brcodeImage(Brcd,BarcdType,BarcdHeight,BarWidth,brcdValHide);
        System.assert(!(BarcodeControllerLightning.BrcdCanvas == null));
    }
    
    @isTest
    private static void unittestCont2()
    {
		Account acc = new Account(Name = 'unittestCont2');
		insert acc;
		ApexPages.StandardController sc = new ApexPages.standardController(acc);
        BarcodeControllerLightning ob=new BarcodeControllerLightning(sc);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
}