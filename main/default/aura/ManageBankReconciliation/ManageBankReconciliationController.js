({
    
    newRecord : function(cmp, event, helper) {
        cmp.set("v.NoSlotsMessage",'');
        cmp.set("v.BankRecon_obj2.Name",'');
        cmp.set("v.BankRecon_obj2.ERP7__Start_Date__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__End_Date__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__Organisation__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__Bank_Account__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__Beginning_Balance__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__Ending_Balance__c",'');
        cmp.set("v.showNewPopup",true);
        var ReconciliationStatus2 = cmp.get("c.getBankReconciliationStatus");
        ReconciliationStatus2.setCallback(this,function(response){
            //cmp.find("stStatus2").set("v.options", response.getReturnValue());
            cmp.set("v.stStatus2Options",response.getReturnValue());
            var stStatus2Options = [];
            if(cmp.get("v.stStatus2Options") != undefined && cmp.get("v.stStatus2Options") != null && cmp.get("v.stStatus2Options").length > 0){
                stStatus2Options = cmp.get("v.stStatus2Options");
            }
            
            if(stStatus2Options.length > 0){
                cmp.set("v.BankRecon_obj2.ERP7__Status__c",stStatus2Options[0].value)
            }
        });
        $A.enqueueAction(ReconciliationStatus2);
    },
    
    editRecord : function(cmp, event, helper) {
        cmp.set("v.ItemToEdit",event.getSource().get("v.name"));
        var selectedId = cmp.get("v.ItemToEdit");
        var action = cmp.get("c.getReconciliationTakeRec");
        action.setParams({brId:selectedId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.showEditPopup",true);
                cmp.set("v.BankRecon_obj",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        var ReconciliationStatus = cmp.get("c.getBankReconciliationStatus");
        ReconciliationStatus.setCallback(this,function(response){
            //cmp.find("stStatus").set("v.options", response.getReturnValue());    
            cmp.set("v.stStatusOptions",response.getReturnValue());
        });
        $A.enqueueAction(ReconciliationStatus);
    },
    
    doInit : function(cmp, event, helper) {
        //cmp.set("v.showMmainSpin",true);
        var show =cmp.get("v.show");
        if(show >50)show=50;
        cmp.set("v.show",show);
        var action = cmp.get("c.getDefaultOrganisation");	
        action.setCallback(this,function(response){
            if(response.getState()==='SUCCESS'){
                if(cmp.get("v.fetchRecordsBool")==true) {
                    cmp.set("v.OrganisationId",response.getReturnValue().Id);
                    cmp.set("v.showMmainSpin",false);
                }else{
                    helper.fetchReconciliation(cmp, event);
                }
            }  
        });
        $A.enqueueAction(action);  
    },
    
    onClick:function(component, event, helper) {
        component.set("v.SaveErrorMsg",'');
        component.set("v.SaveErrorMsg2",'');
        component.set("v.SaveErrorMsg3",'');
    },
    
    getOrganisedRecords : function(cmp, event, helper){
        helper.fetchReconciliation(cmp, event);
    },
    
    searchUserRecord : function(cmp,event,helper){
        try{      
            cmp.set("v.NoSlotsMessage",'');
            var SearchString = cmp.get("v.SearchString");
            if(SearchString!='' && SearchString!=undefined){   
                SearchString=SearchString.toString();
                var bankStmtlist =[]; bankStmtlist=cmp.get("v.BRListDum");
                bankStmtlist = bankStmtlist.filter(function (el) {    
                    return ((el.Name).toString().toLowerCase().indexOf(SearchString.toLowerCase()) != -1);
                });
                cmp.set("v.BRList",bankStmtlist);  if(bankStmtlist.length<=0)  cmp.set("v.NoSlotsMessage",'No Data available');                     
            }else{  cmp.set("v.BRList",cmp.get("v.BRListDum"));
                 }
            
        }catch(ex){
            console.log('searchUser exception=>'+ex);
        }    
    }, 
    
    callToBankReconciliation : function (component, event) {
        var selectedId = event.currentTarget.getAttribute('id');
        $A.createComponent("c:BankReconciliation", {
            "Bank_Reconciliation_Id":selectedId,
            "OrganisationId":component.get("v.OrganisationId"),
            FromSP:true
        }, function(newCmp) {
            if (component.isValid()) {
                var body = component.find("body");
                body.set("v.body", newCmp);
            } 
        });
    },  
    
    searchUser : function(component,event,helper){
        try{  
            var searchString = event.getParam("searchString").toString();
            if(searchString!='' && searchString.length>0){                     
                var UserList =[];
                UserList=component.get("v.BRListDum");
                UserList = UserList.filter(function (el) {
                    return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
                });
                component.set("v.BRList",UserList);            
            }    
            else component.set("v.BRList",component.get("v.BRListDum"));
        }catch(ex){console.log('searchUser exception=>'+ex);}      
    },
    
    CancelDelete :function(cmp, event, helper) {
        cmp.set("v.ItemTOdelete",'');
        cmp.set("v.showPOPUp",false);
        //cmp.set("v.BankRecon_obj2",'');
    },
    
    CancelDelete2 :function(cmp, event, helper) {
        cmp.set("v.ItemTOdelete",'');
        cmp.set("v.showNewPopup",false);
        //cmp.set("v.BankRecon_obj2",null);
        cmp.set("v.BankRecon_obj2.Name",'');
        cmp.set("v.BankRecon_obj2.ERP7__Start_Date__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__End_Date__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__Organisation__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__Bank_Account__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__Beginning_Balance__c",'');
        cmp.set("v.BankRecon_obj2.ERP7__Ending_Balance__c",'');
    },
    
    removeItem : function(cmp, event) {
        cmp.set("v.ItemTOdelete",event.getSource().get("v.name"));
        cmp.set("v.showPOPUp",true);
    },
    
    DeleteRecordById : function(cmp, event, helper){
        var action = cmp.get("c.deleteReconciliation");
        action.setParams({"brId":cmp.get("v.ItemTOdelete")});
        action.setCallback(this,function(response){
            var state= response.getState();
            if(state ==='SUCCESS'){
                if(response.getReturnValue() != ''){
                    cmp.set("v.exceptionError",response.getReturnValue());
                } else{
                    cmp.set("v.ItemTOdelete",'');
                    cmp.set("v.showPOPUp", false);
                    //this.showToast('Success!','success','Bank Reconciliation was deleted Successfully');
                    helper.showToast('Success!','success','Successfully Deleted Record');
                    //cmp.set("v.SaveErrorMsg2",'Successfully Deleted Record');//SaveErrorMsg
                   // cmp.doInit();
                   helper.fetchReconciliation(cmp, event);//added by asra
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    CancelEdit :function(cmp, event, helper) {
        cmp.set("v.ItemToEdit",'');
        cmp.set("v.showEditPopup",false);
    },
    
    saveEditBankRecon_obj :function(cmp, event, helper) {
        if(cmp.get("v.BankRecon_obj.Name")=="") cmp.set("v.SaveErrorMsg3",'Please Enter the Name');
        else if(cmp.get("v.BankRecon_obj.ERP7__Start_Date__c")=="") cmp.set("v.SaveErrorMsg3",'Please Enter the Start Date');
            else if(cmp.get("v.BankRecon_obj.ERP7__End_Date__c")=="") cmp.set("v.SaveErrorMsg3",'Please Enter the End Date');
                else if (cmp.get("v.BankRecon_obj.ERP7__Start_Date__c")>cmp.get("v.BankRecon_obj.ERP7__End_Date__c")) cmp.set("v.SaveErrorMsg3",'End Date should be greater then Start Date');
                    else{
                        cmp.set("v.showMmainSpin",true);
                        var action = cmp.get("c.updateBankReconciliation");
                        action.setParams({"BRRec":JSON.stringify(cmp.get("v.BankRecon_obj"))});
                        action.setCallback(this,function(response){
                            var state= response.getState();
                            if(state ==='SUCCESS'){
                                if(response.getReturnValue() != ''){
                                    cmp.set("v.exceptionError",response.getReturnValue());
                                } else{
                                    cmp.set("v.ItemToEdit",'');
                                    cmp.set("v.showEditPopup",false);
                                    cmp.set("v.showMmainSpin",false);
                                    //cmp.set("v.exceptionError",'Updated Successfully');
                                   // cmp.set("v.SaveErrorMsg2",'Successfully Updated Record');
                                    helper.showToast('Success!','success','Successfully Updated Record');
                                    //cmp.doInit();
                                    helper.fetchReconciliation(cmp, event);//added by asra
                                    
                                }
                            }
                        });
                        $A.enqueueAction(action);
                    }
    },
    
    closeError : function(cmp,event, helper){
        cmp.set("v.exceptionError",'');
        cmp.set("v.showNewPopup",false);
    },
    
    saveNewBankRecon_obj :function(cmp, event, helper) {
        if(cmp.get("v.BankRecon_obj2.Name")=="") cmp.set("v.SaveErrorMsg3",'Please Enter the Name');
        else if(cmp.get("v.BankRecon_obj2.ERP7__Start_Date__c")=="") cmp.set("v.SaveErrorMsg3",'Please Enter the Start Date');
            else if(cmp.get("v.BankRecon_obj2.ERP7__End_Date__c")=="") cmp.set("v.SaveErrorMsg3",'Please Enter the End Date');
                else if(cmp.get("v.BankRecon_obj2.ERP7__Start_Date__c")>cmp.get("v.BankRecon_obj2.ERP7__End_Date__c")) cmp.set("v.SaveErrorMsg3",'End Date should be greater then Start Date');
        //else if(cmp.get("v.BankRecon_obj.ERP7__Organisation__c")==null) cmp.set("v.SaveErrorMsg3",'Please select the Organisation');
        //else if(cmp.get("v.BankRecon_obj.ERP7__Bank_Account__c")==null) cmp.set("v.SaveErrorMsg3",'Please select the Bank Account');
                    else{
                        
                        cmp.set("v.showMmainSpin",true);
                        var action = cmp.get("c.updateBankReconciliation");
                        action.setParams({"BRRec":JSON.stringify(cmp.get("v.BankRecon_obj2"))});
                        action.setCallback(this,function(response){
                            var state= response.getState();
                            if(state ==='SUCCESS'){
                                console.log('response.getReturnValue()'+response.getReturnValue());
                                if(response.getReturnValue() != ''){
                                    cmp.set("v.exceptionError",'Please Enter the Valid Amount');
                                } else{
                                    cmp.set("v.showNewPopup",false);
                                    cmp.set("v.showMmainSpin",false);
                                    
                                    helper.showToast('Success!','success','Record Created Successfully');
                                    //cmp.set("v.BankRecon_obj2",null);
                                    //cmp.set("v.SaveErrorMsg2",'Successfully Created Record');
                                    //cmp.doInit();
                                    helper.fetchReconciliation(cmp, event);//added by asra
                                }
                            }
                        });
                        $A.enqueueAction(action);
                        
                    }
    },
    
    setShow : function(cmp,event,helper){
        cmp.set("v.startCount", 0);
        cmp.set("v.endCount", 0);
        cmp.set("v.Offset", 0);
        cmp.set("v.PageNum", 1);
        helper.fetchReconciliation(cmp, event);
        
    },
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            helper.fetchReconciliation(component, event);
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
            helper.fetchReconciliation(component, event);
        }
    },
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            helper.fetchReconciliation(component, event);}
    },
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.fetchReconciliation(component, event);}
    },
    
    yodleeCalled : function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:YodleeTransaction",
            componentAttributes: {
            }
        });
        evt.fire();
    },
    
    navigateToClosingComponent : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ManageClosingOfBooksCheckList",
            componentAttributes: {
                AP:component.get("v.AccoutingPeriod"),
                OrgId :component.get("v.COBOrgId")
            }
        });
        evt.fire();
    },
})