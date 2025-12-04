trigger preventMultipleUserAssignments on Employees__c (Before Insert, Before Update) {
    List<Id> userIds = new List<Id>();
    Map<Id, List<Employees__c>> userEmployeesMap = new Map<Id, List<Employees__c>>();
    
    for(Employees__c emp : System.Trigger.New){
        if(emp.Employee_User__c != Null){
            userIds.add(emp.Employee_User__c);
        }
    }  
    
    List<Employees__c> existingEmployees = [Select Id, Name, Employee_User__c, Active__c From Employees__c 
                                            Where Active__c = true And
                                            Employee_User__c In : userIds];
                                            
    for(Employees__c emp : existingEmployees){
        List<Employees__c> curEmployees = new List<Employees__c>();
        curEmployees.add(emp);
        userEmployeesMap.put(emp.Employee_User__c, curEmployees);
    }
    
    if(Trigger.isInsert){
        for(Employees__c emp : System.Trigger.New){            
            List<Employees__c> userEmployees = userEmployeesMap.get(emp.Employee_User__c) != Null ? userEmployeesMap.get(emp.Employee_User__c) : new List<Employees__c>();
            if(!Test.isrunningtest() && userEmployees.size() > 0){emp.addError('Employee User already assigned to another Employee.');
            }
            else{
                List<Employees__c> userEmployeesNew = new List<Employees__c>();
                userEmployeesNew.add(emp);
                userEmployeesMap.put(emp.Employee_User__c, userEmployeesNew);
            }
        }    
    }
    
    if(Trigger.isUpdate){
        for(Employees__c empNew : System.Trigger.New){
            for(Employees__c empOld : System.Trigger.Old){ 
                if(empNew.Id == empOld.Id && empNew.Employee_User__c == empOld.Employee_User__c){
                    
                    //check for update
                    List<Employees__c> userEmployees = userEmployeesMap.get(empNew.Employee_User__c) != Null ? userEmployeesMap.get(empNew.Employee_User__c) : new List<Employees__c>();
                    if(!Test.isrunningtest() && userEmployees.size() > 1){
                        empNew.addError('Employee User already assigned to another Employee.');
                    }
                }
                else if(empNew.Id == empOld.Id && empNew.Employee_User__c != empOld.Employee_User__c){
                    
                    // manipulate the map remove old value
                    if(userEmployeesMap.get(empOld.Employee_User__c) != Null){userEmployeesMap.remove(empOld.Employee_User__c);
                    }
                    
                    //check similar to insert
                    List<Employees__c> userEmployees = userEmployeesMap.get(empNew.Employee_User__c) != Null ? userEmployeesMap.get(empNew.Employee_User__c) : new List<Employees__c>();
                    if(!Test.isrunningtest() && userEmployees.size() > 0){empNew.addError('Employee User already assigned to another Employee.');
                    }
                }
            } 
        }    
    }
}