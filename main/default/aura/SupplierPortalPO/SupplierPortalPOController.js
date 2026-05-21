({
    
    doInit : function(component, event, helper) {
        if(event.getParam("viewHome")){
            component.set("v.revert",false);
            $A.createComponent("c:SupplierPortalCommHome",{
                AccId:component.get("v.AccId")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    body.set("v.body", newCmp);
                }
            });
            return;
        }
        //component.set("v.AccId",event.getParam("AccId"));
        /*component.set("v.showMmainSpin",true); 
		var action=component.get("c.getPOList");
        action.setParams({AccId:component.get("v.AccId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if( state === "SUCCESS" ){
                component.set("v.POList",response.getReturnValue());
                component.set("v.POListDup",response.getReturnValue());
                component.set("v.showMmainSpin",false); 
            }
        });
        $A.enqueueAction(action);*/
        helper.getpurchaseOrder(component,event);
        
    },
    getWO : function(component, event, helper){
        component.set("v.revert",false);
        $A.createComponent( "c:SupplierPortalWO", {
            "AccId":component.get("v.AccId"),               
        },function(newCmp) {
            if (component.isValid()) {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);        
            }
        });
        $A.enqueueAction(action);
    },
    getBills : function(component, event, helper){
        component.set("v.revert",false);
        $A.createComponent( "c:SupplierPortalBills", {
            "AccId":component.get("v.AccId"),               
        },function(newCmp) {
            if (component.isValid()) {
                var body = component.find("body");
                body.set("v.body", newCmp);        
            }
        });
    },
    getPayments : function(component, event, helper){
        component.set("v.revert",false);
        $A.createComponent( "c:SupplierPortalPayments", {
            "AccId":component.get("v.AccId"),               
        },
                           function(newCmp) {
                               if (component.isValid()) {
                                   var body = component.find("body");
                                   body.set("v.body", newCmp);        
                               }
                           }
                          );
    },
    getRFPs : function(component, event, helper){
        console.log('AccId ~>'+component.get("v.AccId"));
        $A.createComponent("c:SupplierRequests",{
            currentSupplier : component.get("v.AccId"),
            fromSite : true,
        },function(newCmp, status, errorMessage){
            if (component.isValid() && status === "SUCCESS") {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);
            }
            else{
                
            }
        });
    },
    home :function(component, event, helper){
        
        /*window.location.reload();
        var evt = $A.get("e.c:SupplierPortalCommEvent");
        evt.setParams({ viewHome: true});
        evt.fire();*/
        component.set("v.revert",false);
        //location.reload();
        $A.createComponent("c:SupplierPortalCommHome",{
            AccId:component.get("v.AccId")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
        
        
    },
    
    loadAllDetails : function(cmp, event, helper) {
        window.scrollTo(0, 0);
        $A.util.removeClass(cmp.find('mainSpin'), "slds-hide");
        var currentWCCP = cmp.get("v.PNSs");
        var Overveiw = cmp.get("v.Overview");
        if(Overveiw != undefined){
            var action = cmp.get("c.getAll");
            action.setParams({ currentWCCP : JSON.stringify(currentWCCP), IsNew : "false", Overview : Overveiw, Flow : "MO"});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    try { 
                        cmp.set("v.WCCP.Cols", response.getReturnValue().Cols);
                        cmp.set("v.WCCP.WCS", response.getReturnValue().WCS);
                        cmp.set("v.WCCP.RGS", response.getReturnValue().RGS);
                        cmp.set("v.WCCP.RSS", response.getReturnValue().RSS);
                        cmp.set("v.WCCP.WorkPlanners", response.getReturnValue().WorkPlanners);
                        cmp.set("v.WCCP.ResourceRequirements", response.getReturnValue().ResourceRequirements);
                        cmp.set("v.exceptionError", response.getReturnValue().errMsg);
                        cmp.set("v.FilterShow", false);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                        
                    } catch(err) {
                        cmp.set("v.exceptionError", err.message);
                        //alert("Exception : "+err.message);
                        $A.util.addClass(cmp.find('mainSpin'), "slds-hide");
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    FilterSet : function (component, event) {
        cmp.set("v.FilterShow", !component.get("v.FilterShow"));
    },
    
    getSortedRecords : function(component,event,helper){
      /*  component.set("v.OrderBy",event.currentTarget.id);
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');          
        //var currentTab = component.get("v.selectedTab"); 
        helper.getpurchaseOrder(component,event); */
        component.set("v.sortVar",false);  
        component.set("v.OrderBy",event.currentTarget.id);
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');   
		helper.getpurchaseOrder(component,event);
    }, 
    
    handlemenu : function(component,event,helper){
        var operation = event.detail.menuItem.get("v.label");
        if(operation == "Create Bill"){
            helper.createBill_PO(component,event,helper,event.detail.menuItem.get("v.value"));   
        }else{
        }
    },
    
    createBill_PO : function(component,event,helper){ 
        component.set("v.revert",false);
        var obj = {'ERP7__Amount__c':0.00,'ERP7__Discount_Amount__c':0.00,'ERP7__VAT_TAX_Amount__c':0.00};
        if(!$A.util.isUndefined(event.target.dataset.record))
            //obj['ERP7__Purchase_Order__r'] = {'Id':event.target.dataset.record,'Name':event.target.dataset.name};
        $A.createComponent("c:CreateBill",{
            "showExpenseAccount":false,
            "aura:id": "mBill",
            "Bill": obj,
            "navigateToRecord":false,
            "cancelclick":component.getReference("c.backTO"),
            "saveclick":component.getReference("c.saveBill")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                newCmp.set('v.Bill.ERP7__Purchase_Order__c',event.target.dataset.record);
                //newCmp.set('v.Bill.ERP7__Organisation__c',component.get("v.Organisation.Id"));
                body.set("v.body", newCmp);
            }
        });   
    },
    
    backTO : function(component,event,helper){
        $A.createComponent("c:SupplierPortalPO",{
            "AccId":component.get("v.AccId"),  
            "aura:id": "SupplierPortalPO",
            "selectedTab":component.get("v.selectedTab")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        }); 
    },
    
    saveBill : function(component,event,helper){
        try{
            var cmp = ($A.util.isUndefined(component.find("mBill").length))?component.find("mBill"):component.find("mBill")[0]
            cmp.BillSave(function(response){
                $A.createComponent("c:SupplierPortalPO",{
                    "AccId":component.get("v.AccId"),  
                    "aura:id": "SupplierPortalPO",
                    "selectedTab":component.get("v.selectedTab")
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") { 
                        
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                        component.set("v.showMmainSpin",false); 
                    }
                }); 
            }); 
        }catch(ex){console.log('saveBill catch exception=>'+ex);}    
    },
    
    DownloadPdf: function (component, event, helper) {
        var recordId = event.target.dataset.record;
        var url=$A.get("$Label.c.CommunityURL");
        var url='/SupplierPortal/PurchaseOrderCommunityPdf?Id='+recordId;
        //var url = $A.get("$Label.c.CommunityURL");
        //var url ='/SupplierPortal/PurchaseOrderPDFCommunity?id='+recordId;
        window.open(url,"_blank");
    },
    
    DownloadPdfList: function (component, event, helper) {
        // var url = '/apex/purchaseordertravellerpdf?';
        //var url = '{!$Label.c.URL}';
        var pos=component.get("v.POList");
        var selectedPOS=[];
        for(var x in pos){
            if(pos[x].selected){
                selectedPOS.push(pos[x].PO);
            }
        }
        var pos1=JSON.stringify(selectedPOS);
        
        var url=$A.get("$Label.c.URL");
        url=url+'?Id='+component.get("v.AccId");
        url=url+'&pos='+pos1;
        window.open(url,"_blank");
    },
    
    searchUserRecord : function(component,event,helper){
        try{      
            component.set("v.NoSlotsMessage",'');
            var SearchString = component.get("v.SearchString");
            if(SearchString!='' && SearchString!=undefined){   
                SearchString=SearchString.toString();
                var bankStmtlist =[]; bankStmtlist=component.get("v.POListDup");
                bankStmtlist = bankStmtlist.filter(function (el) {    
                    return ((el.Name).toString().toLowerCase().indexOf(SearchString.toLowerCase()) != -1);
                });
                component.set("v.POList",bankStmtlist);  if(bankStmtlist.length<=0)  component.set("v.NoSlotsMessage",'No Data available');                     
            }else{  //cmp.set("v.POList",cmp.get("v.POListDup"));
                component.doInit();
            }
            
        }catch(ex){
            console.log('searchUser exception=>'+ex);
        }    
    }, 
    
    setShow : function(component,event,helper){
        component.set("v.startCount", 0);
        component.set("v.endCount", 0);
        component.set("v.Offset", 0);
        component.set("v.PageNum", 1);
        helper.getpurchaseOrder(component,event);
        
    },
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            helper.getpurchaseOrder(component,event);
        }
    },
    NextLast : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.endCount") != component.get("v.recSize")){ 
            var Offsetval = (component.get("v.PNS").length-1)*show;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            var currentTab = component.get("v.selectedTab"); 
            helper.getpurchaseOrder(component,event);
        }
    },
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            helper.getpurchaseOrder(component,event);}
    },
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.getpurchaseOrder(component,event);}
    },
    navigate: function(component, event, helper) {
        /*var sobjectId = event.target.dataset.record;
        var url='https://erp-mark7-community-developer-edition.eu14.force.com/SupplierPortal/s/detail/'+sobjectId;
         window.open(url,"_blank");
        $A.get('e.force:refreshView').fire();
        var sobjectId = event.target.dataset.record;
        //if (sobjectId.indexOf("500") >-1) { //Note 500 is prefix for Case Record
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/detail/'+sobjectId,
            "isredirect" :false
        });
        urlEvent.fire();
        $A.get('e.force:refreshView').fire();
        window.location.reload();*/
        
    },
    getRecord : function(component, event, helper){
        /* component.set("v.showData",false);
        component.set("v.RecordId",event.currentTarget.dataset.recordId);
         helper.getFieldsSetApiNameHandler(component,'ERP7__PO__c','ERP7__Purchase_Order_Field_Set'); */
        
        var RecId=event.currentTarget.dataset.recordId;
        var PageAPI=event.currentTarget.dataset.record;
        
       $A.createComponent("c:SupplierFieldSet",{
            RecordId : RecId, PageLayoutName : PageAPI, AccId :component.get("v.AccId"), ObName : "Purchase Orders"
        },function(newCmp, status, errorMessage){
            if (component.isValid() && status === "SUCCESS") {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);
            }
            else{
                
            }
        });   
    },
    
    submit:function(component, event, helper){
        component.find("recordViewForm").submit();
    },
    handleSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        component.set("v.recordId",payload.id);
    },
    setDefaultValues : function(component, event, helper) {
        var obj = component.get("v.defaultValues");
        if(!$A.util.isUndefinedOrNull(obj)){
            var renderedFields = component.find("input_field");
            for(var  x in renderedFields)
                if(obj.hasOwnProperty(renderedFields[x].get('v.fieldName')))
                    renderedFields[x].set("v.value",obj[renderedFields[x].get('v.fieldName')]); 
        }     
    },
    
    GoBack : function(component, event, helper){
        history.back();
    }
})