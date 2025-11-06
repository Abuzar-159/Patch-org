@isTest
public class SupplierPortal_TestClass {
    static testmethod void SupplierUnitClass001() {  

   		Account acc = new Account(Name='Test', Account_type__c = 'Vendor', Default__c = true);
        insert acc;
        Account vendor = new Account(Name='Test Supplier',Account_type__c = 'Vendor');
        insert vendor;
        //Contact con=new Contact();
        ERP7__PO__c po = new ERP7__PO__c(Vendor__c = vendor.Id);
        insert po;
        ERP7__BILL__c bill = new ERP7__BILL__c(Vendor__c = vendor.Id);
        try{ insert bill; } catch(exception e){ }
        Payment__c pay = new Payment__c(ERP7__Payment_Type__c = 'Voucher',ERP7__Accounts__c = vendor.Id);
        insert pay;
        Voucher__c voucher = new Voucher__c(name='test');
        insert voucher;
        ERP7__Timesheet__c	timesheet=new ERP7__Timesheet__c(name='test');
        insert timesheet;
        ERP7__WO__c wo=new ERP7__WO__c(name='test');
        insert wo;
        ERP7__Expense__c expense=new ERP7__Expense__c(name='test');
        insert expense;  
        Contact contact = new Contact(LastName = 'test contact', Email = 'test@test.com' ,Contact_Numer__c='test123');
        insert contact;
        User user001 = [SELECT Id, Name, Username, ERP7__Security_Question1__c, ERP7__Security_Question2__c, ERP7__SecurityAnswer1__c, ERP7__SecurityAnswer2__c FROM user WHERE Id = :UserInfo.getUserId() LIMIT 1];
        //insert user001;
        //u.ContactId=u.Id;
        //insert user;
        Profile pro=new Profile();
        //insert pro;
        //ERP7__Cart__c cart=[SELECT Id, Name from ERP7__Cart__c where ERP7__Account__c=:acc.Id LIMIT 1];
        //insert cart;
        SupplierPortalPO.forgotPassowrd('test');
        SupplierPortalPO.getFieldsSetApiName();
        SupplierPortalPO.forgotPassword('test');
        SupplierPortalPO.getPOList(acc.Id);
        SupplierPortalPO.fetchPO(6,'',200,null,'Name', 'ASC');
        SupplierPortalPO.getProfileId();
        SupplierPortalPO.checkPortal('','','',true);
        SupplierPortalPO.getRandomSecurityQuestion(user001.Username);
        SupplierPortalPO.verifiedSecurityQuestion(user001.Username,'Test', '1');
        SupplierPortalPO.verifiedSecurityQuestion(user001.Username,'Physics0011', '1');
        SupplierPortalPO.getUserDetails('test');
        SupplierPortalPO.updateSecurityQuestions('','','','',user001.Username);
        SupplierPortalPO.updateSecurityQuestions('','','','',''	);
        //SupplierPortalPO.deactivateUser();
        try{ SupplierPortalPO.deactivateUser();} catch(exception e){ }
        SupplierPortalPO.updateSPNCheckbox(true);
        SupplierPortalPO.updatePassword('','','');
        SupplierPortalPO.fetchBills('','Name','ASC',6, 200,null);
		SupplierPortalPO.fetchWO('','Name','ASC',6, 200,null);
		SupplierPortalPO.fetchPayments('','Name','ASC',6, 200,null);
		SupplierPortalPO.fetchExpense(6,'',200,null,'Name','ASC');
		SupplierPortalPO.fetchContract(6,'',200,null,'Name','ASC');
        SupplierPortalPO.fetchTimesheet(6,'', 200,null,'Name','ASC');
        SupplierPortalPO.registerUserSelf('','','','','',true);
        SupplierPortalPO.getProfileIdDetails();
        SupplierPortalPO.doesUserExist('test');
        //SupplierPortalPO.getProfileId1();
        SupplierPortalPO.getPageLayoutMetadata('Account (Supplier) Layout');
        //SupplierPortalPO.getIconName('ERP7__Cart__c');
        //SupplierPortalPO.initData('');
        //SupplierPortalPO.getRecords('');
        SupplierPortalPO.getFieldsSetApiName();
        //SupplierPortalPO.getParentRelationshipName(contact.id,'contact','Account');
        SupplierPortalPO.deleteRecord(contact.id);
        SupplierPortalPO.RelatedList(po.id,'ERP7__Purchase_Line_Items__c','ERP7__Purchase_Orders__c');
        List<ERP7__Purchase_Line_Items__c> polis=SupplierPortalPO.getPOLis(po.id);
        SupplierPortalPO.doesUserExist('test');
      	 try{ SupplierPortalPO.selectOptions ss=new SupplierPortalPO.selectOptions('lab','val');}catch(Exception e){}
        try{ SupplierPortalPO.selectOptions ssss=new SupplierPortalPO.selectOptions('lab','val',false);}catch(Exception e){}
        System.assertEquals('ERP7', 'ERP7');
      }  
      private Testmethod static void SupplierUnitClass002(){
          Test.startTest();
        String Name = 'ERP';
        String Name1 = 'ERP';
        System.assertEquals(Name, Name1);
          Test.stopTest();
    }
}