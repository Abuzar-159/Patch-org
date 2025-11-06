({
    updateData : function (component, event, helper){ 
        component.set('v.showSpinner', true);
        var action = component.get('c.fecthDetails');
        action.setParams({
            Ins : JSON.stringify(component.get('v.Instance')),  
            selectedIso : component.get('v.Instance.SelectedCurrency')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.stopRepeat', false);
                component.set('v.Instance', response.getReturnValue());
                console.log('updateData resp~>',response.getReturnValue());
                
                if(component.get('v.Instance.multiCurrencyEnabled')!=null)
                    component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                //component.set('v.Instance.multiCurrencyEnabled', true);
                component.set('v.Org', component.get('v.Instance.Select_Organisation.ERP7__Organisation__c'));
                component.set('v.SD',  component.get('v.Instance.sDate'));
                component.set('v.ED',  component.get('v.Instance.eDate'));
                component.set('v.showPage', true);  
                component.set('v.showAsset', response.getReturnValue().balanceSheetAccounts['Assets']);
                component.set('v.showLiability', response.getReturnValue().balanceSheetAccounts['Liability']);
                component.set('v.showEquity', response.getReturnValue().balanceSheetAccounts['Equity']);
                if(component.get('v.setPick')=='set') component.set("v.FYOptions",response.getReturnValue().getPickList); //component.find("FY").set("v.options", response.getReturnValue().getPickList);
                component.set('v.setPick','Not set');
                component.set('v.picklists',response.getReturnValue().getPickList);
                component.set('v.showSpinner', false);
                var label = 'Revenue In '+component.get('v.Instance.CurrencyISO');
                component.set('v.chartyLabel', label);
                component.set('v.stopRepeat',true);
                
            }else{
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
        var stockTakeStatus = component.get("c.getCurrencies");
        stockTakeStatus.setCallback(this,function(response){
            //component.find("stStatus").set("v.options", response.getReturnValue());     
            component.set("v.stStatusOptions", response.getReturnValue());
        });
        $A.enqueueAction(stockTakeStatus);
        
    },
    
    fetchData : function (component, event, helper){ 
        component.set('v.showSpinner', true);
        var action = component.get('c.fecthDetails');
        action.setParams({
            Ins : JSON.stringify(component.get('v.Instance')),  
            selectedIso : component.get('v.Instance.SelectedCurrency')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.stopRepeat', false);
                component.set('v.Instance', response.getReturnValue());
                console.log('fetchData resp~>',response.getReturnValue());
                component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
                //component.set('v.Instance.multiCurrencyEnabled', true);
                component.set('v.Org', component.get('v.Instance.Select_Organisation.ERP7__Organisation__c'));
                component.set('v.SD',  component.get('v.Instance.sDate'));
                component.set('v.ED',  component.get('v.Instance.eDate'));
                component.set('v.showPage', true);  
                component.set('v.showAsset', response.getReturnValue().balanceSheetAccounts['Assets']);
                component.set('v.showLiability', response.getReturnValue().balanceSheetAccounts['Liability']);
                component.set('v.showEquity', response.getReturnValue().balanceSheetAccounts['Equity']);
                if(component.get('v.setPick')=='set') component.set("v.FYOptions",response.getReturnValue().getPickList); //component.find("FY").set("v.options", response.getReturnValue().getPickList);
                component.set('v.setPick','Not set');
                component.set('v.picklists',response.getReturnValue().getPickList);
                component.set('v.showSpinner', false);
                var label = 'Revenue In '+component.get('v.Instance.CurrencyISO');
                component.set('v.chartyLabel', label);
                component.set('v.stopRepeat',true);
                
            }else{
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
        
    },
    
    getGraphData : function(component, event, helper){
        var action = component.get('c.getGraphValues');
        action.setParams({
            B:JSON.stringify(component.get('v.Instance'))
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if( state === "SUCCESS"){
                component.set('v.Instance', response.getReturnValue()); 
                var k =[]; var v = [];var data = component.get('v.Instance.datalist');
                for(var a in data ){
                    //if(data[a].data1 > 0 || data[a].data1 <0){
                    if(data[a].name!=undefined && data[a].name!=null && data[a].name!=''){
                        k.push(data[a].name); 
                        v.push(data[a].data1);
                    }
                    //}
                }
                component.set('v.setKeys', k);
                component.set('v.setValues', v);
                component.set('v.showSpinner', false);
                component.set('v.Tab','Tab2');
                //component.find('FY1').set('v.options', component.get('v.picklists'));
                component.set("v.FY1Options",component.get('v.picklists'));
                component.set('v.callGraph',false);
                component.set('v.stopRepeat', true);
                
            }else{
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    
     
    fetchAggregateResult : function(component, event, helper){
        var action = component.get("c.computeDataUpdated");
        action.setParams({
            eDate:component.get('v.eDate'),
            orgId:component.get('v.OrgId'),
            LedgerIds:component.get("v.LedgerIds"),
            FirstRun:false
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var aggregateResults = component.get("v.AggResult");
                aggregateResults.push(response.getReturnValue().aggResult);
                component.set("v.AggResult", aggregateResults);
            }else{
                console.log("Error: ");// + response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    
    /*fetchOpeningBalanceAccountsTab2: function (component, event, helper) {
        var action = component.get("c.fetchOpeniBalanceCOA"); // Call the server method
        
        action.setParams({
            aggList: JSON.stringify(component.get("v.AggResult")),
            orgId: component.get('v.OrgId')
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //var aggregateResults = response.getReturnValue(); // Get the result from the server
                //console.log('Full Aggregate Results:', JSON.stringify(aggregateResults));
                var aggregateResults = component.get("v.AggResult");
                aggregateResults.push(response.getReturnValue());
                component.set("v.AggResult", aggregateResults);
                console.log(JSON.stringify(aggregateResults));
                
                var aggregateResults = component.get("v.AggResult");
                console.log('Full processingData-->' + JSON.stringify(aggregateResults));
                // Group data by fiscal year (FY) without filtering
                let fiscalYearMap = new Map();
                
                // Iterate through the response and group by fiscal year
                aggregateResults.forEach(value => {
                    value.forEach(result => {
                    let fiscalYear = result.FY;  // Extract the fiscal year from the result
                    
                    if (!fiscalYearMap.has(fiscalYear)) {
                    fiscalYearMap.set(fiscalYear, { assets: [], liabilities: [], equity: [] });
            }
            
            // Sort data based on AccountGroup (Assets, Liabilities, Equity)
            if (result.AccountGroup === 'Assets') {
                fiscalYearMap.get(fiscalYear).assets.push(result);
            }
            if (result.AccountGroup === 'Liability') {
                fiscalYearMap.get(fiscalYear).liabilities.push(result);
            }
            if (result.AccountGroup === 'Equity') {
                fiscalYearMap.get(fiscalYear).equity.push(result);
            }
        });
    });
    
    // Initialize arrays to hold all fiscal year data
    let allAssets = [];
    let allLiabilities = [];
    let allEquity = [];
    
    // Initialize sum variables for assets, liabilities, and equity across all fiscal years
    let AssetSum = 0;
    let LiabilitySum = 0;
    let EquitySum = 0;
    
    // Process all fiscal years and their corresponding data
    fiscalYearMap.forEach((data, fiscalYear) => {
    // Calculate sum for this fiscal year's assets, liabilities, and equity
    let fiscalYearAssetSum = 0;
    let fiscalYearLiabilitySum = 0;
    let fiscalYearEquitySum = 0;
    
    data.assets.forEach(result => {
    fiscalYearAssetSum += parseFloat(result.Debit) - parseFloat(result.Credit);
    allAssets.push(result);
});
data.liabilities.forEach(result => {
    fiscalYearLiabilitySum += parseFloat(result.Credit) - parseFloat(result.Debit);
    allLiabilities.push(result);
});
    data.equity.forEach(result => {
    fiscalYearEquitySum += parseFloat(result.Credit) - parseFloat(result.Debit);
    allEquity.push(result);
});
    
    // Add the sums for this fiscal year to the overall sum
    AssetSum += fiscalYearAssetSum;
    LiabilitySum += fiscalYearLiabilitySum;
    EquitySum += fiscalYearEquitySum;
    
    console.log(`Fiscal Year: ${fiscalYear}, Asset Sum: ${fiscalYearAssetSum}, Liability Sum: ${fiscalYearLiabilitySum}, Equity Sum: ${fiscalYearEquitySum}`);
});

// Set the overall sums for all fiscal years
component.set("v.AssetSum", AssetSum);
component.set("v.LiabilitySum", LiabilitySum);
component.set("v.EquitySum", EquitySum);
component.set("v.CalculatedEquity", AssetSum - LiabilitySum);

// Set the aggregated data for all fiscal years to be displayed
component.set("v.AssetData", allAssets);
component.set("v.LiabilityData", allLiabilities);
component.set("v.EquityData", allEquity);

console.log('All Asset Data:', JSON.stringify(allAssets));
console.log('All Liability Data:', JSON.stringify(allLiabilities));
console.log('All Equity Data:', JSON.stringify(allEquity));

component.set("v.showSpinner", false);
component.set("v.initLoad", true);
} else {
    console.log("Error: " + response.getError());
}
});

$A.enqueueAction(action);
},*/
    
    fetchOpeningBalanceAccountsTab2: function (component, event, helper) {
    var action = component.get("c.fetchOpeniBalanceCOA"); // Call the server method

    action.setParams({
        aggList: JSON.stringify(component.get("v.AggResult")),
        orgId: component.get('v.OrgId')
    });

    action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            // Get and push the response data into AggResult
            var aggregateResults = component.get("v.AggResult") || [];
            aggregateResults.push(response.getReturnValue());
            component.set("v.AggResult", aggregateResults);

            console.log('Full processingData:', JSON.stringify(aggregateResults));

            // Initialize a map to group data by fiscal year
            let fiscalYearMap = new Map();

            // Iterate through the aggregateResults and group by fiscal year (FY)
            aggregateResults.forEach(value => {
                value.forEach(result => {
                    let fiscalYear = result.FY;  // Extract the fiscal year from the result

                    if (!fiscalYearMap.has(fiscalYear)) {
                        fiscalYearMap.set(fiscalYear, { assets: [], liabilities: [], equity: [] });
                    }

                    // Sort the data based on AccountGroup (Assets, Liabilities, Equity)
                    if (result.AccountGroup === 'Assets') {
                        fiscalYearMap.get(fiscalYear).assets.push(result);
                    } else if (result.AccountGroup === 'Liability') {
                        fiscalYearMap.get(fiscalYear).liabilities.push(result);
                    } else if (result.AccountGroup === 'Equity') {
                        fiscalYearMap.get(fiscalYear).equity.push(result);
                    }
                });
            });

            // Prepare data for display based on fiscal year
            let fiscalYearData = [];
            fiscalYearMap.forEach((data, fiscalYear) => {
                fiscalYearData.push({
                    fiscalYear: fiscalYear,
                    assets: data.assets,
                    liabilities: data.liabilities,
                    equity: data.equity
                });

                console.log(`Fiscal Year: ${fiscalYear}, Assets: ${data.assets.length}, Liabilities: ${data.liabilities.length}, Equity: ${data.equity.length}`);
            });

            // Set the fiscal year-based data in the component
            component.set("v.FiscalYearData", fiscalYearData);

            component.set("v.showSpinner", false);
            component.set("v.initLoad", true);
        } else {
            console.log("Error: " + response.getError());
        }
    });

    $A.enqueueAction(action);
},



    fetchOpeningBalanceAccounts: function (component, event, helper) {
    var action = component.get("c.fetchOpeniBalanceCOA");
    action.setParams({
        aggList: JSON.stringify(component.get("v.AggResult")),
        orgId: component.get('v.OrgId')
    });
    action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            var aggregateResults = component.get("v.AggResult");
            aggregateResults.push(response.getReturnValue());
            component.set("v.AggResult", aggregateResults);
            console.log(JSON.stringify(aggregateResults));

            var aggregateResults = component.get("v.AggResult");
            console.log('Response processingData-->' + JSON.stringify(aggregateResults));

            let assetMap = new Map();
            let liabilityMap = new Map();
            let equityMap = new Map();

            let AssetSum = 0;
            let LiabilitySum = 0;
            let EquitySum = 0;

            aggregateResults.forEach(value => {
                value.forEach(result => {
                    if (result.AccountGroup === 'Assets' && result.AccountGroup != undefined) {
                        AssetSum = AssetSum + parseFloat(result.Debit) - parseFloat(result.Credit);
                        console.log('sub Group-->' + result.AccountId);

                        if (!assetMap.has(result.AccountId)) {
                            assetMap.set(result.AccountId, result);
                        } else if (assetMap.has(result.AccountId)) {
                            var rsl = assetMap.get(result.AccountId);
                            rsl.Credit = rsl.Credit + result.Credit;
                            rsl.Debit = rsl.Debit + result.Debit;
                            assetMap.set(result.AccountId, rsl);
                        }
                    }

                    if (result.AccountGroup === 'Liability' && result.AccountGroup != undefined) {
                        console.log('sub Group-->' + result.AccountId);
                        LiabilitySum = LiabilitySum + parseFloat(result.Credit) - parseFloat(result.Debit);
                        if (!liabilityMap.has(result.AccountId)) {
                            liabilityMap.set(result.AccountId, result);
                        } else if (liabilityMap.has(result.AccountId)) {
                            var rsl = liabilityMap.get(result.AccountId);
                            rsl.Credit = rsl.Credit + result.Credit;
                            rsl.Debit = rsl.Debit + result.Debit;
                            liabilityMap.set(result.AccountId, rsl);
                        }
                    }

                    if (result.AccountGroup === 'Equity' && result.AccountGroup != undefined) {
                        console.log('sub Group-->' + result.AccountId);
                        EquitySum = EquitySum + parseFloat(result.Credit) - parseFloat(result.Debit);
                        if (!equityMap.has(result.AccountId)) {
                            equityMap.set(result.AccountId, result);
                        } else if (equityMap.has(result.AccountId)) {
                            var rsl = equityMap.get(result.AccountId);
                            rsl.Credit = rsl.Credit + result.Credit;
                            rsl.Debit = rsl.Debit + result.Debit;
                            equityMap.set(result.AccountId, rsl);
                        }
                    }
                });
            });

            component.set("v.AssetSum", AssetSum);
            component.set("v.LiabilitySum", LiabilitySum);
            component.set("v.EquitySum", EquitySum);
			var calculatedEq = AssetSum-LiabilitySum;
            component.set("v.CalculatedEquity", calculatedEq);
            let assetNewMap = new Map();
            assetMap.forEach(result => {
                if (!assetNewMap.has(result.SubAccountGroup)) {
                    assetNewMap.set(result.SubAccountGroup, []);
                }
                assetNewMap.get(result.SubAccountGroup).push(result);
            });
            let assetArray = [];
            assetNewMap.forEach(function (value, key) {
                assetArray.push({ key: key, value: value });
            });
            component.set("v.AssetData", assetArray);
            console.log('assetMap Set' + JSON.stringify(component.get("v.AssetData")));

            let liabNewMap = new Map();
            liabilityMap.forEach(result => {
                if (!liabNewMap.has(result.SubAccountGroup)) {
                    liabNewMap.set(result.SubAccountGroup, []);
                }
                liabNewMap.get(result.SubAccountGroup).push(result);
            });
            let liabilityArray = [];
            liabNewMap.forEach(function (value, key) {
                liabilityArray.push({ key: key, value: value });
            });
            component.set("v.LiabilityData", liabilityArray);
			console.log('LiabilityData Set' + JSON.stringify(component.get("v.LiabilityData")));
            let equityNewMap = new Map();
            equityMap.forEach(result => {
                if (!equityNewMap.has(result.SubAccountGroup)) {
                    equityNewMap.set(result.SubAccountGroup, []);
                }
                equityNewMap.get(result.SubAccountGroup).push(result);
            });
            let equityArray = [];
            equityNewMap.forEach(function (value, key) {
                equityArray.push({ key: key, value: value });
            });
            component.set("v.EquityData", equityArray);
            console.log('equityMap Set' + JSON.stringify(component.get("v.EquityData")));
            component.set("v.showSpinner", false);
            component.set("v.initLoad", true);
            //$A.enqueueAction(component.get("c.processingData"));
        } else {
            console.log("Error:");// + response.getError()[0].message);
        }
    });
    $A.enqueueAction(action);
},

    fetchLedgerIdsDetails: function(component, event, helper) {
        alert('called fetchLedgerIdsDetails');
        var action = component.get("c.fetchNeLedgerIds");
        action.setParams({
            eDate: component.get('v.eDate'),
            orgId: component.get('v.OrgId'),
            LedgerIds: component.get('v.LedgerIds')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var ledgerIds = component.get("v.LedgerIds") || [];
                var newLedgerIds = response.getReturnValue() || [];
                
                // Combine the existing and new ledger IDs without duplicates
                ledgerIds.push(newLedgerIds);
                
                component.set("v.LedgerIds", ledgerIds);
            } else {
                console.error("Error: ");// + response.getError()[0].message);
            }
        });
        
        $A.enqueueAction(action);
    },
    
        processingData : function(component, event, helper){
            var aggregateResults = component.get("v.AggResult");
            console.log('Response processingData-->' + JSON.stringify(aggregateResults));
            let assetMap = new Map();
            let liabilityMap = new Map();
            let equityMap = new Map();
            
            let AssetSum = 0;
        	let LiabilitySum = 0;
            let EquitySum  =  0;
            alert('processingData');
            aggregateResults.forEach(value => {
                value.forEach(result => {
                if (result.AccountGroup === 'Assets' && result.AccountGroup!=undefined) {
                AssetSum = AssetSum + parseFloat(result.Credit) - parseFloat(result.Debit);
                console.log('sub Group-->' + result.AccountId);
                
                if (!assetMap.has(result.AccountId)) {
                	assetMap.set(result.AccountId, result);
            	}else if (assetMap.has(result.AccountId)) {
                	var rsl = assetMap.get(result.AccountId);
                	rsl.Credit = rsl.Credit + result.Credit;
                	rsl.Debit = rsl.Debit + result.Debit;
                	assetMap.set(result.AccountId, rsl);
            	}
            }
                
            if (result.AccountGroup === 'Liability' && result.AccountGroup!=undefined) {
                console.log('sub Group-->' + result.AccountId);
                LiabilitySum = LiabilitySum + parseFloat(result.Credit) - parseFloat(result.Debit);
                if (!liabilityMap.has(result.AccountId)) {
                liabilityMap.set(result.AccountId, result);
            }else if (liabilityMap.has(result.AccountId)) {
                var rsl = liabilityMap.get(result.AccountId);
                rsl.Credit = rsl.Credit + result.Credit;
                rsl.Debit = rsl.Debit + result.Debit;
                liabilityMap.set(result.AccountId, rsl);
            }
            }
                
                if (result.AccountGroup === 'Equity' && result.AccountGroup!=undefined) {
                console.log('sub Group-->' + result.AccountId);
                EquitySum = EquitySum + parseFloat(result.Credit) - parseFloat(result.Debit);
                if (!equityMap.has(result.AccountId)) {
                equityMap.set(result.AccountId, result);
            }else if (equityMap.has(result.AccountId)) {
                var rsl = equityMap.get(result.AccountId);
                rsl.Credit = rsl.Credit + result.Credit;
                rsl.Debit = rsl.Debit + result.Debit;
                equityMap.set(result.AccountId, rsl);
            }
            }
            });
            });
            component.set("v.AssetSum",  AssetSum);
            component.set("v.LiabilitySum",  LiabilitySum);
            component.set("v.EquitySum",  EquitySum);
            
            var calculatedEq = AssetSum-LiabilitySum;
            component.set("v.CalculatedEquity", calculatedEq);  
            let assetNewMap = new Map();
            assetMap.forEach(result => {
                if (!assetNewMap.has(result.SubAccountGroup)) {
                	assetNewMap.set(result.SubAccountGroup, []);
            	}
                	assetNewMap.get(result.SubAccountGroup).push(result);
            });
            let assetArray = [];
                assetNewMap.forEach(function(value, key) {
                assetArray.push({ key: key, value: value });
        	});
        	component.set("v.AssetData", assetArray);
        	console.log('assetMap Set' + JSON.stringify(component.get("v.AssetData")));
        	
    		let liabNewMap = new Map();
            liabilityMap.forEach(result => {
                if (!liabNewMap.has(result.SubAccountGroup)) {
                	liabNewMap.set(result.SubAccountGroup, []);
            	}
                	liabNewMap.get(result.SubAccountGroup).push(result);
            });
    		let liabilityArray = [];
    		liabNewMap.forEach(function(value, key) {
        		liabilityArray.push({ key: key, value: value });
    		});
			component.set("v.LiabilityData", liabilityArray);

			let equityNewMap = new Map();
            equityMap.forEach(result => {
                if (!equityNewMap.has(result.SubAccountGroup)) {
                	equityNewMap.set(result.SubAccountGroup, []);
            	}
                	equityNewMap.get(result.SubAccountGroup).push(result);
            });
			let equityArray = [];
    		equityNewMap.forEach(function(value, key) {
    			equityArray.push({ key: key, value: value });
			});
			component.set("v.EquityData", equityArray);
			console.log('equityMap Set' + JSON.stringify(component.get("v.EquityData")));
			component.set("v.showSpinner", false);
	}
})