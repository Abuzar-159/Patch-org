({
    doInit : function(component, event, helper) {
        //component.set("v.AccId",event.getParam("AccId"));
        
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
        helper.getBills(component,event);
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
        component.set("v.revert",false);
        
        $A.createComponent("c:SupplierRequests",{
            currentSupplier : component.get("v.AccId")
        },function(newCmp, status, errorMessage){
            if (component.isValid() && status === "SUCCESS") {
                var body = component.find("sldshide");
                body.set("v.body", newCmp);
            }
            else{
                
            }
        });
    },
    getExpenses : function(component, event, helper){
        component.set("v.revert",false);
        
        $A.createComponent( "c:SupplierPortalExpense", {
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
    getTimesheets : function(component, event, helper){
        component.set("v.revert",false);
        
        $A.createComponent( "c:SupplierPortalTimesheets", {
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
    
    home :function(component, event, helper){
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
    
    createBill_PO : function(component,event,helper){ 
        console.log('createBill_PO called');
        component.set("v.revert",false);
        var obj = {'ERP7__Amount__c':0.00,'ERP7__Discount_Amount__c':0.00,'ERP7__VAT_TAX_Amount__c':0.00};
        if(!$A.util.isUndefined(event.target.dataset.record)){
            console.log(' here 1');
            //obj['ERP7__Purchase_Order__r'] = {'Id':event.target.dataset.record,'Name':event.target.dataset.name};
            $A.createComponent("c:CreateBill",{
                "showExpenseAccount":false,
                "aura:id": "mBill",
                "Bill": obj,
                "supplier" : true,
                "AccId" : component.get("v.AccId"),
                "navigateToRecord":false,
                "cancelclick":component.getReference("c.backTO"),
                "saveclick":component.getReference("c.saveBill")
            },function(newCmp, status, errorMessage){
                if (status === "SUCCESS") {
                    var body = component.find("body");
                    newCmp.set('v.Bill.ERP7__Purchase_Order__c',event.target.dataset.record);
                    //newCmp.set('v.Bill.ERP7__Organisation__c',component.get("v.Organisation.Id"));
                    body.set("v.body", newCmp);
                }else{
                    console.log('error~>'+errorMessage);
                }
            });   
        }else console.log(' here 2');
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
    },
    
    backTO : function(component,event,helper){
        $A.createComponent("c:SupplierPortalBills",{
            "AccId":component.get("v.AccId"),  
            "aura:id": "SupplierPortalBills",
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
                $A.createComponent("c:SupplierPortalBills",{
                    "AccId":component.get("v.AccId"),  
                    "aura:id": "SupplierPortalBills",
                    "selectedTab":component.get("v.selectedTab")
                },function(newCmp, status, errorMessage){
                    if (status === "SUCCESS") { 
                        
                        var body = component.find("body");
                        body.set("v.body", newCmp);
                        component.set("v.showMmainSpin",false); 
                    }
                }); 
            }); 
        }catch(ex){console.log('saveBill catch enter ex=>'+ex);}    
    },
    
    getSortedRecords : function(component,event,helper){
        component.set("v.sortVar",false);  
        component.set("v.OrderBy",event.currentTarget.id);
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');   
        helper.getBills(component,event);
    }, 
    
    selectAllBills : function(component, event, helper) {
        var allbbox = component.find("cbox_bill");
        if(allbbox.length>0){
            for(var x in allbbox)
                allbbox[x].set("v.value",event.getSource().get("v.value"));
        }else
            allbbox.set("v.value",event.getSource().get("v.value"));
        var selectedBillList = component.get("v.SelectedBills");
        var billList = component.get("v.Bills");
        if(event.getSource().get("v.value")){
            for(var x =0;x < billList.length;x++)
                selectedBillList.push(billList[x]);
        } else{
            selectedBillList = [];
        }
        component.set("v.SelectedBills",selectedBillList);
    },
    
    searchUserRecord : function(cmp,event,helper){
        try{      
            cmp.set("v.NoSlotsMessage",'');
            var SearchString = cmp.get("v.SearchString");
            if(SearchString!='' && SearchString!=undefined){   
                SearchString=SearchString.toString();
                var bankStmtlist =[]; bankStmtlist=cmp.get("v.Bills");
                
                bankStmtlist = bankStmtlist.filter(function (el) {    
                    return ((el.Name).toString().toLowerCase().indexOf(SearchString.toLowerCase()) != -1);
                });
                cmp.set("v.Bills",bankStmtlist);  if(bankStmtlist.length<=0)  cmp.set("v.NoSlotsMessage",'No Data available');                     
            }else{  //cmp.set("v.POList",cmp.get("v.POListDup"));
                cmp.doInit();
            }
            
        }catch(ex){
            console.log('searchUser exception=>'+ex);
        }    
    }, 
    
    setShow : function(cmp,event,helper){
        
        cmp.set("v.startCount", 0);
        cmp.set("v.endCount", 0);
        cmp.set("v.Offset", 0);
        cmp.set("v.PageNum", 1);
        helper.getBills(cmp,event);
        
    },
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            helper.getBills(component,event);
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
            helper.getBills(component,event);
        }
    },
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            helper.getBills(component,event);}
    },
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.getBills(component,event);}
    }, 
    
    navigate: function(component, event, helper) {
        /*var sobjectId = event.target.dataset.record;
        var url='https://erp-mark7-community-developer-edition.eu14.force.com/SupplierPortal/s/detail/'+sobjectId;
        window.open(url,"_blank");*/
    }, 
    
    getRecord : function(component, event, helper){
        component.set("v.revert",false);
        var PageAPI=event.currentTarget.dataset.recordId;
        var RecId=event.currentTarget.dataset.record;
        
        $A.createComponent("c:SupplierFieldSet",{
            RecordId : RecId, AccId :component.get("v.AccId"), ObName : "Bills", PageLayoutName : "ERP7__Bill__c"
        },function(newCmp, status, errorMessage){
            if (component.isValid() && status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
            else{
                
            }
        }); 
    }
})