public with sharing class TestDataFactory {
    public static List<Account> createOrganisationAccounts(integer n){
        List<Account> accountlist = new List<Account>();
        for(Integer i=0;i<n;i++){
            Account a = new Account();
            if(Schema.sObjectType.Account.fields.Name.isCreateable()) a.Name = 'Test_'+i;
            if(Schema.sObjectType.Account.fields.ERP7__Account_Type__c.isCreateable()) a.ERP7__Account_Type__c='Organisation';
            if(Schema.sObjectType.Account.fields.default__c.isCreateable()) a.default__c=true;
            accountlist.add(a);
        }
        if(Schema.sObjectType.Account.isCreateable()) insert accountlist; else{ }
        return accountlist;
    }
    public static List<Account> createCustomerAccounts(integer n){
        List<Account> accountlist = new List<Account>();
        for(Integer i=0;i<n;i++){
            Account a = new Account();
            if(Schema.sObjectType.Account.fields.Name.isCreateable()) a.Name = 'Test_'+i;
            if(Schema.sObjectType.Account.fields.ERP7__Account_Type__c.isCreateable()) a.ERP7__Account_Type__c='Customer';
            accountlist.add(a);
        }
        if(Schema.sObjectType.Account.isCreateable()) insert accountlist; else{ }
        return accountlist;
    }
    public static List<ERP7__Invoice__c> createInvoices(integer n,List<Account> customerAccounts){
        List<ERP7__Invoice__c> invoiceList = new List<ERP7__Invoice__c>();
        for(Account customer :customerAccounts)
        for(Integer i=0;i<n;i++){
            ERP7__Invoice__c inv = new ERP7__Invoice__c();
            if(Schema.sObjectType.ERP7__Invoice__c.fields.Name.isCreateable()) inv.Name='Test_'+i;
            if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Account__c.isCreateable()) inv.ERP7__Account__c=customer.Id;
            if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Amount__c.isCreateable()) inv.ERP7__Invoice_Amount__c=200.00*n;
            if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Posted__c.isCreateable()) inv.ERP7__Posted__c = TRUE;
            invoiceList.add(inv);
        }
        if(Schema.sObjectType.ERP7__Invoice__c.isCreateable()) insert invoiceList; else{ }
        return invoiceList;
    }
    public static List<ERP7__Invoice_Line_Item__c> createInvoicesLineItem(integer n,List<ERP7__Invoice__c> invoices){
        List<ERP7__Invoice_Line_Item__c> invoiceLineItemList = new List<ERP7__Invoice_Line_Item__c>();
        for(ERP7__Invoice__c inv :invoices)
        for(Integer i=0;i<n;i++){
            ERP7__Invoice_Line_Item__c invli = new ERP7__Invoice_Line_Item__c();
            if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.Name.isCreateable()) invli.Name='Test_'+i;
            if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Invoice__c.isCreateable()) invli.ERP7__Invoice__c =inv.id;
            if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Total_Price__c.isCreateable()) invli.ERP7__Total_Price__c=200.00;
            if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sub_Total__c.isCreateable()) invli.ERP7__Sub_Total__c =200.00;
            invoiceLineItemList.add(invli);
        }
        if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.isCreateable()) insert invoiceLineItemList; else{ }
        return invoiceLineItemList;
    }
 
    public static void createData(Integer numberofRecords){
        List<Account> accountlist = createCustomerAccounts(numberofRecords);
        List<ERP7__Invoice__c> invoiceList = createInvoices(numberofRecords*5,accountlist);
        List<ERP7__Invoice_Line_Item__c> invoiceLineItemList = createInvoicesLineItem(numberofRecords*5,invoiceList);
    }
    
    public static Map<String,Object> getData(Integer numberofRecords){
        Map<String,Object> datalist = new Map<String,Object>();
        datalist.put('customerAccount',[SELECT Id, Name FROM Account WHERE ERP7__Account_Type__c='Customer' limit :numberofRecords]);
        return datalist;
    }
}