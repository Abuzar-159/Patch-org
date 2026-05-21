trigger ERPOnAccount on Account (after insert, after update, after Delete,after undelete){
    if(ERP7.PreventRecursiveLedgerEntry.proceed){
        ERP7.PreventRecursiveLedgerEntry.proceed=false; 
        List < ERP7__Employees__c > currentEmployees = [Select Id, Name, ERP7__First_Name__c, ERP7__Last_Name__c, ERP7__Channel__c, ERP7__Employee_User__c, ERP7__Email__c, ERP7__Employee_Profiling__c, ERP7__Organisation__c,
                                                        ERP7__Organisation_Business_Unit__c
                                                        From ERP7__Employees__c
                                                        Where ERP7__Employee_User__c = : UserInfo.getUserId() And
                                                        ERP7__Active__c = True
                                                        Order by CreatedDate Asc Limit 1];
        if(currentEmployees.size()>0){
            if(Trigger.isInsert || Trigger.isUpdate){
                try{
                    // To update the COA
                    Map<String, Decimal> COA = New Map<String, Decimal>(); 
                    // To get the all COA 
                    for( Account acc : System.Trigger.New){
                        COA.put(acc.ERP7__Customer_Account__c, 0);
                    }
                    List<ERP7__Chart_of_Accounts__c> getCOA = [Select id,ERP7__Opening_Balance__c From ERP7__Chart_of_Accounts__c where id IN: COA.KeySet()];
                    for(ERP7__Chart_of_Accounts__c c : getCOA){  if(c.ERP7__Opening_Balance__c==null && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) c.ERP7__Opening_Balance__c=0;  COA.put(c.id, c.ERP7__Opening_Balance__c); } 
                    // Get Equity COA
                    List<ERP7__Chart_of_Accounts__c> getEquityCOA = [Select id,ERP7__Opening_Balance__c from ERP7__Chart_of_Accounts__c where RecordType.DeveloperName ='Equity'
                                                                     And ERP7__Account_Type__c='Equity'];
                    decimal accOpeningBalance=0;
                    decimal oldAccOpeningBalance=0;
                    //Add up all the opening balance to COA
                    for( Account acc : System.Trigger.New){
                        if(acc.ERP7__Opening_Balance__c==null)accOpeningBalance=0;
                        else accOpeningBalance=acc.ERP7__Opening_Balance__c;
                        if(Trigger.oldMap!=null && Trigger.oldMap.get(acc.Id).ERP7__Opening_Balance__c==null)oldAccOpeningBalance=0;
                        else if(Trigger.oldMap!=null)oldAccOpeningBalance=Trigger.oldMap.get(acc.Id).ERP7__Opening_Balance__c;
                        if(Trigger.oldMap!=null && oldAccOpeningBalance!=accOpeningBalance && acc.ERP7__Customer_Account__c!=null){ if(oldAccOpeningBalance==0){ COA.put(acc.ERP7__Customer_Account__c, COA.get(acc.ERP7__Customer_Account__c)+accOpeningBalance); if(getEquityCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) getEquityCOA[0].ERP7__Opening_Balance__c += accOpeningBalance; }
                            else if( oldAccOpeningBalance < accOpeningBalance){ COA.put(acc.ERP7__Customer_Account__c,COA.get(acc.ERP7__Customer_Account__c) + (accOpeningBalance - oldAccOpeningBalance)); if(getEquityCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) getEquityCOA[0].ERP7__Opening_Balance__c = getEquityCOA[0].ERP7__Opening_Balance__c+(accOpeningBalance - oldAccOpeningBalance);  } else{ COA.put(acc.ERP7__Customer_Account__c,COA.get(acc.ERP7__Customer_Account__c) - (oldAccOpeningBalance- accOpeningBalance ));  if(getEquityCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) getEquityCOA[0].ERP7__Opening_Balance__c = getEquityCOA[0].ERP7__Opening_Balance__c - (oldAccOpeningBalance- accOpeningBalance );  } }
                        if(Trigger.oldMap==null){
                            COA.put(acc.ERP7__Customer_Account__c, COA.get(acc.ERP7__Customer_Account__c)+accOpeningBalance);
                            if(getEquityCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) getEquityCOA[0].ERP7__Opening_Balance__c += accOpeningBalance;
                        }
                    }
                    //update the updated opening balance to COA  
                    for(ERP7__Chart_of_Accounts__c c : getCOA){ if(Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) c.ERP7__Opening_Balance__c = COA.get(c.id);
                    }
                    if(getCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isUpdateable()){ upsert getCOA; } else{ /* no access */ }
                    if(getEquityCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isUpdateable()){ upsert getEquityCOA; } else{ /* no access */ }} catch(exception ex){ String exceptionError = ex.getMessage(); exceptionError += ' Line No: ' + ex.getLineNumber(); exceptionError += ' getStackTraceString: ' + ex.getStackTraceString(); } 
            }
            
            if(Trigger.isDelete){
                try{
                    Map<String, decimal> updateCOA = new Map<String, Decimal>();
                    // Get Equity COA
                    List<ERP7__Chart_of_Accounts__c> getEquityCOA = [Select id,ERP7__Opening_Balance__c from ERP7__Chart_of_Accounts__c where RecordType.DeveloperName ='Equity'
                                                                     And ERP7__Account_Type__c='Equity'];
                    for(Account acc : Trigger.old){  if(acc.ERP7__Opening_Balance__c!=null && acc.ERP7__Opening_Balance__c>0){
                            if(updateCOA.get(acc.ERP7__Customer_Account__c)==null)updateCOA.put(acc.ERP7__Customer_Account__c, acc.ERP7__Opening_Balance__c);  else updateCOA.put(acc.ERP7__Customer_Account__c, updateCOA.get(acc.ERP7__Customer_Account__c)+acc.ERP7__Opening_Balance__c);
                        }
                    }
                    if(updateCOA.size()>0){  List<ERP7__Chart_of_Accounts__c> getCOA =[Select id,ERP7__Opening_Balance__c from ERP7__Chart_of_Accounts__c where id IN: updateCOA.KeySet()];
                                           for(ERP7__Chart_of_Accounts__c c : getCOA){
                                               if(updateCOA.get(c.id)!=null && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) c.ERP7__Opening_Balance__c = c.ERP7__Opening_Balance__c - updateCOA.get(c.id); 
                                               if(getEquityCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) getEquityCOA[0].ERP7__Opening_Balance__c = getEquityCOA[0].ERP7__Opening_Balance__c - updateCOA.get(c.id);
                                           }
                                           if(getCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isUpdateable()) { upsert getCOA; } else{ /* no access*/ }
                                           if(getEquityCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isUpdateable()){ upsert getEquityCOA; } else{ /* no access */ }
                                          }
                } catch(exception ex){  String exceptionError = ex.getMessage(); exceptionError += ' Line No: ' + ex.getLineNumber(); exceptionError += ' getStackTraceString: ' + ex.getStackTraceString();
                                     } 
            }
            
            if(Trigger.isUndelete){
                try{
                    // updating the COA'S on undelete of Account   
                    Map<String, Decimal> COA = New Map<String, Decimal>(); 
                    // Get Equity COA
                    List<ERP7__Chart_of_Accounts__c> getEquityCOA = [Select id,ERP7__Opening_Balance__c from ERP7__Chart_of_Accounts__c where RecordType.DeveloperName ='Equity'
                                                                     And ERP7__Account_Type__c='Equity'];
                    if(getEquityCOA.size()>0 && getEquityCOA[0].ERP7__Opening_Balance__c==null) getEquityCOA[0].ERP7__Opening_Balance__c=0;   
                    for(Account a : trigger.new){
                        if( a.ERP7__Opening_Balance__c!=null && a.ERP7__Customer_Account__c!=null ){
                            if(COA.get(a.ERP7__Customer_Account__c)!=null)COA.put(a.ERP7__Customer_Account__c,COA.get(a.ERP7__Customer_Account__c)+a.ERP7__Opening_Balance__c );
                            else COA.put(a.ERP7__Customer_Account__c, a.ERP7__Opening_Balance__c);
                            if(getEquityCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) getEquityCOA[0].ERP7__Opening_Balance__c = getEquityCOA[0].ERP7__Opening_Balance__c+ a.ERP7__Opening_Balance__c;
                        }
                    }
                    if(COA.size()>0){
                        List<ERP7__Chart_of_Accounts__c> updateCOA = [Select id,ERP7__Opening_Balance__c from ERP7__Chart_of_Accounts__c where id IN:COA.keyset()];
                        for(ERP7__Chart_of_Accounts__c c : updateCOA){
                           if(Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.fields.ERP7__Opening_Balance__c.isUpdateable()) c.ERP7__Opening_Balance__c = c.ERP7__Opening_Balance__c + COA.get(c.id);
                        }
                        // upserting the COA
                        if(updateCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isUpdateable()){ upsert updateCOA; } else{ /* no access */ }
                        // upserting the equity COA
                        if(getEquityCOA.size()>0 && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isCreateable() && Schema.sObjectType.ERP7__Chart_of_Accounts__c.isUpdateable()) { upsert getEquityCOA;   } else{ /* no access */ }
                    }
                }catch(Exception ex){ String exceptionError = ex.getMessage(); exceptionError += ' Line No: ' + ex.getLineNumber(); exceptionError += ' getStackTraceString: ' + ex.getStackTraceString();
                                    }  
            }
        }
    }
}