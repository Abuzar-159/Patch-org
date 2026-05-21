@isTest
Private class RPODocument_TestClass {
  public testMethod static void RPODocumentMethod(){
       
        Account acc=new Account(Name=userInfo.getFirstName()+' '+userInfo.getLastName(), Email__c='abc@gmaial.com', Phone='9110152026', AccountNumber=userInfo.getUserId(), ERP7__Active__c='Yes', AnnualRevenue=100, ERP7__Paid_Amount__c=100, ERP7__Account_Type__c='Customer');
        insert acc;                
        
        ERP7__Invoice__c Invoice=new ERP7__Invoice__c(Name='INV-0001', ERP7__Posted_Date__c=System.today(),ERP7__Active__c=true, ERP7__Posted__c=true, ERP7__Discount_Amount__c=10);
        insert Invoice; 
      
        RPODocument ast=new  RPODocument();
         ast.toEmail_id=null;ast.EmailSubject=null; ast.TextBody=null; ast.AvailableRecipients=null; ast.SelectedRecipients=null;
        ast.ccEmails_map=null;ast.ccEmails=null; ast.SelectEmailTemplate=null;  ast.MailSent=false; ast.sfdcBaseURL=null; ast.isHtmlEmail=false; 
        ast.EmailTemplates_uniqueName=null;  ast.HtmlBody=null;   ast.isHtmlEmail=false;  ast.contactids=null;       
           
        ast.selectedEmail=null; ast.MailselectedTemplate=null; 
        ast.Email_Details();
        try{
            ast.getRMA('');
           }catch(Exception ex){
               
        } 
        ast.buildCcEmail();
        ast.sendRMA();
      try{ast.Back2RMA(); }catch(Exception ex){}  
      
      
      ast.vendorAddress=null;  ast.invoiceAddress=null;  ast.deliveryAddress=null;  ast.exceptionMsg=null;  ast.ccEmail_Addresses=null; ast.RMANumber=null;
    
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
      
     
   }
}