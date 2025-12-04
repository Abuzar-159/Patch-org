global with sharing class PaymentUpdates_GuestUserSchedule implements Schedulable{
    global void execute(SchedulableContext ctx){
        String cUser='payments Site Guest User';
        List<ERP7__Payment__c> pmntList=[Select Id,Name,CreatedById,CreatedBy.Name,ERP7__Posted__c from ERP7__Payment__c where ERP7__Posted__c=false AND CreatedBy.Name=:cUser];
        for(ERP7__Payment__c pt:pmntList){
            if(pt.CreatedBy.Name =='payments Site Guest User'){ if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Posted__c.isUpdateable()){pt.ERP7__Posted__c=true; }else{/*not allowed to update*/} if(Schema.sObjectType.ERP7__Payment__c.fields.ERP7__Status__c.isUpdateable()){pt.ERP7__Status__c = 'Paid';}else{/*not allowed to update*/} }	
        }
        if(pmntList.size() > 0 && Schema.sObjectType.ERP7__Payment__c.isUpdateable()){update pmntList;}else{/*not allowed to update*/}
        
        DateTime dtime = system.now().addMinutes(5);
        String day = string.valueOf(dtime.day());
        String month = string.valueOf(dtime.month());
        String hour = string.valueOf(dtime.hour());
        String minute = string.valueOf(dtime.minute());
        String second = string.valueOf(dtime.second());
        String year = string.valueOf(dtime.year());        
        String strJobName = 'PaymentCreate_Guest '+hour+':'+minute;
        String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
        System.schedule(strJobName, strSchedule, new PaymentUpdates_GuestUserSchedule());
        system.abortJob(ctx.getTriggerId());        
    }   

}