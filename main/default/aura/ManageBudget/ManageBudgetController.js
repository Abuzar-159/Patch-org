({
    cancelclick : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Budget",
            componentAttributes: {
                //contactId : component.get("v.contact.Id")
            }
        });
        evt.fire();
    },
    
    onCheck : function(component, event, helper) {
        var currBudgetType = event.currentTarget.getAttribute('data-billType');
        component.set('v.setRT',currBudgetType);
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
        helper.getYears(cmp);
        if(cmp.get("v.BudgetId")!='' && cmp.get("v.BudgetId")!=null && cmp.get("v.BudgetId")!=undefined){
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
                }
            }  
        });
        $A.enqueueAction(action);
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
                    if(cmp.get("v.setRT")=='Monthly Budget'){
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
                                        var amount = budgetList[l].ERP7__Amount__c || 0;
                                        projectAmount += parseFloat(amount);
                                        departmentAmount += parseFloat(amount);
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
                        cmp.set("v.showMmainSpin",false);
                    }else if(cmp.get("v.setRT")=='Quarterly Budget'){
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
                                        var Q1amount = budgetList[i].ERP7__First_Quarter_Amount__c || 0;
                                        var Q2amount = budgetList[i].ERP7__Second_Quarter_Amount__c || 0;
                                        var Q3amount = budgetList[i].ERP7__Third_Quarter_Amount__c || 0;
                                        var Q4amount = budgetList[i].ERP7__Fourth_Quarter_Amount__c || 0;
                                        projectAmount += parseFloat(Q1amount) + parseFloat(Q2amount) + parseFloat(Q3amount) + parseFloat(Q4amount);
                                        departmentAmount += parseFloat(Q1amount) + parseFloat(Q2amount) + parseFloat(Q3amount) + parseFloat(Q4amount);
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
                        cmp.set("v.showMmainSpin",false);
                    }else{
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
                                        console.log('account-->' + JSON.stringify(budgetList[k]));
                                        var janamount = budgetList[i].ERP7__January_Budget__c || 0;
                                        var febamount = budgetList[i].ERP7__February_Budget__c || 0;
                                        var maramount = budgetList[i].ERP7__March_Budget__c || 0;
                                        var apramount = budgetList[i].ERP7__April_Budget__c || 0;
                                        var mayamount = budgetList[i].ERP7__May_Budget__c || 0;
                                        var junamount = budgetList[i].ERP7__June_Budget__c || 0;
                                        var julamount = budgetList[i].ERP7__July_Budget__c || 0;
                                        var augamount = budgetList[i].ERP7__August_Budget__c || 0;
                                        var sepamount = budgetList[i].ERP7__September_Budget__c || 0;
                                        var octamount = budgetList[i].ERP7__October_Budget__c || 0;
                                        var novamount = budgetList[i].ERP7__November_Budget__c || 0;
                                        var decamount = budgetList[i].ERP7__December_Budget__c || 0;
                                        projectAmount += parseFloat(janamount) + parseFloat(febamount) + parseFloat(maramount) + parseFloat(apramount);
                                        projectAmount += parseFloat(mayamount) + parseFloat(junamount) + parseFloat(julamount) + parseFloat(augamount);
                                        projectAmount += parseFloat(sepamount) + parseFloat(octamount) + parseFloat(novamount) + parseFloat(decamount);
                                        departmentAmount += parseFloat(janamount) + parseFloat(febamount) + parseFloat(maramount) + parseFloat(apramount);
                                        departmentAmount += parseFloat(mayamount) + parseFloat(junamount) + parseFloat(julamount) + parseFloat(augamount);
                                        departmentAmount += parseFloat(sepamount) + parseFloat(octamount) + parseFloat(novamount) + parseFloat(decamount);
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
                        cmp.set("v.showMmainSpin",false);
                    }
                }
            }  
        });
        $A.enqueueAction(action); 
    },
	
    saveBudgetUpdate: function(cmp, event, helper) {
        cmp.set("v.showMmainSpin", true);
        // Retrieve the necessary parameters
        var orgId = cmp.get("v.Organisation.Id");
        var selectedYear = cmp.get("v.selectedYear");
        var selectedMonth = cmp.get("v.selectedMonth");
        var budgetId = cmp.get("v.BudgetId");
        var setRT = cmp.get("v.setRT");
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
                            "budgetAccount": []
                        };
                        
                        // Iterate over budgetAccount for each department and construct budget account data
                        depart.budgetAccount.forEach(function(budget) {
                            var budgetData = {
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
                            if((budget.ERP7__Amount__c=='' || budget.ERP7__Amount__c==null || budget.ERP7__Amount__c==0) && cmp.get("v.setRT")=='Monthly Budget'){
                                helper.showToast('Error!', 'error', 'Budget Amount is less than or equal to 0');
                                isValid = false;
                                cmp.set("v.showMmainSpin", false);
                                return;
                            }
                            depData.budgetAccount.push(budgetData);
                        });
                        
                        depWrapList.push(depData);
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
    
    addProject : function(cmp, event, helper) { 
        var Index = event.currentTarget.get("v.value");
        //var Index=event.getSource().get("v.value");
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
        var Index=event.getSource().get("v.value");
        var pIndex=event.getSource().get("v.name");
        console.log('Index-->'+pIndex);
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        ProjectWrapperList[Index].projWrapList.splice(pIndex, 1);
        cmp.set("v.ProjectWrapperList", ProjectWrapperList);
        $A.enqueueAction(cmp.get("c.updateProjectTotal"));
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
        console.log(event.getSource().get("v.value"));
        var PrIndex=event.getSource().get("v.value");
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
        var PIndex=event.getSource().get("v.name");
        var PrIndex=event.getSource().get("v.value");
        var drIndex=event.getSource().get("v.title");
        console.log('PrIndex-->'+PrIndex);
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        ProjectWrapperList[PIndex].projWrapList[PrIndex].depWrapList.splice(drIndex, 1);
        cmp.set("v.ProjectWrapperList", ProjectWrapperList);
        $A.enqueueAction(cmp.get("c.updateProjectTotal"));
    },
    
    updateProjectTotal: function(cmp, event, helper) { 
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
                        var amount = budgetList[l].ERP7__Amount__c || 0;
                        projectAmount += parseFloat(amount);
                        departmentAmount += parseFloat(amount);
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


    
    updateProjectQuarterTotal : function(cmp, event, helper) { 
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
                        var Q1amount = budgetList[i].ERP7__First_Quarter_Amount__c || 0;
                        var Q2amount = budgetList[i].ERP7__Second_Quarter_Amount__c || 0;
                        var Q3amount = budgetList[i].ERP7__Third_Quarter_Amount__c || 0;
                        var Q4amount = budgetList[i].ERP7__Fourth_Quarter_Amount__c || 0;
                        projectAmount += parseFloat(Q1amount) + parseFloat(Q2amount) + parseFloat(Q3amount) + parseFloat(Q4amount);
                        departmentAmount += parseFloat(Q1amount) + parseFloat(Q2amount) + parseFloat(Q3amount) + parseFloat(Q4amount);
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
    
    updateProjectYearTotal : function(cmp, event, helper) {
        
        
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
                        console.log('account-->' + JSON.stringify(budgetList[k]));
                        var janamount = budgetList[i].ERP7__January_Budget__c || 0;
                        var febamount = budgetList[i].ERP7__February_Budget__c || 0;
                        var maramount = budgetList[i].ERP7__March_Budget__c || 0;
                        var apramount = budgetList[i].ERP7__April_Budget__c || 0;
                        var mayamount = budgetList[i].ERP7__May_Budget__c || 0;
                        var junamount = budgetList[i].ERP7__June_Budget__c || 0;
                        var julamount = budgetList[i].ERP7__July_Budget__c || 0;
                        var augamount = budgetList[i].ERP7__August_Budget__c || 0;
                        var sepamount = budgetList[i].ERP7__September_Budget__c || 0;
                        var octamount = budgetList[i].ERP7__October_Budget__c || 0;
                        var novamount = budgetList[i].ERP7__November_Budget__c || 0;
                        var decamount = budgetList[i].ERP7__December_Budget__c || 0;
                        projectAmount += parseFloat(janamount) + parseFloat(febamount) + parseFloat(maramount) + parseFloat(apramount);
                        projectAmount += parseFloat(mayamount) + parseFloat(junamount) + parseFloat(julamount) + parseFloat(augamount);
                        projectAmount += parseFloat(sepamount) + parseFloat(octamount) + parseFloat(novamount) + parseFloat(decamount);
                        departmentAmount += parseFloat(janamount) + parseFloat(febamount) + parseFloat(maramount) + parseFloat(apramount);
                        departmentAmount += parseFloat(mayamount) + parseFloat(junamount) + parseFloat(julamount) + parseFloat(augamount);
                        departmentAmount += parseFloat(sepamount) + parseFloat(octamount) + parseFloat(novamount) + parseFloat(decamount);
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
    
    removeItem: function(cmp, event, helper) {
        var pIndex = event.getSource().get("v.name");
        var depIndex = event.getSource().get("v.value");
        var coaIndex = event.getSource().get("v.title");
        console.log('pIndex-->'+pIndex);  
        console.log('depIndex-->'+depIndex);  
        console.log('coaIndex-->'+coaIndex); 
        var projectWrapperList = cmp.get("v.ProjectWrapperList");
        var budgetId = projectWrapperList[pIndex].depWrapList[depIndex].budgetAccount[coaIndex].Id;
        console.log('budgetId-->'+budgetId);  
        if (budgetId == null) {
            projectWrapperList[pIndex].depWrapList[depIndex].budgetAccount.splice(coaIndex, 1); // Changed remove to splice
            console.log('pIndex r-->'+pIndex);
            for (var i = 0; i < projectWrapperList.length; i++) {
                var projectAmount = 0;
                var departList = projectWrapperList[i].depWrapList;
                for (var j = 0; j < departList.length; j++) {
                    var budgetList = departList[j].budgetAccount;
                    var departmentAmount = 0;
                    for (var k = 0; k < budgetList.length; k++) {
                        console.log('account-->' + JSON.stringify(budgetList[k]));
                        var amount = budgetList[k].ERP7__Amount__c || 0;
                        projectAmount += parseFloat(amount);
                        departmentAmount += parseFloat(amount);
                    }
                    projectWrapperList[i].depWrapList[j].DepartmentBudgetAmount = departmentAmount;
                }
                projectWrapperList[i].ProjectBudgetAmount = projectAmount;
            }
            var totalBud = 0;
            for (var j = 0; j < projectWrapperList.length; j++) {
                totalBud += parseFloat(projectWrapperList[j].ProjectBudgetAmount);
            }
            cmp.set("v.totalBudget", totalBud);
            // Update the ProjectWrapperList attribute with the modified list
            cmp.set("v.ProjectWrapperList", projectWrapperList);
        }
    }





    
    
})