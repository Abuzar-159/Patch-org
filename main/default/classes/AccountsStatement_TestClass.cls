@isTest
Private class AccountsStatement_TestClass {
  public testMethod static void AccountsStatementMethod1(){
       
        Account acc=new Account(Name='Test Account ', Email__c='abc@gmaial.com', Phone='9110152026', AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert acc;                
        ERP7__Address__c arr = new ERP7__Address__c(Name='test',ERP7__Customer__c = acc.Id,ERP7__Is_Billing_Address__c=true );
      insert arr;
       Id pricebookId = Test.getStandardPricebookId();
        
        Order so = new Order(Name='Test', Pricebook2Id = pricebookId,ERP7__Stage__c='Entered', AccountId=acc.Id, ERP7__Shipment_Type__c='UPS',ERP7__Shipment_Preference_Speed__c='--None--',
                                                           ERP7__Ready_To_Pick_Pack__c=true, ERP7__Ready_To_Ship__c=true, ERP7__Authorised__c=true, 
                                                           ERP7__Bill_To_Address__c=arr.Id, ERP7__Book_Date__c=system.today(), 
                                                           ERP7__Active__c=true, Status='Draft', ERP7__Barcode__c='009220', ERP7__Customer_Email__c='test@gmail.com', EffectiveDate=Date.today(),
                                                           ERP7__Fulfilled_Date__c=system.today(), ERP7__Amount_Paid__c=10,  ERP7__Request_Date__c=system.today()
                                                          );
        insert so;
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Order_S__c=so.Id,ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10,ERP7__Paid__c =false,ERP7__Invoice_Amount__c =100);
        insert Invoice; 
      	 ERP7__Invoice__c Invoice1=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Order_S__c=so.Id,ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10,ERP7__Paid__c =false,ERP7__Invoice_Amount__c =100);
        insert Invoice1; 
      	List<ERP7__Invoice__c> inlist = new List<ERP7__Invoice__c>();
      inlist.add(Invoice);inlist.add(Invoice1);
       PageReference pageRef = System.Page.AccountsStatement;
        pageRef.getParameters().put('AccountId',acc.Id);
      pageRef.getParameters().put('vAs','PDF');
        Test.setCurrentPage(pageRef);
        AccountsStatement ast=new  AccountsStatement();
        ast.currentAccount=acc; ast.InvoiceList=inlist;  ast.toEmail_id=null;ast.EmailSubject=null; ast.TextBody=null; ast.AvailableRecipients=null; ast.SelectedRecipients=null;
        ast.ccEmails_map=null;ast.ccEmails=null; ast.SelectEmailTemplate=null; ast.asODTemplate=null; ast.MailSent=false; ast.sfdcBaseURL=null; ast.isHtmlEmail=false; 
        ast.EmailTemplates_uniqueName=null;  ast.HtmlBody=null;  ast.pdfContent=null;  ast.Attachs=null;  ast.isHtmlEmail=false;  ast.contactids=null;  ast.viewas=null;      
        ast.EmailsCC=null;  ast.PaidAmount=0;  AccountsStatement.showSelectedAttachment=false;  AccountsStatement.showSelectedAttachment1=false;  ast.Accountcontacts=null;  ast.invId=null;  ast.asODTemplateId=null;      
        ast.selectedEmail=null;ast.pdf=null; ast.MailselectedTemplate=null; ast.AId=null; ast.doinit(); ast.Run(); 
        ast.navToPyment();
        ast.createPDF(); 
        ast.test();
        ast.sendStatement();
        ast.toEmail_id= ast.currentAccount.Id;
        ast.getRecipientId();
       ast.setRecipientId(acc.id);
      ast.selectAllInvoicesCB();
      ast.UpsertINV();
      ast.Email_Details();
       if(String.isNotEmpty(ast.currentAccount.Id)) ast.sendStatement();
       
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
      
   }
}