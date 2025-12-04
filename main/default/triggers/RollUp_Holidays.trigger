trigger RollUp_Holidays on Leave_Entitlements_Holidays__c (after insert, after update, after delete, after undelete) 
{
    
      list<AggregateResult> Sum_InEntitle = new list<AggregateResult>();
       set<id> lh = new set<id>();
        map<id,Leave_Entitlement__c> pi = new map<id,Leave_Entitlement__c>([SELECT id,Total_Entitled_Leaves__c FROM Leave_Entitlement__c Where Name != null]);
        if(Trigger.isInsert || Trigger.isUpdate||Trigger.isUndelete){
                 for(Leave_Entitlements_Holidays__c ISF: Trigger.new){
                     if(ISF.Number_of_Days__c!=null){
                         lh.add(ISF.Leave_Entitlement__c);
                     }
                         
                 }         
            }
            if(Trigger.isDelete){
                for(Leave_Entitlements_Holidays__c ISF: Trigger.old){
                     if(ISF.Number_of_Days__c!=null){
                         lh.add(ISF.Leave_Entitlement__c);
                     }
                         
                 }  
            }
            if(pi.size()==1){
            List<Leave_Entitlement__c> EL = pi.values();
            EL[pi.size()-1].Total_Entitled_Leaves__c=0;
                pi.put(EL[pi.size()-1].id,EL[pi.size()-1]);    
            }
            if(lh.size()> 0 ){
                        Sum_InEntitle = [SELECT Leave_Entitlement__c it, SUM(Number_of_Days__c) sum FROM Leave_Entitlements_Holidays__c WHERE Leave_Entitlement__c in : lh  GROUP BY Leave_Entitlement__c];
                        for(AggregateResult PS:Sum_InEntitle ){
                            Leave_Entitlement__c PU = new Leave_Entitlement__c();
                          
                            if(PS.get('sum')!=null){
                                PU=pi.get((id)PS.get('it'));
                                if(Schema.sObjectType.Leave_Entitlement__c.fields.Total_Entitled_Leaves__c.isUpdateable() ){PU.Total_Entitled_Leaves__c =(decimal)PS.get('sum'); } else{ /* no access*/}
                                pi.put((id)PS.get('it'),PU);
                            }
                        
                        }
            }
    if(pi.size()>0 && Schema.sObjectType.Leave_Entitlement__c.isUpdateable()) { update pi.values(); } else{ /* no access */ }
            
}