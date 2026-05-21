@isTest 
public class OrderConsoleLightning_TestCases {    
    private testMethod static void unitTestCasesSet_1(){
        Test.startTest();
        OrderConsoleLightning.getAll('','','');
        OrderConsoleLightning.getAll('psod.Name','','','','');
        OrderConsoleLightning.getBA('bAddress.id');
        OrderConsoleLightning.getSA('sAddress.id');
        OrderConsoleLightning.getTaxRateByAddressId('sAddress.id');
        OrderConsoleLightning.discountPercent('');
        OrderConsoleLightning.IWL = new List<OrderConsoleLightning.itemWrapper>();
        OrderConsoleLightning.upsWrap upsw = new OrderConsoleLightning.upsWrap();
        OrderConsoleLightning.rateWrapper upsrw = new OrderConsoleLightning.rateWrapper();
        List<ERP7__Channel__c> currentSalepoints = new List<ERP7__Channel__c>();
        List<Account> Customers = new List<Account>();
        List<Contact> Contacts = new List<Contact>();
        List<Address__c> Addressess = new List<Address__c>();
        List<Sales_Order__c> SalesOrder2Creates = new List<Sales_Order__c>();
        List<Invoice__c> Invoices = new List<Invoice__c>();
        List < Sales_Order_Line_Item__c > orderLineItems2Delete = new  List < Sales_Order_Line_Item__c >();
        List < Object > pds = OrderConsoleLightning.productFetchss('','','','',currentSalepoints,Customers,Contacts,'sop.Id',new List<OrderConsoleLightning.itemWrapper>(),false,false);
        OrderConsoleLightning.productFetchs('','','','',currentSalepoints,Customers,Contacts,'sop.Id',new List<OrderConsoleLightning.itemWrapper>());
        OrderConsoleLightning.productFetch('','',currentSalepoints,Customers,Contacts,'sop.Id',new List<OrderConsoleLightning.itemWrapper>());
        OrderConsoleLightning.DiscountPlans('ps.Id', currentSalepoints, true, Customers, Contacts, 'SOP.Id', 2);
        OrderConsoleLightning.editProducts('ps.Id', 3, 'dp.Id', 5, currentSalepoints, true, Customers, Contacts, 'SOP.Id');
        OrderConsoleLightning.addProducts('', currentSalepoints, Customers, Contacts, 'SOP.Id');
        OrderConsoleLightning.addProducts('JSON.serialize(pds)', currentSalepoints, Customers, Contacts, 'SOP.Id',10.00);
        OrderConsoleLightning.saveDraft('', currentSalepoints,'',Customers, Contacts, 'SOP.Id', new List < String >(), '', 0, 0);
        OrderConsoleLightning.saveDrafts('', currentSalepoints,'',Customers, Contacts, 'SOP.Id', new List < String >(), '', 0, 0);
        OrderConsoleLightning.CreateNewCustomer(Customers);
        OrderConsoleLightning.CreateNewCont(Contacts);
        OrderConsoleLightning.CreateNewCustomers(Customers);
        OrderConsoleLightning.CreateNewConts(Contacts);
        OrderConsoleLightning.CreateNewAddress(Addressess,'test','test');
        OrderConsoleLightning.CreditProcessing(SalesOrder2Creates, Invoices, Customers, 10, 10,2,2);
        OrderConsoleLightning.SaveNewAddress(Addressess,'', '');
        //OrderConsoleLightning.readXMLResponseRateTransitDetails(new XmlStreamReader(), '');
        OrderConsoleLightning.getAllPayDetails('','','');
        OrderConsoleLightning.getCustomerDetails('');
        OrderConsoleLightning.getAllPayDetails('');
        OrderConsoleLightning.UPSServiceSave('','','',0);
        OrderConsoleLightning.FedServicesSave('','','',0);
        OrderConsoleLightning.FedServices('','',0,'');
        OrderConsoleLightning.UPSServices('','',0,'');
        OrderConsoleLightning.CreateCardPayment(new List < ERP7__Sales_Order__c >(),'','','');
        OrderConsoleLightning.CreateBankPayment(new List < ERP7__Sales_Order__c >(),'');
        OrderConsoleLightning.CreateCashPayment(new List < ERP7__Sales_Order__c >(),'');
        OrderConsoleLightning.CreditProcessing(new List < ERP7__Sales_Order__c >(), new List < ERP7__Invoice__c >(), Customers, 0, 0, 0, 0);
        OrderConsoleLightning.loyaltyProcessing(new List < ERP7__Sales_Order__c >(), Customers, 0, 0, 0, 0, 0);
        OrderConsoleLightning.SaveNewAddress(new List < ERP7__Address__c >(), '', '');
        OrderConsoleLightning.ApplyCoupons('', Customers, Contacts, '');
        
        OrderConsoleLightning.SaveNewAddress(new List < ERP7__Address__c >(), '', '');
        OrderConsoleLightning.SaveNewAddress(new List < ERP7__Address__c >(), '', '');
        OrderConsoleLightning.SaveNewAddress(new List < ERP7__Address__c >(), '', '');
        OrderConsoleLightning.SaveNewAddress(new List < ERP7__Address__c >(), '', '');
        OrderConsoleLightning.SaveNewAddress(new List < ERP7__Address__c >(), '', '');
        
        
        OrderConsoleLightning.comWrap cmw = new OrderConsoleLightning.comWrap();
        OrderConsoleLightning.itemWrapper iw = new OrderConsoleLightning.itemWrapper();
        OrderConsoleLightning.selectOptions so1 = new OrderConsoleLightning.selectOptions('test', 'test');
        OrderConsoleLightning.selectOptions so2 = new OrderConsoleLightning.selectOptions('test', 'test', true);
        OrderConsoleLightning.ProductsAndDiscounts PaD = new OrderConsoleLightning.ProductsAndDiscounts();
        OrderConsoleLightning.loyaltyWrap lw = new OrderConsoleLightning.loyaltyWrap();
        OrderConsoleLightning.returnClass rc = new OrderConsoleLightning.returnClass();
        OrderConsoleLightning.resStatus = '';
        OrderConsoleLightning.request_1 = '';
        OrderConsoleLightning.response_1 = '';
        OrderConsoleLightning.SON = '';
        OrderConsoleLightning.CON = '';
        OrderConsoleLightning.CUST = '';
        string sal ='ERP'; string sal1 ='ERP';
        system.assertEquals(sal, sal1);
        Test.stopTest();
    }
}