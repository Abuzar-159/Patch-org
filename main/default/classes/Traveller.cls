global With Sharing Class Traveller{ 
    global Contact currentContact                                  { get; set; }
    global Sobject Record                                          { get; set; }
    global EmailTemplate MailselectedTemplate                      { get; set; }
    global String sfdcBaseURL                                      { get; set; }
    global Boolean isHtmlEmail                                     { get; set; }
    global List<SetEmailTemplates__c> EmailTemplates_uniqueName    { get; set; }
    global String pdf                                              { get; set; }
    global String renderAs                                         { get; set; }
    global String prnt                                             { get; set; }
    global String dataStr                                          { get; set; }
    global String Id                                               { get; set; }
    global Attachment Attachment                                   { get; set; }
    
    global Traveller(ApexPages.StandardController controller){
        try {
            if(Id == Null) Id = ApexPages.currentPage().getParameters().get('RId');
            renderAs = ApexPages.currentPage().getParameters().get('ra');
            
            system.debug('Id~>'+Id);
            system.debug('renderAs~>'+renderAs);
            
            prnt = ApexPages.currentPage().getParameters().get('nav');
            dataStr = '';
            List< ERP7__Manufacturing_Order__c > MOS =  [Select Id, Name From ERP7__Manufacturing_Order__c Where Id =: Id Limit 1];
            List< ERP7__WO__c > WOS =  [Select Id, Name From ERP7__WO__c Where Id =: Id Limit 1];
            if(MOS.size() > 0) Record = MOS[0];
            else if(WOS.size() > 0) Record = WOS[0]; 
            currentContact = [Select id, Name, FirstName, LastName ,Email, AccountId, Account.Organisation__c, Phone, Contact_Numer__c, Company__c From Contact Where Email != null Limit 1];
            Attachment = new Attachment();
            
            /* Fetching instance Name From SFDC URL */
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            
            system.debug('sfdcBaseURL here1~>'+sfdcBaseURL);
            
            String initurl = Label.initURL;
            String DestinationURL = Label.DestURL;
            
            system.debug('initurl here1~>'+initurl);
            system.debug('DestinationURL here1~>'+DestinationURL);
            
            sfdcBaseURL = sfdcBaseURL.replace(initurl,DestinationURL);
            sfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');  //need to uncommented
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            system.debug('sfdcBaseURL here2~>'+sfdcBaseURL);
            
            /* Querying The Template for Preview and attachment */
            String WOLabel = Label.WOrderTraveller;
            String MOLabel = Label.MorderTraveller;
            
            if(MOS.size() > 0){
                //dataStr = MOS[0].Connection_Data__c;
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c, OrgWideEmailAddress__c, Html_Body__c, TemplateAsAttachment__c, Add_Template_As_Attachment__c 
                                                From SetEmailTemplates__c 
                                                where Name = :MOLabel //'MOTraveller'
                                                limit 1];
                
                if (EmailTemplates_uniqueName.isEmpty()) {
                    EmailTemplates_uniqueName = new List < SetEmailTemplates__c > ();
                    EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null, Template_Unique_Name__c = MOLabel, TemplateAsAttachment__c = true,
                        Add_Template_As_Attachment__c = true, Html_Body__c = false));
                }
                List<Attachment> Attachments = [Select Id, Name, ParentId From Attachment Where ParentId =: Id And Name = 'Signature' Order By CreatedDate Asc];
                if(Attachments.size() > 0) Attachment = Attachments[0];
            }
            if(WOS.size() > 0){
                //dataStr = WOS[0].Connection_Data__c;
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c, OrgWideEmailAddress__c, Html_Body__c, TemplateAsAttachment__c, Add_Template_As_Attachment__c 
                                                From SetEmailTemplates__c 
                                                where Name = :WOLabel  //'WOTraveller'
                                                limit 1];
                
                if (EmailTemplates_uniqueName.isEmpty()) {
                    EmailTemplates_uniqueName = new List < SetEmailTemplates__c > ();
                    EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null, Template_Unique_Name__c = WOLabel, TemplateAsAttachment__c = true,
                        Add_Template_As_Attachment__c = true, Html_Body__c = false));
                }
            }
            
            if (EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c != null) {
                MailselectedTemplate = [select id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName = : EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c]; 
                isHtmlEmail = EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Html_Body__c;
            } else { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'To SetUp  Email Template provide Unique Template Name or Contact your Administrator')); }
        } catch (Exception e) { system.debug('Exception~> '+e.getMessage()+' at ~>'+e.getStackTraceString()); ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        
    }
    
     global pageReference createPDF() {
        try {
            String csfdcBaseURL;
            if(renderAs == 'pdf') {
                String sendEmailBaseURL = Label.sendEmailBaseURL; 
                system.debug('sendEmailBaseURL here1'+sendEmailBaseURL);
                
                sendEmailBaseURL = sfdcBaseURL.replace(Label.DestURL,sendEmailBaseURL);
                sendEmailBaseURL = sendEmailBaseURL.replace('--c','');
                system.debug('sendEmailBaseURL here2'+sendEmailBaseURL);//erp-mark-7-dev-ed.file.force.com
                
                csfdcBaseURL = sendEmailBaseURL;
            }else csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
            
            system.debug('csfdcBaseURL~>'+csfdcBaseURL);
            csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            
            PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            system.debug('page');
            system.debug('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            //="https://{!$Label.erp7__Host_Path}/email/templaterenderer?id={!MailselectedTemplate.id}&recipient_type_id={!currentContact.id}&related_to_id={!Record.id}&base_href=https://{!$Label.erp7__Template_Path}salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail"/>
            //PageReference pageRef = new PageReference('https://erp-mark-7-dev-ed--erp7.content.force.com/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+Label.Template_Path+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            //pdf = EncodingUtil.Base64Encode(ApexPages.currentPage().getContentAsPdf());
            pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?PageRef.getContentAsPdf():Blob.valueOf('Test'));
            
            system.debug('inheresuccess');
            
        } catch (Exception e) { system.debug('Exception~> '+e.getMessage()+' at ~>'+e.getStackTraceString()); ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
         
         if(renderAs == 'pdf') { system.debug('pdf > '+pdf); return page.MOTravellerPDF; }
         else return null;
    } 
    
    global pageReference createPDFs() {
        try {
            System.debug('createPDFs');
            String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            System.debug('csfdcBaseURL'+csfdcBaseURL);
            PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            //="https://{!$Label.erp7__Host_Path}/email/templaterenderer?id={!MailselectedTemplate.id}&recipient_type_id={!currentContact.id}&related_to_id={!Record.id}&base_href=https://{!$Label.erp7__Template_Path}salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail"/>
            //PageReference pageRef = new PageReference('https://erp-mark-7-dev-ed--erp7.content.force.com/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+Label.Template_Path+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            //pdf = EncodingUtil.Base64Encode(ApexPages.currentPage().getContentAsPdf());
            pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?PageRef.getContentAsPdf():Blob.valueOf('Test'));
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        return page.MOTravellerPDF;
    }   
    
}