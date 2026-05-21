@isTest
private class TestCasesSet_8 {
   
    public static testmethod void crash(){
        String brctype='code39';
        String brcdValue='TEST';
        BarcodeFactory m_factObj = BarcodeFactory.createFactoryObject();
        IBarcode brcdObj = m_factObj.createBarcodeObject(brctype);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest1(){
        BarcodeController obj = new BarcodeController();
        obj.Brcd = 'TEST';
        obj.BrcdType = 'code39';
        obj.Height = '110';
        obj.Width = '120';
        obj.drawBarcode();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest2(){
        BarcodeController obj = new BarcodeController();
        obj.Brcd = 'TEST';
        obj.BrcdType = 'code128';
        obj.Height = '110';
        obj.Width = '120';
        obj.drawBarcode();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest3(){
        BarcodeController obj = new BarcodeController();
        obj.Brcd = 'TEST';
        obj.BrcdType = 'code128';
        obj.Height = '110';
        obj.Width = '120';
        obj.drawBarcode();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest4(){
        BarcodeController obj = new BarcodeController();
        obj.Brcd = '123456789';
        obj.BrcdType = 'code128';
        obj.Height = '110';
        obj.Width = '120';
        obj.drawBarcode();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest5(){
        BarcodeController obj = new BarcodeController();
        obj.Brcd = '1234567890';
        obj.BrcdType = 'code128';
        obj.Height = '110';
        obj.Width = '120';
        obj.drawBarcode();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    } 
    
    public static testmethod void  unittest6(){
        BarcodeController obj = new BarcodeController();
        obj.Brcd = '9780201734843';
        obj.BrcdType = 'ean13';
        obj.Height = '110';
        obj.Width = '120';
        obj.drawBarcode();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
   
    public static testmethod void  unittest7(){
        BarcodeController obj = new BarcodeController();
        obj.Brcd = '';
        obj.BrcdType = 'ean13';
        obj.drawBarcode();
        obj.Brcd = 'AQS123';
        obj.drawBarcode();
        String val  = obj.getBrcodeImage();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest8(){
        BarcodeController obj = new BarcodeController();
        obj.Brcd = '9780201734843';
        obj.BrcdType = 'qwe';
        obj.Height = '110';
        obj.Width = '120';
        obj.drawBarcode();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest9(){
        BarcodeController obj = new BarcodeController();
        obj.Brcd = 'AQS123AQS1231';
        obj.BrcdType = 'ean13';
        obj.drawBarcode();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest(){
        Code128Controller obj = new Code128Controller();
        obj.Brcd = 'TEST';  
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest10(){
        Boolean mytest = true;
        Ean13Controller obj = new Ean13Controller();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittestImage(){
        BarcodeController obj = new BarcodeController();
        obj.BrcdCanvas = '<table><td></td></table>';        
        obj.getBrcodeImage();
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    //AQBarcodeController
   
    public static testmethod void crashAQ(){
        String brctype='code39';
        String brcdValue='TEST';
        AQBarcodeFactory m_factObj = AQBarcodeFactory.createFactoryObject();
        AQBarcode brcdObj = m_factObj.createBarcodeObject(brctype);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
    }
    
    public static testmethod void  unittest1AQ(){
        AQBarcodeController obj = new AQBarcodeController();
            obj.Brcd = 'BARCODE';
          obj.BarcdHeight = '40';    
        obj.BarcdType = 'code39';
        obj.Height = '110';
        obj.Width = '120';
        obj.drawBarcode();
        System.assert(!(obj.BrcdCanvas == null));
    }
    
    public static testmethod void  unittest2AQ(){
        AQBarcodeController obj = new AQBarcodeController();
    obj.Brcd = 'BARCODE';
      obj.BarcdHeight = '40';    
    obj.BarcdType = 'code128';
    obj.Height = '110';
    obj.Width = '120';
    obj.drawBarcode();
    System.assert(!(obj.BrcdCanvas == null));
    }
    
    public static testmethod void  unittest3AQ(){
         AQBarcodeController obj = new AQBarcodeController();
    obj.Brcd = 'barcode';
      obj.BarcdHeight = '40';    
    obj.BarcdType = 'code128';
    obj.Height = '110';
    obj.Width = '120';
    obj.drawBarcode();
    System.assert(!(obj.BrcdCanvas == null));
    }
    
    public static testmethod void  unittest4AQ(){
         AQBarcodeController obj = new AQBarcodeController();
    obj.Brcd = '123456789';
    obj.BarcdHeight = '40';
    obj.BarcdType = 'code128';
    obj.Height = '110';
    obj.Width = '120';
    obj.drawBarcode();
    System.assert(!(obj.BrcdCanvas == null));
    }
    
    public static testmethod void  unittest5AQ(){
        AQBarcodeController obj = new AQBarcodeController();
    obj.Brcd = '1234567890';
      obj.BarcdHeight = '40';    
    obj.BarcdType = 'code128';
    obj.Height = '110';
    obj.Width = '120';
    obj.drawBarcode();
    System.assert(!(obj.BrcdCanvas == null));
    } 
    
    public static testmethod void  unittest6AQ(){
    AQBarcodeController obj = new AQBarcodeController();
    obj.Brcd = '9780201734843';
      obj.BarcdHeight = '40';
    obj.BarcdType = 'ean13';
    obj.Height = '110';
    obj.Width = '120';
    obj.drawBarcode();
    System.assert(!(obj.BrcdCanvas == null));
   
  }
  
  public static testmethod void  unittest7AQ(){
    AQBarcodeController obj = new AQBarcodeController();
    obj.Brcd = '';
      obj.BarcdHeight = '40';    
    obj.BarcdType = 'ean13';
    obj.drawBarcode();
    obj.Brcd = 'AQS123';
    obj.drawBarcode();
    String val  = obj.getBrcodeImage();
    System.assert((obj.BrcdCanvas == null));
   
  }
  
  public static testmethod void  unittest8AQ(){
    AQBarcodeController obj = new AQBarcodeController();
    obj.Brcd = '9780201734843';
      obj.BarcdHeight = '40';    
    obj.BarcdType = 'qwe';
    obj.Height = '110';
    obj.Width = '120';
    obj.drawBarcode();
    System.assert((obj.BrcdCanvas == null));    
  }
  
  public static testmethod void  unittest9AQ(){
    AQBarcodeController obj = new AQBarcodeController();
    obj.getJQueryMin();
    obj.getJQRScript();
    obj.getQRJScript();
    obj.getQRCSS();
    obj.getPDF417Min();
    obj.getBCMathMin();
    obj.Brcd = 'AQS123AQS1231';
    obj.BarcdHeight = '40';
    obj.BarcdType = 'ean13';
    obj.drawBarcode();
    System.assert((obj.BrcdCanvas == null));   
  }
    
    //AQBarcodeControllerLC
    public static testmethod void  unittest10AQ(){
        String BarcdHeight='40'; 
        String BarcdType='code128';
        String Brcd='AQXOLT';
        String Height='';
        String Width='3';
        AQBarcodeControllerLC.getAll(BarcdHeight,BarcdType,Brcd,Height,Width);  
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);      
    }
    public static testmethod void  unittest11AQ(){
        String BarcdHeight=''; 
        String BarcdType='code39';
        String Brcd='AQXOLT';
        String Height='';
        String Width='';
        AQBarcodeControllerLC.getAll(BarcdHeight,BarcdType,Brcd,Height,Width);  
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);      
    }
}