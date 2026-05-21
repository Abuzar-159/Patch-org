({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showMmainSpin",true);
        var action = cmp.get("c.getDefaultOrganisation");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(cmp.get("v.fetchRecordsBool")==true) {
                    cmp.set("v.Organisation",response.getReturnValue());
                    cmp.set("v.showMmainSpin",false);
                }
            }  
        });
        $A.enqueueAction(action);  
    },
    
    getOrganisedRecords:function(cmp,event){
        cmp.set("v.NoSlotsMessage",'');
        var orgId=cmp.get("v.Organisation.Id");
        var action=cmp.get("c.getBudgetList");
        action.setParams({
            OrgId:orgId,
            OrderBy:cmp.get("v.OrderBy"),
            Order:cmp.get("v.Order"),
            Offset: cmp.get("v.Offset"),
            RecordLimit: cmp.get('v.show')
        });
        
        action.setCallback(this, function(res){
            if(res.getState()=='SUCCESS'){
                try{
                    cmp.set("v.BudgetList",res.getReturnValue().FilteredBudgetList);
                    cmp.set("v.BudgetListDum",res.getReturnValue().CompleteBudgetList);
                    var BankReconciliationlist=[];
                    BankReconciliationlist=cmp.get("v.BudgetList");
                    if(BankReconciliationlist.length<=0) cmp.set("v.NoSlotsMessage",'No Data Available');
                    var Offsetval=parseInt(cmp.get("v.Offset"));
                    var records=[];   
                    records = res.getReturnValue().FilteredBudgetList;   
                    cmp.set('v.recSize',res.getReturnValue().recSize);    
                    if(Offsetval!=0){
                        if(records.length > 0) {
                            var startCount = Offsetval + 1;
                            var endCount = Offsetval + records.length;
                            cmp.set("v.startCount", startCount);
                            cmp.set("v.endCount", endCount);
                        }
                    }
                    if(Offsetval==0){
                        if(records.length > 0) {
                            var startCount = 1;
                            var endCount = records.length;
                            cmp.set("v.startCount", startCount);
                            cmp.set("v.endCount", endCount); 
                            cmp.set("v.PageNum",1);
                        }
                    }
                    var myPNS = [];
                    var ES = 10;
                    var i=0;
                    var show=cmp.get('v.show');
                    while(ES >= show){
                        i++; myPNS.push(i); ES=ES-show;
                    } 
                    if(ES > 0) myPNS.push(i+1);
                    cmp.set("v.PNS", myPNS); 
                }
                catch(e){
                    console.log('doInit exception'+ e);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            helper.fetchBudgetList(component, event);
        }
    },
    NextLast : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.endCount") != component.get("v.recSize")){ 
            var Offsetval = (component.get("v.PNS").length-1)*show;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            //var currentTab = component.get("v.selectedTab"); 
            helper.fetchBudgetList(component, event);
        }
    },
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            helper.fetchBudgetList(component, event);}
    },
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.fetchBudgetList(component, event);}
    },
    
    searchUserRecord : function(cmp,event,helper){
        try{      
            cmp.set("v.NoSlotsMessage",'');
            var SearchString = cmp.get("v.SearchString");
            if(SearchString!='' && SearchString!=undefined){   
                SearchString=SearchString.toString();
                var bankStmtlist =[]; bankStmtlist=cmp.get("v.BudgetListDum");
                bankStmtlist = bankStmtlist.filter(function (el) {    
                    return ((el.Name).toString().toLowerCase().indexOf(SearchString.toLowerCase()) != -1);
                });
                cmp.set("v.BudgetList",bankStmtlist);  if(bankStmtlist.length<=0)  cmp.set("v.NoSlotsMessage",'No Data available');                     
            }else{  cmp.set("v.BudgetList",cmp.get("v.BudgetListDum"));
                 }
            
        }catch(ex){
            console.log('searchUser exception=>'+ex);
        }    
    }, 
    
    
    searchUser : function(component,event,helper){
        try{  
            var searchString = event.getParam("searchString").toString();
            if(searchString!='' && searchString.length>0){                     
                var UserList =[];
                UserList=component.get("v.BudgetListDum");
                UserList = UserList.filter(function (el) {
                    return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
                });
                component.set("v.BudgetList",UserList);            
            }    
            else component.set("v.BudgetList",component.get("v.BudgetListDum"));
        }catch(ex){console.log('searchUser exception=>'+ex);}      
    },
    
    removeItem : function(cmp, event) {
        cmp.set("v.ItemTOdelete",event.getSource().get("v.name"));
        cmp.set("v.showPOPUp",true);
    },
    
    DeleteRecordById : function(cmp, event) {
        cmp.set("v.showPOPUp",false);
    },
    CancelDelete :function(cmp, event, helper) {
        cmp.set("v.ItemTOdelete",'');
        cmp.set("v.showPOPUp",false);
    },
    
    CreateBudget : function(cmp, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BudgetPlannerUpdated",//"c:ManageBudget",//"c:BudgetPlannerUpdated",//"c:ManageBudget",
            componentAttributes: {
                //contactId : component.get("v.contact.Id")
            }
        });
        evt.fire();
    },
    /*
    ManageBudget : function(cmp, event, helper) {
        var purId = event.currentTarget.getAttribute('data-record');//event.target.dataset.record;
        var budgetType = event.currentTarget.getAttribute('data-name');//event.target.dataset.name;
        if(budgetType=='Monthly'){
            budgetType = 'Monthly Budget';
        }else if(budgetType=='Quarterly'){
            budgetType = 'Quarterly Budget';
        }else{
            budgetType = 'Yearly Budget';
        }
        var Name = event.currentTarget.getAttribute('data-service');//event.target.dataset.service;
        var parts = Name.split(" ");
        var month = parts[0]; // "April"
        var year = '';
        // Sample string
        var str = 'February Budget 2024';
        
        // Split the string by space
        var parts = str.split(' ');
        // Find the part that contains the year
        var year;
        parts.forEach(function(part) {
            if (!isNaN(part) && part.length === 4) { // Check if the part is a 4-digit number
                year = parseInt(part); // Convert the part to a number
            }
        });
        
        // Display the year
        console.log(year); // Output: 2024

        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ManageBudget",
            componentAttributes: {
                BudgetId : event.currentTarget.getAttribute('data-record'),//event.target.dataset.record,
                ShowBudgetType : false,
                setRT : budgetType,
                selectedYear:year,
                selectedMonth:month
            }
        });
        evt.fire();
    },
	*/
	
    ManageBudget : function(cmp, event, helper) {
        var purId = event.currentTarget.getAttribute('data-record');//event.target.dataset.record;
        var budgetType = event.currentTarget.getAttribute('data-name');//event.target.dataset.name;
        if(budgetType=='Monthly'){
            budgetType = 'Monthly';
        }else if(budgetType=='Quarterly'){
            budgetType = 'Quarterly';
        }else if(budgetType=='Yearly'){
            budgetType = 'Yearly';
        }else{
            budgetType = '--None--';
        }
        var Name = event.currentTarget.getAttribute('data-service');//event.target.dataset.service;
        var parts = Name.split(" ");
        var month = parts[0]; // "April"
        var year = '';
        // Sample string
        var str = 'February Budget 2024';
        
        // Split the string by space
        var parts = str.split(' ');
        // Find the part that contains the year
        var year;
        parts.forEach(function(part) {
            if (!isNaN(part) && part.length === 4) { // Check if the part is a 4-digit number
                year = parseInt(part); // Convert the part to a number
            }
        });
        
        // Display the year
        console.log(year); // Output: 2024
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BudgetPlannerUpdated",
            componentAttributes: {
                BudgetId : event.currentTarget.getAttribute('data-record'),//event.target.dataset.record,
                ShowBudgetType : false,
                setRT : budgetType,
                selectedPeriod : budgetType,
                setBudgetType : event.currentTarget.getAttribute('data-category'),
                selectedYear:year,
                selectedMonth:month,
                fromProject : cmp.get("v.fromProject"),
                fromProjectWB : cmp.get("v.fromProjectWB"),
                currentProj : cmp.get("v.currentProj")
            }
        });
        evt.fire();
    },
    
    BudgetForecast : function(cmp, event, helper) {
        var purId = event.currentTarget.getAttribute('data-record');//event.target.dataset.record;
        var budgetType = event.currentTarget.getAttribute('data-name');//event.target.dataset.name;
        if(budgetType=='Monthly'){
            budgetType = 'Monthly Budget';
        }else if(budgetType=='Quarterly'){
            budgetType = 'Quarterly Budget';
        }else{
            budgetType = 'Yearly Budget';
        }
        var Name = event.currentTarget.getAttribute('data-service');//event.target.dataset.service;
        var parts = Name.split(" ");
        var month = parts[0]; // "April"
        var year = '';
        // Sample string
        var str = 'February Budget 2024';
        
        // Split the string by space
        var parts = str.split(' ');
        // Find the part that contains the year
        var year;
        parts.forEach(function(part) {
            if (!isNaN(part) && part.length === 4) { // Check if the part is a 4-digit number
                year = parseInt(part); // Convert the part to a number
            }
        });
        
        // Display the year
        console.log(year); // Output: 2024

        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BudgetForecasting",
            componentAttributes: {
                BudgetId : event.currentTarget.getAttribute('data-record'),//event.target.dataset.record,
                ShowBudgetType : false,
                setRT : budgetType,
                selectedYear:year,
                selectedMonth:month
            }
        });
        evt.fire();
    },
    
    submitForApproval : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var action = component.get("c.submitRecordForApproval");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showBudgetConfirmation", false);
                component.set("v.showMmainSpin",false);
                $A.enqueueAction(component.get("c.getOrganisedRecords"));
                //location.reload();
            } else {
                var errors = response.getError();
                if (errors) {
                    console.error("Error submitting for approval: " + errors[0].message);
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    submitForConfirmation : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        component.set("v.recordId", event.getSource().get("v.value"));
        component.set("v.showBudgetConfirmation", true);
        component.set("v.showMmainSpin",false);
    },
    
    cancelSubmit : function(component, event, helper) {
        component.set("v.showBudgetConfirmation", false);
    },
    
    backToProject : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Milestones",
            componentAttributes: {
                "currentProj" : component.get("v.currentProj"),
                "projectId" : component.get("v.ProjectId"),
                "newProj" : false
            }
        });
        evt.fire();
    },
    
    backToProjectWB : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ProjectWorkbench",
            componentAttributes: {
                //contactId : component.get("v.contact.Id")
            }
        });
        evt.fire();
    }
})