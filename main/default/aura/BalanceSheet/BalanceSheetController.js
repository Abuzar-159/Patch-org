({
    doinit : function(component, event, helper) {
        component.set("v.FYOptions", [
            {label: "This Fiscal Year", value: "THIS_FISCAL_YEAR"},
            {label: "Previous Fiscal Year", value: "LAST_FISCAL_YEAR AND ERP7__General_Ledger_Entry_DateTime__c <= THIS_FISCAL_YEAR"},
        ]);
		component.set("v.showSpinner", true);
        //helper.fetchAggregateResult(component, event, helper);
        var action = component.get("c.computeDataUpdated");
        action.setParams({
            eDate: component.get('v.eDate'),
            orgId: component.get('v.OrgId'),
            FiscalYear: component.get("v.FiscalYear"),
            lastId : component.get("v.lastId")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var aggregateResults = component.get("v.AggResult");
				
                if (component.get("v.eDate") == null || component.get("v.eDate") == undefined || component.get("v.eDate") == '') {
                    component.set("v.eDate", response.getReturnValue().eDate);
                }
                if (component.get("v.OrgId") == null || component.get("v.OrgId") == undefined || component.get("v.OrgId") == '') {
                    component.set("v.OrgId", response.getReturnValue().orgId);
                }

                if (response.getReturnValue().aggResult != null && response.getReturnValue().lastId!='' && response.getReturnValue().lastId!=null) {
                    aggregateResults.push(response.getReturnValue().aggResult);
                    component.set("v.AggResult", aggregateResults);
            		component.set("v.lastId", response.getReturnValue().lastId);
            		console.log(JSON.stringify(aggregateResults));
					$A.enqueueAction(component.get("c.doinit"));
                } else {
            		if(component.get('v.Tab')=='Tab1') helper.fetchOpeningBalanceAccounts(component, event, helper);
            		else helper.fetchOpeningBalanceAccountsTab2(component, event, helper);
            		//helper.processingData(component, event, helper);
                }
            } else {
                console.error("Error: " + response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);
    },
        
    onScriptsLoaded1: function(component, event, helper) {
        console.log('Script Loaded 1');
    },
        
    fetchDataUpdated : function(component, event, helper) {
        component.set("v.showSpinner", true);
        if(component.get("v.initLoad")){
            var aggregateResults =[];
            component.set("v.AggResult", aggregateResults);
            component.set("v.lastId", '');
            $A.enqueueAction(component.get("c.doinit"));
        }
    },
    
    fetchDetailscontroller : function(component, event, helper){
        if(component.get('v.stopRepeat')){
            helper.fetchData(component, event, helper);
        }
    },
    
    
    onOrgChange : function(component, event, helper) {
        var org = component.get('v.Instance.Select_Organisation.ERP7__Organisation__c');
        if(component.get('v.stopRepeat') &&  org != null && org != undefined && org != ''){
            helper.updateData(component, event, helper);
        }
    },
    
    FYChange : function(component, event, helper){
        var FY = component.get('v.Instance.SelectedFy_BS');
        if( component.get('v.stopRepeat') &&  FY != null && FY != undefined && FY != ''){
            helper.updateData(component, event, helper);           
        }
    },
    
    SDChange : function(component, event, helper){
        if( component.get('v.stopRepeat')){
            helper.updateData(component, event, helper); 
        } 
    },
    
    EDChange : function(component, event, helper){
        if( component.get('v.stopRepeat')){
            helper.updateData(component, event, helper); 
        } 
    },
    
    
    changeTab1 : function(component, event, helper){
        component.set('v.Tab', 'Tab1');
        component.set('v.Instance.SelectedCurrency',component.get('v.Instance.userIsoCode'));
        //component.find('FY').set('v.options', component.get('v.picklists'));
        component.set("v.FYOptions",component.get('v.picklists')); 
        var stockTakeStatus = component.get("c.getCurrencies");
        stockTakeStatus.setCallback(this,function(response){
            //component.find("stStatus").set("v.options", response.getReturnValue()); 
            component.set("v.stStatusOptions", response.getReturnValue());
        });
        $A.enqueueAction(stockTakeStatus);
        $A.enqueueAction(component.get("c.fetchDataUpdated"));
    },
    
    changeTab2 : function(component, event, helper){
        component.set('v.stopRepeat', false);
        component.set('v.showSpinner', true);
        component.set('v.callGraph',true);
        component.set('v.Tab','Tab2');
        $A.enqueueAction(component.get("c.fetchDataUpdated"));
    }, 
    
    changeData : function(component, event, helper){
        component.set('v.stopRepeat', false);
        component.set('v.showSpinner', true);
        var selType= event.currentTarget.getAttribute("name");
        switch(selType) {
            case 'Fyear'    :component.set('v.setView', 'Annually');
                break;
            case 'FQuarter' : component.set('v.setView', 'Quaterly');
                break;
            case 'FMonthly' :component.set('v.setView', 'Monthly');
                break;
        }
        component.set('v.Instance.YearorQuarter', selType); 
        var action = component.get('c.ComputeData');
        action.setParams({
            B:JSON.stringify(component.get('v.Instance'))
        });
        action.setCallback(this, function(response){
            var state = response.getState();    
            if( state === "SUCCESS"){
                component.set('v.Instance', response.getReturnValue());
                component.set('v.showSpinner', false);
                component.set('v.stopRepeat', true);
            }else{
                component.set('v.showSpinner', false);
            }
        });
        $A.enqueueAction(action);
    }, 
        
    exportToPDF : function(component, event, helper) {
        /*console.log('called');
        var doc = new jsPDF();
        console.log('called 2');
        doc.text("Fiscal Year Data Report", 10, 10);
        // Loop over FiscalYearData and append it to the PDF
        var fiscalYearData = component.get("v.FiscalYearData");
        var yOffset = 20;
        fiscalYearData.forEach(function(fyData, index) {
            doc.text("Fiscal Year: " + fyData.fiscalYear, 10, yOffset);
            yOffset += 10;
            doc.text("Assets", 10, yOffset);
            yOffset += 10;
            fyData.assets.forEach(function(asset) {
                doc.text(asset.AccountName + ": Debit: " + asset.Debit + ", Credit: " + asset.Credit, 10, yOffset);
                yOffset += 10;
            });
            doc.text("Liabilities", 10, yOffset);
            yOffset += 10;
            fyData.liabilities.forEach(function(liability) {
                doc.text(liability.AccountName + ": Debit: " + liability.Debit + ", Credit: " + liability.Credit, 10, yOffset);
                yOffset += 10;
            });
            doc.text("Equity", 10, yOffset);
            yOffset += 10;
            fyData.equity.forEach(function(equity) {
                doc.text(equity.AccountName + ": Debit: " + equity.Debit + ", Credit: " + equity.Credit, 10, yOffset);
                yOffset += 10;
            });
        });
        doc.save('FiscalYearData.pdf');*/
        console.log('called');
        try {
            var doc = new jsPDF();
            console.log('jsPDF object created:', doc);
            
            // Simple test with only basic PDF content
            doc.text("Test PDF Download", 10, 10);  // Simple text for testing
            doc.save('test.pdf');  // Trigger download
            console.log('PDF saved successfully');
        } catch (error) {
            console.error('Error creating or saving the PDF:', error);
        }
    },
        
        
        exportToExcel : function(component, event, helper) {
        var fiscalYearData = component.get("v.FiscalYearData");
        
        var worksheet_data = [];
        worksheet_data.push(["Fiscal Year", "Account Name", "Debit", "Credit"]);

        fiscalYearData.forEach(function(fyData) {
            fyData.assets.forEach(function(asset) {
                worksheet_data.push([fyData.fiscalYear, asset.AccountName, asset.Debit, asset.Credit]);
            });
            fyData.liabilities.forEach(function(liability) {
                worksheet_data.push([fyData.fiscalYear, liability.AccountName, liability.Debit, liability.Credit]);
            });
            fyData.equity.forEach(function(equity) {
                worksheet_data.push([fyData.fiscalYear, equity.AccountName, equity.Debit, equity.Credit]);
            });
        });

        var ws = XLSX.utils.aoa_to_sheet(worksheet_data);
        var wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Fiscal Year Data");

        XLSX.writeFile(wb, "FiscalYearData.xlsx");
    }
})