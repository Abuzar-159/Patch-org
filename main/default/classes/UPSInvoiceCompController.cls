public with sharing class UPSInvoiceCompController {
    
    public String shipmentId         { get; set; }    
    public String currencycode       { get; set; }    
    public Decimal invoiceTotal      { get; set; }
    public Integer NoOfPackages      { get; set; } 
    public Decimal packageWeight     { get; set; }    
    
    /*
      method for getting organization's currency code
    */
    public static String getCurrencyIsoCode(SObject someObject) {
        String currencyIso = UserInfo.isMultiCurrencyOrganization() ? (String) someObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
        return currencyIso;
    }
    
    /*
      getting all package list upon shipment.
    */    
    public List<plWrapper> getPackageListsWrapper() {
        List<plWrapper> packListWrapper = new List<plWrapper>(); 
        try {
            List<Country_Codes__c> countryCodes;
            Set<Id> productIds = new Set<Id>();
            Set<Id> custProfileIds = new Set<Id>();            
            if(shipmentId != null && shipmentId != '') {
                Organization myOrg = [Select o.Id, o.Country, o.ComplianceBccEmail, o.City From Organization o limit 10000]; 
                if(myOrg != null && myOrg.Country != null) countryCodes = [Select Id, Name, Code__c, Country__c From Country_Codes__c Where Country__c =: myOrg.Country Limit 1]; 
                NoOfPackages = 0; packageWeight = 0.0;               
                for (Package__c p : [select Name, Weight__c, (Select Id, Name, Active__c, Package__c, Package__r.Name, Quantity__c, Sales_Order_Line_Item__c, Package__r.Sales_Order__c, Sales_Order_Line_Item__r.Product__r.Name, ERP7__Order_Product__c, ERP7__Order_Product__r.Product2Id,ERP7__Order_Product__r.Product2.Name,
                                    Sales_Order_Line_Item__r.Quantity__c, Sales_Order_Line_Item__r.Total_Price__c, Sales_Order_Line_Item__r.Product__c, Sales_Order_Line_Item__r.ReturnedQuantity__c, Sales_Order_Line_Item__r.Sales_Order__r.Name, 
                                    Sales_Order_Line_Item__r.Base_Price__c, Sales_Order_Line_Item__r.Price_Product__c From Package_Lists__r) from Package__c Where Shipment__c =: shipmentId And Active__c = true Order by CreatedDate Asc]) {                                                  
                    for(ERP7__Package_List__c  packlist : p.Package_Lists__r) { 
                         
                        if (packlist.Sales_Order_Line_Item__c != null) {
        productIds.add(packlist.Sales_Order_Line_Item__r.Product__c);
    } else if (packlist.ERP7__Order_Product__c != null) {
        productIds.add(packlist.ERP7__Order_Product__r.Product2Id);
    }
                        
                        //custProfileIds.add(((Package_List__c)c).Sales_Order__r.Customer_Profile__c);
                        
                        plWrapper wr = new plWrapper();
                        wr.pl = (Package_List__c)packlist;
                        packListWrapper.add(wr);
                    } NoOfPackages++; 
                      packageWeight = packageWeight + p.Weight__c;
                } 
                if(productIds.size() > 0) {                 
                    List<Product2> PSAList = [select Id, Name, Declared_Shipment_Value__c, Commodity_Code__c, Goods_Description__c from Product2 where Id In: productIds];
                    invoiceTotal = 0.0;
                    for(plWrapper plw: packListWrapper) {
                        for(Product2 psa: PSAList) {
                            if(plw.pl.Sales_Order_Line_Item__r.Product__c == psa.Id) { plw.psa = psa;
                                currencycode = getCurrencyIsoCode(psa);
                                if(countryCodes != null && countryCodes.size()>0 && countryCodes[countryCodes.size() -1].Code__c != null) plw.countryCode = countryCodes[countryCodes.size() -1].Code__c;
                                else plw.countryCode = myOrg.Country;
                                if(psa.Declared_Shipment_Value__c != null) plw.totalValue = (plw.pl.Quantity__c * psa.Declared_Shipment_Value__c).setScale(2);
                                if(plw.totalValue != null) invoiceTotal = (invoiceTotal + plw.totalValue).setScale(2);
                                break;
                            }
                             else if(plw.pl.ERP7__Order_Product__r.Product2Id == psa.Id) { plw.psa = psa;
                                currencycode = getCurrencyIsoCode(psa);
                                if(countryCodes != null && countryCodes.size()>0 && countryCodes[countryCodes.size() -1].Code__c != null) plw.countryCode = countryCodes[countryCodes.size() -1].Code__c;
                                else plw.countryCode = myOrg.Country;
                                if(psa.Declared_Shipment_Value__c != null) plw.totalValue = (plw.pl.Quantity__c * psa.Declared_Shipment_Value__c).setScale(2);
                                if(plw.totalValue != null) invoiceTotal = (invoiceTotal + plw.totalValue).setScale(2);
                                break;
                            }
                        }
                    }
                }   
            }            
        } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +', '+ e.getStackTraceString() +', '+ e.getLineNumber())); }
        return packListWrapper;
    }
    
    /*
      wrapper class definitions.
    */
    public class plWrapper {
        public String countryCode                   { get; set; }  
        public Decimal totalValue                   { get; set; }
        public Package_List__c pl                   { get; set; }
        public Product2 psa    { get; set; }
        
        public plWrapper() {
            totalValue = 0;
            countryCode = '';            
            pl = new Package_List__c();
            psa = new Product2();
        }    
    }
}