/*
* Changes made by Syed Moin Pasha 
* Date - 12th August 2021
* Reason - to Fetch the customsetting for controlling the screen display
* 
* 
* 
*/

public with sharing class ExpenseSheetLC { 
    //@AuraEnabled
    //public Attachment Attach                                { get; set; }
    @AuraEnabled public Decimal numAmountRej                            { get; set; }  @AuraEnabled public Decimal numAmountTax                            { get; set; }
    @AuraEnabled public Decimal numAmountSub                             { get; set; } @AuraEnabled public Decimal numAmountApp                             { get; set; }
    @AuraEnabled public Decimal numAmountPaid                            { get; set; } @AuraEnabled public list < Expense_Line_Item__c > expenseLine        { get; set; }
    @AuraEnabled public Expense__c expense                               { get; set; } @AuraEnabled public ERP7__Expense__c Expense1                        { get; set; }
    @AuraEnabled public list <ERP7__Expense_Line_Item__c> ExpenseLines1  { get; set; } @AuraEnabled public Boolean approvalProcess                             {get; set; }
    @AuraEnabled public List<Attachment> accList {get;set;}                            
    @AuraEnabled public List<ERP7__Expense__c> expenses                  { get; set; }  @AuraEnabled public List<ExpenseWrap> expwraplist    {get; set; }
    @AuraEnabled
    public static List<ExpenseSheetLC> getSheet(String FiscalYear, String UserId) {
        if(!Schema.sObjectType.Expense__c.isAccessible()) { throw new System.NoAccessException(); } 
        else {
            String [] expenseAccessFields = new String [] {'Id', 'Name', 'ERP7__Paid__c', 'ERP7__Amount__c', 'ERP7__VAT_Amount__c', 'ERP7__Amount_Submitted__c', 'ERP7__Date__c', 'ERP7__Employees__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Expense__c.fields.getMap();
            for (String fieldToCheck : expenseAccessFields) { if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); } }
            
            String selectedFY = (FiscalYear == '' || FiscalYear == null)?'!=THIS_FISCAL_YEAR' : '='+FiscalYear;
            List<ExpenseSheetLC> EXwrpList = new List<ExpenseSheetLC>();
            List<ERP7__Expense__c> expn = new List<ERP7__Expense__c>();
            List<ERP7__Expense_Line_Item__c> exLines = new List<ERP7__Expense_Line_Item__c>();
            set<Id> setIds = new set<Id>();
            String usrId = '';
            if(UserId == '' || UserId == null) usrId = userinfo.getUserId();
            else usrId = UserId;
            String exQry = 'SELECT Id, Name, ERP7__Project__c, Project__r.Name, Paid__c,'+
                ' Amount__c, ERP7__Approver__c, Approver__r.Name, Status__c, VAT_Amount__c, ERP7__Amount_Submitted__c, Date__c'+
                ' FROM Expense__c where Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(usrId)+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY)+
                ' and ERP7__Status__c != \'Approved\' and ERP7__Status__c != \'Rejected\' order by ERP7__Date__c desc';
            expn = database.query(exQry);
            for(ERP7__Expense__c ex : expn){ setIds.add(ex.Id);
                                           }
            if(setIds.size() > 0){
                exLines = [SELECT Id, Name, ERP7__Claimed_Amount__c, ERP7__Expense__c, ERP7__Expensed_Submitted__c FROM ERP7__Expense_Line_Item__c where ERP7__Expense__c =:setIds ORDER BY Name asc];
                for(ERP7__Expense__c ex1 : expn){
                    ExpenseSheetLC EXwrp = new ExpenseSheetLC();
                    List<ERP7__Expense_Line_Item__c> EX_lines = new List<ERP7__Expense_Line_Item__c>();
                    for(ERP7__Expense_Line_Item__c exli : exLines){
                        if(exli.ERP7__Expense__c == ex1.Id){
                            EX_lines.add(exli);
                        }
                    }
                    EXwrp.Expense1 = ex1;
                    EXwrp.ExpenseLines1 = (EX_lines.size()>0)?EX_lines : new List<ERP7__Expense_Line_Item__c>();
                    EXwrpList.add(EXwrp);
                }
            }
            return EXwrpList;
        }
    }
    
    @AuraEnabled
    public static List<ExpenseSheetLC> getSheetRefund(String FiscalYear, String UserId) {
        if(!Schema.sObjectType.Expense__c.isAccessible()) {  throw new System.NoAccessException(); //return null;
                                                          } 
        else {
            String [] expenseAccessFields = new String [] {'Id', 'Name', 'ERP7__Paid__c', 'ERP7__Amount__c', 'ERP7__VAT_Amount__c', 'ERP7__Amount_Submitted__c', 'ERP7__Date__c', 'ERP7__Employees__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Expense__c.fields.getMap();
            for (String fieldToCheck : expenseAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return null;
                                                                      }
            }
            
            String selectedFY = (FiscalYear == '' || FiscalYear == null)?'!=THIS_FISCAL_YEAR' : '='+FiscalYear;
            List<ExpenseSheetLC> EXwrpList = new List<ExpenseSheetLC>();
            List<ERP7__Expense__c> expn = new List<ERP7__Expense__c>();
            String usrId = '';
            if(UserId == '' || UserId == null) usrId = userinfo.getUserId();
            else usrId = UserId;
            List<ERP7__Expense_Line_Item__c> exLines = new List<ERP7__Expense_Line_Item__c>();
            set<Id> setIds = new set<Id>();
            String exQry = 'SELECT id, Name, ERP7__Project__c, ERP7__Refund_Expense__c, Project__r.Name, Paid__c,'+
                ' Amount__c, ERP7__Approver__c, Approver__r.Name, Status__c, VAT_Amount__c, ERP7__Amount_Submitted__c, Date__c'+
                ' FROM Expense__c where Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(usrId)+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY)+
                ' and ERP7__Status__c != \'Approved\' and ERP7__Status__c != \'Rejected\' and ERP7__Refund_Expense__c = true';
            expn = database.query(exQry);
            for(ERP7__Expense__c ex : expn){ setIds.add(ex.Id);
                                           }
            if(setIds.size() > 0){
                exLines = [SELECT Id, Name, ERP7__Claimed_Amount__c, ERP7__Expense__c, ERP7__Expensed_Submitted__c FROM ERP7__Expense_Line_Item__c where ERP7__Expense__c =:setIds ORDER BY Name asc];
                for(ERP7__Expense__c ex1 : expn){
                    ExpenseSheetLC EXwrp = new ExpenseSheetLC();
                    List<ERP7__Expense_Line_Item__c> EX_lines = new List<ERP7__Expense_Line_Item__c>();
                    for(ERP7__Expense_Line_Item__c exli : exLines){
                        if(exli.ERP7__Expense__c == ex1.Id){
                            EX_lines.add(exli);
                        }
                    }
                    EXwrp.Expense1 = ex1;
                    EXwrp.ExpenseLines1 = (EX_lines.size()>0)?EX_lines : new List<ERP7__Expense_Line_Item__c>();
                    EXwrpList.add(EXwrp);
                }
            }
            return EXwrpList;
        }
    }
    
    @AuraEnabled
    public static List<ExpenseSheetLC> getSheetApproved(String FiscalYear) {
        if(!Schema.sObjectType.Expense__c.isAccessible()) { throw new System.NoAccessException(); //return null;
                                                          } 
        else {
            String [] expenseAccessFields = new String [] {'Id', 'Name', 'ERP7__Paid__c', 'ERP7__Amount__c', 'ERP7__VAT_Amount__c', 'ERP7__Amount_Submitted__c', 'ERP7__Date__c', 'ERP7__Employees__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Expense__c.fields.getMap();
            for (String fieldToCheck : expenseAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException(); //return null;
                                                                      }
            }
            
            String selectedFY = (FiscalYear == '' || FiscalYear == null)?'!=THIS_FISCAL_YEAR' : '='+FiscalYear;
            List<ExpenseSheetLC> EXwrpList = new List<ExpenseSheetLC>();
            List<ERP7__Expense__c> expn = new List<ERP7__Expense__c>();
            List<ERP7__Expense_Line_Item__c> exLines = new List<ERP7__Expense_Line_Item__c>();
            set<Id> setIds = new set<Id>();
            String exQry = 'SELECT id, Name, ERP7__Project__c, Project__r.Name, Paid__c,'+
                ' Amount__c, ERP7__Approver__c, Approver__r.Name, Status__c, VAT_Amount__c, Amount_Submitted__c, Date__c'+
                ' FROM Expense__c where Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(userinfo.getUserId())+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY)+
                ' and (ERP7__Status__c = \'Approved\' or ERP7__Status__c = \'Rejected\')';
            expn = database.query(exQry);
            for(ERP7__Expense__c ex : expn){ setIds.add(ex.Id);
                                           }
            if(setIds.size() > 0){
                exLines = [SELECT Id, Name, ERP7__Claimed_Amount__c, ERP7__Expense__c FROM ERP7__Expense_Line_Item__c where ERP7__Expense__c =:setIds ORDER BY Name asc];
                for(ERP7__Expense__c ex1 : expn){
                    ExpenseSheetLC EXwrp = new ExpenseSheetLC();
                    List<ERP7__Expense_Line_Item__c> EX_lines = new List<ERP7__Expense_Line_Item__c>();
                    for(ERP7__Expense_Line_Item__c exli : exLines){ if(exli.ERP7__Expense__c == ex1.Id){ EX_lines.add(exli);
                                                                                                       }
                                                                  }
                    EXwrp.Expense1 = ex1;
                    EXwrp.ExpenseLines1 = (EX_lines.size()>0)?EX_lines : new List<ERP7__Expense_Line_Item__c>();
                    EXwrpList.add(EXwrp);
                }
            }
            return EXwrpList;
        }
    }
    
    @AuraEnabled
    public static List < Expense__c > getExpenses(String strDate) {
        if(strDate == null)strDate='Today';
        strDate = strDate.containsIgnoreCase('Today') ? '<=' + strDate : '=' + strDate;
        String SQuery;
        List < Expense__c > exp;
        
        String [] expenseAccessFields = new String [] {'Id',
            'Name',
            'ERP7__Paid__c',
            'ERP7__Amount__c',
            'ERP7__VAT_Amount__c',
            'ERP7__Amount_Submitted__c',
            'ERP7__Date__c',
            'ERP7__Employees__c'
            };
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Expense__c.fields.getMap();
        for (String fieldToCheck : expenseAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                   }
        }
        
        SQuery = 'SELECT Id, Name, ERP7__Project__c, ERP7__Project__r.Name, Paid__c, ' +
            'Amount__c, ERP7__Approver__c, Approver__r.Name, Status__c, VAT_Amount__c, Amount_Submitted__c, Date__c' +
            ' FROM Expense__c where Status__c != \'Approved\' and Date__c ' + String.escapeSingleQuotes(strDate) +
            ' and Employees__r.Employee_User__c = \'' + String.escapeSingleQuotes(userinfo.getUserId()) + '\'';
        exp = Database.query(SQuery);
        return exp;
    }
    
    @AuraEnabled
    public static List < Expense__c > getApprovedExpenses(String strDate) {
        try{
        if(strDate == null || strDate == '') strDate = 'Today';
        strDate = strDate.containsIgnoreCase('Today') ? '<=' + strDate : '=' + strDate;
        String SQuery;
        List < Expense__c > exp;
        if(!Schema.sObjectType.Expense__c.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Expense__c.Label)); return null;
                                                          } else {
                                                              String [] expenseAccessFields = new String [] {'Id',
                                                                  'Name',
                                                                  'ERP7__Paid__c',
                                                                  'ERP7__Amount__c',
                                                                  'ERP7__Status__c',
                                                                  'ERP7__VAT_Amount__c',
                                                                  'ERP7__Amount_Submitted__c',
                                                                  'ERP7__Date__c',
                                                                  'ERP7__Employees__c'
                                                                  };
                                                                      Map<String,Schema.SObjectField> m = Schema.SObjectType.Expense__c.fields.getMap();
                                                              for (String fieldToCheck : expenseAccessFields) {
                                                                  if (!m.get(fieldToCheck).getDescribe().isAccessible()) { throw new System.NoAccessException();  }
                                                              }
                                                              SQuery = 'SELECT Id, Name, Project__r.Name, Paid__c, ' +
                                                                  'Amount__c, ERP7__Approver__c, Approver__r.Name, Status__c, VAT_Amount__c, Amount_Submitted__c, Date__c' +
                                                                  ' FROM Expense__c where Status__c = \'Approved\' and Date__c ' + String.escapeSingleQuotes(strDate) +
                                                                  ' and Employees__r.Employee_User__c = \'' + String.escapeSingleQuotes(userinfo.getUserId()) + '\'';
                                                              exp = Database.query(SQuery);
                                                              return exp;
                                                          }
        }catch(Exception ex){
            return null;
        }
        
    }
    
    @AuraEnabled
    public static ERP7__Employees__c getEmployeeDetails() {
        if(!Schema.sObjectType.Employees__c.isAccessible()) { return null;
                                                            }
        else {
            String [] EmployeeAccessFields = new String [] {'Id', 'Name', 'ERP7__First_Name__c', 'ERP7__Last_Name__c', 'ERP7__ReportingManager__c', 'ERP7__Job_Title__c', 'ERP7__Employee_User__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Employees__c.fields.getMap();
            for (String fieldToCheck : EmployeeAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); //return null;
                                                                       }
            }
            return [select id, name, First_Name__c, Last_Name__c, Employee_User__c, Employee_User__r.fullphotourl, Employee_User__r.Name, ReportingManager__r.First_Name__c, ReportingManager__r.Last_Name__c,
                    Job_Title__c FROM Employees__c where Employee_User__c =: userinfo.getUserId()];
        }
    }
    
    @AuraEnabled
    public static Id deleteExpense(Id recordId) {
        Id oldExpenseId = null;
        try {
            if(Schema.SObjectType.Expense__c.isDeletable() && recordId!= null){ delete new Expense__c(Id = recordId); oldExpenseId = recordId; }else{ } } catch (System.Exception caught) {}
        return oldExpenseId;
    }
    
    @AuraEnabled
    public static void deleteMultiExpense(List<String> StrId) {//---------------------------------------------------------------------------------
       // Id oldExpenseId = null;
        Set<String> ExpIdsDel = new Set<String>();
        ExpIdsDel.addAll(StrId);
        List<Expense__c> exp= new List<Expense__c>();
        // List<Expense__c> delexp= new List<Expense__c>();
        //EXwrp.expenses=[SELECT id, N FROM Expense__c where Id In:ExpIdstoupdate];
        try {
            if(Schema.SObjectType.Expense__c.isDeletable()){ 
                for(String ids: ExpIdsDel ){
                  Expense__c expsub = new Expense__c(Id = ids);  
                    exp.add(expsub);
                //delete new Expense__c(Id = ids); oldExpenseId = recordId;                    
                }
               // delete new Expense__c(Id = recordId);
               delete exp;
                
                
                
               // oldExpenseId = recordId;
            }else{
            } 
        } catch (System.Exception caught) {}
        //return oldExpenseId;
    }
    
    @AuraEnabled
    public static ExpenseSheetLC GetRecordCounts(String strDate,String FiscalYear, String UserId) {
        ExpenseSheetLC result;
        String SQuery;
        String SQueryA;
        String SQueryP;
        String SQueryRej;
        String SQueryT;
        if(strDate == '' || strDate == null) strDate = '<= :System.today()';
        else strDate = '=' +strDate;
        String usrId = '';
        if(UserId == '' || UserId == null) usrId = userinfo.getUserId();
        else usrId = UserId;
        String selectedFY = (FiscalYear == '' || FiscalYear == null)?'!=THIS_FISCAL_YEAR' : '='+FiscalYear;
        if(!Schema.sObjectType.Expense__c.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Expense__c.Label)); return null;
                                                          } else {
                                                              
                                                              String [] expenseAccessFields = new String [] {'Id',
                                                                  'Name',
                                                                  'ERP7__Amount_Submitted__c',
                                                                  'ERP7__Date__c',
                                                                  'ERP7__Employees__c'
                                                                  };
                                                                      Map<String,Schema.SObjectField> m = Schema.SObjectType.Expense__c.fields.getMap();
                                                              for (String fieldToCheck : expenseAccessFields) {
                                                                  if (!m.get(fieldToCheck).getDescribe().isAccessible()) { throw new System.NoAccessException(); //return null;
                                                                                                                         }
                                                              }
                                                              result = new ExpenseSheetLC();
                                                              ERP7__Functionality_Control__c customList=new ERP7__Functionality_Control__c();
                                                              customList = ERP7__Functionality_Control__c.getValues(UserInfo.getUserId());
                                                              if(customList == null){ 
                                                                  customList = ERP7__Functionality_Control__c.getValues(UserInfo.getProfileId());
                                                                  if(customList==null) customList = ERP7__Functionality_Control__c.getInstance();            
                                                              }
                                                              if(customList != null){
                                                                  result.approvalProcess=customList.ERP7__Expense_Approval__c;
                                                              }
                                                              
                                                              /*Map<string, Module__c > RunModule = new Map<string, Module__c >();
RunModule =  Module__c.getAll();
result.approvalProcess=RunModule.get('Finance').ERP7__Foreign_Sales__c;*/
                                                              if(result.approvalProcess){
                                                                  SQuery = 'select SUM(ERP7__Amount__c) num' +
                                                                      ' FROM Expense__c where Status__c = \'Submitted\' and Date__c ' + String.escapeSingleQuotes(strDate) +
                                                                      ' and Employees__r.Employee_User__c =\'' + String.escapeSingleQuotes(usrId) + '\'';
                                                                  aggregateResult temp = Database.query(SQuery);
                                                                  if (temp.get('num') == null) {
                                                                      result.numAmountSub = 0.00;} else {result.numAmountSub = double.valueOf(temp.get('num'));
                                                                                                        }
                                                                  
                                                                  
                                                                  
                                                                  
                                                                  SQueryA = 'select SUM(ERP7__Amount__c) num2' +
                                                                      ' from Expense__c where Status__c = \'Approved\' and Date__c ' + String.escapeSingleQuotes(strDate) +
                                                                      ' and Employees__r.Employee_User__c =\'' + String.escapeSingleQuotes(usrId) + '\'';
                                                                  aggregateResult temp2 = Database.query(SQueryA);
                                                                  if (temp2.get('num2') == null) {
                                                                      result.numAmountApp = 0.00;} else {result.numAmountApp = double.valueOf(temp2.get('num2'));
                                                                                                        }
                                                                  
                                                                  
                                                                  
                                                                  SQueryP = 'select SUM(Amount__c) num3' +
                                                                      ' from Expense__c where Status__c = \'Approved\' and Date__c ' + String.escapeSingleQuotes(strDate) +
                                                                      ' and Paid__c = true and Employees__r.Employee_User__c =\'' + String.escapeSingleQuotes(usrId) + '\'';
                                                                  aggregateResult temp3 = Database.query(SQueryP);
                                                                  if (temp3.get('num3') == null) {
                                                                      result.numAmountPaid = 0.00;} else {result.numAmountPaid = double.valueOf(temp3.get('num3'));
                                                                                                         }
                                                                  
                                                                  SQueryRej = 'select SUM(Amount__c) num3' +
                                                                      ' from Expense__c where Status__c = \'Rejected\' and Date__c ' + String.escapeSingleQuotes(strDate) +
                                                                      ' and Employees__r.Employee_User__c =\'' + String.escapeSingleQuotes(usrId) + '\'';
                                                                  aggregateResult temp4 = Database.query(SQueryRej);
                                                                  if (temp4.get('num3') == null) {
                                                                      result.numAmountRej = 0.00;} else {result.numAmountRej = double.valueOf(temp4.get('num3'));
                                                                                                         }
                                                                  
                                                                  
                                                                  
                                                                  return result;
                                                              }else{
                                                                  
                                                                  SQuery = 'select SUM(ERP7__Amount__c) num' +
                                                                      ' FROM Expense__c '+'where Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(usrId)+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY);
                                                                  aggregateResult temp = Database.query(SQuery);
                                                                  if (temp.get('num') == null) {
                                                                      result.numAmountSub = 0.00;} else {result.numAmountSub = double.valueOf(temp.get('num'));
                                                                                                        }
                                                                  
                                                                  
                                                                  
                                                                  
                                                                  SQueryA = 'select SUM(ERP7__Amount__c) num2' +
                                                                      ' from Expense__c '+'where Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(usrId)+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY);
                                                                  aggregateResult temp2 = Database.query(SQueryA);
                                                                  if (temp2.get('num2') == null) {
                                                                      result.numAmountApp = 0.00;} else {result.numAmountApp = double.valueOf(temp2.get('num2'));
                                                                                                        }
                                                                  
                                                                  
                                                                  
                                                                  SQueryP = 'select SUM(Amount_Submitted__c) num1, SUM(ERP7__VAT_Amount__c) num2' +
                                                                      ' from Expense__c '+'where Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(usrId)+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY);
                                                                  aggregateResult temp3 = Database.query(SQueryP);
                                                                  if (temp3.get('num1') == null) {
                                                                      result.numAmountPaid = 0.00;} else {result.numAmountPaid = double.valueOf(temp3.get('num1'))+double.valueOf(temp3.get('num2'));
                                                                                                         }
                                                                  
                                                                   SQueryT = 'select SUM(ERP7__VAT_Amount__c) num4' +
                                                                      ' from Expense__c '+'where Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(usrId)+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY);
                                                                  aggregateResult temp4 = Database.query(SQueryT);
                                                                  if (temp4.get('num4') == null) {
                                                                      result.numAmountTax = 0.00;} else {result.numAmountTax = double.valueOf(temp4.get('num4'));
                                                                                                        }
                                                                  return result;
                                                                  
                                                              }
                                                          } //return null;
    }
    
    
    @AuraEnabled
    public static ExpenseSheetLC GetPaidRecordCounts(String strDate,String FiscalYear) {
        ExpenseSheetLC result;
        String SQuery;
        String SQueryA;
        String SQueryP;
        result = new ExpenseSheetLC();
        if(strDate == '' || strDate == null) strDate = '<= :System.today()'; else strDate = '=' +strDate;
        String selectedFY = (FiscalYear == '' || FiscalYear == null)?'!=THIS_FISCAL_YEAR' : '='+FiscalYear;
        if(!Schema.sObjectType.Expense__c.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Expense__c.Label)); return null;
        } else {
            
            String [] expenseAccessFields = new String [] {'Id',
                'Name',
                'ERP7__Amount_Submitted__c',
                'ERP7__Date__c',
                'ERP7__Employees__c'
                };
                    try{
                        SQuery = 'select SUM(Amount_Submitted__c) num ' +
                            ' FROM Expense__c '+'where ERP7__Refund_Expense__c = true and Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(userinfo.getUserId())+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY);
                        aggregateResult temp = Database.query(SQuery);
                        if (temp.get('num') == null) {
                            result.numAmountSub = 0.00;} else {result.numAmountSub = double.valueOf(temp.get('num'));
                                                              }
                        
                        
                        
                        
                        SQueryA = 'select SUM(ERP7__Amount__c) num2 ' +
                            ' from Expense__c '+'where ERP7__Refund_Expense__c = true and Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(userinfo.getUserId())+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY);
                        aggregateResult temp2 = Database.query(SQueryA);
                        if (temp2.get('num2') == null) {
                            result.numAmountApp = 0.00;} else {result.numAmountApp = double.valueOf(temp2.get('num2'));
                                                              }
                        
                        
                        
                        SQueryP = 'select SUM(Amount_Submitted__c) num1, SUM(ERP7__VAT_Amount__c) num2 ' +
                            ' from Expense__c '+'where ERP7__Refund_Expense__c = true and Employees__r.Employee_User__c = \''+String.escapeSingleQuotes(userinfo.getUserId())+'\'and ERP7__Date__c '+String.escapeSingleQuotes(selectedFY);
                        aggregateResult temp3 = Database.query(SQueryP);
                        if (temp3.get('num1') == null) {
                            result.numAmountPaid = 0.00;} else {result.numAmountPaid = double.valueOf(temp3.get('num1'))+double.valueOf(temp3.get('num2'));
                                                               }
                        
                        
                        return result; }catch(Exception e){ return result;
                    }
            
            //}
        } //return null;
    }
    
    @AuraEnabled
    public static Employees__c getEmployees() {
        Id userId = UserInfo.getUserId();
        if(!Schema.sObjectType.Employees__c.isAccessible()) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Employees__c.Label));  return null;
                                                            } else {
                                                                String [] EmployessAccessFields = new String [] {'Id',
                                                                    'Name',
                                                                    'ERP7__Organisation__c',
                                                                    'ERP7__Organisation_Business_Unit__c',
                                                                    'ERP7__Work_Status__c',
                                                                    'ERP7__ReportingManager__c',
                                                                    'ERP7__Marital_Status__c',
                                                                    'ERP7__First_Name__c',
                                                                    'ERP7__Gender__c',
                                                                    'ERP7__Job_Title__c',
                                                                    'ERP7__Former_Employee__c',
                                                                    'ERP7__Former_Employee_Record__c',
                                                                    'ERP7__Employment_End_Date__c',
                                                                    'ERP7__Employee_User__c',
                                                                    'ERP7__Social_Security_Number__c'
                                                                    };
                                                                        Map<String,Schema.SObjectField> m = Schema.SObjectType.Employees__c.fields.getMap();
                                                                for (String fieldToCheck : EmployessAccessFields) {
                                                                    if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException();  //return null;
                                                                                                                           }
                                                                }
                                                                return [Select Id, Organisation__c, Organisation__r.Start_of_Week__c, Organisation__r.Name, Organisation_Business_Unit__r.Name, Organisation_Business_Unit__c, Work_Status__c, Social_Security_Number__c, ReportingManager__c, Name, Marital_Status__c,
                                                                        Last_Name__c, Job_Title__c, Gender__c, Former_Employee__c, Former_Employee_Record__c, First_Name__c,
                                                                        Employment_End_Date__c, Employee_User__c, ReportingManager__r.First_Name__c, ReportingManager__r.Last_Name__c, ERP7__Employee_User__r.ManagerId 
                                                                        From Employees__c
                                                                        where Employee_User__c =: userId ORDER BY CREATEDDATE asc limit 1];
                                                            }
        
    }
    
    @AuraEnabled
    public static Id deleteExpenseSheet(Id recordId) {
        Id oldAccountId = null;
        
        try {
            if(Schema.SObjectType.Expense__c.isDeletable() && recordId != null){ delete new Expense__c(Id = recordId); oldAccountId = recordId; }else{ } } catch (System.Exception caught) {}
        return oldAccountId;
    }
    @AuraEnabled
    public static Id deleteElineItem(Id recordId) {
        Id oldAccountId = null;
        
        try {
            if(Schema.SObjectType.Expense_Line_Item__c.isDeletable()) delete new Expense_Line_Item__c(Id = recordId); else{ }
            oldAccountId = recordId;} catch (System.Exception caught) {}
        return oldAccountId;
        
    }
    @AuraEnabled
    public static Expense__c save_ExpenseIK(String isExpenseUpdate, String exp, String expliList, Boolean FromSP){
        try{
            Expense__c expense1 = (Expense__c) JSON.deserialize(exp, Expense__c .class);
            List<ExpenseWrapper> expenseLI1 = (List<ExpenseWrapper>) JSON.deserialize(expliList, List<ExpenseWrapper> .class);
            Id userId = UserInfo.getUserId();
            User manager = new User();
            List<ERP7__Expense_Line_Item__c> expenseLineI = new List<ERP7__Expense_Line_Item__c>();
            List<ERP7__Expense_Line_Item__c> expenseLineupdated = new List<ERP7__Expense_Line_Item__c>();
            ERP7__Employees__c emp = new ERP7__Employees__c();
            if(!FromSP){ emp = [Select Id, Name, ERP7__Employee_User__c From ERP7__Employees__c where ERP7__Employee_User__c =: userId limit 1]; manager = [Select Id, Name, ManagerId from User where Id =: emp.ERP7__Employee_User__c limit 1];
                       }
            
            if(expense1 != null && expense1.ERP7__Post__c){
                expense1.ERP7__Posted_Date__c = system.today();
            }
            
            if(isExpenseUpdate == 'false'){ 
                expense1.ERP7__Active__c = true; 
                //if(expense1.ERP7__Employees__c==null) expense1.ERP7__Employees__c = emp.Id; 
            }
            for(ExpenseWrapper eli : expenseLI1){ 
                expenseLineI.add(eli.ExpLI);
            }
            
            /*if(checkExpensesLine(expenseLineI)){
if(expense1 != null ) expense1.ERP7__Status__c = 'Submitted';
}else{
expense1.ERP7__Status__c = 'Draft';
}*/
            if( expense1.ERP7__Status__c == '')expense1.ERP7__Status__c = 'Draft';
            if(expense1 != null ) //&& Schema.SObjectType.Expense__c.isCreateable() && Schema.SObjectType.Expense__c.isUpdateable()
            {
                upsert expense1;
            }
            for(Expense_Line_Item__c expl:expenseLineI){ 
                if(expl.ERP7__Expense__c == Null) expl.ERP7__Expense__c=expense1.id; 
                expenseLineupdated.add(expl);
            }
            
            if(expenseLineupdated.size()>0){ 
                try{ 
                    upsert expenseLineupdated; 
                }catch(DMLException e){
                    
                }
            }
            //if(!FromSP && Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Approver__c.isAccessible()){
            
            
            
            if (expense1.ERP7__Status__c == 'Submitted' && expense1.ERP7__Approver__c !=null) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitted for approval. Please review and approve.');
                req.setObjectId(expense1.Id);
                system.debug('LeaveReq.ERP7__Approvers__c -->'+expense1.ERP7__Approver__c);
                req.setNextApproverIds(new Id[]{ expense1.ERP7__Approver__c});
                Approval.ProcessResult result = Approval.process(req);
            }
            //}
            //if (expense1 != null) return expense1;
            
            return expense1; 
        }
        catch (Exception e) {
            System.debug('Exception > '+ e.getMessage()+'; save_ExpenseIK at line > '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; save_ExpenseIK at line ~> '+e.getStackTraceString());
        } 
        
    }
    
    @AuraEnabled
    public static void upsateAllExpli(String expWrapList, Boolean posted){
        try{
            System.debug('expenses multi save');
         List <Expense_Line_Item__c> expline = (List <Expense_Line_Item__c> ) JSON.deserialize(expWrapList, List <Expense_Line_Item__c> .class); 
        update expline;
        Set<Id> expIds = new Set<Id>();
        system.debug(posted==true);
        if(posted==true){
            system.debug('posted-->'+posted);
            for(Expense_Line_Item__c exline : expline){
                if(exline.ERP7__Expense__c!=null){
                    expIds.add(exline.ERP7__Expense__c);
                }
            }
            if(expIds.size()>0){
                List<Expense__c> explist = new List<Expense__c>();
                explist = [select Id, Name, ERP7__Post__c from Expense__c where Id IN :expIds];
                for(Expense__c exp : explist){
                    exp.ERP7__Post__c = true;
                    exp.ERP7__Status__c = 'Submitted';
                }
                update explist;
            }
        }
        } catch (Exception e) {
            System.debug('Exception > '+ e.getMessage()+'; at line > '+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage()+'; at line ~> '+e.getStackTraceString());
        } 
    }


    
    @AuraEnabled
    public static Boolean checkExpensesLine(List<Expense_Line_Item__c> expenseLine){
        if(expenseLine!=null){
            set<Id> explineId = new Set<Id>();
            for(Expense_Line_Item__c expline : expenseLine){
                if(expline.ERP7__Vendor__c == null){
                    return false;
                }
                if(expline.ERP7__Chart_of_Account__c == null && expline.ERP7__Expense_Type__c != 'Bill Payment' && expline.ERP7__Expense_Type__c != 'Interim payment'){
                    return false;
                }
                if(expline.ERP7__Expense_Type__c != 'Bill Payment' && expline.ERP7__Expense_Type__c != 'Interim payment') explineId.add(expline.Id);
            }
            List<Attachment> accList = new List<Attachment>();
            Map<Id, Attachment> accMap = new Map<Id, Attachment>();
            accList = [select Id, parentId from Attachment where parentId IN :explineId ];
            if(explineId.size()<=0){
                return true;
            }
            if(accList.size()<=0){
                return false;
            }else{
                for(Attachment acc : accList){
                    accMap.put(acc.parentId, acc);
                }
                for(Expense_Line_Item__c expline : expenseLine){
                    if(!accMap.containsKey(expline.Id) && expline.ERP7__Expense_Type__c != 'Bill Payment' && expline.ERP7__Expense_Type__c != 'Interim payment'){
                        return false;
                    }
                }
            }
            return true;
        }
        return false;
    }
    @AuraEnabled
    public static Expense_Line_Item__c saveExpenseLineItem(String eLineEntry1) {
        Expense_Line_Item__c eLineEntry = (Expense_Line_Item__c) JSON.deserialize(eLineEntry1, Expense_Line_Item__c.class);
        if (eLineEntry != null) {
            upsert eLineEntry;
        }
        return eLineEntry;
    }
     
    
    @AuraEnabled
    public static ExpenseSheetLC EditExpense(String strId) {
        ExpenseSheetLC temp = new ExpenseSheetLC();
        if(Schema.sObjectType.Expense__c.isAccessible()) {
            temp.expense = [SELECT id, Name, Amount_Submitted__c, Approve_Rejected_Reason__c, Approve_Rejected_Date__c, Amount__c, ERP7__Refund_Expense__c, ERP7__Date__c, Employees__c, VAT_Amount__c, Status__c, Project__c, ERP7__Approver__c, ERP7__Approver__r.Name,ERP7__Vendor_Account__c, ERP7__Chart_of_Account__c, ERP7__Sales_Order__c, ERP7__Post__c FROM Expense__c where Id =: strId];
        }
        if(Schema.sObjectType.Expense_Line_Item__c.isAccessible()) {
            temp.expenseLine = [SELECT Id, Name, Expense__r.Name, Expensed_Submitted__c, ERP7__Description__c, Claimed_Amount__c, Expense_Category__c, ERP7__Expense_Date__c,   Expense_Type__c, VAT_Amount__c, ERP7__Chart_of_Account__c, Status__c, Expense__c,ERP7__Vendor__c,ERP7__Bill__c, ERP7__Refund__c, ERP7__Split_Total__c FROM Expense_Line_Item__c where Expense__c =: strId and ERP7__Expense_Line_Item__c = null];
            List<Expense_Line_Item__c> expList = new List<Expense_Line_Item__c>();
            expList = [SELECT Id, Name, Expense__r.Name, Expensed_Submitted__c, ERP7__Description__c, Claimed_Amount__c, Expense_Category__c, ERP7__Expense_Date__c,   Expense_Type__c, VAT_Amount__c, ERP7__Chart_of_Account__c, Status__c, Expense__c,ERP7__Vendor__c,ERP7__Bill__c, ERP7__Refund__c, ERP7__Split_Total__c FROM Expense_Line_Item__c where Expense__c =: strId and ERP7__Expense_Line_Item__c = null];
            system.debug('temp.expenseLine-->'+temp.expenseLine);
            if(expList.size()>0){
                Map<Id, Expense_Line_Item__c> expMap = new Map<Id, Expense_Line_Item__c>(expList);
                temp.accList = [select Id, Name, ParentId from Attachment where ParentId IN :expMap.keyset()];
                system.debug('temp.accList-->'+temp.accList);
            }
        }
        return temp;
    }
    
    @AuraEnabled//-----------------------------------------------------------------------------------------------------------------------------------
    public static List<ExpenseSheetLC> EditMultiExpense(List<String> ExpIds) {
     List<ExpenseSheetLC> temp = new List<ExpenseSheetLC>();
        ExpenseSheetLC EXwrp = new ExpenseSheetLC();
    Set<String> ExpIdstoupdate = new Set<String>();
    ExpIdstoupdate.addAll(ExpIds);
    //EXwrp.expenses=[SELECT id, Name, Amount_Submitted__c, Approve_Rejected_Reason__c, Approve_Rejected_Date__c, Amount__c, ERP7__Refund_Expense__c, ERP7__Date__c, Employees__c, VAT_Amount__c, Status__c, Project__c, ERP7__Approver__c, ERP7__Approver__r.Name,ERP7__Vendor_Account__c, ERP7__Chart_of_Account__c, ERP7__Sales_Order__c, ERP7__Post__c FROM Expense__c where Id In:ExpIdstoupdate];

        
        System.debug('Set Ids-->'+ExpIdstoupdate );
       
        if(Schema.sObjectType.Expense__c.isAccessible()) {
            EXwrp.expenses = [SELECT id, Name, Amount_Submitted__c, Approve_Rejected_Reason__c, Approve_Rejected_Date__c, Amount__c, ERP7__Refund_Expense__c, ERP7__Date__c, Employees__c, VAT_Amount__c, Status__c, Project__c, ERP7__Approver__c, ERP7__Approver__r.Name,ERP7__Vendor_Account__c, ERP7__Chart_of_Account__c, ERP7__Sales_Order__c, ERP7__Post__c FROM Expense__c WHERE Id IN :ExpIdstoupdate];
        }
        if(Schema.sObjectType.Expense_Line_Item__c.isAccessible()) {
            List<Expense_Line_Item__c> expList = new List<Expense_Line_Item__c>();
            
            EXwrp.expenseLine = expList = [SELECT Id, Name, Expense__r.Name, Expensed_Submitted__c, ERP7__Description__c, Claimed_Amount__c, ERP7__Expense_Category__c, ERP7__Expense_Date__c,   Expense_Type__c, VAT_Amount__c, ERP7__Chart_of_Account__c, Status__c, Expense__c,ERP7__Vendor__c,ERP7__Bill__c, ERP7__Refund__c, ERP7__Split_Total__c FROM Expense_Line_Item__c where Expense__c IN :ExpIdstoupdate and ERP7__Expense_Line_Item__c = null];
            
            //expList = [SELECT Id, Name, Expense__r.Name, Expensed_Submitted__c, ERP7__Description__c, Claimed_Amount__c, Expense_Category__c, ERP7__Expense_Date__c,   Expense_Type__c, VAT_Amount__c, ERP7__Chart_of_Account__c, Status__c, Expense__c,ERP7__Vendor__c,ERP7__Bill__c, ERP7__Refund__c, ERP7__Split_Total__c FROM Expense_Line_Item__c where Expense__c IN :ExpIdstoupdate and ERP7__Expense_Line_Item__c = null];
            system.debug('temp.expenseLine-->'+EXwrp.expenseLine);
            
            //EXwrp.expenseToExpenseLineMap = new Map<Id, List<Expense_Line_Item__c>>();
            Map<Id, Expense__c> explMap = new Map<Id, Expense__c>();
            Map<Id, List<Expense_Line_Item__c>> explineMap = new Map<Id, List<Expense_Line_Item__c>>();
            // Populate the expenseToExpenseLineMap
            for (Expense__c expense : EXwrp.expenses) {
                //EXwrp.expenseToExpenseLineMap.put(expense.Id, new List<Expense_Line_Item__c>());
                explMap.put(expense.Id, expense);
            }
            
            for (Expense_Line_Item__c expenseLineItem : EXwrp.expenseLine) {
                if (explineMap.containsKey(expenseLineItem.Expense__c)) {
                    explineMap.get(expenseLineItem.Expense__c).add(expenseLineItem);
                } else {
                    explineMap.put(expenseLineItem.Expense__c, new List<Expense_Line_Item__c>{expenseLineItem});
                }
            }
            EXwrp.expwraplist = new List<ExpenseWrap>();
            if(explineMap!=null && explineMap.size()>0){
                for(Id expId : explineMap.keySet()){
                    ExpenseWrap expwrap = new ExpenseWrap();
                    expwrap.exp = explMap.get(expId);
                    expwrap.expline = explineMap.get(expId);
                    EXwrp.expwraplist.add(expwrap);
                }
            }
             System.debug('checking new mapped?'+ EXwrp.expwraplist);
           // System.debug('checking mapped'+ EXwrp.expenseToExpenseLineMap.get('a1r06000013pDdZAAU'));
            if(expList.size()>0){
                Map<Id, Expense_Line_Item__c> expMap = new Map<Id, Expense_Line_Item__c>(expList);
                EXwrp.accList = [select Id, Name, ParentId from Attachment where ParentId IN :expMap.keyset()];
               // system.debug('temp.accList-->'+EXwrp.accList);
            }
        }
        temp.add(EXwrp);
        List<ExpenseWrap> exp = temp[0].expwraplist;
         List<Expense_Line_Item__c> expLin = temp[0].expenseLine;
        system.debug('expwraplist chart of Acc'+ exp);
        
        //system.debug('Chart 1'+ expLin[0].ERP7__Chart_of_Account__c);
        // system.debug('Chart 2'+ expLin[1].ERP7__Chart_of_Account__c);
        return temp;
    }
    
    public class ExpenseWrap{
        @AuraEnabled public Expense__c exp {get;set;}
        @AuraEnabled public List<Expense_Line_Item__c> expline {get;set;}
        public ExpenseWrap(){
            exp = new Expense__c();
            expline = new List<Expense_Line_Item__c>();
        }
    }
    @AuraEnabled
    public static List<lineWrapper> fetchExpRecords(String ExpId){
        List<ERP7__Expense_Line_Item__c> expline = new List<ERP7__Expense_Line_Item__c>();
        List<lineWrapper> lwrapList = new List<lineWrapper>();
        expline = [SELECT Id, Name, ERP7__Claimed_Amount__c, ERP7__Description__c, ERP7__Expensed_Submitted__c, ERP7__Chart_Of_Account__c FROM ERP7__Expense_Line_Item__c where ERP7__Expense_Line_Item__c =: ExpId];
        if(expline.size()>0){
            for(ERP7__Expense_Line_Item__c ex : expline){
                lineWrapper lwrap = new lineWrapper();
                lwrap.expline = ex;
                lwrap.COAId = ex.ERP7__Chart_Of_Account__c;
                lwrapList.add(lwrap);
            }
        }
        return lwrapList;
    }
    
    public class lineWrapper{
        @AuraEnabled
        public ERP7__Expense_Line_Item__c expline;
        @AuraEnabled
        public Id COAId;
        public lineWrapper(){
            expline = new  ERP7__Expense_Line_Item__c();
            COAId = null; 
        }
    }
    
    @AuraEnabled
    public static Id getCOA(String ExplineId){
        Expense_Line_Item__c exp = [SELECT Id, Name, Expense__r.Name, Expensed_Submitted__c, ERP7__Description__c, Claimed_Amount__c, Expense_Category__c, ERP7__Expense_Date__c,   Expense_Type__c, VAT_Amount__c, ERP7__Chart_of_Account__c, Status__c, Expense__c,ERP7__Vendor__c,ERP7__Bill__c, ERP7__Refund__c FROM Expense_Line_Item__c where Id =: ExplineId];
        return exp.ERP7__Chart_of_Account__c;
    }
    
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        Attachment a = new Attachment();
        a.parentId = parentId;
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;
        if (a != null) {
            if(Schema.SObjectType.Attachment.isCreateable() && Schema.SObjectType.Attachment.isUpdateable()) upsert a;
        }
        return a.Id;
    }
    
    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType); } else {appendToFile(fileId, base64Data);
                                                                                      }
        
        return Id.valueOf(fileId);
    }
    
    @TestVisible
    private static void appendToFile(Id fileId, String base64Data) { 
        if(String.isNotEmpty(base64Data) && fileId != null){ base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8'); Attachment a;
            if(!Schema.sObjectType.Attachment.isAccessible()) { ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access to Object '+ sObjectType.Attachment.Label));} else { a = [SELECT Id, Body FROM Attachment WHERE Id =: fileId]; }
            String existingBody = EncodingUtil.base64Encode(a.Body); a.Body = EncodingUtil.base64Decode(existingBody + base64Data); if(Schema.SObjectType.Attachment.isUpdateable()) update a; else{ } 
        }
        
    }
    
    @AuraEnabled
    public static List<ExpenseSheetLC> getApproval() {
        if(!Schema.sObjectType.Expense__c.isAccessible()){ throw new System.NoAccessException();  //return null;
                                                         }
        else {
            String [] expenseAccessFields = new String [] {'Id', 'Name', 'ERP7__Paid__c', 'ERP7__Amount__c', 'ERP7__VAT_Amount__c', 'ERP7__Amount_Submitted__c', 'ERP7__Date__c', 'ERP7__Employees__c', 'ERP7__Approve_Rejected_Reason__c', 'ERP7__Approve_Rejected_Date__c'};
                Map<String,Schema.SObjectField> m = Schema.SObjectType.Expense__c.fields.getMap();
            for (String fieldToCheck : expenseAccessFields) {
                if (!m.get(fieldToCheck).getDescribe().isAccessible()){ throw new System.NoAccessException();  //return null;
                                                                      }
            }
            
            List<ExpenseSheetLC> EXwrpList = new List<ExpenseSheetLC>();
            List<ERP7__Expense__c> expn = new List<ERP7__Expense__c>();
            List<ERP7__Expense_Line_Item__c> exLines = new List<ERP7__Expense_Line_Item__c>();
            set<Id> setIds = new set<Id>();
            String exQry = 'SELECT id, Name, ERP7__Project__c, Project__r.Name, Paid__c,'+
                ' Employees__r.Employee_User__c, Employees__r.First_Name__c, Employees__r.Last_Name__c, ERP7__Amount__c, ERP7__Approver__c, Approver__r.Name, Status__c, VAT_Amount__c, Amount_Submitted__c, Date__c'+
                ' FROM Expense__c where ERP7__Approver__c = \''+String.escapeSingleQuotes(userinfo.getUserId())+'\'and ERP7__Status__c = \'Submitted\'';
            expn = database.query(exQry);
            for(ERP7__Expense__c ex : expn){ setIds.add(ex.Id);
                                           }
            if(setIds.size() > 0){
                exLines = [SELECT Id, Name, ERP7__Claimed_Amount__c, ERP7__Expense__c FROM ERP7__Expense_Line_Item__c where ERP7__Expense__c =:setIds ORDER BY Name asc];
                for(ERP7__Expense__c ex1 : expn){
                    ExpenseSheetLC EXwrp = new ExpenseSheetLC();
                    List<ERP7__Expense_Line_Item__c> EX_lines = new List<ERP7__Expense_Line_Item__c>();
                    for(ERP7__Expense_Line_Item__c exli : exLines){
                        if(exli.ERP7__Expense__c == ex1.Id){
                            EX_lines.add(exli);
                        }
                    }
                    EXwrp.Expense1 = ex1;
                    EXwrp.ExpenseLines1 = (EX_lines.size()>0)?EX_lines : new List<ERP7__Expense_Line_Item__c>();
                    EXwrpList.add(EXwrp);
                }
            }
            return EXwrpList;
        }
    }
    
    @AuraEnabled
    public static void saveApprovedExpense(String reason, String tid, String sts) {
        string[] alltid = tid.split(',');
        list < Expense__c > listts = new list < Expense__c > ();
        for (String s: alltid) {
            Expense__c ts = new Expense__c(id = (ID) s);
            if(Schema.sObjectType.Expense__c.fields.Approve_Rejected_Reason__c.isUpdateable()) ts.Approve_Rejected_Reason__c = reason;
            if(Schema.sObjectType.Expense__c.fields.Status__c.isUpdateable()) ts.Status__c = sts;
            listts.add(ts);
        }
        if(Schema.SObjectType.Expense__c.isUpdateable()){
            String [] expenseAccessFields = new String [] {'Id',
                'ERP7__Status__c',
                'ERP7__Approve_Rejected_Reason__c',
                'ERP7__Approve_Rejected_Date__c'
                };
                    Map<String,Schema.SObjectField> m = Schema.SObjectType.Expense__c.fields.getMap();
            for (String fieldToCheck : expenseAccessFields) { if (!m.get(fieldToCheck).getDescribe().isAccessible()) {throw new System.NoAccessException(); } } if(Schema.sObjectType.Expense__c.isUpdateable()) update listts; else{ }
        }
    }
    
    
    @AuraEnabled
    public static List < String > getCategorypickval() {
        List < String > options = new List < String > ();
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Expense_Line_Item__c.Expense_Category__c.getDescribe();
        
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List < String > getTypepickval() {
        List < String > options = new List < String > ();
        options.add('--None--');
        Schema.DescribeFieldResult fieldResult = Expense_Line_Item__c.Expense_Type__c.getDescribe();
        
        List < Schema.PicklistEntry > ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f: ple) {
            options.add(f.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static String getCurrencyIsoCode() {//SObject someObject
        String currencyIso = UserInfo.getDefaultCurrency();
        return currencyIso;
    }
    
   /* @AuraEnabled
    public static ExpenseWrapper uploadFileAK(String parent, String fileName, String base64Data, String contentType) { 
        
        ExpenseWrapper ExpW = new ExpenseWrapper();
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment a = new Attachment();
            if(Schema.sObjectType.Attachment.fields.parentId.isCreateable()) a.parentId = parent;
            if(Schema.sObjectType.Attachment.fields.Body.isCreateable()) a.Body = EncodingUtil.base64Decode(base64Data);
            if(Schema.sObjectType.Attachment.fields.Name.isCreateable()) a.Name = fileName;
            if(Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) a.ContentType = contentType; 
            if(Schema.sObjectType.Attachment.isCreateable()) insert a; else{ }
            ExpW.Attach = a;
        } catch(Exception e){ ExpW.exceptionError = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return ExpW;        
    }*/
    @AuraEnabled
    public static ExpenseWrapper uploadFileAK(String parent, String fileName, String base64Data, String contentType) {
        system.debug('uploadFileAK: Starting file upload for parentId: ' + parent);
        ExpenseWrapper ExpW = new ExpenseWrapper();
        try {
            system.debug('uploadFileAK: Decoding Base64 data.');
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            Attachment a = new Attachment();
            system.debug('uploadFileAK: Checking Field Level Security before DML.');
            if (Schema.sObjectType.Attachment.fields.parentId.isCreateable()) a.parentId = parent;
            if (Schema.sObjectType.Attachment.fields.Body.isCreateable()) a.Body = EncodingUtil.base64Decode(base64Data);
            if (Schema.sObjectType.Attachment.fields.Name.isCreateable()) a.Name = fileName;
            if (Schema.sObjectType.Attachment.fields.ContentType.isCreateable()) a.ContentType = contentType;

            system.debug('uploadFileAK: Attempting to insert new Attachment.');
            if (Schema.sObjectType.Attachment.isCreateable()) {
                insert a;
                system.debug('uploadFileAK: Attachment inserted successfully with Id: ' + a.Id);
            } else {
                system.debug('uploadFileAK: FLS check failed. User cannot create Attachment records.');
                ExpW.exceptionError = 'User does not have permission to create attachments.';
                return ExpW; // Return early on FLS failure
            }

            // Query all attachments for the parent record
            system.debug('uploadFileAK: Querying all attachments for parentId: ' + parent);
            List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :parent];
            system.debug('uploadFileAK: Found ' + attachments.size() + ' attachments.');

            // Assign the list to the wrapper
            ExpW.Attachments = attachments;
            system.debug('uploadFileAK: Wrapper populated with ' + attachments.size() + ' attachments.');
        } catch(Exception e) {
            system.debug('uploadFileAK: Caught Exception: ' + e.getMessage() + ' at line ' + e.getLineNumber());
            ExpW.exceptionError = e.getMessage() + ' Line Number @ : ' + e.getLineNumber();
        }
        system.debug('uploadFileAK: Method finished, returning wrapper.');
        return ExpW;
    }

  /*  @AuraEnabled
public static ExpenseWrapper DeleteAT(String RAId, String ObjName) {          
    ExpenseWrapper ExpW = new ExpenseWrapper();        
    try {
        // Build and execute the query
        String query = 'SELECT Id FROM ' + String.escapeSingleQuotes(ObjName) + ' WHERE Id = :RAId LIMIT 1';
        List<SObject> results = Database.query(query);

        // Check if any record was found
        if (results.isEmpty()) {
            ExpW.exceptionError = 'No record found with the specified Id: ' + RAId;
            return ExpW;
        }

        // Retrieve the record
        SObject AT = results[0];

        // Check delete permissions
        SObjectType sObjType = AT.getSObjectType();
        if (sObjType.getDescribe().isDeletable()) {
            delete AT;
        } else {
            ExpW.exceptionError = 'You do not have permission to delete this record.';
        }
    } catch (Exception e) {
        ExpW.exceptionError = e.getMessage() + ' Line Number @ : ' + e.getLineNumber();
    }

    return ExpW;
}*/
    @AuraEnabled
    public static ExpenseWrapper DeleteAT(String RAId, String ObjName) {
        system.debug('DeleteAT: Starting deletion process for RAId: ' + RAId + ', ObjName: ' + ObjName);
        ExpenseWrapper ExpW = new ExpenseWrapper();
        try {
            if (ObjName!=''|| ObjName!=null ) {
                system.debug('DeleteAT: Object is an Attachment. Checking FLS.');
                if (Attachment.sObjectType.getDescribe().isDeletable()) {
                    system.debug('DeleteAT: User has delete permission. Querying attachment to delete.');
                    Attachment attachmentToDelete = [SELECT Id, ParentId FROM Attachment WHERE Id = :RAId LIMIT 1];
                    if (attachmentToDelete != null) {
                        Id parentId = attachmentToDelete.ParentId;
                        ExpW.expLineId = parentId;
                        system.debug('DeleteAT: Found attachment with Id: ' + attachmentToDelete.Id + ' and ParentId: ' + parentId);
                        delete attachmentToDelete;
                        system.debug('DeleteAT: Attachment deleted successfully.');
                        
                        // Query all remaining attachments for the parent record
                        system.debug('DeleteAT: Querying all remaining attachments for ParentId: ' + parentId);
                        List<Attachment> remainingAttachments = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId = :parentId];
                        system.debug('DeleteAT: Found ' + remainingAttachments.size() + ' remaining attachments.');
                        ExpW.Attachments = remainingAttachments;
                    } else {
                        system.debug('DeleteAT: Attachment not found for Id: ' + RAId);
                    }
                } else {
                    system.debug('DeleteAT: FLS check failed. User does not have permission to delete attachments.');
                    ExpW.exceptionError = 'You do not have permission to delete attachments.';
                }
            } else {
                system.debug('DeleteAT: Invalid object name provided: ' + ObjName);
                ExpW.exceptionError = 'Invalid object name provided.';
            }
        } catch (Exception e) {
            system.debug('DeleteAT: Caught Exception: ' + e.getMessage() + ' Line Number @ : ' + e.getLineNumber());
            ExpW.exceptionError = e.getMessage() + ' Line Number @ : ' + e.getLineNumber();
        }
        system.debug('DeleteAT: Method finished, returning wrapper.');
        return ExpW;
    }
    
    @AuraEnabled
    public static String delCurExpli(String delExpli){
        ERP7__Expense_Line_Item__c expLi = (ERP7__Expense_Line_Item__c) JSON.deserialize(delExpli, ERP7__Expense_Line_Item__c.class);
        try {
            if(ERP7__Expense_Line_Item__c.sObjectType.getDescribe().isDeletable()) delete expli; else{ }
            return 'expense line item deleted.'; } catch (DMLException ex) {  return null;}
    }
    
    @AuraEnabled 
    public static Account getDefaultOrganisation(){
        return UtilClass.getOrganisationByLogin_Employee();
    }   
    
    @AuraEnabled
    public static ExpWrap fetchDefaultTaxCOA(Decimal Amount){
        ExpWrap expwr = new ExpWrap();
        ERP7__Chart_of_Accounts__c coa = [select Id, Name from ERP7__Chart_of_Accounts__c where ERP7__Default_Expense_Tax__c = true order by createddate desc limit 1 ];
        system.debug('coa-->'+coa);
        if(coa != null){
            ERP7__Expense_Line_Item__c expline = new ERP7__Expense_Line_Item__c(ERP7__Chart_Of_Account__c = coa.Id, ERP7__Claimed_Amount__c = Amount);
            system.debug('expline-->'+expline);
            List<ERP7__Expense_Line_Item__c> expList = new List<ERP7__Expense_Line_Item__c>();
            expList.add(expline);
            expwr.expLine = expList;
            expwr.COAId = coa.Id;
            return expwr;
        }else{
            return null;
        }
        
    }
    
    public class ExpWrap{
        @AuraEnabled
        public List<ERP7__Expense_Line_Item__c> expLine;
        @AuraEnabled
        public Id COAId;
        public ExpWrap(){
             expLine = new List<ERP7__Expense_Line_Item__c>();
             COAId = null;
        }
    }
    @AuraEnabled
    public static String CreateSplitItem(String Expline, String ExpRecord){
        List<ERP7__Expense_Line_Item__c> expList = (List<ERP7__Expense_Line_Item__c>) JSON.deserialize(Expline, List<ERP7__Expense_Line_Item__c>.class);
        ERP7__Expense_Line_Item__c expR = (ERP7__Expense_Line_Item__c) JSON.deserialize(ExpRecord, ERP7__Expense_Line_Item__c.class); 
        String RecordId = expR.Id;
        if(expR!=null) expR.ERP7__Expense_Type__c = 'Split';
        update expR;
        for(ERP7__Expense_Line_Item__c exp :expList){
            exp.ERP7__Expense_Line_Item__c = RecordId;
            System.debug('exp.ERP7__Expense__c:'+exp.ERP7__Expense__c);
            if(exp.ERP7__Expense__c==null && exp.Name==null) exp.ERP7__Expense__c = expR.ERP7__Expense__c;
        }
        upsert expList;
        return null;    
    }
    
    /*public class ExpenseWrapper{
        @AuraEnabled public Expense_Line_Item__c ExpLI          { get; set; }
        @AuraEnabled public Attachment Attach             { get; set; }
        @AuraEnabled public String exceptionError            { get; set; }
        
        public ExpenseWrapper() {
            ExpLI = new Expense_Line_Item__c();
            Attach = new Attachment();
            exceptionError = '';
        }        
    }*/
    public class ExpenseWrapper{
        @AuraEnabled public Expense_Line_Item__c ExpLI          { get; set; }
        //@AuraEnabled public Attachment Attach             { get; set; }
        @AuraEnabled public List<Attachment> Attachments { get; set; } // <--- Updated to a List by adnan to show multiple recept attachments
        @AuraEnabled public String expLineId { get; set; }
        @AuraEnabled public String exceptionError            { get; set; }
        
        public ExpenseWrapper() {
            ExpLI = new Expense_Line_Item__c();
            //Attach = new Attachment();
            Attachments = new List<Attachment>(); // Initialize the list
            exceptionError = '';
            expLineId='';
        }
    }
    
    
    public class AddExpenseFlsWrap{                   
        @AuraEnabled public Boolean projectAccess            { get; set; }
        @AuraEnabled public Boolean CategoryAccess            { get; set; }
        @AuraEnabled public Boolean TypeAccess            { get; set; }
        @AuraEnabled public Boolean soAccess            { get; set; }
        @AuraEnabled public Boolean approverAccess            { get; set; }
        @AuraEnabled public Boolean statusAccess            { get; set; }
        @AuraEnabled public Boolean caAccess            { get; set; }
        @AuraEnabled public Boolean nameAccess            { get; set; }
        @AuraEnabled public Boolean allExpenseAccess            { get; set; }
        @AuraEnabled public String UserId            { get; set; }
        public AddExpenseFlsWrap(){
            projectAccess = false;
            CategoryAccess=false;
            soAccess=false;
            approverAccess = false;
            statusAccess = false;
            caAccess = false;
            TypeAccess = false;
            nameAccess = false;
            allExpenseAccess = false;
            UserId = '';
        }
    }
    
    @AuraEnabled 
    public static AddExpenseFlsWrap AddExpenseCheckFLS(){
        AddExpenseFlsWrap flsWRAP = new AddExpenseFlsWrap();
        if (Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Project__c.isAccessible()){ flsWRAP.projectAccess = true; }
        if (Schema.sObjectType.ERP7__Expense_Line_Item__c.fields.ERP7__Expense_Category__c.isAccessible()){ flsWRAP.CategoryAccess= true; }
        if (Schema.sObjectType.ERP7__Expense_Line_Item__c.fields.ERP7__Claimed_Amount__c.isAccessible()){ flsWRAP.caAccess= true; }
        if (Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Sales_Order__c.isAccessible()){ flsWRAP.soAccess= true; }
        if (Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Approver__c.isAccessible()){ flsWRAP.approverAccess= true; }
        if (Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Status__c.isAccessible()){ flsWRAP.statusAccess= true; }
        if (Schema.sObjectType.ERP7__Expense_Line_Item__c.fields.ERP7__Expense_Type__c.isAccessible()){ flsWRAP.TypeAccess= true; }
        if (Schema.sObjectType.ERP7__Expense_Line_Item__c.fields.Name.isAccessible()){ flsWRAP.nameAccess= true; }
        if (Schema.sObjectType.ERP7__Expense__c.fields.ERP7__Access_All_Expenses__c.isAccessible()){ flsWRAP.allExpenseAccess= true; }
        flsWRAP.UserId = UserInfo.getUserId();
        return flsWRAP;
    }
    
    @AuraEnabled 
    public static String SendApprovedExpense(String reason,String recId) {
        String error = null;
        try {
           
            ERP7__Expense__c expense = [SELECT Id, Name, ERP7__Approver__c FROM ERP7__Expense__c WHERE Id = :recId AND ERP7__Status__c = 'Draft' LIMIT 1];
            system.debug('expense size:'+expense);
            
            User currentUser = [SELECT Id, Name, ManagerId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            
            if (expense != null) {
                
                expense.ERP7__Status__c = 'Submitted';
                upsert expense;
                
               
                /*Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                if (reason != null) {
                    req.setComments('Submitted for approval. Please review and approve. ' + reason);
                } else {
                    req.setComments('Submitted for approval. Please review and approve.');
                }
                req.setObjectId(expense.Id);
                req.setNextApproverIds(new Id[]{ currentUser.ManagerId });
                Approval.ProcessResult result = Approval.process(req);*/
            } else {
                error = 'Manager is not defined for the current user or the expense record does not exist.';
                System.debug(error);
                return error;
            }
        } catch (Exception e) {
            error = 'Exception: ' + e.getMessage() + ' at line ' + e.getLineNumber();
            System.debug('Exception-->' + error);
        }
        return error;
    }
    
    @AuraEnabled 
    public static String SendMultiApproval(List<String> StrId) {
        Set<String> expIds = new Set<String>();
        expIds.addAll(StrId);
        List<ERP7__Expense__c> expenseList = new List<ERP7__Expense__c>();
        List<ERP7__Expense__c> exp2update = new List<ERP7__Expense__c>();
        String error = null;
        
        User Manager = new User(); 
        Id userId = UserInfo.getUserId();
        manager = [Select Id, Name, ManagerId from User where Id =:UserInfo.getUserId() limit 1];
        
        try {
            
            expenseList = [SELECT Id, Name, ERP7__Approver__c FROM ERP7__Expense__c WHERE Id IN :expIds AND ERP7__Status__c = 'Draft'];
            
            
            if (!expenseList.isEmpty()) {
                for (ERP7__Expense__c exp : expenseList) {
                    exp.ERP7__Status__c = 'Submitted';
                    exp2update.add(exp);
                }
            }
            
            
            if (!exp2update.isEmpty()) {
                upsert exp2update;
            }
            
            
            /*for (ERP7__Expense__c exp : exp2update) {
                if (manager.ManagerId != null) {
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitted for approval. Please review and approve.');
                    req.setObjectId(exp.Id);
                    req.setNextApproverIds(new Id[]{ manager.ManagerId });
                    Approval.ProcessResult result = Approval.process(req);
                } else {
                    error = 'Manager is not defined for Expense: ' + exp.Name;
                    System.debug(error);
                    return error;
                }
            }*/
        } catch (Exception e) {
            error = String.valueOf(e);
            System.debug('Exception-->' + e + ' Message: ' + e.getMessage() + ' Line: ' + e.getLineNumber());
        }
        return error;
    }
    
  
}