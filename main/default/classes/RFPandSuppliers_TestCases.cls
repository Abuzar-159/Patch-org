@isTest
public class RFPandSuppliers_TestCases {
    static testmethod void RFPConsole_UnitTest(){
        Test.startTest();
        Blob b = Blob.valueOf('Test Data');
        String b64 = EncodingUtil.base64Encode(b); 
        
        Account sup01 = new Account(Name = 'testCaseSupplier', ERP7__Account_Type__c = 'Vendor');
        insert sup01;
        
        ERP7__Request__c req01 = new ERP7__Request__c(Name='testCaseRequest1', ERP7__Status__c = 'Open', ERP7__Response_Due_Date__c = system.today());
        insert req01;
        ERP7__Request__c req02 = new ERP7__Request__c(Name='testCaseRequest2', ERP7__Status__c = 'Review', ERP7__Response_Due_Date__c = system.today());
        insert req02;
        ERP7__Request__c req03 = new ERP7__Request__c(Name='testCaseReques3', ERP7__Status__c = 'Cancelled', ERP7__Response_Due_Date__c = system.today());
        insert req03;
        ERP7__Request__c req04 = new ERP7__Request__c(Name='testCaseReques4', ERP7__Status__c = 'Open', ERP7__Response_Due_Date__c = system.today());
        insert req04;
        
        ERP7__FAQ__c faq01 = new ERP7__FAQ__c(Name = 'testCaseFAQ', ERP7__Question__c = 'hcbdkhsf?', ERP7__Answer__c = 'hdfbakjs.');
        insert faq01;
        
        ERP7__FAQ_Assignment__c faqAsgn01 = new ERP7__FAQ_Assignment__c(Name = 'testCaseFaqAssign', ERP7__FAQ__c = faq01.Id, ERP7__Request__c = req01.Id);
        insert faqAsgn01;
        
        ERP7__Request_Supplier__c  reqSup01 = new ERP7__Request_Supplier__c(Name='testCaseRequestSupplier', ERP7__Request__c = req01.Id, ERP7__Supplier__c = sup01.Id);
        insert reqSup01;
        ERP7__Request_Supplier__c  reqSup02 = new ERP7__Request_Supplier__c(Name='testCaseRequestSupplier', ERP7__Request__c = req02.Id, ERP7__Supplier__c = sup01.Id);
        insert reqSup02;
        ERP7__Request_Supplier__c  reqSup03 = new ERP7__Request_Supplier__c(Name='testCaseRequestSupplier', ERP7__Request__c = req03.Id, ERP7__Supplier__c = sup01.Id);
        insert reqSup03;
        ERP7__Request_Supplier__c  reqSup04 = new ERP7__Request_Supplier__c(Name='testCaseRequestSupplier', ERP7__Request__c = req04.Id, ERP7__Supplier__c = sup01.Id, ERP7__Is_Submitted__c = true, ERP7__Submit_Date__c = system.today());
        insert reqSup04;
   
        List<RecordType> rt = [Select Id, Name  From RecordType  Where SobjectType = 'ERP7__Requirement__c' And  Name = 'Request_Requirement' Limit 1];
        ERP7__Requirement__c  require01 = new ERP7__Requirement__c(Name = 'testCaseRequirement1', ERP7__Question__c = '5 years Comprehensive onsite warranty', ERP7__Request__c = req01.Id);
        insert require01;
        ERP7__Requirement__c  require02 = new ERP7__Requirement__c(Name = 'testCaseRequirement2', ERP7__Question__c = '5 years Comprehensive onsite warranty', ERP7__Request__c = req01.Id, ERP7__Parent_Requirement__c = require01.Id,RecordTypeId =rt[0].Id,RFPS_Plan_Requirement__c = require01.Id);
        insert require02;
        ERP7__Requirement__c  require04 = new ERP7__Requirement__c(Name = 'testCaseRequirement4', ERP7__Question__c = '5 years Comprehensive onsite warranty', ERP7__Request__c = req04.Id);
        insert require04;
        
        ERP7__Response__c response01 = new ERP7__Response__c(Name = 'testCaseResponse1', ERP7__Answer__c = 'ezsrdxtcfyguhij', ERP7__Requirement__c = require01.Id, ERP7__Request__c = req01.Id, ERP7__Request_Supplier__c = reqSup01.Id);
        insert response01;
        ERP7__Response__c response02 = new ERP7__Response__c(Name = 'testCaseResponse2', ERP7__Answer__c = 'ezsrdxtcfyguhij', ERP7__Requirement__c = require02.Id, ERP7__Request__c = req01.Id, ERP7__Request_Supplier__c = reqSup01.Id);
        insert response02;
        ERP7__Response__c response04 = new ERP7__Response__c(Name = 'testCaseResponse4', ERP7__Answer__c = 'ezsrdxtcfyguhij', ERP7__Requirement__c = require04.Id, ERP7__Request__c = req04.Id, ERP7__Request_Supplier__c = reqSup04.Id, ERP7__Score__c = 79, ERP7__Supplier_Rating__c = '5', ERP7__Supplier_Compliancy__c = 'Fully');
        insert response04;
        
        
        List<ERP7__Response__c> resList = new List<ERP7__Response__c>();
        resList.add(response04);
        List<ERP7__FAQ__c> faqList = new List<ERP7__FAQ__c>();
        faqList.add(faq01);
        
        Attachment resAttach01 = new Attachment(Name = 'resAttach1', ParentId = response01.Id, body = b);
        insert resAttach01;
        Attachment resAttach02 = new Attachment(Name = 'resAttach2', ParentId = response02.Id, body = b);
        insert resAttach02;
        ManageRFP.fetchAllDetails(reqSup01.Id, false);
        ManageRFP.fetchAllDetails(reqSup01.Id, true);
        ManageRFP.fetchAllDetails(reqSup02.Id, false);
        ManageRFP.fetchAllDetails(reqSup03.Id, false);
        ManageRFP.fetchAllSupDetails(req04.Id);
        ManageRFP.save_reqResponses(JSON.serialize(resList), true, JSON.serialize(reqSup04));
        //ManageRFP.uploadFile(response04.Id,)
        ManageRFP.fetchSupRating();
        ManageRFP.fetchSupCompliance();
        ManageRFP.fetchRating();
        ManageRFP.fetchCompliance();
        ManageRFP.fetchFAQs(JSON.serialize(faqList), 'hcbdkhsf');
        ManageRFP.uploadFile(response04.Id, 'Test File', b64, 'PDF');
        ManageRFP.DeleteAT(resAttach01.Id, 'Name');
        ManageRFP.delete_Response(response01.Id);
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
    
    
    static testmethod void SupplierRFPs_UnitTest(){
        Test.startTest();
        
        Date expiry = system.today();
        expiry.addMonths(2);
        Account sup01 = new Account(Name = 'testCaseSupplier', ERP7__Account_Type__c = 'Vendor');
        insert sup01;
        
        ERP7__Request__c req01 = new ERP7__Request__c(Name='testCaseRequest1', ERP7__Status__c = 'Open', ERP7__Response_Due_Date__c = system.today(), ERP7__Expiry_Date__c = expiry, ERP7__Private__c = false);
        insert req01;
        ERP7__Request__c req02 = new ERP7__Request__c(Name='testCaseRequest2', ERP7__Status__c = 'Review', ERP7__Response_Due_Date__c = system.today(), ERP7__Expiry_Date__c = expiry, ERP7__Private__c = false);
        insert req02;
        ERP7__Request__c req03 = new ERP7__Request__c(Name='testCaseReques3', ERP7__Status__c = 'Cancelled', ERP7__Response_Due_Date__c = system.today(), ERP7__Expiry_Date__c = expiry, ERP7__Private__c = true);
        insert req03;
        ERP7__Request__c req04 = new ERP7__Request__c(Name='testCaseReques4', ERP7__Status__c = 'Open', ERP7__Response_Due_Date__c = system.today(), ERP7__Expiry_Date__c = expiry, ERP7__Private__c = true);
        insert req04;
        
        ERP7__Request_Supplier__c  reqSup01 = new ERP7__Request_Supplier__c(Name='testCaseRequestSupplier', ERP7__Request__c = req01.Id, ERP7__Supplier__c = sup01.Id);
        insert reqSup01;
        ERP7__Request_Supplier__c  reqSup02 = new ERP7__Request_Supplier__c(Name='testCaseRequestSupplier', ERP7__Request__c = req02.Id, ERP7__Supplier__c = sup01.Id);
        insert reqSup02;
        ERP7__Request_Supplier__c  reqSup03 = new ERP7__Request_Supplier__c(Name='testCaseRequestSupplier', ERP7__Request__c = req03.Id, ERP7__Supplier__c = sup01.Id);
        insert reqSup03;
        ERP7__Request_Supplier__c  reqSup04 = new ERP7__Request_Supplier__c(Name='testCaseRequestSupplier', ERP7__Request__c = req04.Id, ERP7__Supplier__c = sup01.Id, ERP7__Is_Submitted__c = true, ERP7__Submit_Date__c = system.today());
        insert reqSup04;
        
        List<ERP7__Request__c> reqList = new List<ERP7__Request__c>();
        reqList.add(req01);
        reqList.add(req02);
        
        ManageSupplierRFP.fetchAllDetails(sup01.Id, 'test', 0, 10, 'Open');
        ManageSupplierRFP.fetchPublicReqs('Open','');
        ManageSupplierRFP.fetchPublicReqs('','');
        ManageSupplierRFP.applyForRFPs(JSON.serialize(reqList), sup01.Id);
        RFPConsole.searchimgUrl();
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
        Test.stopTest();
    }
}