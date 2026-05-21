global with sharing class CreditNote {
    
   
    global string forCreditName{
        get{
            return forCreditName;  }  set{    forCreditName=value; InitMethod();  }
    }
   global string forCreditDate{
        get{    return forCreditDate; } set{  forCreditDate=value;  InitMethod();   }
    }
    global string forDescription{
        get{   return forDescription;  } set{ forDescription=value; InitMethod();   }
    }
    Global Invoice__c invoice {get; set;} public ERP7__Credit_Note__c creditName {get;set;} public ERP7__Credit_Note__c creditDate {get;set;}   public ERP7__Credit_Note__c creditDescription {get;set;}
    Global void InitMethod(){
      
        invoice =new Invoice__c();
        if(forCreditName!=null)   creditName=[select id, name from ERP7__Credit_Note__c where ERP7__Invoice__c=:forCreditName];
        if(forCreditDate!=null) creditDate=[select id, name,ERP7__Applied_Date__c from ERP7__Credit_Note__c where ERP7__Invoice__c=:forCreditDate];    
        if(forDescription!=null)  creditDescription=[select id, name,ERP7__Applied_Date__c,ERP7__Description__c from ERP7__Credit_Note__c where ERP7__Invoice__c=:forDescription];    
          
    }

}