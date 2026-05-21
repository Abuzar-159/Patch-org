trigger RollupTotalAddtionAndDeduction on Pay_Adjustment_Line_Item__c (after insert, after update, after undelete, after delete) {
   List<Id> PALIDS = New List<Id>();
   List<Id> EPLI = New List<Id>();
   map<Id, Employee_Pay_Line_Item__c> addLine2Empline = new map<id,Employee_Pay_Line_Item__c>();
   List<Pay_Adjustment_Line_Item__c> Palis;
   
   if(!(Trigger.IsDelete)){
       for(Pay_Adjustment_Line_Item__c pali :System.Trigger.New){     
           PALIDS.add(pali.Id);     
       }
       Palis = [Select id, name, Adjustment_Category__r.Employee_Pay_Line_Item__c, Adjustment_Category__r.Total_Addition1__c, Adjustment_Category__r.Total_Deduction__c, Adjustment_Category1__c, Amount__c from Pay_Adjustment_Line_Item__c where id in : PALIDS];
       for(Pay_Adjustment_Line_Item__c pali :Palis){
           EPLI.add(pali.Adjustment_Category__r.Employee_Pay_Line_Item__c);
           
       }
       List<Employee_Pay_Line_Item__c> EPLIS = [Select id, Name, Adjustment_Category__c, Adjustment_Category_Type__c, Amount__c, Description__c, Employee_Pay__c, Total_Addition__c, Total_Deduction__c From Employee_Pay_Line_Item__c Where id In :EPLI];   
       for(Pay_Adjustment_Line_Item__c adjustLineItem : Palis){
           for(Employee_Pay_Line_Item__c empItem : EPLIS){
               if(empItem.id == adjustLineItem.Adjustment_Category__r.Employee_Pay_Line_Item__c){   
                   addLine2Empline.put(adjustLineItem.id, empItem);
               }
           }
       }
   }
   
   if(Trigger.IsDelete){
       List<Id> catIds = new List<Id>();
       for(Pay_Adjustment_Line_Item__c pali :System.Trigger.Old){                
           catIds.add(pali.Adjustment_Category__c);   
       }
       List<Pay_Adjustment_Category__c> allCats = [Select id, Name, Description__c, Employee_Pay_Line_Item__c, Total_Addition1__c, Total_Deduction__c From Pay_Adjustment_Category__c where Id in : catIds];
       for(Pay_Adjustment_Category__c pcat : allCats){
          EPLI.add(pcat.Employee_Pay_Line_Item__c); 
       }      
       List<Employee_Pay_Line_Item__c> EPLIS = [Select id, Name, Adjustment_Category__c, Adjustment_Category_Type__c, Amount__c, Description__c, Employee_Pay__c, Total_Addition__c, Total_Deduction__c From Employee_Pay_Line_Item__c Where id In :EPLI];   
       for(Pay_Adjustment_Line_Item__c pali :System.Trigger.Old){
           for(Pay_Adjustment_Category__c pcat : allCats){
               if(pcat.Id == pali.Adjustment_Category__c)
               for(Employee_Pay_Line_Item__c empItem : EPLIS){
                   if(empItem.id == pcat.Employee_Pay_Line_Item__c)   
                   addLine2Empline.put(pali.Id, empItem);
               }
           }
       }
   }
    
   if(Trigger.IsInsert){
       List<Employee_Pay_Line_Item__c> Items2Update = new List<Employee_Pay_Line_Item__c>();
       for(Pay_Adjustment_Line_Item__c adjustLineItem : System.trigger.New){
           Employee_Pay_Line_Item__c currEmpPaylineItem = addLine2Empline.get(adjustLineItem.id);           
           if(adjustLineItem.Adjustment_Category1__c == 'Addition'){
               if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Addition__c.isUpdateable()){
                   if(currEmpPaylineItem.Total_Addition__c != null){
                       currEmpPaylineItem.Total_Addition__c += adjustLineItem.Amount__c;
                   }
                   else {
                       currEmpPaylineItem.Total_Addition__c = adjustLineItem.Amount__c;
                   } 
               }
               else{ /* no access*/ }
           }
           else if(adjustLineItem.Adjustment_Category1__c == 'Deduction'){
               if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Deduction__c.isUpdateable()){
                   if(currEmpPaylineItem.Total_Deduction__c != null){
                       currEmpPaylineItem.Total_Deduction__c += adjustLineItem.Amount__c;
                   }
                   else{
                       currEmpPaylineItem.Total_Deduction__c = adjustLineItem.Amount__c;
                   } 
               }
               else{ /* no access*/ }
               
           }
           Items2Update.add(currEmpPaylineItem);
       }
       if(Schema.sObjectType.Employee_Pay_Line_Item__c.isUpdateable()){ update Items2Update; } else{ /* no access */ }
   }
   
   if(Trigger.IsUpdate){
       List<Employee_Pay_Line_Item__c> Items2Update4 = new List<Employee_Pay_Line_Item__c>();
       for(Pay_Adjustment_Line_Item__c adjustLineItem_New : System.trigger.New){
           for(Pay_Adjustment_Line_Item__c adjustLineItem_Old : System.trigger.Old){
               if(adjustLineItem_New.Id == adjustLineItem_Old.Id){                   
                   Employee_Pay_Line_Item__c currEmpPaylineItem = addLine2Empline.get(adjustLineItem_New.id);                   
                   
                   if(adjustLineItem_New.Adjustment_Category1__c == adjustLineItem_Old.Adjustment_Category1__c){
                       if(adjustLineItem_New.Adjustment_Category1__c == 'Addition'){
                           if(currEmpPaylineItem.Total_Addition__c != null){
                               if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Addition__c.isUpdateable()){currEmpPaylineItem.Total_Addition__c = currEmpPaylineItem.Total_Addition__c + (adjustLineItem_New.Amount__c - adjustLineItem_Old.Amount__c); } else{ /* no access */ }
                           }
                           else {
                               if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Addition__c.isUpdateable()){ currEmpPaylineItem.Total_Addition__c = (adjustLineItem_New.Amount__c - adjustLineItem_Old.Amount__c); } else{ /* no access */ }
                           }
                       }
                       else if(adjustLineItem_New.Adjustment_Category1__c == 'Deduction'){                           
                           if(currEmpPaylineItem.Total_Deduction__c != null){
                               if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Deduction__c.isUpdateable()){currEmpPaylineItem.Total_Deduction__c = currEmpPaylineItem.Total_Deduction__c + (adjustLineItem_New.Amount__c - adjustLineItem_Old.Amount__c); } else{/* no access*/ }
                           }
                           else{
                               if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Deduction__c.isUpdateable()){currEmpPaylineItem.Total_Deduction__c = (adjustLineItem_New.Amount__c - adjustLineItem_Old.Amount__c); } else{ /* no access*/ }
                           }
                       }
                       
                   }
                   
                   else if(adjustLineItem_New.Adjustment_Category1__c == 'Addition' && adjustLineItem_Old.Adjustment_Category1__c == 'Deduction'){                       
                       if(currEmpPaylineItem.Total_Addition__c != null){
                           if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Addition__c.isUpdateable()){ currEmpPaylineItem.Total_Addition__c = currEmpPaylineItem.Total_Addition__c + adjustLineItem_New.Amount__c; } else{}
                       }
                       else {
                           if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Addition__c.isUpdateable()){ currEmpPaylineItem.Total_Addition__c = adjustLineItem_New.Amount__c;} else{}
                       }  
                       if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Deduction__c.isUpdateable()){ currEmpPaylineItem.Total_Deduction__c = currEmpPaylineItem.Total_Deduction__c - adjustLineItem_Old.Amount__c;   } else{ /* no access*/ }                          
                   }
                   
                   else if(adjustLineItem_New.Adjustment_Category1__c == 'Deduction' && adjustLineItem_Old.Adjustment_Category1__c == 'Addition'){                       
                       if(currEmpPaylineItem.Total_Deduction__c != null){
                           if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Deduction__c.isUpdateable()){currEmpPaylineItem.Total_Deduction__c = currEmpPaylineItem.Total_Deduction__c + adjustLineItem_New.Amount__c; } else{ }
                       }
                       else{
                           if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Deduction__c.isUpdateable()){currEmpPaylineItem.Total_Deduction__c =adjustLineItem_New.Amount__c ; } else { }
                       }  
                       if(Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Addition__c.isUpdateable()){ 
                       currEmpPaylineItem.Total_Addition__c  = (currEmpPaylineItem != null && currEmpPaylineItem.Total_Addition__c != null)? currEmpPaylineItem.Total_Addition__c:0;
                       currEmpPaylineItem.Total_Addition__c = currEmpPaylineItem.Total_Addition__c -  adjustLineItem_Old.Amount__c;
                       } else{ /* no access*/ }                                           
                   }                                      
                   Items2Update4.add(currEmpPaylineItem);               
               }
           }
       }
       if(Schema.sObjectType.Employee_Pay_Line_Item__c.isUpdateable()){ update Items2Update4; } else{ /* no access */ }
   }
   
   if(Trigger.IsDelete){
       List<Employee_Pay_Line_Item__c> Items2Update2 = new List<Employee_Pay_Line_Item__c>();
       for(Pay_Adjustment_Line_Item__c adjustLineItem : System.trigger.Old){
           Employee_Pay_Line_Item__c currEmpPaylineItem = addLine2Empline.get(adjustLineItem.id);
           if(adjustLineItem.Adjustment_Category1__c == 'Addition' && Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Addition__c.isUpdateable()){               
               currEmpPaylineItem.Total_Addition__c -= adjustLineItem.Amount__c;               
           }
           else if(adjustLineItem.Adjustment_Category1__c == 'Deduction' && Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Deduction__c.isUpdateable()){               
               currEmpPaylineItem.Total_Deduction__c -= adjustLineItem.Amount__c;               
           }
           Items2Update2.add(currEmpPaylineItem);
       }
       if(Schema.sObjectType.Employee_Pay_Line_Item__c.isUpdateable()){ update Items2Update2; } else { /* no access */ }
   }
   
   if(Trigger.IsUndelete){
       List<Employee_Pay_Line_Item__c> Items2Update3 = new List<Employee_Pay_Line_Item__c>();
       for(Pay_Adjustment_Line_Item__c adjustLineItem : System.trigger.New){
           Employee_Pay_Line_Item__c currEmpPaylineItem = addLine2Empline.get(adjustLineItem.id);
           if(adjustLineItem.Adjustment_Category1__c == 'Addition' && Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Addition__c.isUpdateable()){               
               currEmpPaylineItem.Total_Addition__c += adjustLineItem.Amount__c;               
           }
           else if(adjustLineItem.Adjustment_Category1__c == 'Deduction' && Schema.sObjectType.Employee_Pay_Line_Item__c.fields.Total_Deduction__c.isUpdateable()){               
               currEmpPaylineItem.Total_Deduction__c += adjustLineItem.Amount__c;               
           }
           Items2Update3.add(currEmpPaylineItem);
       }
       if(Schema.sObjectType.Employee_Pay_Line_Item__c.isUpdateable()){ update Items2Update3; } else { /* no access */ }
   }   
}