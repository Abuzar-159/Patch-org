public With Sharing Class MOrderLabel{ 
    
    public Contact currentContact                                  { get; set; }
    public Sobject Record                                          { get; set; }
    public EmailTemplate MailselectedTemplate                      { get; set; }
    public String sfdcBaseURL                                      { get; set; }
    public Boolean isHtmlEmail                                     { get; set; }
    public List<SetEmailTemplates__c> EmailTemplates_uniqueName    { get; set; }
    public String pdf                                              { get; set; }
    public String renderAs                                         { get; set; }
    public String prnt                                             { get; set; }
    
    public MOrderLabel(ApexPages.StandardController controller){
        try {
            String MOId = ApexPages.currentPage().getParameters().get('MId');
            renderAs = ApexPages.currentPage().getParameters().get('ra');
            prnt = ApexPages.currentPage().getParameters().get('nav');
            List< ERP7__Manufacturing_Order__c > wos =  [Select Id, Name From ERP7__Manufacturing_Order__c Where Id =: MOId Limit 1];
            if(wos.size() > 0) Record = wos[0];
            
            currentContact = [Select id, Name, FirstName, LastName ,Email, AccountId, Account.Organisation__c, Phone, Contact_Numer__c, Company__c From Contact Where Email != null Limit 1];
            
            /* Fetching instance Name From SFDC URL */
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            String initurl = Label.initURL;
            String DestinationURL = Label.DestURL;
           // sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
           //sfdcBaseURL = sfdcBaseURL.replace('.visual.force.com','.content.force.com'); //need to be uncommented
           //  sfdcBaseURL = sfdcBaseURL.replace('.visualforce.com','.documentforce.com'); 
           sfdcBaseURL = sfdcBaseURL.replace(initurl,DestinationURL);
            sfdcBaseURL = sfdcBaseURL.replace('--erp7', '--c');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            /* Querying The Template for Preview and attachment */
            if(wos.size() > 0){
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c, OrgWideEmailAddress__c, Html_Body__c, TemplateAsAttachment__c, Add_Template_As_Attachment__c 
                                                From SetEmailTemplates__c 
                                                where Name = 'MOLabel'
                                                limit 1];
                if (EmailTemplates_uniqueName.isEmpty()) {
                    EmailTemplates_uniqueName = new List < SetEmailTemplates__c > ();
                    EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null, Template_Unique_Name__c = 'MOLabel', TemplateAsAttachment__c = true,
                        Add_Template_As_Attachment__c = true, Html_Body__c = false));
                }
            }
            
            if (EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c != null) {
                MailselectedTemplate = [select id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName = : EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c]; 
                isHtmlEmail = EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Html_Body__c;
            } else { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'To SetUp  Email Template provide Unique Template Name or Contact your Administrator')); }
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage())); }
    }
    
     public pageReference createPDF() {
        try {
            //String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
            
            /*
            String initurl = Label.initURL;
            String DestinationURL = Label.DestURL;
            
            system.debug('initurl here1~>'+initurl);
            system.debug('DestinationURL here1~>'+DestinationURL);
            
            csfdcBaseURL = csfdcBaseURL.replace(initurl,DestinationURL);
            csfdcBaseURL = csfdcBaseURL.replace('--erp7','--c');
            */
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
            
            //PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'documentforce.com/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            PageReference pageRef = new PageReference('https://'+csfdcBaseURL+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+csfdcBaseURL+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?PageRef.getContentAsPdf():Blob.valueOf('Test'));
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage())); }
        if(renderAs == 'pdf') return page.MOrderLabelPDF;
        else return null;
    }   
    
}