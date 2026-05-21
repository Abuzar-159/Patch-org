({
	getTimeSheets : function(component,event){
        var fetchTSAction = component.get("c.fetchTimesheet");
        //fetchPoAction.setStorable();
      fetchTSAction.setParams({Offset: component.get("v.Offset"),AccId: component.get("v.AccId"),
          RecordLimit: component.get('v.show'),searchString :component.get('v.SearchString'),OrderBy:component.get("v.OrderBy"),Order:component.get("v.Order")});
        fetchTSAction.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.TSList",response.getReturnValue().Timesheet);
                component.set("v.TSListDup",response.getReturnValue().TimesheetSL);
                var Offsetval=parseInt(component.get("v.Offset"));
                var records;   
                records = response.getReturnValue().Timesheet;   
                component.set('v.recSize',response.getReturnValue().recSize);    
                if(Offsetval!=0){
                    if(records.length > 0) {
                        var startCount = Offsetval + 1;
                        var endCount = Offsetval + records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount);
                    }
                }
                if(Offsetval==0){
                    if(records.length > 0) {
                        var startCount = 1;
                        var endCount = records.length;
                        component.set("v.startCount", startCount);
                        component.set("v.endCount", endCount); 
                        component.set("v.PageNum",1);
                    }
                }
                var myPNS = [];
                var ES = response.getReturnValue().recSize;
                var i=0;
                var show=component.get('v.show');
                while(ES >= show){
                    i++; myPNS.push(i); ES=ES-show;
                } 
                if(ES > 0) myPNS.push(i+1);
                component.set("v.PNS", myPNS);  
                
            }
        });
        $A.enqueueAction(fetchTSAction);
    },
       hideSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.addClass(spinner, "slds-hide");    
    },
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, "slds-hide");   
    },
})