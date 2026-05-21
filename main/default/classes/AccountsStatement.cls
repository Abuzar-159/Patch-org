global With Sharing Class AccountsStatement{ 
    
    global list<Invoice__c> InvoiceList                			{ get; set; } 
    global Account currentAccount                      			{ get; set; }
    global ERP7__Address__c currentAccountAddress               { get; set; }
    global String  toEmail_id                          			{ get; set; }
    global String EmailSubject                         			{ get; set; }
    global String TextBody                             			{ get; set; }
    global List<selectoption> AvailableRecipients      			{ get; set; }
    global List<selectoption> SelectedRecipients       			{ get; set; }
    global String selectedEmail                        			{ get; set; }
    global Map<string,string> ccEmails_map             			{ get; set; }
    global list<String>  ccEmails                      			{ get; set; }    
    global EmailTemplate SelectEmailTemplate           			{ get; set; }  
    global EmailTemplate ASODTemplate                  			{ get; set; }  
    global Boolean MailSent                            			{ get; set; }
    global String sfdcBaseURL                          			{ get; set; }
    global String pdf                          					{ get; set; }
    global Boolean isHtmlEmail                         			{ get; set; }
    global List<SetEmailTemplates__c> EmailTemplates_uniqueName { get; set; }
    global String HtmlBody                             			{ get; set; }
    global blob pdfContent                             			{ get; set; }
    global attachment Attachs                          			{ get; set; }
    global list<String> contactids                           	{ get; set; }
    global String viewAS 										{ set; get; }
    global String  EmailsCC                      				{ get; set; }   
    global EmailTemplate MailselectedTemplate          			{ get; set; }
    global String AccountId                      				{ get; set; }
    global String sendInvoiceConfirmation                      	{ get; set; } 
    global list<Invoice__c> SlectedInvoiceList            		{ get; set; }        
    global static String hrefStr                          		{ get; set; }
    global Decimal DueAmount                       				{ get; set; }
    global Decimal TotalAmount                       			{ get; set; }
    global Decimal PaidAmount                       			{ get; set; }
    global static Boolean showSelectedAttachment          		{ get; set; }
    global static Boolean showSelectedAttachment1          		{ get; set; }
    global list<Contact> Accountcontacts                 		{ get; set; }
    global String  invId                      					{ get; set; } 
    global String  ASODTemplateId               				{ get; set; } 
    global Document doc                      					{ get; set; } 
    global Boolean allInvoicesSelect							{ get; set; }
    public String DueAmountStr									{ get; set; }
    public Date todayDate										{ get; set; }
    public Boolean thirtydays 									{get;set;}
    public Boolean sixtydays 									{get;set;}
    public Boolean ninetydays 									{get;set;}
    global string recipientId;
    global string getRecipientId() {return recipientId; }
    global void setRecipientId(string inString) { AccountId=inString;        InvoiceList=new list<Invoice__c>();
                                                 if(String.isNotEmpty(AccountId ))  InvoiceList=[SELECT Id, Name, ERP7__Active__c,ERP7__Status__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Order__r.ERP7__Purchase_Order_Number__c,ERP7__Order_S__r.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Total_Discount__c
                                                                                                 ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order__c,ERP7__Order_S__c, ERP7__Order__r.ERP7__Status__c ,ERP7__Order_S__r.Status, ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Order__r.ERP7__Order_Date__c,ERP7__Order_S__r.EffectiveDate, ERP7__Due_Date__c                  
                                                                                                 ,ERP7__Order__r.Name ,ERP7__Order_S__r.Name,ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c
                                                                                                 FROM ERP7__Invoice__c WHERE ERP7__Account__c=:AccountId AND (ERP7__Order__c!=Null OR ERP7__Order_S__c!=Null) AND Total_Due__c>0 and  ERP7__Paid__c=false
                                                                                                ];            
                                                 Set<Id> invIds1=new Set<Id>();
                                                 set<Id> transId = new Set<Id>();
                                                 for(ERP7__Invoice__c inv:InvoiceList)invIds1.add(inv.Id);
                                                 if(invIds1.size() > 0){  SlectedInvoiceList = new List<ERP7__Invoice__c>();   
                                                                        SlectedInvoiceList=[SELECT Id, Name, ERP7__Active__c,ERP7__Status__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Order__r.ERP7__Purchase_Order_Number__c,ERP7__Order_S__r.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Total_Discount__c
                                                                                            ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order__c,ERP7__Order_S__c, ERP7__Order__r.ERP7__Status__c ,ERP7__Order_S__r.Status, ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Order__r.ERP7__Order_Date__c,ERP7__Order_S__r.EffectiveDate, ERP7__Due_Date__c ,ERP7__Due_date_days__c                 
                                                                                            ,ERP7__Order__r.Name ,ERP7__Order_S__r.Name,ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c
                                                                                            FROM ERP7__Invoice__c 
                                                                                            WHERE Id IN:invIds1 AND ERP7__Due_Date__c != null and ERP7__Paid__c=false Order by ERP7__Due_Date__c desc
                                                                                           ]; 
                                                                        DueAmount=0; TotalAmount=0; PaidAmount=0;
                                                                        for(ERP7__Invoice__c  inv:SlectedInvoiceList){   DueAmount+=inv.Total_Due__c; TotalAmount+=inv.Sales_Order_Amount__c;  PaidAmount+=inv.Amount_Paid__c;   transId.add(inv.Id);}
                                                                       }
                                                 if(SlectedInvoiceList[0].ERP7__Due_date_days__c > 30 && SlectedInvoiceList[0].ERP7__Due_date_days__c <=60 ){thirtydays = true;} if(SlectedInvoiceList[0].ERP7__Due_date_days__c > 60 && SlectedInvoiceList[0].ERP7__Due_date_days__c <=90 ){sixtydays = true;} if(SlectedInvoiceList[0].ERP7__Due_date_days__c > 90){ninetydays = true;}
                                                }
    
    
    
    global  String AId{
        get{
            return AId;
        }
        set{
            
            AId=value;
            doInit();
        }
    }
    public void doinit(){
        
    }
    
    global PageReference Run() {
        return null;
    }
    
    global AccountsStatement(){ 
        try{
            todayDate = system.today();            
            allInvoicesSelect = true;
            AccountId=ApexPages.currentPage().getParameters().get('AccountId');
            EmailsCC='';
            try{   
                viewAS=ApexPages.currentPage().getParameters().get('vAs');  }catch(Exception ex){}
            
            try{    
                InvoiceList=new list<Invoice__c>();
                if(String.isNotEmpty(AccountId ))  InvoiceList=[SELECT Id, Name, ERP7__Active__c,ERP7__Status__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Order__r.ERP7__Purchase_Order_Number__c,ERP7__Order_S__r.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Total_Discount__c
                                                                ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order__c,ERP7__Order_S__c, ERP7__Order__r.ERP7__Status__c ,ERP7__Order_S__r.Status, ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Order__r.ERP7__Order_Date__c,ERP7__Order_S__r.EffectiveDate, ERP7__Due_Date__c                  
                                                                ,ERP7__Order__r.Name ,ERP7__Order_S__r.Name,ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c
                                                                FROM ERP7__Invoice__c 
                                                                WHERE ERP7__Account__c=:AccountId AND (ERP7__Order__c!=Null OR ERP7__Order_S__c!=Null) AND Total_Due__c>0 and ERP7__Paid__c=false
                                                               ];    
                                
                list<ERP7__Invoice__c> InvList=new list<ERP7__Invoice__c>(); 
                for(ERP7__Invoice__c  inv:InvoiceList) {  inv.ERP7__Active__c=true; InvList.add(inv);
                                                       }
                InvoiceList.clear();
                InvoiceList.addAll(InvList);
                
                sendInvoiceConfirmation='';
                //sfdcBaseURL = URL.getSalesforceBaseUrl().getHost(); 
                sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();
                //sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
               sfdcBaseURL = sfdcBaseURL.replace('visual.force.com','content.force.com'); //need to be uncommented
               // sfdcBaseURL = sfdcBaseURL.replace('.visualforce.com','.documentforce.com');
                sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
                AvailableRecipients =new List<selectoption>();
                ccEmails_map=new Map<string,string>();
                ccEmails=new  list<String>();         
                
                if(String.isNotEmpty(AccountId)) currentAccount = [Select id, Name , Email__c, Phone From Account Where Id=:AccountId];
                if(String.isNotEmpty(AccountId)) currentAccountAddress = [Select id, Name , ERP7__Customer__c, ERP7__Is_Billing_Address__c, ERP7__Country__c, ERP7__State__c, ERP7__Postal_Code__c, ERP7__City__c, ERP7__Address_Line1__c  From ERP7__Address__c Where ERP7__Customer__c=:AccountId AND ERP7__Is_Billing_Address__c=true LIMIT 1];
                if(String.isNotEmpty(AccountId)) toEmail_id = currentAccount.Email__c; else toEmail_id='';
                MailSent = false;
                List<Contact> Allcontacts=new list<Contact>();
                try{
                    if(String.isNotEmpty(currentAccount.Id)) Allcontacts=[SELECT  Id, Name, FirstName, LastName ,Email, AccountId,Account.Organisation__c, Phone, Contact_Numer__c, Company__c FROM Contact where AccountId=:currentAccount.Id];
                }catch(Exception ex){}    
                Email_Details();
                
                contactids=new list<String>();                           
                for(Contact c:Allcontacts) contactids.add(c.Id); 
                
                if(Allcontacts!=null && Allcontacts.size()>0) for(Integer i=0;i<Allcontacts.size()&&i<1000;i++){  Contact c=Allcontacts[i]; AvailableRecipients.add(new SelectOption(c.id,c.Name)); ccEmails_map.put(c.id,c.Email);
                                                                                                               }
                
                Accountcontacts=Allcontacts;  }catch(Exception e){   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()+ ' @ Line Number ' +e.getLineNumber()));
                                                                  
                                                                 }  
            
            
            try{                               
                String InvIds=ApexPages.currentPage().getParameters().get('InvIds');
                String[] strArray; if(InvIds != '' && InvIds != null) strArray=InvIds.split(','); 
                
                hrefStr=''; DueAmount=0; TotalAmount=0; PaidAmount=0; showSelectedAttachment=false;
                if(String.isNotEmpty(InvIds)){  SlectedInvoiceList = new List<ERP7__Invoice__c>();   SlectedInvoiceList=[SELECT Id, Name, ERP7__Active__c,ERP7__Status__c,ERP7__Amount_Paid__c,  ERP7__Code__c, ERP7__Account__c, ERP7__Customer_Id__c, ERP7__Discount_Amount__c, ERP7__Customer_Purchase_Order_No__c, ERP7__Order__r.ERP7__Purchase_Order_Number__c,ERP7__Order_S__r.ERP7__Customer_Purchase_Order_Reference__c, ERP7__Total_Discount__c
                                                                                                                         ,ERP7__Total_Due__c, ERP7__Final_Due_Amount__c, ERP7__Invoice_Amount__c, ERP7__Invoice_Date__c, ERP7__Name__c, ERP7__Order__c,ERP7__Order_S__c, ERP7__Order__r.ERP7__Status__c ,ERP7__Order_S__r.Status, ERP7__Account__r.ERP7__Payment_Terms__c, ERP7__Order__r.ERP7__Order_Date__c,ERP7__Order_S__r.EffectiveDate, ERP7__Due_Date__c                  
                                                                                                                         ,ERP7__Order__r.Name ,ERP7__Order_S__r.Name,ERP7__Order_Number__c, ERP7__Organisation__c, ERP7__Organisation__r.Name, ERP7__Paid__c, ERP7__Posted__c, ERP7__Posted_Date__c, ERP7__Return_Amount__c, ERP7__Sales_Order_Amount__c, ERP7__Sub_Total_Amount__c, ERP7__Tax_Amount__c, ERP7__Total_Tax__c, ERP7__Tax_Receipt__c
                                                                                                                         FROM ERP7__Invoice__c 
                                                                                                                         WHERE Id IN:strArray
                                                                                                                        ];
                                              
                                              for(ERP7__Invoice__c  inv:SlectedInvoiceList){  DueAmount+=inv.Total_Due__c; TotalAmount+=inv.Sales_Order_Amount__c; PaidAmount+=inv.Amount_Paid__c;  }   }  }catch(Exception e){ } 
            
            
            
            try{      
                doc=new Document();
                doc=[SELECT Id, Name FROM Document WHERE Name='Organisation Logo'];
                
            }catch(Exception ex){}  }catch(Exception ex){   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()+ ' @ Line Number ' +ex.getLineNumber()));
                                                        
                                                        }
    }
    
    
    global pageReference navToPyment(){ 
        if(DueAmount==null) DueAmount=0;
        sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
        String Url='https://'+sfdcBaseURL+'/apex/ERP7__CardPaymentLC?AccountId=' +AccountId+ '&DA=' +DueAmount; 
        PageReference pageRef = new PageReference(Url);
        pageRef.setRedirect(true);
        
        return pageRef;
    } 
    
    global pageReference createPDF() {
        try{ 
            SlectedInvoiceList=new list<ERP7__Invoice__c>();
            list<ERP7__Invoice__c> InvList=new list<ERP7__Invoice__c>(); 
            String InvIds='';
            
            for(Integer i=0; i<InvoiceList.size(); i++) {  if(InvoiceList[i].Active__c==true){  InvList.add(InvoiceList[i]); InvIds +=','+InvoiceList[i].Id;
                                                                                             } 
                                                        }
            
            SlectedInvoiceList.addAll(InvList);
            SelectEmailTemplate=new EmailTemplate();  SelectEmailTemplate = [Select Id, Name From EmailTemplate where Name ='Account Statement' limit 1]; /*String sfdcBaseURL=URL.getSalesforceBaseUrl().getHost();*/String sfdcBaseURL=System.Url.getOrgDomainUrl().getHost();  String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c'); sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';  String myURL = 'https://'+sfdcBaseURL+'/apex/ERP7__Invoices?vAs=pdf&AccountId='+AccountId+'&InvIds='+InvIds;
            PageReference pageRef = new PageReference(myURL);  pageRef.setRedirect(true);  Blob b = pageRef.getContentAsPdf();  if(!test.isRunningTest()) pdf =EncodingUtil.Base64Encode(Blob.valueOf('Test')); return pageRef;
        }catch(exception ex){   return null; }   
        
        
    }  
    
    global pageReference test() {
        return null;
        
    }  
    
    public PageReference UpsertINV() {
        
        SlectedInvoiceList = new List<ERP7__Invoice__c>();
        for(ERP7__Invoice__c inv : InvoiceList){  if(inv.Active__c == true) { SlectedInvoiceList.add(inv);
                                                                            }
                                               }
        DueAmount = TotalAmount = PaidAmount = 0;
        for(ERP7__Invoice__c  inv:SlectedInvoiceList){   DueAmount += inv.Total_Due__c;  TotalAmount += inv.Sales_Order_Amount__c;  PaidAmount += inv.Amount_Paid__c;
                                                     } 
        return null;
    }
    
    global String Email_Details(){ //void 
        try{
                 
            SelectEmailTemplate=new EmailTemplate(); 
            SelectEmailTemplate = [Select Id, Name From EmailTemplate where Name ='Account Statement' limit 1];  
                  
            EmailSubject=System.Label.AccStmt_EmailSubject;//'ERP MARK7: Your Due Amount';     
            
            // DueAmount=100;
            UpsertINV();
            
            /*String csfdcBaseURL = sfdcBaseURL.replace('visual.force.com','content.force.com');
            csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
            
            //String newBasURL = System.URL.getSalesforceBaseURL();
            //newBasURL = newBasURL.replace('salesforce.com','lightning.force.com');
            
            
            String latestBaseURL = URL.getSalesforceBaseUrl().getHost();
            latestBaseURL = sfdcBaseURL.removeEndIgnoreCase('.visualforce.com');
            latestBaseURL = latestBaseURL.replace('.visualforce.com','.visual.force.com');
            //sfdcBaseURL = sfdcBaseURL.replace('.visual.force.com','.documentforce.com');
            latestBaseURL = latestBaseURL.replace('--erp7','--c');*/
            String base='';
            Site mySite = [select Id from Site where Name = 'payments'];
            SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];            
            base=mySiteDetail.SecureURL+'?AccountId=';
            /*String payments1='payments';
            list<Network> net = new list<Network>();
            net = [SELECT Id FROM Network WHERE Name =:payments1];
            base= Network.getLoginUrl(net[0].Id);            
            base = base.replace('/login','?AccountId=');
            */
            //String hrefStr='https://'+latestBaseURL+'/apex/ERP7__CardPaymentLC?AccountId='+AccountId+'&DA='+DueAmount; 
            String hrefStr=base+AccountId+'&DA='+DueAmount;   
            
            
            TextBody='Hi '+currentAccount.Name+','+System.Label.AccStmt_Header+
                
                '<a href="'+hrefStr+System.Label.AccStm_Footer; 
            
            
            return TextBody;
        }catch(Exception ex){}
        return TextBody; 
    }
    
    global PageReference selectAllInvoicesCB(){
        if(allInvoicesSelect){
            for(ERP7__Invoice__c inv : InvoiceList) if(inv.ERP7__Active__c == false) inv.ERP7__Active__c = true;
        }
        else if(!allInvoicesSelect){
            for(ERP7__Invoice__c inv : InvoiceList) if(inv.ERP7__Active__c == true) inv.ERP7__Active__c = false;
        }
        return null;
    }
    
    global PageReference sendStatement(){
        try{
            if(String.isNotEmpty(toEmail_id)==false) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Customer email address is mandatory'));
            if(Test.isRunningTest()) toEmail_id = 'Test@gmail.com';
            SlectedInvoiceList=new list<ERP7__Invoice__c>();
            list<ERP7__Invoice__c> InvList=new list<ERP7__Invoice__c>(); 
            String InvIds = '';
            for(Integer i=0; i<InvoiceList.size(); i++) {  if(InvoiceList[i].Active__c==true){  InvList.add(InvoiceList[i]); InvIds +=','+InvoiceList[i].Id;
                                                                                             } 
                                                        }
            
            SlectedInvoiceList.addAll(InvList);
            SelectEmailTemplate=new EmailTemplate();
            SelectEmailTemplate = [Select Id, Name From EmailTemplate where Name ='Account Statement' limit 1];
            // String sfdcBaseURL=URL.getSalesforceBaseUrl().getHost();
            String sfdcBaseURL=System.Url.getOrgDomainUrl().getHost();
            String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            String myURL = 'https://'+sfdcBaseURL+'/apex/ERP7__Invoices?vAs=pdf&AccountId='+AccountId+'&InvIds='+InvIds;
            PageReference pageRef = new PageReference(myURL);
            pageRef.setRedirect(true);
            Blob b;
            if(Test.isRunningTest()) b = blob.valueOf('TESTERRR');
            else b = pageRef.getContentAsPdf();
            //pdf.getParameters().put('AccountId',AccountId);
            //pdf.getParameters().put('DueAmountStr',string.valueOf(DueAmount));
            //pdf.setRedirect(false);
            //Blob b = pdf.getContentAsPdf();
            
            //Send Statement Here  
            if(String.isNotEmpty(toEmail_id)){  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); SelectEmailTemplate =new EmailTemplate();  SelectEmailTemplate = [Select Id, Name From EmailTemplate where Name ='Account Statement' limit 1]; email.setTemplateId(SelectEmailTemplate.Id);  email.setSenderDisplayName('ERP_MARK7');  String [] toCcAddresses;  if(String.isNotEmpty(EmailsCC)) toCcAddresses = EmailsCC.split(',');  email.setCcAddresses(toCcAddresses );  String [] toAddresses = toEmail_id.split(',');  email.setToAddresses(toAddresses); email.setBccSender(false); email.setUseSignature(false); email.setTreatBodiesAsTemplate(true);   email.setSubject(EmailSubject); email.setSaveAsActivity(false);
                                              
                                              
                                              
                                              
                                              SlectedInvoiceList = new List<ERP7__Invoice__c>();  for(ERP7__Invoice__c inv : InvoiceList){ if(inv.Active__c == true) {  SlectedInvoiceList.add(inv);
                                                                                                                                                                     }
                                                                                                                                         }
                                              DueAmount = TotalAmount = PaidAmount = 0; for(ERP7__Invoice__c  inv:SlectedInvoiceList){   DueAmount += inv.Total_Due__c;  TotalAmount += inv.Sales_Order_Amount__c;   PaidAmount += inv.Amount_Paid__c;
                                                                                                                                  }
                                              
                                              //String csfdcBaseURL = sfdcBaseURL.replace('--c.','--erp7.visualforce.com');
                                                                                           
                                              //String hrefStr='https://'+csfdcBaseURL+'/apex/ERP7__CardPaymentLC?AccountId='+AccountId+'&DA='+DueAmount;
                                              
                                              String base='';
                                              Site mySite = [select Id from Site where Name = 'payments'];
                                              SiteDetail mySiteDetail = [select SecureURL from SiteDetail where DurableId = :mySite.Id];
                                              
                                              
                                              base=mySiteDetail.SecureURL+'?AccountId=';
                                              String hrefStr=base+AccountId+'&DA='+DueAmount;   
                                               
                                              
                                              
                                              TextBody=TextBody;  String lasthref = TextBody.substringAfterLast('href=');
                                              lasthref = lasthref.substringBeforeLast('target='); 
                                              
                                              String str = TextBody.replace(lasthref, '"'+hrefStr+'"');
                                              
                                              
                                              
                                              String HtmlEmailBody = '<pre style="font-size: 14px;font-family: sans-serif;">'+str+'</pre>';  email.setHtmlBody(str); //HtmlEmailBody
                                              
                                              
                                              
                                              Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment(); attach.setBody(b); attach.setFileName('Account Statement.pdf'); email.setFileAttachments(new Messaging.EmailFileAttachment[] {attach});
                                              
                                               
                                              Messaging.SendEmailResult [] Email_Result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});       mailsent = Email_Result.get(0).isSuccess();
                                              
                                              if(mailsent){  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,'Email Sent Successfully !'));
                                                          }
                                              else  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,Email_Result.get(0).getErrors()[0].getMessage()));
                                              
                                              
                                              
                                              
                                              
                                              
                                              
                                              
                                              Attachment InvoiceAttachment = new Attachment(Name=currentAccount.Name+'.pdf',contentType='application/pdf',body=(!test.isRunningTest())?b:Blob.valueof('Test'),ParentId=AccountId);
                                              
                                              for(ERP7__Invoice__c inv : InvoiceList){  inv.Active__c = false; }   SlectedInvoiceList = new List<ERP7__Invoice__c>();
                                             } 
        }catch(Exception ex){}              
        return null; //null; 
    } 
    
    
}