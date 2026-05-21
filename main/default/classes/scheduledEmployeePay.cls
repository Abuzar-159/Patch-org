public With Sharing Class scheduledEmployeePay implements Schedulable{
   public void execute(SchedulableContext sc) {       
      Date myDate = System.Today();      
      List<ERP7__Employees__c> employees;
      if(Schema.sObjectType.Employees__c.isAccessible())
      employees = [Select Id, Name, Employment_Status__c, Employee_Profiling__c, Organisation_Business_Unit__c, Organisation__c, 
                                      Non_Employee__c,Active__c
                                      From ERP7__Employees__c 
                                      Where Employment_Status__c = 'Active' And
                                      Non_Employee__c = false 
                                      Limit 50000];
                                           
      List<ERP7__Employee_Pay__c> employeesPayment = new List<ERP7__Employee_Pay__c>();
      Map<String, Schema.SObjectField> EMPPAYFields = Schema.SObjectType.ERP7__Employee_Pay__c.fields.getMap();
      for(ERP7__Employees__c Emp :employees){
          ERP7__Employee_Pay__c empPay = new ERP7__Employee_Pay__c();
          
          if(EMPPAYFields.get('ERP7__Active__c').getDescribe().isCreateable()) { 
              
              empPay.ERP7__Active__c = true; }
          
          if(EMPPAYFields.get('ERP7__Employees__c').getDescribe().isCreateable()) { empPay.ERP7__Employees__c = emp.Id; } 
          employeesPayment.add(empPay); 
      }      
      if(employeesPayment.size() > 0){
          try { if(Schema.sObjectType.ERP7__Employee_Pay__c.isCreateable()) { DMLManager.insertAsUser(employeesPayment); } else{ /*No access*/ } } 
          catch(Exception e){
              // send email notification to concerned person
          }
      }           
   }   
}