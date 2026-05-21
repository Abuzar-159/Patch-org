trigger PrePaymentTrigger on PrePayment__c (after insert, after update, before delete, after undelete) {
    if(Trigger.isAfter){
        if(!Trigger.isDelete){
        list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Credit__c', 'ERP7__Prepaid_Credit_Balance__c')
        };
        RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions1, trigger.new, 'ERP7__PrePayment__c','ERP7__Account__c', 'Account', '');
        
        list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions2 = new list<RollUpSummaryUtility.fieldDefinition> {
            new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Debit__c', 'ERP7__Prepaid_Debit_Balance__c')
        };
        RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions2, trigger.new, 'ERP7__PrePayment__c','ERP7__Account__c', 'Account', '');
      }
    }else{
        if(Trigger.isDelete){   list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions1 = new list<RollUpSummaryUtility.fieldDefinition> {  new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Credit__c', 'ERP7__Prepaid_Credit_Balance__c')
        };
        RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions1, trigger.old, 'ERP7__PrePayment__c','ERP7__Account__c', 'Account', '');
        
        list<RollUpSummaryUtility.fieldDefinition> MAPfieldDefinitions2 = new list<RollUpSummaryUtility.fieldDefinition> {  new RollUpSummaryUtility.fieldDefinition('SUM', 'ERP7__Debit__c', 'ERP7__Prepaid_Debit_Balance__c')
        };   RollUpSummaryUtility.rollUpTrigger(MAPfieldDefinitions2, trigger.old, 'ERP7__PrePayment__c','ERP7__Account__c', 'Account', '');
    
        }
    
    }
  }