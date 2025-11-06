({
    getTab:function(cmp, event, helper,showTabs){ 
        if(showTabs==undefined) showTabs=cmp.get("v.showTabs");   
        cmp.set("v.showTabs",showTabs);
        $A.util.removeClass(cmp.find("cusId"),'slds-is-active');
        $A.util.removeClass(cmp.find("invId"),'slds-is-active');
        $A.util.removeClass(cmp.find("payId"),'slds-is-active');     
        //$A.util.removeClass(cmp.find("creId").getElement(),'slds-is-active');
        //$A.util.removeClass(cmp.find("dunId").getElement(),'slds-is-active');
        //$A.util.removeClass(cmp.find("debId").getElement(),'slds-is-active');
        var val=showTabs;
        $A.util.addClass(cmp.find(val+'Id'),'slds-is-active');  
        //this.fetchRecords(cmp, event, helper);  
    },

    showToast : function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":"dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            //component.set("v.showMainSpin",false);
            toastEvent.fire();
        }
    },
    
    getDetails : function(component, event, helper) {
        component.set("v.showMmainSpin",true);
        var brId=component.get("v.Bank_Reconciliation_Id");
        if(brId!=null){
            var action=component.get("c.retrieveDetails");
            action.setParams({
                bankAccid:'',
                bReconcileId:component.get("v.Bank_Reconciliation_Id")
            });
            action.setCallback(this, function(res){
                if(res.getState()=='SUCCESS'){
                    try{
                        component.set("v.BankRecon_obj",res.getReturnValue().BankRecon_obj);
                        component.set("v.bankStmtlist",res.getReturnValue().bankStmtlist);
                        component.set("v.bankStmtlistDum",res.getReturnValue().bankStmtlist);
                        component.set("v.listitems",res.getReturnValue().OrganisationId);
                        var bankStmtlist=[]; bankStmtlist=component.get("v.bankStmtlist");
                        if(bankStmtlist.length>0) component.set("v.NoSlotsMessage",'');
                        component.set("v.showMmainSpin",false);
                        //this.getPagination(component, event, helper);
                        
                    }catch(ex){console.log('fetchTimeSlots  exception=>'+ex);}  
                    
                    
                }       
            });
            //this.getPagination(component, event, helper);
            $A.enqueueAction(action);
        }
        else {
            component.set("v.BankRecon_obj",null);
            component.set("v.bankStmtlist",null);
            component.set("v.bankStmtlistDum",null);
            component.set("v.showMmainSpin",false);
        }
        var stockTakeStatus = component.get("c.getTransactionStatus");
        stockTakeStatus.setCallback(this,function(response){
            //component.find("stStatus2").set("v.options", response.getReturnValue());
            component.set("v.stStatus2Options",response.getReturnValue());
        });
        $A.enqueueAction(stockTakeStatus);
        
        
        
    },
    getPagination : function(component, event, helper) { 
        //component.set("v.SearchString",''); 
        var counter=0;   
        var RecordList=[]; RecordList=component.get("v.bankStmtlistDum");
        var Entries=component.get("v.Entries");    
        var PageNumbers=(RecordList.length)/Entries;                         
        var PageNumbersArray = new Array(); 
        for(var i=0;i<PageNumbers; i++ ){         
            PageNumbersArray.push(i+1);          
        }
        if(PageNumbersArray.length==0) PageNumbersArray.push(1);
        component.set("v.pageNumbers",PageNumbersArray);
        
        if(PageNumbersArray.length==1) component.set("v.nextDisa",true); 
        else  component.set("v.nextDisa",false);     
        var RecordListNew=[]; 
        
        if(Entries<=RecordList.length){  counter=counter+Entries;  
                                       for(var i=0;i<Entries; i++) RecordListNew.push(RecordList[i]);
                                      }  
        else{ counter=RecordList.length; 
             for(var i=0;i<RecordList.length; i++) RecordListNew.push(RecordList[i]);
            }   
        component.set("v.counter",counter);
        component.set("v.bankStmtlist",RecordListNew);                                                   
        //if(RecordListNew.length==0 || RecordListNew==undefined || RecordListNew=='') component.set("v.criteriaMsg",'No Resource Found');
        //else component.set("v.criteriaMsg",''); 
        
        setTimeout(
            $A.getCallback(function() {
                if(component.find("PNIds")!=undefined)
                    if(component.find("PNIds")[0]!=undefined) $A.util.addClass(component.find("PNIds")[0].getElement(),"pageNumberClass");
                    else $A.util.addClass(component.find("PNIds").getElement(),"pageNumberClass");
            }), 1000
        );
        component.set("v.prevDisa",true);                                                                                                    
    },  
    
    
    /*CSV2JSON: function (component,csv) {
        
        //var array = [];
        var arr = []; 
        
        arr =  csv.split('\n');;
        
        arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};
            for(var j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
            }
            jsonObj.push(obj);
        }
        var json = JSON.stringify(jsonObj);
        return json;
        
        
    },*/
    
    CreateAccount : function (component,jsonstr){
        var action = component.get("c.insertData");
        alert('@@@ Server Action' + action);    
        action.setParams({
            "strfromlex" : jsonstr
        });
        /*action.setCallback(this, function(response) {
            var state = response.getState();
            alert(state);
            if (state === "SUCCESS") {  
            alert("Accounts Inserted Succesfully");            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                }
            }
        }); */
        window.setTimeout($A.getCallback(function(){
            helper.CreateAccount(component,result);
        }), 10);
        
        $A.enqueueAction(action);    
        
    },
    
    getDocument : function(component, event, helper) {
        var action=component.get("c.fetchDocuments");
        action.setParams({
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            // alert(state);
            if (state === "SUCCESS") {
                component.set("v.DocumentId",response.getReturnValue());
            }
        });
        $A.enqueueAction(action); 
        /*var stockTakeStatus2 = component.get("c.getTransactionType");
        stockTakeStatus2.setCallback(this,function(response){
            component.find("stStatus3").set("v.options", response.getReturnValue());     
        });
        $A.enqueueAction(stockTakeStatus2);*/
    },
    
    getTab2:function(cmp, event, helper,showTabs){ 
        if(showTabs==undefined) showTabs=cmp.get("v.showSubTabs");  
        cmp.set("v.showSubTabs",showTabs);
        $A.util.removeClass(cmp.find("cus2Id"),'slds-is-active');
        $A.util.removeClass(cmp.find("inv2Id"),'slds-is-active');
        $A.util.removeClass(cmp.find("pay2Id"),'slds-is-active');
        $A.util.removeClass(cmp.find("sel2Id"),'slds-is-active');
        var val=showTabs;
        $A.util.addClass(cmp.find(val+'Id'),'slds-is-active');  
    },
    
    CSV2JSON: function (component,csv) {
        //component.set("v.showMmainSpin",false);
        var action=component.get("c.importCSVFile");
        action.setParams({
            BankRecon_obj1:JSON.stringify(component.get("v.BankRecon_obj")),
            selectedBankAccount:component.get("v.BankRecon_obj.ERP7__Bank_Account__c"),
            csvAsString:csv
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                if(response.getReturnValue()==null) component.set("v.SaveErrorMsg",$A.get('$Label.c.Invalid_File_Data'));
                component.set("v.showMmainSpin",false);
                component.doInit();
                
               }
            else{
                component.set("v.NoSlotsMessage",$A.get('$Label.c.Please_Enter_the_valid_data'));
            }
        });
        $A.enqueueAction(action); 
    },
    
})