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
            if(cmp.get("v.setRT")=='Monthly Budget') $A.enqueueAction(cmp.get("c.fetchMonthly"));
            else if(cmp.get("v.setRT")=='Quarterly Budget') $A.enqueueAction(cmp.get("c.fetchQuarterly"));
            else $A.enqueueAction(cmp.get("c.fetchYearly"));
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
        var action = cmp.get("c.getProjectWrapp");	
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
        var action = cmp.get("c.fetchMonthlyBudgetForecast");
        action.setParams({
            OrgId:orgId,
            BudgetId:cmp.get("v.BudgetId")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(cmp.get("v.fetchRecordsBool")==true) {
                    console.log('MonthlyBudgetAccount-->'+JSON.stringify(response.getReturnValue()));
                    cmp.set("v.ProjectWrapperList",response.getReturnValue());
                    var projectWrapperList = cmp.get("v.ProjectWrapperList");
                    var totalBud = 0;
                    var totalBudConsume = 0;
                    var totalBudCommitted = 0;
                    for(var j = 0; j< projectWrapperList.length; j++){
                        if(projectWrapperList[j].UnpostedEx) cmp.set("v.unposted", true);
                        totalBud += parseFloat(projectWrapperList[j].ProjectBudgetAmount);
                        totalBudConsume += parseFloat(projectWrapperList[j].ProjectConsumeAmount);
                        totalBudCommitted += parseFloat(projectWrapperList[j].ProjectCommittedAmount);
                    }
                    cmp.set("v.committedBudget", totalBudCommitted);
                    cmp.set("v.consumeBudget", totalBudConsume);
                    cmp.set("v.totalBudget", totalBud);
                    cmp.set("v.budgetUsed", (((totalBudConsume+totalBudCommitted)/totalBud)*100).toFixed(2));
                    // Update the ProjectWrapperList attribute with the modified list
                    cmp.set("v.ProjectWrapperList", projectWrapperList);
                    cmp.set("v.showMmainSpin",false);
                }
            }  
        });
        $A.enqueueAction(action); 
    },
	
    fetchQuarterly : function(cmp, event, helper) {
        cmp.set("v.showMmainSpin",true);
        var orgId=cmp.get("v.Organisation.Id");
        var action = cmp.get("c.fetchQuerterBudgetForecast");
        action.setParams({
            OrgId:orgId,
            BudgetId:cmp.get("v.BudgetId")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(cmp.get("v.fetchRecordsBool")==true) {
                    console.log('MonthlyBudgetAccount-->'+JSON.stringify(response.getReturnValue()));
                    cmp.set("v.ProjectWrapperList",response.getReturnValue());
                    var projectWrapperList = cmp.get("v.ProjectWrapperList");
                    var totalBud = 0;
                    var totalBudConsume = 0;
                    for(var j = 0; j< projectWrapperList.length; j++){
                        totalBud += parseFloat(projectWrapperList[j].ProjectBudgetAmount);
                        totalBudConsume += parseFloat(projectWrapperList[j].ProjectConsumeAmount);
                    }
                    cmp.set("v.consumeBudget", totalBudConsume);
                    cmp.set("v.totalBudget", totalBud);
                    cmp.set("v.budgetUsed", ((totalBudConsume/totalBud)*100).toFixed(2));
                    // Update the ProjectWrapperList attribute with the modified list
                    cmp.set("v.ProjectWrapperList", projectWrapperList);
                    cmp.set("v.showMmainSpin",false);
                }
            }  
        });
        $A.enqueueAction(action); 
    },
    
    fetchYearly : function(cmp, event, helper) {
        cmp.set("v.showMmainSpin",true);
        var orgId=cmp.get("v.Organisation.Id");
        var action = cmp.get("c.fetchYearBudgetForecast");
        action.setParams({
            OrgId:orgId,
            BudgetId:cmp.get("v.BudgetId")
        });
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(cmp.get("v.fetchRecordsBool")==true) {
                    console.log('MonthlyBudgetAccount-->'+JSON.stringify(response.getReturnValue()));
                    cmp.set("v.ProjectWrapperList",response.getReturnValue());
                    var projectWrapperList = cmp.get("v.ProjectWrapperList");
                    var totalBud = 0;
                    var totalBudConsume = 0;
                    for(var j = 0; j< projectWrapperList.length; j++){
                        totalBud += parseFloat(projectWrapperList[j].ProjectBudgetAmount);
                        totalBudConsume += parseFloat(projectWrapperList[j].ProjectConsumeAmount);
                    }
                    cmp.set("v.consumeBudget", totalBudConsume);
                    cmp.set("v.totalBudget", totalBud);
                    cmp.set("v.budgetUsed", ((totalBudConsume/totalBud)*100).toFixed(2));
                    // Update the ProjectWrapperList attribute with the modified list
                    cmp.set("v.ProjectWrapperList", projectWrapperList);
                    cmp.set("v.showMmainSpin",false);
                }
            }  
        });
        $A.enqueueAction(action); 
    },
    
    saveBudget: function(cmp, event, helper) {
        cmp.set("v.showMmainSpin", true);
        var orgId = cmp.get("v.Organisation.Id");
        var action = cmp.get("c.SaveMonthlyBudget");
        
        // Retrieve the monthly budget account data
        var monthlyBudgetAccount = cmp.get("v.MonthlyBudgetAccount");
        console.log('Monthly Budget Before Account:', JSON.stringify(monthlyBudgetAccount));
        console.log('asset-->'+JSON.stringify(monthlyBudgetAccount[0].assetAccount));
        // Check if monthlyBudgetAccount is populated and is an object
        if (monthlyBudgetAccount && typeof monthlyBudgetAccount === 'object') {
            // Construct a wrapper object with the desired properties
            var budgetWrapper = {
                assetAccount: monthlyBudgetAccount[0].assetAccount || [],
                laibilityAccount: monthlyBudgetAccount[0].laibilityAccount || [],
                EquityAccount: monthlyBudgetAccount[0].EquityAccount || [],
                RevenueAccount: monthlyBudgetAccount[0].RevenueAccount || [],
                ExpenseAccount: monthlyBudgetAccount[0].ExpenseAccount || []
            };
            
            // Serialize the wrapper object into JSON
            var monthlyBudgetAccountJSON = JSON.stringify(budgetWrapper);
            console.log('Monthly Budget Account:', budgetWrapper);
            console.log('Monthly Budget Account JSON:', monthlyBudgetAccountJSON);
            
            // Set parameters and call the Apex method
            action.setParams({
                OrgId: orgId,
                year: cmp.get("v.selectedYear"),
                month: cmp.get("v.selectedMonth"),
                wrapListJSON: monthlyBudgetAccountJSON,
            	BudgetId:cmp.get("v.BudgetId")
            });
            
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
            
            $A.enqueueAction(action); 
        } else {
            console.error('MonthlyBudgetAccount is not populated or is not an object:', monthlyBudgetAccount);
            helper.showToast('Error!', 'error', 'MonthlyBudgetAccount is not populated or is not an object.');
            cmp.set("v.showMmainSpin", false);
        }
    },
    
    saveBudgetUpdate : function(cmp, event, helper) {
        cmp.set("v.showMmainSpin", true);
        var orgId = cmp.get("v.Organisation.Id");
        var action = cmp.get("c.SaveMonthlyBudgetUpdated");
        
        // Retrieve the monthly budget account data
        var monthlyBudgetAccount = cmp.get("v.ProjectWrapperList");
        console.log('Monthly Budget Before Account:', JSON.stringify(monthlyBudgetAccount));
        console.log('asset-->'+JSON.stringify(monthlyBudgetAccount[0].budgetAccount));
        // Check if monthlyBudgetAccount is populated and is an object
        if (monthlyBudgetAccount && typeof monthlyBudgetAccount === 'object') {
            // Construct a wrapper object with the desired properties
            /*var budgetWrapper = {
                budgetAccount: monthlyBudgetAccount[0].budgetAccount || []
            };
            */
            var budgetAccounts = [];
            
            // Iterate over each item in ProjectWrapperList
            for (var i = 0; i < monthlyBudgetAccount.length; i++) {
                // Access the budgetAccount data from each item
                var budgetAccountData = monthlyBudgetAccount[i].budgetAccount;
                
                // Check if budgetAccountData is populated and is an array
                if (Array.isArray(budgetAccountData) && budgetAccountData.length > 0) {
                    // Add budgetAccountData to the budgetAccounts array
                    budgetAccounts = budgetAccounts.concat(budgetAccountData);
                }
            }
            
            // Construct a wrapper object with the desired properties
            var budgetWrapper = {
                budgetAccount: budgetAccounts
            };
            
            // Serialize the wrapper object into JSON
            var monthlyBudgetAccountJSON = JSON.stringify(budgetWrapper);
            console.log('Monthly Budget Account:', budgetWrapper);
            console.log('Monthly Budget Account JSON:', monthlyBudgetAccountJSON);
            console.log('thresold-->',cmp.get("v.thresholdvalue"));
            console.log('selectedOption-->',cmp.get("v.selectedOption"));
            console.log('totalBudget-->',cmp.get("v.totalBudget"));
            // Set parameters and call the Apex method
            action.setParams({
                OrgId: orgId,
                year: cmp.get("v.selectedYear"),
                month: cmp.get("v.selectedMonth"),
                wrapListJSON: monthlyBudgetAccountJSON,
            	BudgetId:cmp.get("v.BudgetId"),
                budgetType : cmp.get("v.setRT"),
                threshold : cmp.get("v.thresholdvalue"),
                budgetControl : cmp.get("v.selectedOption"),
                budgetAmount : cmp.get("v.totalBudget")
            });
            
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
            
            $A.enqueueAction(action); 
        } else {
            console.error('MonthlyBudgetAccount is not populated or is not an object:', monthlyBudgetAccount);
            helper.showToast('Error!', 'error', 'MonthlyBudgetAccount is not populated or is not an object.');
            cmp.set("v.showMmainSpin", false);
        }
    },
    
    
    addBudgetAccount : function(cmp, event, helper) { 
        var Index=event.getSource().get("v.name");
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        var action = cmp.get("c.getBudgetInstance");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                ProjectWrapperList[Index].budgetAccount.unshift(response.getReturnValue());
                cmp.set("v.ProjectWrapperList", ProjectWrapperList);
            }  
        });
        $A.enqueueAction(action);
    },
    
    addProject : function(cmp, event, helper) { 
        var ProjectWrapperList=[]; 
        ProjectWrapperList=cmp.get("v.ProjectWrapperList");
        var action = cmp.get("c.getProjectWrapp");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                ProjectWrapperList.unshift(response.getReturnValue());
                cmp.set("v.ProjectWrapperList", ProjectWrapperList);
            }  
        });
        $A.enqueueAction(action);
    },
    
    updateProjectTotal: function(cmp, event, helper) { 
        // Retrieve the index from the event
        var index = event.getSource().get("v.name");
        if (index === undefined) {
            console.error("Index is undefined.");
            return;
        }
        
        // Retrieve the ProjectWrapperList from the component
        var projectWrapperList = cmp.get("v.ProjectWrapperList");
        
        // Retrieve the budgetList from the ProjectWrapperList
        var budgetList = projectWrapperList[index].budgetAccount;
        
        // Initialize projectAmount
        var projectAmount = 0;
        
        // Loop through the budgetList and calculate projectAmount
        for (var i = 0; i < budgetList.length; i++) {
            console.log('account-->'+JSON.stringify(budgetList[i]));
            var amount = budgetList[i].ERP7__Amount__c || 0;
            projectAmount += parseFloat(amount);
        }
        // Update the ProjectBudgetAmount in the ProjectWrapperList
        projectWrapperList[index].ProjectBudgetAmount = projectAmount;
        var totalBud = 0;
        for(var j = 0; j < projectWrapperList.length; j++){
            totalBud += parseFloat(projectWrapperList[j].ProjectBudgetAmount);
        }
        cmp.set("v.totalBudget", totalBud);
        // Update the ProjectWrapperList attribute with the modified list
        cmp.set("v.ProjectWrapperList", projectWrapperList);
    },
    
    updateProjectQuarterTotal: function(cmp, event, helper) { 
        // Retrieve the index from the event
        var index = event.getSource().get("v.name");
        if (index === undefined) {
            console.error("Index is undefined.");
            return;
        }
        
        // Retrieve the ProjectWrapperList from the component
        var projectWrapperList = cmp.get("v.ProjectWrapperList");
        
        // Retrieve the budgetList from the ProjectWrapperList
        var budgetList = projectWrapperList[index].budgetAccount;
        
        // Initialize projectAmount
        var projectAmount = 0;
        
        // Loop through the budgetList and calculate projectAmount
        for (var i = 0; i < budgetList.length; i++) {
            console.log('account-->'+JSON.stringify(budgetList[i]));
            var Q1amount = budgetList[i].ERP7__First_Quarter_Amount__c || 0;
            var Q2amount = budgetList[i].ERP7__Second_Quarter_Amount__c || 0;
            var Q3amount = budgetList[i].ERP7__Third_Quarter_Amount__c || 0;
            var Q4amount = budgetList[i].ERP7__Fourth_Quarter_Amount__c || 0;
            projectAmount += parseFloat(Q1amount) + parseFloat(Q2amount) + parseFloat(Q3amount) + parseFloat(Q4amount);
        }
        // Update the ProjectBudgetAmount in the ProjectWrapperList
        projectWrapperList[index].ProjectBudgetAmount = projectAmount;
        var totalBud = 0;
        for(var j = 0; j < projectWrapperList.length; j++){
            totalBud += parseFloat(projectWrapperList[j].ProjectBudgetAmount);
        }
        cmp.set("v.totalBudget", totalBud);
        // Update the ProjectWrapperList attribute with the modified list
        cmp.set("v.ProjectWrapperList", projectWrapperList);
    },
    
    updateProjectYearTotal : function(cmp, event, helper) { 
        // Retrieve the index from the event
        var index = event.getSource().get("v.name");
        if (index === undefined) {
            console.error("Index is undefined.");
            return;
        }
        
        // Retrieve the ProjectWrapperList from the component
        var projectWrapperList = cmp.get("v.ProjectWrapperList");
        
        // Retrieve the budgetList from the ProjectWrapperList
        var budgetList = projectWrapperList[index].budgetAccount;
        
        // Initialize projectAmount
        var projectAmount = 0;
        
        // Loop through the budgetList and calculate projectAmount
        for (var i = 0; i < budgetList.length; i++) {
            console.log('account-->'+JSON.stringify(budgetList[i]));
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
        }
        // Update the ProjectBudgetAmount in the ProjectWrapperList
        projectWrapperList[index].ProjectBudgetAmount = projectAmount;
        var totalBud = 0;
        for(var j = 0; j < projectWrapperList.length; j++){
            totalBud += parseFloat(projectWrapperList[j].ProjectBudgetAmount);
        }
        cmp.set("v.totalBudget", totalBud);
        // Update the ProjectWrapperList attribute with the modified list
        cmp.set("v.ProjectWrapperList", projectWrapperList);
    },
    
    lookupClickProduct: function(cmp, event, helper) { 
        var pIndex = event.target.getAttribute('data-index');
        var coaIndex = event.target.getAttribute('data-indexed');
        var chartId = event.target.getAttribute('data-value');
        if(chartId!=undefined && chartId!=null && chartId!=''){
            var ProjectWrapperList=[]; 
            ProjectWrapperList=cmp.get("v.ProjectWrapperList");
            var action = cmp.get("c.getChartOfAccountDetails");	
            action.setParams({
                "coaId": chartId
            });
            action.setCallback(this,function(response){
                if(response.getState()==='SUCCESS'){
                    ProjectWrapperList[pIndex].budgetAccount[coaIndex].ERP7__Account_Number__c=response.getReturnValue().ERP7__Account_Code__c;
                    ProjectWrapperList[pIndex].budgetAccount[coaIndex].ERP7__Budget_Account_Category__c =response.getReturnValue().RecordType.DeveloperName;
                    cmp.set("v.ProjectWrapperList", ProjectWrapperList);
                }  
            });
            $A.enqueueAction(action);
        }
    },
    
    lookupClickProject : function(cmp, event, helper) { 
        var pIndex = event.target.getAttribute('data-index');
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
        }
    },




    
    
})