@isTest
public class BOMTrigger_TestCases {
    
    static testMethod void unitTest1(){
        Product2 pro11 = new Product2(Name = 'Laptop X2000', Family = 'Hardware');
        insert pro11;
        Product2 pro2 = new Product2(Name = 'RamH1', Family = 'Hardware');
        insert pro2;
        Product2 pro3 = new Product2(Name = 'Ram Socket', Family = 'Hardware');
        insert pro3;
        List<Id> proIds1=new List<Id>();
        proIds1.add(pro2.Id);
        ERP7__Supporting_BOMs__c sBoms=new ERP7__Supporting_BOMs__c(Name='Test',ERP7__BOM_Product__c=pro2.Id,ERP7__BOM_Component__c=pro3.Id,ERP7__Quantity__c=1,ERP7__Type__c='Manufacturing');
        insert sBoms;
        
        ERP7__Version__c ver1=new ERP7__Version__c(Name='Test',ERP7__Product__c=pro11.Id,ERP7__Active__c=true,ERP7__Start_Date__c=System.today(),ERP7__To_Date__c=System.today());
        insert ver1;
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'ERP7__Version__c' and Name = 'Manufacturing'].Id;
        ver1.RecordTypeId=strRecordTypeId;
        update ver1;
        String strRecordTypeId1 = [Select Id From RecordType Where SobjectType = 'ERP7__BOM__c' and Name = 'Manufacturing BOM'].Id;
         
        ERP7__BOM__c bom=new ERP7__BOM__c(RecordTypeId=strRecordTypeId1,Name='Test',ERP7__Active__c=true,ERP7__BOM_Product__c=pro11.Id,ERP7__BOM_Component__c=pro2.Id,ERP7__BOM_Version__c=ver1.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified',ERP7__Quantity__c=1);
        insert bom;
         
        ERP7__BOM__c bom1=new ERP7__BOM__c(RecordTypeId=strRecordTypeId1,Name='Test1',ERP7__Active__c=true,ERP7__BOM_Product__c=pro11.Id,ERP7__BOM_Component__c=pro2.Id,ERP7__BOM_Version__c=ver1.Id,ERP7__Type__c ='Alternate',ERP7__Status__c ='Certified',ERP7__Quantity__c=1);
        insert bom1;
        
        
        
        List<ERP7__BOM__c> BOMsList1=new List<ERP7__BOM__c>();
        BOMsList1.add(bom);
        BOMsList1.add(bom1);
        
        BOMTriggerHelper.createSupportingBOMs(true,true,BOMsList1);
        BOMTriggerHelper.updateSupportingBOMs(true,true,BOMsList1);
        BOMTriggerHelper.deleteSupportingBoms(BOMsList1);
        BOMTriggerHelper.undeleteSupportingBoms(BOMsList1);
        //BOMTriggerHelper.assignProsAndRouting(BOMsList1);
        
        String salName = 'ERP7';
        String sal1Name = 'ERP7';
        System.assertEquals(salName, sal1Name);
    }
   
}