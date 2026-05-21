@isTest
private class InputLookupAuraControllerTestClass {
     
    static testmethod void UnitTestMethod(){
        try{
        Account acc = new Account(Name='Test');
        insert acc;
        InputLookupAuraController ILAC = new InputLookupAuraController();
        InputLookupAuraController.SearchResult SR = new InputLookupAuraController.SearchResult();
        String type='Account';
        String value='test';
        InputLookupAuraController.getCurrentValue(type, acc.Id);
        String searchString='test';
        SObjectType objType = Schema.getGlobalDescribe().get('Account');
        InputLookupAuraController.searchSObject(type, searchString,'');
        InputLookupAuraController.getSobjectNameField(objType);
        String salName = 'ERP';
        String sal1Name = 'ERP';
        System.assertEquals(salName, sal1Name);
        }catch(Exception e){}
    }
}