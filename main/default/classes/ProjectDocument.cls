global with sharing class ProjectDocument {
     
    global Contact currentContact                                  { get; set; }
    global Sobject Record                                          { get; set; }
    global EmailTemplate MailselectedTemplate                      { get; set; }
    global String sfdcBaseURL                                      { get; set; }
    global Boolean isHtmlEmail                                     { get; set; }
    global List<SetEmailTemplates__c> EmailTemplates_uniqueName    { get; set; }
    global String pdf                                              { get; set; }
    global String renderAs                                         { get; set; }
    global String dataStr                                          { get; set; }
    global String Id                                               { get; set; }
    global Attachment Attachment                                   { get; set; }
    
    global ProjectDocument(ApexPages.StandardController controller){
        try {
            if(Id == Null) Id = ApexPages.currentPage().getParameters().get('projId');
            renderAs = ApexPages.currentPage().getParameters().get('ra');
            dataStr = '';
            ERP7__Project__c PJT =  [Select Id, Name, ERP7__Contact__c From ERP7__Project__c Where Id =: Id Limit 1];
            if(PJT != null) Record = PJT;
            currentContact = [Select id, Name, FirstName, LastName ,Email, AccountId, Account.Organisation__c, Phone, Contact_Numer__c, Company__c From Contact Where Email != null Limit 1];
            Attachment = new Attachment();
            
            /* Fetching instance Name From SFDC URL */
            sfdcBaseURL = System.Url.getOrgDomainUrl().getHost();//URL.getSalesforceBaseUrl().getHost();
            sfdcBaseURL = sfdcBaseURL.removeEndIgnoreCase('visualforce.com');
            sfdcBaseURL = sfdcBaseURL.replace('--erp7', '--c');
            sfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            
            /* Querying The Template for Preview and attachment */
            if(PJT != null){
                EmailTemplates_uniqueName = [Select Template_Unique_Name__c, OrgWideEmailAddress__c, Html_Body__c, TemplateAsAttachment__c, Add_Template_As_Attachment__c 
                                                From SetEmailTemplates__c 
                                                where Name = 'ProjectDoc'
                                                limit 1];
                if (EmailTemplates_uniqueName.isEmpty()) {	
                    EmailTemplates_uniqueName = new List < SetEmailTemplates__c > ();
                    EmailTemplates_uniqueName.add(new SetEmailTemplates__c(OrgWideEmailAddress__c = null, Template_Unique_Name__c = 'ProjectDoc', TemplateAsAttachment__c = true,
                        Add_Template_As_Attachment__c = true, Html_Body__c = false));
                }
                List<Attachment> Attachments = [Select Id, Name, ParentId From Attachment Where ParentId =: Id And Name = 'Signature' Order By CreatedDate Asc];
                if(Attachments.size() > 0) Attachment = Attachments[0];
            }
            if (EmailTemplates_uniqueName.size() > 0 && EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c != null) {
                MailselectedTemplate = [select id, Body, Subject, HtmlValue from EmailTemplate where DeveloperName = : EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Template_Unique_Name__c]; 
                isHtmlEmail = EmailTemplates_uniqueName[EmailTemplates_uniqueName.size() - 1].Html_Body__c;
            } else { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.info, 'To SetUp  Email Template provide Unique Template Name or Contact your Administrator')); }
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        
    }
    
    global pageReference createPDF() {
        try {
            String csfdcBaseURL = sfdcBaseURL.replace('--erp7','--c');
            csfdcBaseURL = System.Url.getOrgDomainUrl().toExternalForm().substringBetween('https://','.my.salesforce.com')+'.file.force.com';
            PageReference pageRef = new PageReference('https://'+Label.Host_Path+'/email/templaterenderer?id='+MailselectedTemplate.id+'&recipient_type_id='+currentContact.id+'&related_to_id='+Record.id+'&base_href=https://'+Label.Template_Path+'salesforce.com&preview_frame=previewFrame&render_type=REPLACED_HTML_BODY&setupid=CommunicationTemplatesEmail&val='+ApexPages.currentPage().getParameters().get('val'));
            pdf = EncodingUtil.Base64Encode((!test.isRunningTest())?pageRef.getContentAsPdf():Blob.valueOf('Test'));
            
        } catch (Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()+' Line Number @ : '+ e.getLineNumber())); }
        if(renderAs == 'pdf') return page.projectDocPDF;
        else return null;
    } 
}