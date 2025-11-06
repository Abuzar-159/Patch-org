({
    cancelclick : function(component, event, helper) {
        if(component.get("v.fromProject")){
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
        }else if(component.get("v.fromProjectWB")){
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:ProjectWorkbench",
                componentAttributes: {
                    //contactId : component.get("v.contact.Id")
                }
            });
            evt.fire();
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef : "c:Budget",
                componentAttributes: {
                    //contactId : component.get("v.contact.Id")
                }
            });
            evt.fire();
        }
    },
    
    onCheck : function(component, event, helper) {
        var currBudgetType = event.currentTarget.getAttribute('data-billType');
        component.set('v.setBudgetType',currBudgetType);
        component.set('v.ShowBudgetType',false);
        //$A.enqueueAction(component.get("c.fetchMonthly"));
    },
    
    handleOptionChange: function(component, event, helper) {
        var selectedOption = component.get("v.selectedOption");
        console.log("Selected option: " + selectedOption);
        // You can perform additional actions based on the selected option here
    },
    
    doInit : function(cmp, event, helper) {
        cmp.set("v.showMmainSpin",true);
        console.log(cmp.get("v.setBudgetType"));
        helper.getYears(cmp);
        if(cmp.get("v.BudgetId")!='' && cmp.get("v.BudgetId")!=null && cmp.get("v.BudgetId")!=undefined){
            $A.enqueueAction(cmp.get("c.fetchBudgetFetails"));
            $A.enqueueAction(cmp.get("c.fetchMonthly"));
        }
        var selectedOption = cmp.get("v.selectedOption");
        console.log("Selected option: " + selectedOption);
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
        var action = cmp.get("c.getProgrammeWrapp");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(cmp.get("v.fetchRecordsBool")==true) {
                    cmp.set("v.ProjectWrapperList",response.getReturnValue());
                    if(cmp.get("v.ProjectId") != null && cmp.get("v.ProjectId") != undefined && cmp.get("v.ProjectId") != ""){
                        console.log('Entered');
                        var ProjectWrapperList=[]; 
        				ProjectWrapperList=cmp.get("v.ProjectWrapperList");
                        ProjectWrapperList[0].projWrapList[0].Project = cmp.get("v.ProjectId");
                    }
                }
            }  
        });
        $A.enqueueAction(action);
        
        let BudgetFC = cmp.get("c.getBudgetFC");
        BudgetFC.setCallback(this,function(response){
            console.log('state getBillFC~>'+response.getState());
            if(response.getState() === 'SUCCESS'){
                console.log('getBillFC resp~>',response.getReturnValue());
                cmp.set("v.displayProgramme", response.getReturnValue().displayProgramme);
                cmp.set("v.displayDepartment", response.getReturnValue().displayDepartment);
            }else{
                console.log('Error:',response.getError());
            }
        });
        $A.enqueueAction(BudgetFC);
    },
    
    addBudgetTimeAccount :  function(cmp, event, helper) { 
        var Index=event.getSource().get("v.value");
        var DepIndex=event.getSource().get("v.name");
        var ProjectWrapperList=[]; 
        console.log('DepIndex-->'+DepIndex);
        console.log('Index-->'+Index);
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        var action = cmp.get("c.getBudgetInstance");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(ProjectWrapperList[Index].depWrapList[DepIndex].budgetTimeAccount!=undefined){
                    ProjectWrapperList[Index].depWrapList[DepIndex].budgetTimeAccount.unshift(response.getReturnValue());
                }else{
                    ProjectWrapperList[Index].depWrapList[DepIndex].budgetTimeAccount = response.getReturnValue();
                }
                
                cmp.set("v.ProjectWrapperList", ProjectWrapperList);
            }  
        });
        $A.enqueueAction(action);
    },
    
    addBudgetAccount : function(cmp, event, helper) { 
        var Index=event.getSource().get("v.value");
        var DepIndex=event.getSource().get("v.name");
        var progIndex=event.getSource().get("v.title");
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        var action = cmp.get("c.getBudgetInstance");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                ProjectWrapperList[progIndex].projWrapList[Index].depWrapList[DepIndex].budgetAccount.unshift(response.getReturnValue());
                cmp.set("v.ProjectWrapperList", ProjectWrapperList);
            }  
        });
        $A.enqueueAction(action);
    },
    
    handledebitmenu: function(cmp,event,helper){
        var operation = event.detail.menuItem.get("v.label");
        if(operation == "Add Project" ){
            var Index=event.detail.menuItem.get("v.title");
            console.log('Index-->'+Index);
            var ProjectWrapperList=[]; 
            ProjectWrapperList=cmp.get("v.ProjectWrapperList");
            var action = cmp.get("c.getProjectWrapp");	
            action.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                    console.log('Response-->'+JSON.stringify(response.getReturnValue()));
                    ProjectWrapperList[Index].projWrapList.unshift(response.getReturnValue());
                    console.log('Response 1-->'+JSON.stringify(ProjectWrapperList));
                    cmp.set("v.ProjectWrapperList", ProjectWrapperList);
                }  
            });
            $A.enqueueAction(action);
            //helper.fetchDebitUpdate(cmp,event,helper,event.detail.menuItem.get("v.value"),event.detail.menuItem.get("v.title"));   
        } else if(operation == "Delete Project"){
            //helper.getPaymentPopupForDebit(cmp,event,helper,event.detail.menuItem.get("v.value"));
            var Index=event.detail.menuItem.get("v.title");
            var pIndex=event.detail.menuItem.get("v.value");
            console.log('Indexing-->'+Index);
            console.log('Index-->'+pIndex);
            var ProjectWrapperList=[]; 
            ProjectWrapperList=cmp.get("v.ProjectWrapperList");
            ProjectWrapperList[Index].projWrapList.splice(pIndex, 1);
            cmp.set("v.ProjectWrapperList", ProjectWrapperList);
            $A.enqueueAction(cmp.get("c.updateProjectTotal"));
        }
    },
    
    addProject : function(cmp, event, helper) { 
        var Index=event.getSource().get("v.value");
        console.log('Index-->'+Index);
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        var action = cmp.get("c.getProjectWrapp");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                console.log('Response-->'+JSON.stringify(response.getReturnValue()));
                ProjectWrapperList[Index].projWrapList.unshift(response.getReturnValue());
                console.log('Response 1-->'+JSON.stringify(ProjectWrapperList));
                cmp.set("v.ProjectWrapperList", ProjectWrapperList);
            }  
        });
        $A.enqueueAction(action);
    },
    
    deleteProject : function(cmp, event, helper) { 
        var Index=event.detail.menuItem.get("v.title");
        var pIndex=event.detail.menuItem.get("v.value");
        console.log('Index-->'+pIndex);
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        ProjectWrapperList[Index].projWrapList.splice(pIndex, 1);
        cmp.set("v.ProjectWrapperList", ProjectWrapperList);
        $A.enqueueAction(cmp.get("c.updateProjectTotal"));
    },
    
    
    fetchBudgetFetails : function(cmp, event, helper) { 
        var action = cmp.get("c.getBudgetDetails");	
        action.setParams({
            BudgetId:cmp.get("v.BudgetId")
        });
		action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                cmp.set("v.thresholdvalue", response.getReturnValue().ERP7__Threshold_Limit__c);
                cmp.set("v.selectedPeriod", response.getReturnValue().ERP7__Budget_Type__c);
                if(response.getReturnValue().ERP7__Posted_Actual_Expenditures__c){
                    cmp.set("v.selectedOption", 'Posted Actual Expenditures');
                }else{
                    cmp.set("v.selectedOption", 'UnPosted Actual Expenditures');
                }
                //cmp.set("v.selectedOption", response.getReturnValue().ERP7__Posted_Actual_Expenditures__c);
            }  
        });
        $A.enqueueAction(action);
    },
    addProgramme : function(cmp, event, helper) { 
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        var action = cmp.get("c.getProgrammeWrapp");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                ProjectWrapperList.unshift(response.getReturnValue());
                cmp.set("v.ProjectWrapperList", ProjectWrapperList);
            }  
        });
        $A.enqueueAction(action);
    },
    
    deleteProgramme : function(cmp, event, helper) { 
        console.log('called');
        console.log(event.detail.menuItem.get("v.value"));
        var PrIndex=event.detail.menuItem.get("v.value");
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        ProjectWrapperList.splice(PrIndex, 1);
        cmp.set("v.ProjectWrapperList", ProjectWrapperList);
        $A.enqueueAction(cmp.get("c.updateProjectTotal"));
    },
    
    addDepartment : function(cmp, event, helper) { 
        var PIndex=event.getSource().get("v.name");
        var PrIndex=event.getSource().get("v.value");
        console.log('PrIndex-->'+PrIndex);
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        var action = cmp.get("c.getDepartmentWrapp");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                console.log('Response-->'+JSON.stringify(response.getReturnValue()));
                ProjectWrapperList[PIndex].projWrapList[PrIndex].depWrapList.unshift(response.getReturnValue());
                console.log('Response 1-->'+JSON.stringify(ProjectWrapperList));
                cmp.set("v.ProjectWrapperList", ProjectWrapperList);
            }  
        });
        $A.enqueueAction(action);
    },
    
    deleteDepartment : function(cmp, event, helper) { 
        var PIndex=event.detail.menuItem.get("v.tabindex");
        var PrIndex=event.detail.menuItem.get("v.value");
        var drIndex=event.detail.menuItem.get("v.title");
        console.log('PrIndex-->'+PrIndex);
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        ProjectWrapperList[PIndex].projWrapList[PrIndex].depWrapList.splice(drIndex, 1);
        cmp.set("v.ProjectWrapperList", ProjectWrapperList);
        $A.enqueueAction(cmp.get("c.updateProjectTotal"));
    },
    
    
    addBudgetTimeAccount : function(cmp, event, helper) { 
        var Index=event.getSource().get("v.value");
        var DepIndex=event.getSource().get("v.name");
        var progIndex=event.getSource().get("v.title");
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        var action = cmp.get("c.getBudgetInstance");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                ProjectWrapperList[progIndex].projWrapList[Index].depWrapList[DepIndex].budgetTimeAccount.unshift(response.getReturnValue());
                cmp.set("v.ProjectWrapperList", ProjectWrapperList);
            }  
        });
        $A.enqueueAction(action);
    },
    
    updateProjectTotal: function(cmp, event, helper) { 
        console.log('updateProjectTotal-->');
        var projectWrapperList = cmp.get("v.ProjectWrapperList");
        for (var i = 0; i < projectWrapperList.length; i++) {
            var projList = projectWrapperList[i].projWrapList;
            for(var j = 0; j < projList.length; j++){
                var projectAmount = 0;
                var departList = projList[j].depWrapList;
                var departmentAmount = 0;
                for(var k = 0; k < departList.length; k++){
                    var budgetList = departList[k].budgetAccount;
                    for (var l = 0; l < budgetList.length; l++) {
                        console.log('account 12-->'+JSON.stringify(budgetList[l]));
                        var amount = budgetList[l].ERP7__Amount__c || 0;
                        projectAmount += parseFloat(amount);
                        departmentAmount += parseFloat(amount);
                        
                        var Q1amount = budgetList[l].ERP7__First_Quarter_Amount__c || 0;
                        var Q2amount = budgetList[l].ERP7__Second_Quarter_Amount__c || 0;
                        var Q3amount = budgetList[l].ERP7__Third_Quarter_Amount__c || 0;
                        var Q4amount = budgetList[l].ERP7__Fourth_Quarter_Amount__c || 0;
                        projectAmount += parseFloat(Q1amount) + parseFloat(Q2amount) + parseFloat(Q3amount) + parseFloat(Q4amount);
                        departmentAmount += parseFloat(Q1amount) + parseFloat(Q2amount) + parseFloat(Q3amount) + parseFloat(Q4amount);
                        
                        var janamount = budgetList[l].ERP7__January_Budget__c || 0;
                        var febamount = budgetList[l].ERP7__February_Budget__c || 0;
                        var maramount = budgetList[l].ERP7__March_Budget__c || 0;
                        var apramount = budgetList[l].ERP7__April_Budget__c || 0;
                        var mayamount = budgetList[l].ERP7__May_Budget__c || 0;
                        var junamount = budgetList[l].ERP7__June_Budget__c || 0;
                        var julamount = budgetList[l].ERP7__July_Budget__c || 0;
                        var augamount = budgetList[l].ERP7__August_Budget__c || 0;
                        var sepamount = budgetList[l].ERP7__September_Budget__c || 0;
                        var octamount = budgetList[l].ERP7__October_Budget__c || 0;
                        var novamount = budgetList[l].ERP7__November_Budget__c || 0;
                        var decamount = budgetList[l].ERP7__December_Budget__c || 0;
                        projectAmount += parseFloat(janamount) + parseFloat(febamount) + parseFloat(maramount) + parseFloat(apramount);
                        projectAmount += parseFloat(mayamount) + parseFloat(junamount) + parseFloat(julamount) + parseFloat(augamount);
                        projectAmount += parseFloat(sepamount) + parseFloat(octamount) + parseFloat(novamount) + parseFloat(decamount);
                        departmentAmount += parseFloat(janamount) + parseFloat(febamount) + parseFloat(maramount) + parseFloat(apramount);
                        departmentAmount += parseFloat(mayamount) + parseFloat(junamount) + parseFloat(julamount) + parseFloat(augamount);
                        departmentAmount += parseFloat(sepamount) + parseFloat(octamount) + parseFloat(novamount) + parseFloat(decamount);
                    }
                    var budgetList = departList[k].budgetTimeAccount;
                    for (var l = 0; l < budgetList.length; l++) {
                        console.log('account-->'+JSON.stringify(budgetList[l]));
                        var amount = budgetList[l].ERP7__Cost_Per_Hour__c || 0;
                        var projamount = budgetList[l].ERP7__Project_Hour__c || 0;
                        budgetList[l].ERP7__Amount__c = parseFloat(amount)*parseFloat(projamount);
                        projectAmount += parseFloat(amount)*parseFloat(projamount);
                        departmentAmount += parseFloat(amount)*parseFloat(projamount);
                        
                        var Q1amount = budgetList[l].ERP7__First_Quarter_Amount__c || 0;
                        var Q2amount = budgetList[l].ERP7__Second_Quarter_Amount__c || 0;
                        var Q3amount = budgetList[l].ERP7__Third_Quarter_Amount__c || 0;
                        var Q4amount = budgetList[l].ERP7__Fourth_Quarter_Amount__c || 0;
                        budgetList[l].ERP7__Amount__c += parseFloat(Q1amount)*parseFloat(amount) + parseFloat(Q2amount)*parseFloat(amount)  + parseFloat(Q3amount)*parseFloat(amount)  + parseFloat(Q4amount)*parseFloat(amount) ;
                        projectAmount += parseFloat(Q1amount)*parseFloat(amount) + parseFloat(Q2amount)*parseFloat(amount)  + parseFloat(Q3amount)*parseFloat(amount)  + parseFloat(Q4amount)*parseFloat(amount) ;
                        departmentAmount += parseFloat(Q1amount)*parseFloat(amount)  + parseFloat(Q2amount)*parseFloat(amount)  + parseFloat(Q3amount)*parseFloat(amount)  + parseFloat(Q4amount)*parseFloat(amount) ;
                        
                        var janamount = budgetList[l].ERP7__January_Budget__c || 0;
                        var febamount = budgetList[l].ERP7__February_Budget__c || 0;
                        var maramount = budgetList[l].ERP7__March_Budget__c || 0;
                        var apramount = budgetList[l].ERP7__April_Budget__c || 0;
                        var mayamount = budgetList[l].ERP7__May_Budget__c || 0;
                        var junamount = budgetList[l].ERP7__June_Budget__c || 0;
                        var julamount = budgetList[l].ERP7__July_Budget__c || 0;
                        var augamount = budgetList[l].ERP7__August_Budget__c || 0;
                        var sepamount = budgetList[l].ERP7__September_Budget__c || 0;
                        var octamount = budgetList[l].ERP7__October_Budget__c || 0;
                        var novamount = budgetList[l].ERP7__November_Budget__c || 0;
                        var decamount = budgetList[l].ERP7__December_Budget__c || 0;
                        budgetList[l].ERP7__Amount__c += parseFloat(janamount)*parseFloat(amount)  + parseFloat(febamount)*parseFloat(amount)  + parseFloat(maramount)*parseFloat(amount)  + parseFloat(apramount)*parseFloat(amount) ;
                        budgetList[l].ERP7__Amount__c += parseFloat(mayamount)*parseFloat(amount)  + parseFloat(junamount)*parseFloat(amount)  + parseFloat(julamount)*parseFloat(amount)  + parseFloat(augamount);
                        budgetList[l].ERP7__Amount__c += parseFloat(sepamount)*parseFloat(amount)  + parseFloat(octamount)*parseFloat(amount)  + parseFloat(novamount)*parseFloat(amount)  + parseFloat(decamount)*parseFloat(amount) ;
                        projectAmount += parseFloat(janamount)*parseFloat(amount)  + parseFloat(febamount)*parseFloat(amount)  + parseFloat(maramount)*parseFloat(amount)  + parseFloat(apramount)*parseFloat(amount) ;
                        projectAmount += parseFloat(mayamount)*parseFloat(amount)  + parseFloat(junamount)*parseFloat(amount)  + parseFloat(julamount)*parseFloat(amount)  + parseFloat(augamount);
                        projectAmount += parseFloat(sepamount)*parseFloat(amount)  + parseFloat(octamount)*parseFloat(amount)  + parseFloat(novamount)*parseFloat(amount)  + parseFloat(decamount)*parseFloat(amount) ;
                        departmentAmount += parseFloat(janamount)*parseFloat(amount)  + parseFloat(febamount)*parseFloat(amount)  + parseFloat(maramount)*parseFloat(amount)  + parseFloat(apramount)*parseFloat(amount) ;
                        departmentAmount += parseFloat(mayamount)*parseFloat(amount)  + parseFloat(junamount)*parseFloat(amount)  + parseFloat(julamount)*parseFloat(amount)  + parseFloat(augamount)*parseFloat(amount) ;
                        departmentAmount += parseFloat(sepamount)*parseFloat(amount)  + parseFloat(octamount)*parseFloat(amount)  + parseFloat(novamount)*parseFloat(amount)  + parseFloat(decamount)*parseFloat(amount) ;
                    }
                    console.log('i-->'+i+'j-->'+j+'k-->'+k);
                    projectWrapperList[i].projWrapList[j].depWrapList[k].DepartmentBudgetAmount = departmentAmount;
                }
                console.log('projectAmount-->'+projectAmount);
                projectWrapperList[i].projWrapList[j].ProjectBudgetAmount = projectAmount;
            }
        }
        var totalBud = 0;
        for(var j = 0; j < projectWrapperList.length; j++){
            for(k = 0; k < projectWrapperList[j].projWrapList.length; k++){
                totalBud += parseFloat(projectWrapperList[j].projWrapList[k].ProjectBudgetAmount);
            }// Fixed indexing
        }
        cmp.set("v.totalBudget", totalBud);
        // Update the ProjectWrapperList attribute with the modified list
        cmp.set("v.ProjectWrapperList", projectWrapperList);
    },
    
    updateProjectTotalTime: function(cmp, event, helper) { 
        var projectWrapperList = cmp.get("v.ProjectWrapperList");
        for (var i = 0; i < projectWrapperList.length; i++) {
            var projList = projectWrapperList[i].projWrapList;
            
            for(var j = 0; j < projList.length; j++){
                var projectAmount = 0;
                var departList = projList[j].depWrapList;
                var departmentAmount = 0;
                for(var k = 0; k < departList.length; k++){
                    var budgetList = departList[k].budgetAccount;
                    for (var l = 0; l < budgetList.length; l++) {
                        console.log('account-->'+JSON.stringify(budgetList[l]));
                        var amount = budgetList[l].ERP7__Amount__c || 0;
                        projectAmount += parseFloat(amount);
                        departmentAmount += parseFloat(amount);
                        
                        var Q1amount = budgetList[l].ERP7__Q1_Allocated_Hours__c || 0;
                        var Q2amount = budgetList[l].ERP7__Q2_Allocated_Hours__c || 0;
                        var Q3amount = budgetList[l].ERP7__Q3_Allocated_Hours__c || 0;
                        var Q4amount = budgetList[l].ERP7__Q4_Allocated_Hours__c || 0;
                        projectAmount += parseFloat(Q1amount) + parseFloat(Q2amount) + parseFloat(Q3amount) + parseFloat(Q4amount);
                        departmentAmount += parseFloat(Q1amount) + parseFloat(Q2amount) + parseFloat(Q3amount) + parseFloat(Q4amount);
                        
                        var janamount = budgetList[l].ERP7__January_Budget__c || 0;
                        var febamount = budgetList[l].ERP7__February_Budget__c || 0;
                        var maramount = budgetList[l].ERP7__March_Budget__c || 0;
                        var apramount = budgetList[l].ERP7__April_Budget__c || 0;
                        var mayamount = budgetList[l].ERP7__May_Budget__c || 0;
                        var junamount = budgetList[l].ERP7__June_Budget__c || 0;
                        var julamount = budgetList[l].ERP7__July_Budget__c || 0;
                        var augamount = budgetList[l].ERP7__August_Budget__c || 0;
                        var sepamount = budgetList[l].ERP7__September_Budget__c || 0;
                        var octamount = budgetList[l].ERP7__October_Budget__c || 0;
                        var novamount = budgetList[l].ERP7__November_Budget__c || 0;
                        var decamount = budgetList[l].ERP7__December_Budget__c || 0;
                        projectAmount += parseFloat(janamount) + parseFloat(febamount) + parseFloat(maramount) + parseFloat(apramount);
                        projectAmount += parseFloat(mayamount) + parseFloat(junamount) + parseFloat(julamount) + parseFloat(augamount);
                        projectAmount += parseFloat(sepamount) + parseFloat(octamount) + parseFloat(novamount) + parseFloat(decamount);
                        departmentAmount += parseFloat(janamount) + parseFloat(febamount) + parseFloat(maramount) + parseFloat(apramount);
                        departmentAmount += parseFloat(mayamount) + parseFloat(junamount) + parseFloat(julamount) + parseFloat(augamount);
                        departmentAmount += parseFloat(sepamount) + parseFloat(octamount) + parseFloat(novamount) + parseFloat(decamount);
                    }
                    
                    var budgetList = departList[k].budgetTimeAccount;
                    for (var l = 0; l < budgetList.length; l++) {
                        console.log('account-->'+JSON.stringify(budgetList[l]));
                        var amount = budgetList[l].ERP7__Cost_Per_Hour__c || 0;
                        var projamount = budgetList[l].ERP7__Project_Hour__c || 0;
                        budgetList[l].ERP7__Amount__c = parseFloat(amount)*parseFloat(projamount);
                        projectAmount += parseFloat(amount)*parseFloat(projamount);;
                        departmentAmount += parseFloat(amount)*parseFloat(projamount);;
                        
                        var Q1amount = budgetList[l].ERP7__First_Quarter_Amount__c || 0;
                        var Q2amount = budgetList[l].ERP7__Second_Quarter_Amount__c || 0;
                        var Q3amount = budgetList[l].ERP7__Third_Quarter_Amount__c || 0;
                        var Q4amount = budgetList[l].ERP7__Fourth_Quarter_Amount__c || 0;
                        budgetList[l].ERP7__Amount__c += parseFloat(Q1amount)*parseFloat(amount) + parseFloat(Q2amount)*parseFloat(amount)  + parseFloat(Q3amount)*parseFloat(amount)  + parseFloat(Q4amount)*parseFloat(amount) ;
                        projectAmount += parseFloat(Q1amount)*parseFloat(amount) + parseFloat(Q2amount)*parseFloat(amount)  + parseFloat(Q3amount)*parseFloat(amount)  + parseFloat(Q4amount)*parseFloat(amount) ;
                        departmentAmount += parseFloat(Q1amount)*parseFloat(amount)  + parseFloat(Q2amount)*parseFloat(amount)  + parseFloat(Q3amount)*parseFloat(amount)  + parseFloat(Q4amount)*parseFloat(amount) ;
                        
                        var janamount = budgetList[l].ERP7__January_Budget__c || 0;
                        var febamount = budgetList[l].ERP7__February_Budget__c || 0;
                        var maramount = budgetList[l].ERP7__March_Budget__c || 0;
                        var apramount = budgetList[l].ERP7__April_Budget__c || 0;
                        var mayamount = budgetList[l].ERP7__May_Budget__c || 0;
                        var junamount = budgetList[l].ERP7__June_Budget__c || 0;
                        var julamount = budgetList[l].ERP7__July_Budget__c || 0;
                        var augamount = budgetList[l].ERP7__August_Budget__c || 0;
                        var sepamount = budgetList[l].ERP7__September_Budget__c || 0;
                        var octamount = budgetList[l].ERP7__October_Budget__c || 0;
                        var novamount = budgetList[l].ERP7__November_Budget__c || 0;
                        var decamount = budgetList[l].ERP7__December_Budget__c || 0;
                        budgetList[l].ERP7__Amount__c += parseFloat(janamount)*parseFloat(amount)  + parseFloat(febamount)*parseFloat(amount)  + parseFloat(maramount)*parseFloat(amount)  + parseFloat(apramount)*parseFloat(amount) ;
                        budgetList[l].ERP7__Amount__c += parseFloat(mayamount)*parseFloat(amount)  + parseFloat(junamount)*parseFloat(amount)  + parseFloat(julamount)*parseFloat(amount)  + parseFloat(augamount);
                        budgetList[l].ERP7__Amount__c += parseFloat(sepamount)*parseFloat(amount)  + parseFloat(octamount)*parseFloat(amount)  + parseFloat(novamount)*parseFloat(amount)  + parseFloat(decamount)*parseFloat(amount) ;
                        projectAmount += parseFloat(janamount)*parseFloat(amount)  + parseFloat(febamount)*parseFloat(amount)  + parseFloat(maramount)*parseFloat(amount)  + parseFloat(apramount)*parseFloat(amount) ;
                        projectAmount += parseFloat(mayamount)*parseFloat(amount)  + parseFloat(junamount)*parseFloat(amount)  + parseFloat(julamount)*parseFloat(amount)  + parseFloat(augamount);
                        projectAmount += parseFloat(sepamount)*parseFloat(amount)  + parseFloat(octamount)*parseFloat(amount)  + parseFloat(novamount)*parseFloat(amount)  + parseFloat(decamount)*parseFloat(amount) ;
                        departmentAmount += parseFloat(janamount)*parseFloat(amount)  + parseFloat(febamount)*parseFloat(amount)  + parseFloat(maramount)*parseFloat(amount)  + parseFloat(apramount)*parseFloat(amount) ;
                        departmentAmount += parseFloat(mayamount)*parseFloat(amount)  + parseFloat(junamount)*parseFloat(amount)  + parseFloat(julamount)*parseFloat(amount)  + parseFloat(augamount)*parseFloat(amount) ;
                        departmentAmount += parseFloat(sepamount)*parseFloat(amount)  + parseFloat(octamount)*parseFloat(amount)  + parseFloat(novamount)*parseFloat(amount)  + parseFloat(decamount)*parseFloat(amount) ;
                    }
                    console.log('i-->'+i+'j-->'+j+'k-->'+k);
                    projectWrapperList[i].projWrapList[j].depWrapList[k].DepartmentBudgetAmount = departmentAmount;
                }
                projectWrapperList[i].projWrapList[j].ProjectBudgetAmount = projectAmount;
            }
        }
        var totalBud = 0;
        for(var j = 0; j < projectWrapperList.length; j++){
            for(k = 0; k < projectWrapperList[j].projWrapList.length; k++){
                totalBud += parseFloat(projectWrapperList[j].projWrapList[k].ProjectBudgetAmount);
            }// Fixed indexing
        }
        cmp.set("v.totalBudget", totalBud);
        // Update the ProjectWrapperList attribute with the modified list
        cmp.set("v.ProjectWrapperList", projectWrapperList);
    },
    
    lookupClickProduct: function(cmp, event, helper) { 
        var pIndex = event.target.getAttribute('data-index');
        var depIndex = event.target.getAttribute('data-indexe');
        var coaIndex = event.target.getAttribute('data-indexed');
        var chartId = event.target.getAttribute('data-value');
        var progIndex = event.target.getAttribute('data-indexing');
        if(chartId!=undefined && chartId!=null && chartId!=''){
            var ProjectWrapperList=[]; 
            ProjectWrapperList=cmp.get("v.ProjectWrapperList");
            var action = cmp.get("c.getChartOfAccountDetails");	
            action.setParams({
                "coaId": chartId
            });
            action.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                    ProjectWrapperList[progIndex].projWrapList[pIndex].depWrapList[depIndex].budgetAccount[coaIndex].ERP7__Account_Number__c=response.getReturnValue().ERP7__Account_Code__c;
                    ProjectWrapperList[progIndex].projWrapList[pIndex].depWrapList[depIndex].budgetAccount[coaIndex].ERP7__Budget_Account_Category__c =response.getReturnValue().RecordType.DeveloperName;
                    cmp.set("v.ProjectWrapperList", ProjectWrapperList);
                }  
            });
            $A.enqueueAction(action);
        }
    },
    
    lookupClickProject : function(cmp, event, helper) { 
        /*var pIndex = event.target.getAttribute('data-index');
        var chartId = event.target.getAttribute('data-value');
        if(chartId!=undefined && chartId!=null && chartId!=''){
            var ProjectWrapperList=[]; 
            ProjectWrapperList=cmp.get("v.ProjectWrapperList");
            var budgetAccount = [];
            budgetAccount = ProjectWrapperList[pIndex].budgetAccount;
            for (var i = 0; i < budgetAccount.length; i++) {
                console.log('account-->'+JSON.stringify(budgetAccount[i]));
                ProjectWrapperList[pIndex].budgetAccount[i].ERP7__Project__c = chartId;
            }
            cmp.set("v.ProjectWrapperList", ProjectWrapperList);
        }*/
    },
    
    confirmation : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        component.set("v.showBudgetConfirmation", true);
        component.set("v.showMmainSpin",false);
    },
    
    cancelSubmit : function(component, event, helper) {
        component.set("v.showBudgetConfirmation", false);
    },
    
    changeBudgetPeriod : function(cmp, event, helper) {
        var projectWrapperList = cmp.get("v.ProjectWrapperList");
        for (var i = 0; i < projectWrapperList.length; i++) {
            var projList = projectWrapperList[i].projWrapList;
            var projectAmount = 0;
            for(var j = 0; j < projList.length; j++){
                var departList = projList[j].depWrapList;
                var departmentAmount = 0;
                for(var k = 0; k < departList.length; k++){
                    var budgetList = departList[k].budgetAccount;
                    for (var l = 0; l < budgetList.length; l++) {
                        console.log('account-->'+JSON.stringify(budgetList[l]));
                        budgetList[l].ERP7__Amount__c = 0;
                        budgetList[l].ERP7__Cost_Per_Hour__c = 0;
                        budgetList[i].ERP7__First_Quarter_Amount__c = 0;
                        budgetList[i].ERP7__Second_Quarter_Amount__c = 0;
                        budgetList[i].ERP7__Third_Quarter_Amount__c = 0;
                        budgetList[i].ERP7__Fourth_Quarter_Amount__c = 0;
                        budgetList[i].ERP7__January_Budget__c = 0;
                        budgetList[i].ERP7__February_Budget__c = 0;
                        budgetList[i].ERP7__March_Budget__c = 0;
                        budgetList[i].ERP7__April_Budget__c = 0;
                        budgetList[i].ERP7__May_Budget__c = 0;
                        budgetList[i].ERP7__June_Budget__c = 0;
                        budgetList[i].ERP7__July_Budget__c = 0;
                        budgetList[i].ERP7__August_Budget__c = 0;
                        budgetList[i].ERP7__September_Budget__c = 0;
                        budgetList[i].ERP7__October_Budget__c = 0;
                        budgetList[i].ERP7__November_Budget__c = 0;
                        budgetList[i].ERP7__December_Budget__c = 0;
                    }
                    console.log('i-->'+i+'j-->'+j+'k-->'+k);
                    projectWrapperList[i].projWrapList[j].depWrapList[k].DepartmentBudgetAmount = departmentAmount;
                }
                projectWrapperList[i].projWrapList[j].ProjectBudgetAmount = projectAmount;
            }
        }
        var totalBud = 0;
        for(var j = 0; j < projectWrapperList.length; j++){
            for(k = 0; k < projectWrapperList[j].projWrapList.length; k++){
                totalBud += parseFloat(projectWrapperList[j].projWrapList[k].ProjectBudgetAmount);
            }// Fixed indexing
        }
        cmp.set("v.totalBudget", totalBud);
        // Update the ProjectWrapperList attribute with the modified list
        cmp.set("v.ProjectWrapperList", projectWrapperList);
        cmp.set("v.showMmainSpin", false);
        cmp.set("v.showBudgetConfirmation", false);
    },
    
    saveBudgetUpdate: function(cmp, event, helper) {
        cmp.set("v.showMmainSpin", true);
        // Retrieve the necessary parameters
        var orgId = cmp.get("v.Organisation.Id");
        var selectedYear = cmp.get("v.selectedYear");
        var selectedMonth = cmp.get("v.selectedMonth");
        var budgetId = cmp.get("v.BudgetId");
        var setRT = cmp.get("v.selectedPeriod");
        var thresholdvalue = cmp.get("v.thresholdvalue");
        var selectedOption = cmp.get("v.selectedOption");
        var totalBudget = cmp.get("v.totalBudget");
        var isValid = true;
        // Retrieve the monthly budget account data
        var projectWrapperList = cmp.get("v.ProjectWrapperList");
        console.log('data-->'+JSON.stringify(projectWrapperList));
        // Check if projectWrapperList is not empty and is an array
        if (projectWrapperList && Array.isArray(projectWrapperList) && projectWrapperList.length > 0) {
            // Construct the wrapper object
            var programmeWrapList = [];
            // Iterate over each item in projectWrapperList and construct department data
            projectWrapperList.forEach(function(wrapper) {
                var projWrapList = [];
                wrapper.projWrapList.forEach(function(proj) {
                    // Iterate over each department in wrapper and construct department data
                    var depWrapList = [];
                    proj.depWrapList.forEach(function(depart) {
                        var depData = {
                            "DepartmentId": depart.DepartmentId,
                            "DepartmentBudgetAmount": depart.DepartmentBudgetAmount,
                            "budgetAccount": [],
                            "budgetTimeAccount": []
                        };
                        
                        // Iterate over budgetAccount for each department and construct budget account data
                        depart.budgetAccount.forEach(function(budget) {
                            var budgetData = {
                                "Id": budget.Id,
                                "Name": budget.Name,
                                "ERP7__Amount__c": budget.ERP7__Amount__c,
                                "ERP7__Chart_of_Account__c": budget.ERP7__Chart_of_Account__c,
                                "ERP7__Budget_Account_Category__c": budget.ERP7__Budget_Account_Category__c
                            };
                            if(budget.ERP7__Chart_of_Account__c=='' || budget.ERP7__Chart_of_Account__c==null || budget.ERP7__Chart_of_Account__c==0){
                                helper.showToast('Error!', 'error', 'Please Select the Budget Category');
                                isValid = false;
                                cmp.set("v.showMmainSpin", false);
                                return;
                            }
                            if((budget.ERP7__Amount__c=='' || budget.ERP7__Amount__c==null || budget.ERP7__Amount__c==0) && cmp.get("v.selectedPeriod")=='Monthly'){
                                helper.showToast('Error!', 'error', 'Budget Amount is less than or equal to 0');
                                isValid = false;
                                cmp.set("v.showMmainSpin", false);
                                return;
                            }
                            depData.budgetAccount.push(budgetData);
                        });
                        
                        //depWrapList.push(depData);
						//console.log('depWrapList-->'+JSON.stringify(depWrapList));                        
                        depart.budgetTimeAccount.forEach(function(budget) {
                            var budgetData = {
                                "Id": budget.Id,
                                "Name": budget.Name,
                                "ERP7__Amount__c": budget.ERP7__Amount__c,
                                "ERP7__Activity_Type__c": budget.ERP7__Activity_Type__c,
                                "ERP7__Project_Hour__c": budget.ERP7__Project_Hour__c,
                                "ERP7__Q1_Allocated_Hours__c": budget.ERP7__Q1_Allocated_Hours__c,
                                "ERP7__Q2_Allocated_Hours__c": budget.ERP7__Q2_Allocated_Hours__c,
                                "ERP7__Q3_Allocated_Hours__c": budget.ERP7__Q3_Allocated_Hours__c,
                                "ERP7__Q4_Allocated_Hours__c": budget.ERP7__Q4_Allocated_Hours__c,
                                "ERP7__January_Budget__c": budget.ERP7__January_Budget__c,
                                "ERP7__February_Budget__c": budget.ERP7__February_Budget__c,
                                "ERP7__March_Budget__c": budget.ERP7__March_Budget__c,
                                "ERP7__April_Budget__c": budget.ERP7__April_Budget__c,
                                "ERP7__May_Budget__c": budget.ERP7__May_Budget__c,
                                "ERP7__June_Budget__c": budget.ERP7__June_Budget__c,
                                "ERP7__July_Budget__c": budget.ERP7__July_Budget__c,
                                "ERP7__August_Budget__c": budget.ERP7__August_Budget__c,
                                "ERP7__September_Budget__c": budget.ERP7__September_Budget__c,
                                "ERP7__October_Budget__c": budget.ERP7__October_Budget__c,
                                "ERP7__November_Budget__c": budget.ERP7__November_Budget__c,
                                "ERP7__December_Budget__c": budget.ERP7__December_Budget__c,
                                "ERP7__Cost_Per_Hour__c" : budget.ERP7__Cost_Per_Hour__c
                            };
                            depData.budgetTimeAccount.push(budgetData);
                        });
                        
                        depWrapList.push(depData);
                        console.log('depWrapList-->'+JSON.stringify(depWrapList));
                    });
                    var projwrap = {
                        "Project": proj.Project,
                        "ProjectBudgetAmount": proj.ProjectBudgetAmount,
                        "depWrapList": depWrapList
                    };
                    projWrapList.push(projwrap);
                });
                var projwrap = {
                    "Programme": wrapper.Programme,
                    "projWrapList": projWrapList
                };
                programmeWrapList.push(projwrap);
                
            });
            
            console.log('programmeWrapList:', programmeWrapList); // Debugging statement
            
            // Serialize the wrapper object into JSON
            var wrapListJSON = JSON.stringify(programmeWrapList);
            console.log('wrapListJSON:', wrapListJSON); // Debugging statement
            if(isValid){
                var action = cmp.get("c.SaveMonthlyBudgetUpdated");
                // Set parameters and call the Apex method
                action.setParams({
                    OrgId: orgId,
                    year: selectedYear,
                    month: selectedMonth,
                    wrapListJSON: wrapListJSON,
                    BudgetId: budgetId,
                    budgetType: setRT,
                    budgetCat : cmp.get("v.setBudgetType"),
                    threshold: thresholdvalue,
                    budgetControl: selectedOption,
                    budgetAmount: totalBudget
                });
                
                // Callback function
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === 'SUCCESS') {
                        var returnValue = response.getReturnValue();
                        if (returnValue === 'Budget Plan saved successfully.') {
                            helper.showToast($A.get('$Label.c.Success'), 'success', 'Budget Plan saved successfully.');
                            var evt = $A.get("e.force:navigateToComponent");
                            evt.setParams({
                                componentDef: "c:Budget",
                                componentAttributes: {
                                    fromProject : cmp.get("v.fromProject"),
                                    fromProjectWB : cmp.get("v.fromProjectWB"),
                                    currentProj : cmp.get("v.currentProj")
                                    // contactId: component.get("v.contact.Id")
                                }
                            });
                            evt.fire();
                        } else {
                            helper.showToast('Error!', 'error', returnValue);
                        }
                    } else {
                        helper.showToast('Error!', 'error', 'An error occurred while calling the Apex method.');
                    }
                    cmp.set("v.showMmainSpin", false);
                });
                
                // Enqueue the action
                $A.enqueueAction(action);
            }
        } else {
            console.error('ProjectWrapperList is empty or not an array:', projectWrapperList);
            helper.showToast('Error!', 'error', 'ProjectWrapperList is empty or not an array.');
            cmp.set("v.showMmainSpin", false);
        }
    },
    
    
    
    removeItem: function(cmp, event, helper) {
        var pIndex = event.getSource().get("v.name");
        var depIndex = event.getSource().get("v.value");
        var coaIndex = event.getSource().get("v.title");
        var budgetIndex = event.getSource().get("v.tabindex");
        console.log('pIndex-->'+pIndex);  
        console.log('depIndex-->'+depIndex);  
        console.log('coaIndex-->'+coaIndex); 
        console.log('budgetIndex-->'+budgetIndex); 
        var projectWrapperList = [];
        projectWrapperList = cmp.get("v.ProjectWrapperList");
        console.log('projectWrapperList-->'+projectWrapperList); 
        var budgetId = projectWrapperList[pIndex].projWrapList[coaIndex].depWrapList[depIndex].budgetAccount[budgetIndex].Id;
        console.log('budgetId-->'+budgetId);  
        if (budgetId == null) {
            projectWrapperList[pIndex].projWrapList[coaIndex].depWrapList[depIndex].budgetAccount.splice(budgetIndex, 1); // Changed remove to splice
            cmp.set("v.ProjectWrapperList", projectWrapperList);
            $A.enqueueAction(cmp.get("c.updateProjectTotal"));
        }
    },
    
    
    fetchMonthly : function(cmp, event, helper) {
        cmp.set("v.showMmainSpin",true);
        var orgId=cmp.get("v.Organisation.Id");
        var action = cmp.get("c.fetchMonthlyBudgetUpdate");
        action.setParams({
            OrgId:orgId,
            BudgetId:cmp.get("v.BudgetId")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(cmp.get("v.fetchRecordsBool")==true) {
                    console.log('MonthlyBudgetAccount-->'+JSON.stringify(response.getReturnValue()));
                    cmp.set("v.ProjectWrapperList",response.getReturnValue());
                    cmp.set("v.showMmainSpin",false);
                    $A.enqueueAction(cmp.get("c.updateProjectTotal"));
                }
            }
        });
        $A.enqueueAction(action); 
    },
})