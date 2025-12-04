global With Sharing Class MOLabel1{ 
    
    global Contact currentContact                                  { get; set; }    global ERP7__Batch__c Batch                                    { get; set; }
    global Sobject Record                                          { get; set; }
    global EmailTemplate MailselectedTemplate                      { get; set; }
    global String sfdcBaseURL                                      { get; set; }
    global Boolean isHtmlEmail                                     { get; set; }
    global List<SetEmailTemplates__c> EmailTemplates_uniqueName    { get; set; }
    global String pdf                                              { get; set; }
    global String renderAs                                         { get; set; }
    global String prnt                                             { get; set; }
    global String dataStr                                          { get; set; }
    
    global MOLabel1(ApexPages.StandardController controller){
        try {
            String BatchId = ApexPages.currentPage().getParameters().get('RId');
            renderAs = ApexPages.currentPage().getParameters().get('ra');
            prnt = ApexPages.currentPage().getParameters().get('nav');
            dataStr = '';
            List<ERP7__Batch__c> bats =  [Select Id, Name, Connection_Data__c From ERP7__Batch__c Where Id =: BatchId Limit 1];
            List< ERP7__Serial_Number__c > sers =  [Select Id, Name, Connection_Data__c From ERP7__Serial_Number__c Where Id =: BatchId Limit 1];
            if(bats.size() > 0) Record = bats[0];            else if(sers.size() > 0) Record = sers[0]; 
            currentContact = [Select id, Name, FirstName, LastName ,Email, AccountId, Account.Organisation__c, Phone, Contact_Numer__c, Company__c From Contact Where Email != null Limit 1];
            
            
            
            /* Fetching instance Name From SFDC URL */
            /*
            sfdcBaseURL = URL.getSalesforceBaseUrl().getHost();
            sfdcBaseURL = sfdcBaseURL.replace('.visual.force.com','.content.force.com');
            sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
            */
            
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';//URL.getSalesforceBaseUrl().getHost();
            
            system.debug('sfdcBaseURL here1~>'+sfdcBaseURL);
            
            String initurl = Label.initURL;
            String DestinationURL = Label.DestURL;
            
            system.debug('initurl here1~>'+initurl);
            system.debug('DestinationURL here1~>'+DestinationURL);
            
            sfdcBaseURL = sfdcBaseURL.replace(initurl,DestinationURL);
            sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');  //need to uncommented
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            
            /* Querying The Template for Preview and attachment */
            if(bats.size() > 0){
                dataStr = bats[0].Connection_Data__c;
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c, OrgWideEmailAddress__c, Html_Body__c, TemplateAsAttachment__c, Add_Template_As_Attachment__c 
                                                From SetEmailTemplates__c 
                                                where Name = 'MOLabelBatchp'
                                                limit 1];
                if (EmailTemplates_uniqueName.isEmpty()) {
                    EmailTemplates_uniqueName = new List < SetEmailTemplates__c > ();
                    EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null, Template_Unique_Name__c = 'MOLabelBatchp', TemplateAsAttachment__c = true,
                        Add_Template_As_Attachment__c = true, Html_Body__c = false));
                }
            }
            if(sers.size() > 0){ dataStr = sers[0].Connection_Data__c;
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c, OrgWideEmailAddress__c, Html_Body__c, TemplateAsAttachment__c, Add_Template_As_Attachment__c 
                                                From SetEmailTemplates__c 
                                                where Name = 'MOLabelSerialp'
                                                limit 1];
                if (EmailTemplates_uniqueName.isEmpty()) { EmailTemplates_uniqueName = new List < SetEmailTemplates__c > ();  EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null, Template_Unique_Name__c = 'MOLabelSerialp', TemplateAsAttachment__c = true,  Add_Template_As_Attachment__c = true, Html_Body__c = false));
                }
            }
            if (EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c != null) {
                MailselectedTemplate = [select id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName = : EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c]; 
                isHtmlEmail = EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Html_Body__c;
            } else { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'To SetUp  Email Template provide Unique Template Name or Contact your Administrator')); }
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
    }
    
     global pageReference createPDF() {
        try {
            String csfdcBaseURL;
            if(renderAs == 'pdf') {
                csfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
                String sendEmailBaseURL = Label.sendEmailBaseURL; 
                system.debug('sendEmailBaseURL here1'+sendEmailBaseURL);
                
                sendEmailBaseURL = sfdcBaseURL.replace(Label.DestURL,sendEmailBaseURL);
                sendEmailBaseURL = sendEmailBaseURL.replace('--c','');
                system.debug('sendEmailBaseURL here2'+sendEmailBaseURL);
                
                csfdcBaseURL = sendEmailBaseURL;
                csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
             }
             else csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c'); csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            
            PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?PageRef.getContentAsPdf():Blob.valueOf('Test'));
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        if(renderAs == 'pdf') return page.MOLabelPDF1;
        else return null;
    }   
    
}