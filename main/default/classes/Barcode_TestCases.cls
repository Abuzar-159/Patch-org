@isTest
public class Barcode_TestCases {
    public static testmethod void  AQEan13Unittest(){
        AQEan13Controller obj = new AQEan13Controller();
        String brcd ='9780201734843';
        String BarcdHeight ='40';
        obj.drawBarcode(brcd,BarcdHeight);
        System.assert(obj.IsValid(brcd));
    }
    
    public static testmethod void  AQEan8Unittest(){
        AQEan8Controller obj = new AQEan8Controller();
        String brcd ='96385074';
        String BarcdHeight ='40';
        obj.drawBarcode(brcd,BarcdHeight);
        System.assert(obj.IsValid(brcd));
    }
    
    public static testmethod void  Ean8Unittest(){
        Ean8Controller obj = new Ean8Controller();
        String brcd ='96385074';
        String BarcdHeight ='40';
        obj.drawBarcode(brcd,BarcdHeight);
        System.assert(obj.IsValid(brcd));
    }
    
    public static testmethod void  AQCode39Unittest(){
        AQCode39Controller obj = new AQCode39Controller();
        obj.Brcd = 'BARCODE';
        obj.BarcdHeight = '40';
        String brcd ='BARCODE';
        String BarcdHeight ='40';
        obj.drawBarcode(brcd,BarcdHeight);
        System.assert(obj.isValid( obj.Brcd));
    }
    
    public static testmethod void  AQCode128Unittest(){
        AQCode128Controller obj = new AQCode128Controller();
        obj.Brcd = 'APEXCLOUD';
        obj.BarcdHeight = '40';
        String brcd ='APEXCLOUD';
        String BarcdHeight ='40';
        obj.drawBarcode(brcd,BarcdHeight);
        System.assert(obj.isValid( obj.Brcd));
    }
    
    public static testmethod void  Ean13Unittest(){
        Ean13Controller obj = new Ean13Controller();
        String brcd ='9780201734843';
        String BarcdHeight ='40';
        obj.drawBarcode(brcd);
        System.assert(obj.IsValid(brcd));
    }
    
    public static testmethod void  Code39Unittest(){
        Code39Controller obj = new Code39Controller();
        obj.Brcd = 'BARCODE';
        String brcd ='BARCODE';
        obj.drawBarcode(brcd);
        System.assert(obj.isValid( obj.Brcd));
    }
    
    public static testmethod void  Code128Unittest(){
        Code128Controller obj = new Code128Controller();
        obj.Brcd = 'APEXCLOUD';
        String brcd ='APEXCLOUD';
        obj.drawBarcode(brcd);
        System.assert(obj.isValid( obj.Brcd));
    }
   
    public static testmethod void AQCodeE8Unittest(){
        BarcodeControllerLightning.drawBarcode('96385074','ean8','40','3',false);
        System.assert(!(BarcodeControllerLightning.BrcdCanvas == null));
    }  

}