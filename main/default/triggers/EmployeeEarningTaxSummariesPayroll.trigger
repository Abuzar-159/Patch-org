trigger EmployeeEarningTaxSummariesPayroll on Employee_Pay__c (before insert, after insert, after update) {
    /*
    if(Trigger.IsBefore){
        Set<Id> empIds = new Set<Id>();
        for(Employee_Pay__c emp : System.Trigger.New){
            empIds.add(emp.Employees__c);
        }
        List<Employee_Earnings__c> empEarnings = [Select Id, Name, Active__c, Employees__c From Employee_Earnings__c
                                                  Where Active__c = true And
                                                  Employees__c In : empIds 
                                                  Order by CreatedDate Asc];
        
        Map<Id,List<Employee_Earnings__c>> emp_Earnings = new Map<Id,List<Employee_Earnings__c>>();
        
        for(Id empId : empIds){
            Boolean assign = true;
            List<Employee_Earnings__c> myEarnings = new List<Employee_Earnings__c>();
            for(Employee_Earnings__c EE : empEarnings){ if(empId == EE.Employees__c && assign == true){ myEarnings.add(EE); assign = false; } }
            emp_Earnings.put(empId, myEarnings);
        }
        
        for(Employee_Pay__c empPay : System.Trigger.New){
            List<Employee_Earnings__c> currentEarnings = (emp_Earnings.get(empPay.Employees__c) != Null) ? emp_Earnings.get(empPay.Employees__c) : new List<Employee_Earnings__c>();
            if(currentEarnings.size() > 0 && empPay.Employee_Earning__c != Null){ empPay.Employee_Earning__c = currentEarnings[0].Id; }
        }
    }  
    else if(Trigger.IsAfter && !PreventRecursiveLedgerEntry.testCasesTransactions){
        Id CIT; CIT = Schema.SObjectType.ERP7__Transaction__c.getRecordTypeInfosByDeveloperName().get('Employee_Pay_Transaction').getRecordTypeId();
        
        List<Id> EmpPayIds = new List<Id>();
        Map<Id, Transaction__c> creditTransaction_AccPay = new Map<Id, Transaction__c>();
        Map<Id, Transaction__c> debitTransaction_SalaryPay = new Map<Id, Transaction__c>();
        Map<Id, Transaction__c> debitTransaction_AccPay = new Map<Id, Transaction__c>();
        Map<Id, Transaction__c> creditTransaction_SalaryPay  = new Map<Id, Transaction__c>();
        for(Employee_Pay__c EmpPay : System.Trigger.New){
            EmpPayIds.add(EmpPay.Id);
        }
        
        List<Transaction__c> existingCreditTransactions_AccPay = [Select Id, Name, Active__c, Amount__c, Employee_Pay__c, 
                                                                  Expense__c, Finance_Category_Type__c, Invoice__c, 
                                                                  Organisation__c,  Payment__c, 
                                                                  Sales_Order__c,  Transaction_Date__c, 
                                                                  Transaction_Method__c, Transaction_Status__c, Transaction_Type__c 
                                                                  From Transaction__c
                                                                  Where Employee_Pay__c In : EmpPayIds And
                                                                  Transaction_Type__c = 'Accounts Payable' And
                                                                  Finance_Category_Type__c = 'Credit']; 
        
        List<Transaction__c> existingDebitTransactions_SalaryPay = [Select Id, Name, Active__c, Amount__c, Employee_Pay__c, 
                                                                    Expense__c, Finance_Category_Type__c, Invoice__c, 
                                                                    Organisation__c,  Payment__c, 
                                                                    Sales_Order__c,Transaction_Date__c, 
                                                                    Transaction_Method__c, Transaction_Status__c, Transaction_Type__c 
                                                                    From Transaction__c
                                                                    Where Employee_Pay__c In : EmpPayIds And
                                                                    Transaction_Type__c = 'Salaries Payable' And
                                                                    Finance_Category_Type__c = 'Debit'];                                                      
         
                                                                                  
        List<Transaction__c> existingDebitTransactions_AccPay = [Select Id, Name, Active__c, Amount__c, Employee_Pay__c, 
                                                                 Expense__c, Finance_Category_Type__c, Invoice__c, 
                                                                 Organisation__c,  Payment__c, 
                                                                 Sales_Order__c, Transaction_Date__c, 
                                                                 Transaction_Method__c, Transaction_Status__c, Transaction_Type__c 
                                                                 From Transaction__c
                                                                 Where Employee_Pay__c In : EmpPayIds And
                                                                 Transaction_Type__c = 'Accounts Payable' And
                                                                 Finance_Category_Type__c = 'Debit']; 
        
        List<Transaction__c> existingCreditTransactions_SalaryPay = [Select Id, Name, Active__c, Amount__c, Employee_Pay__c, 
                                                                     Expense__c, Finance_Category_Type__c, Invoice__c, 
                                                                     Organisation__c,  Payment__c, 
                                                                     Sales_Order__c, Transaction_Date__c, 
                                                                     Transaction_Method__c, Transaction_Status__c, Transaction_Type__c 
                                                                     From Transaction__c
                                                                     Where Employee_Pay__c In : EmpPayIds And
                                                                     Transaction_Type__c = 'Salaries Payable' And
                                                                     Finance_Category_Type__c = 'Credit']; 
     
        for(Transaction__c creditTrans : existingCreditTransactions_AccPay){
            creditTransaction_AccPay.put(creditTrans.Employee_Pay__c, creditTrans);
        } 
        
        for(Transaction__c debitTrans : existingDebitTransactions_SalaryPay){
            debitTransaction_SalaryPay.put(debitTrans.Employee_Pay__c, debitTrans);
        } 
        
        for(Transaction__c debitTrans : existingDebitTransactions_AccPay){ debitTransaction_AccPay.put(debitTrans.Employee_Pay__c, debitTrans); }
        
        for(Transaction__c creditTrans : existingCreditTransactions_SalaryPay){ creditTransaction_SalaryPay.put(creditTrans.Employee_Pay__c, creditTrans); } 
        
        List<Transaction__c> Transactions2update = new List<Transaction__c>();
        
        for(Employee_Pay__c EmpPay : System.Trigger.New){
            if(EmpPay.Active__c && !(creditTransaction_AccPay.containsKey(EmpPay.Id))){
                Transaction__c trans = new Transaction__c();
                if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
                if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = EmpPay.Net_Pay__c;
                if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Credit';
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Accounts Payable';
                if(Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isUpdateable()) trans.Employee_Pay__c = EmpPay.Id;
                if(CIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = CIT; }
                Transactions2update.add(trans);
            }
            else if(EmpPay.Active__c && creditTransaction_AccPay.containsKey(EmpPay.Id)){
                Transaction__c trans = creditTransaction_AccPay.get(EmpPay.Id);
                if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
                if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = EmpPay.Net_Pay__c;
                if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Credit';
                if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()) trans.Organisation__c = EmpPay.Organisation__c;
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
                if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Accounts Payable';
                if(Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isUpdateable()) trans.Employee_Pay__c = EmpPay.Id;
                Transactions2update.add(trans);
           }
           if(EmpPay.Active__c && !(debitTransaction_SalaryPay.containsKey(EmpPay.Id))){
               Transaction__c trans = new Transaction__c();
               if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
               if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = EmpPay.Net_Pay__c;
               if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Debit';
               if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()) trans.Organisation__c = EmpPay.Organisation__c;
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Salaries Payable';
               if(Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isUpdateable()) trans.Employee_Pay__c = EmpPay.Id;
               if(CIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = CIT; }
               Transactions2update.add(trans);
           }
           else if(EmpPay.Active__c && debitTransaction_SalaryPay.containsKey(EmpPay.Id)){
               Transaction__c trans = debitTransaction_SalaryPay.get(EmpPay.Id);
               if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
               if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = EmpPay.Net_Pay__c;
               if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Debit';
               if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()) trans.Organisation__c = EmpPay.Organisation__c;
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Salaries Payable';
               if(Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isUpdateable()) trans.Employee_Pay__c = EmpPay.Id;
               Transactions2update.add(trans);
           }
            
           if(EmpPay.Active__c && EmpPay.Paid__c == true && !(debitTransaction_AccPay.containsKey(EmpPay.Id))){
               Transaction__c trans = new Transaction__c();
               if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
               if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = EmpPay.Net_Pay__c;
               if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Debit';
               if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()) trans.Organisation__c = EmpPay.Organisation__c;
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Accounts Payable';
               if(Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isUpdateable()) trans.Employee_Pay__c = EmpPay.Id;
               if(CIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = CIT; }
               Transactions2update.add(trans);
           }
           else if(EmpPay.Active__c && EmpPay.Paid__c == true && debitTransaction_AccPay.containsKey(EmpPay.Id)){
               Transaction__c trans = debitTransaction_AccPay.get(EmpPay.Id);
               if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
               if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = EmpPay.Net_Pay__c;
               if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Debit';
               if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()) trans.Organisation__c = EmpPay.Organisation__c;
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Accounts Payable';
               if(Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isUpdateable()) trans.Employee_Pay__c = EmpPay.Id;
               Transactions2update.add(trans);
           }
            
           if(EmpPay.Active__c && EmpPay.Paid__c == true && !(creditTransaction_SalaryPay.containsKey(EmpPay.Id))){
               Transaction__c trans = new Transaction__c();
               if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
               if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = EmpPay.Net_Pay__c;
               if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Credit';
               if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()) trans.Organisation__c = EmpPay.Organisation__c;
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Date__c.isUpdateable()) trans.Transaction_Date__c = System.Today();
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Salaries Payable';
               if(Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isUpdateable()) trans.Employee_Pay__c = EmpPay.Id;
               if(CIT != null && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Transaction__c.fields.RecordTypeId.isUpdateable()){ trans.RecordTypeId = CIT; }
               Transactions2update.add(trans);
           }
           else if(EmpPay.Active__c && EmpPay.Paid__c == true && creditTransaction_SalaryPay.containsKey(EmpPay.Id)){
               Transaction__c trans = creditTransaction_SalaryPay.get(EmpPay.Id);
               if(Schema.sObjectType.Transaction__c.fields.Active__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Active__c.isUpdateable()) trans.Active__c = true;
               if(Schema.sObjectType.Transaction__c.fields.Amount__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Amount__c.isUpdateable()) trans.Amount__c = EmpPay.Net_Pay__c;
               if(Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Finance_Category_Type__c.isUpdateable()) trans.Finance_Category_Type__c = 'Credit';
               if(Schema.sObjectType.Transaction__c.fields.Organisation__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Organisation__c.isUpdateable()) trans.Organisation__c = EmpPay.Organisation__c;
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Status__c.isUpdateable()) trans.Transaction_Status__c = 'Completed';
               if(Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Transaction_Type__c.isUpdateable()) trans.Transaction_Type__c = 'Salaries Payable';
               if(Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isCreateable() && Schema.sObjectType.Transaction__c.fields.Employee_Pay__c.isUpdateable()) trans.Employee_Pay__c = EmpPay.Id;
               Transactions2update.add(trans);
          } 
        } 
     
        if(Transactions2update.size() > 0 && Schema.sObjectType.Transaction__c.isCreateable() && Schema.sObjectType.Transaction__c.isUpdateable()){ upsert Transactions2update; } else{ /* no access / }
            
        if(Trigger.IsInsert){
             List<Tax_Summary__c> taxSummaries = new List<Tax_Summary__c>();
             Id rt; rt = Schema.SObjectType.ERP7__Tax_Summary__c.getRecordTypeInfosByDeveloperName().get('Payroll_Tax_Summary').getRecordTypeId();
                
             for(Employee_Pay__c emp : System.Trigger.New){
                 Tax_Summary__c taxSummary = new Tax_Summary__c();                        
                 if(Schema.sObjectType.Tax_Summary__c.fields.Active__c.isCreateable() && Schema.sObjectType.Tax_Summary__c.fields.Active__c.isUpdateable()) taxSummary.Active__c = true;
                 if(Schema.sObjectType.Tax_Summary__c.fields.Employee_Pay__c.isCreateable() && Schema.sObjectType.Tax_Summary__c.fields.Employee_Pay__c.isUpdateable()) taxSummary.Employee_Pay__c = emp.Id;                               
                 if(Schema.sObjectType.Tax_Summary__c.fields.Received__c.isCreateable() && Schema.sObjectType.Tax_Summary__c.fields.Received__c.isUpdateable()) taxSummary.Received__c = true;
                 if(rt != null && Schema.sObjectType.Tax_Summary__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.Tax_Summary__c.fields.RecordTypeId.isUpdateable()){ taxSummary.RecordTypeId = rt; }     
                 taxSummaries.add(taxSummary);
             }    
            if(Schema.sObjectType.Tax_Summary__c.isCreateable() && Schema.sObjectType.Tax_Summary__c.isUpdateable()){ upsert taxSummaries;  } else{ /* no access / }
        }
    }*/
}