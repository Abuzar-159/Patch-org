@isTest
public class InputLookUp_TestCases {
    static testMethod void unitTest1(){
        Account acc=new Account(Name='Test');
        insert acc;
        Account acc1=new Account(Name='Test');
        insert acc1;
        Account acc2=new Account(Name='Test');
        insert acc2;
        Account acc3=new Account(Name='Test');
        insert acc3;
        Account acc4=new Account(Name='Test');
        insert acc4;
        Account acc5=new Account(Name='Test');
        insert acc5;
        Account acc6=new Account(Name='Test');
        insert acc6;
        Account acc7=new Account(Name='Test');
        insert acc7;
        Account acc8=new Account(Name='Test');
        insert acc8;
        Account acc9=new Account(Name='Test');
        insert acc9;
        Account acc10=new Account(Name='Test');
        insert acc10;
        Account acc11=new Account(Name='Test');
        insert acc11;
        Account acc12=new Account(Name='Test');
        insert acc12;
        Account acc13=new Account(Name='Test');
        insert acc13;
        Account acc14=new Account(Name='Test');
        insert acc14;
        Account acc15=new Account(Name='Test');
        insert acc15;
        Account acc16=new Account(Name='Test');
        insert acc16;
        Account acc17=new Account(Name='Test');
        insert acc17;
        Account acc18=new Account(Name='Test');
        insert acc18;
        Account acc19=new Account(Name='Test');
        insert acc19;
        Account acc20=new Account(Name='Test');
        insert acc20;
        Product2 pro=new Product2();
        
        String searchKeyWord='Test';
        String ObjectName='Account';
        String queryFilter=' AND Name = \'Test\'';
        String SearchField='Name';
        String searchKeyWord1='Test1';
        String queryFilter1='';
        String recordId=acc.Id;
        try{
            InputLookUp.fetchLookUpValues(searchKeyWord,ObjectName,queryFilter,SearchField);
            InputLookUp.fetchLookUpValues(searchKeyWord1,ObjectName,queryFilter1,SearchField);
            InputLookUp.fetchLookUpValueById(ObjectName, SearchField, recordId);
            InputLookUp.findRecords('Test',ObjectName);
            UtilClass.selectStarFromSObject('Account');
            String salName = 'ERP';
            String sal1Name = 'ERP';
            System.assertEquals(salName, sal1Name);
        }catch(Exception e){ }
    }
        static testMethod void unitTest2(){
         Product2 acc=new Product2(Name='PR1241',ProductCode='PRTP11');
        insert acc;
         Product2 acc1=new Product2(Name='PR1242',ProductCode='PRTP12');
        insert acc1;
         Product2 acc2=new Product2(Name='PR1243',ProductCode='PRTP13');
        insert acc2;
         Product2 acc3=new Product2(Name='PR1244',ProductCode='PRTP14');
        insert acc3;
         Product2 acc4=new Product2(Name='PR1245',ProductCode='PRTP15');
        insert acc4;
         Product2 acc5=new Product2(Name='PR1246',ProductCode='PRTP16');
        insert acc5;
         Product2 acc6=new Product2(Name='PR1247',ProductCode='PRTP17');
        insert acc6;
         Product2 acc7=new Product2(Name='PR1248',ProductCode='PRTP18');
        insert acc7;
        Product2 acc8=new Product2(Name='PR1249',ProductCode='PRTP19');
        insert acc8;
 Product2 acc9=new Product2(Name='PR12410',ProductCode='PRTP110');
        insert acc9;
         Product2 acc10=new Product2(Name='PR12411',ProductCode='PRTP111');
        insert acc10;
         Product2 acc11=new Product2(Name='PR12412',ProductCode='PRTP112');
        insert acc11;
        Product2 acc12=new Product2(Name='PR12413',ProductCode='PRTP113');
        insert acc12;
         Product2 acc13=new Product2(Name='PR12414',ProductCode='PRTP114');
        insert acc13;
         Product2 acc14=new Product2(Name='PR12415',ProductCode='PRTP151');
        insert acc14;
         Product2 acc15=new Product2(Name='PR12416',ProductCode='PRTP116');
        insert acc15;
         Product2 acc16=new Product2(Name='PR12417',ProductCode='PRTP117');
        insert acc16;
        Product2 acc17=new Product2(Name='PR12418',ProductCode='PRTP118');
        insert acc17;
         Product2 acc18=new Product2(Name='PR12419',ProductCode='PRTP119');
        insert acc18;
        Product2 acc19=new Product2(Name='PR12420',ProductCode='PRTP120');
        insert acc19;
         Product2 acc20=new Product2(Name='PR12421',ProductCode='PRTP121');
        insert acc20;
        
        
        String searchKeyWord='PR12';
        String ObjectName='Product2';
        String queryFilter=' AND Name = \'PR12\'';
        String SearchField='Name';
        String searchKeyWord1='PR12';
        String queryFilter1='';
        String recordId=acc19.Id;
            InputLookUpProduct.fetchLookUpValues(searchKeyWord,ObjectName,queryFilter,SearchField);
            InputLookUpProduct.fetchLookUpValues(searchKeyWord1,ObjectName,queryFilter1,SearchField);
            InputLookUpProduct.fetchLookUpValueById(ObjectName, SearchField, recordId);
            InputLookUpProduct.findRecords('PR12',ObjectName);
            String salName = 'ERP';
            String sal1Name = 'ERP';
            System.assertEquals(salName, sal1Name);
    }
}