public With Sharing Class ViewEmployeePays{
   
   public List<Employee_Pay__c  > empPayList {get;set;}
   public String query {get;set;}
   public String allFields {get;set;}
    
    public ViewEmployeePays(){
         empPayList = new List<Employee_Pay__c>();
         allFields = UtilClass.selectStarFromSObject('ERP7__Employee_Pay__c');
         UtilClass.FlSCheck(allFields.split(',') ,'ERP7__Employee_Pay__c');
          UtilClass.FlSCheck(new string[]{'Name','Employee_User__c'} ,'ERP7__Employees__c');
         Boolean bol = true;
         query = 'SELECT ' + String.escapeSingleQuotes(allFields) + ' , Employee__r.Name, Employee__r.Employee_User__c From Employee_Pay__c  Where Active__c =: bol order by CreatedDate Desc ';  
         try{
            if(Schema.sObjectType.Employee_Pay__c.isAccessible())
            empPayList  = Database.query(query);             
         }catch(Exception e){ }    
    }  
    
    public PageReference viewPaySlip(){
       return null;
    }
}