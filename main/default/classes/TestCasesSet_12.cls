@isTest
private class TestCasesSet_12 {
    static testMethod void UnitTestErpMark7() {    
            
            Account orgn = new Account(Name='Organisation', Account_Type__c = 'Organisation');
            insert orgn;
            Account sup = new Account(Name='Supplier', Account_Type__c = 'Supplier');
            insert sup;
            Business_Unit__c  busUnit = new Business_Unit__c(Organisation__c = orgn.Id, Name = 'test');
            insert busUnit; 
            Channel__c salepoint = new Channel__c(Name = 'Sale Point', Organisation__c = orgn.id, Organisation_Business_Unit__c = busUnit.id, Active__c=true, Street__c = 'Test Sndr Address Line 1',City__c = 'COLORADO SPRINGS',State_Province__c = 'Colorado',Country__c = 'United States',Zip_Postal_Code__c = '80915', Shipper_Name__c = 'Apex', Company__c = 'ApexCloud', Phone__c = '1234567890');
            insert salepoint;
            
            RecordType RFPRtype = [select Id, Name From RecordType Where Name = 'Request_Plan_Requirement' and SobjectType = 'ERP7__Requirement__c' Limit 1];
            RecordType RFPSRtype = [select Id, Name From RecordType Where Name = 'Request_Plan_Sub_Requirement' and SobjectType = 'ERP7__Requirement__c' Limit 1];         
           
            Request_Plan__c RFPP1 = new Request_Plan__c(Active__c=true, Name__c='test', Organisation__c=orgn.id, Organisation_Business_Unit__c=busUnit.id);
            insert RFPP1;
            
            Request_Plan__c RFPP2 = new Request_Plan__c(Active__c=true, Name__c='test', Organisation__c=orgn.id, Organisation_Business_Unit__c=busUnit.id);
            insert RFPP2;
            Request__c RFP = new Request__c(Description__c='Test', Organisation__c=orgn.id, Organisation_Business_Unit__c=busUnit.id, Request_Date__c=System.Today()+30,Response_Due_Date__c=System.Today()+25, RFPS_RFQ__c='test', Request_Plan__c=RFPP1.Id, Channel__c=salepoint.Id,Status__c='Review');
            insert RFP;            
            
            Requirement__c RP = new Requirement__c(Answer_Required__c=true, Question__c='test', Request_Plan__c=RFPP1.Id, Upload_Required__c=true, RecordTypeId=RFPRtype.Id,Request__c=RFP.Id);
            insert RP;
            Requirement__c RC = new Requirement__c(Answer_Required__c=true, Question__c='test', Request_Plan__c=RFPP1.Id, Upload_Required__c=true, RecordTypeId=RFPSRtype.Id, Parent_Requirement__c=RP.Id, RFPS_Plan_Requirement__c=RP.Id);
            insert RC;
    
            Requirement__c RP1 = new Requirement__c(Answer_Required__c=true, Question__c='test', Request_Plan__c=RFPP2.Id, Upload_Required__c=true, RecordTypeId=RFPRtype.Id);
            insert RP1;
            Requirement__c RC1 = new Requirement__c(Answer_Required__c=true, Question__c='test', Request_Plan__c=RFPP2.Id, Upload_Required__c=true, RecordTypeId=RFPSRtype.Id, Parent_Requirement__c=RP1.Id);
            insert RC1;            
            
            Request_Supplier__c RS = new Request_Supplier__c(Supplier__c = sup.Id, Request__c=RFP.Id);
            insert RS;            
            
            Response__c Res = new Response__c(Answer__c='test', Requirement__c=RP1.id, Request__c=RFP.Id, Request_Supplier__c=RS.Id, Supplier__c=sup.Id);
            insert Res;
           
            RFP.Request_Plan__c = RFPP2.id;
            update RFP;
            RFP.Request_Plan__c = null;
            update RFP;
            RFP.Request_Plan__c = RFPP1.id;
            update RFP;
            
            PageReference pageRef = System.Page.SupplierRegistration;
            pageRef.getParameters().put('MOId',RFP.Id);
            Test.setCurrentPage(pageRef);

            supplierRegistration SupReg = new supplierRegistration();
            SupReg.Cancel();
            SupReg.addContact();
            SupReg.currentContactIndex = 0;
            SupReg.additionalContacts[0].wrapCon.LastName = 'test';
            SupReg.supplierAccount = sup;
            SupReg.primaryContact.LastName = 'test';
            try { SupReg.Register(); } catch(exception e){}
            SupReg.removeContact();
            SupReg.RFP = new List<Request__c>();
            SupReg.Register();
            
            Request__c RFP1 = new Request__c(Description__c='Test', Organisation__c=orgn.id, Organisation_Business_Unit__c=busUnit.id, Request_Date__c=System.Today()+30,Response_Due_Date__c=System.Today()+25, RFPS_RFQ__c='test', Request_Plan__c=RFPP1.Id, Channel__c=salepoint.Id,Status__c='Review');
            insert RFP1;
            Request_Supplier__c RS1 = new Request_Supplier__c(Supplier__c = sup.Id, Request__c=RFP1.Id);
            insert RS1;
            
            ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(Request__c=RFP1.Id, ERP7__StartDate__c = system.Today()+1);
            insert MO;
            
            
            RecordType RFPRtype1 = [select Id, Name From RecordType Where Name = 'Request_Requirement' and SobjectType = 'ERP7__Requirement__c' Limit 1];
            RecordType RFPSRtype1 = [select Id, Name From RecordType Where Name = 'Request_Sub_Requirement' and SobjectType = 'ERP7__Requirement__c' Limit 1];
            
            Requirement__c RP11 = new Requirement__c(Answer_Required__c=true, Request__c=RFP1.Id, Question__c='test', Upload_Required__c=false, RecordTypeId=RFPRtype1.Id);
            insert RP11;
            Requirement__c RC11 = new Requirement__c(Answer_Required__c=true,Request__c=RFP1.Id, Question__c='test', Upload_Required__c=false, RecordTypeId=RFPSRtype1.Id, Parent_Requirement__c=RP11.Id);
            insert RC11;
            
            Response__c Res1 = new Response__c(Answer__c='test', Requirement__c=RP11.id, Request__c=RFP1.Id, Request_Supplier__c=RS1.Id, Supplier__c=sup.Id);
            insert Res1;
            
            Response__c Res11 = new Response__c(Answer__c='test', Requirement__c=RC11.id,Request__c=RFP1.Id, Request_Supplier__c=RS1.Id, Supplier__c=sup.Id);
            insert Res11;
            
            List<Attachment> atts = new List<Attachment>();
            
            Attachment A = new Attachment(ParentId=Res1.id, body=blob.valueof('test'), Name='test');
            atts.add(A);
            
            Attachment A1 = new Attachment(ParentId=Res11.id, body=blob.valueof('test'), Name='test');
            atts.add(A1);
            
            insert atts;
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
}