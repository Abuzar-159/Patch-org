({
    
    doInit : function(component, event, helper) {
        //component.set("v.AccId",event.getParam("AccId"));        
        helper.getContract(component,event);
    },
    
    getPO : function(component, event, helper){
        component.set("v.revert",false);
        $A.createComponent( "c:SupplierPortalPO", {
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
    getWO : function(component, event, helper){
        component.set("v.revert",false);
        $A.createComponent( "c:SupplierPortalWO", {
            "AccId":component.get("v.AccId"),               
        },
                           function(newCmp) {
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
        },
                           function(newCmp) {
                               if (component.isValid()) {
                                   var body = component.find("body");
                                   body.set("v.body", newCmp);        
                               }
                           }
                          );
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
    home :function(component, event, helper){
        
        component.set("v.revert",false);
        $A.createComponent("c:SupplierPortalCommHome",{
            AccId:component.get("v.AccId")
        },function(newCmp, status, errorMessage){
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },

    getSortedRecords : function(component,event,helper){
        component.set("v.sortVar",false);  
        component.set("v.OrderBy",event.currentTarget.id);
        if(component.get("v.Order")=='DESC') component.set("v.Order",'ASC'); 
        else if(component.get("v.Order")=='ASC') component.set("v.Order",'DESC');   
		helper.getContract(component,event);
    }, 
    
    searchUserRecord : function(cmp,event,helper){
        try{      
            cmp.set("v.NoSlotsMessage",'');
            var SearchString = cmp.get("v.SearchString");
            if(SearchString!='' && SearchString!=undefined){   
                SearchString=SearchString.toString();
                var bankStmtlist =[]; bankStmtlist=cmp.get("v.ContractListDup");
                bankStmtlist = bankStmtlist.filter(function (el) {    
                    return ((el.Name).toString().toLowerCase().indexOf(SearchString.toLowerCase()) != -1);
                });
                cmp.set("v.ContractList",bankStmtlist);  if(bankStmtlist.length<=0)  cmp.set("v.NoSlotsMessage",'No Data available');                     
            }else{  //cmp.set("v.TSList",cmp.get("v.TSListDup"));
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
        helper.getContract(cmp,event);
        
    },
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            helper.getContract(component,event);
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
            helper.getContract(component,event);
        }
    },
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            helper.getContract(component,event);}
    },
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            //alert(Offsetval);
            component.set("v.Offset", Offsetval);
            component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            helper.getContract(component,event);}
    },
    navigate: function(component, event, helper) {
        /*var sobjectId = event.target.dataset.record;
        var url='https://erp-mark7-community-developer-edition.eu14.force.com/SupplierPortal/s/detail/'+sobjectId;
        window.open(url,"_blank");*/
        // $A.get('e.force:refreshView').fire();
    },
    
    
    createContract : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contract",
      	 	//"navigationLocation": "RELATED_LIST"
        	"navigationLocation": "LOOKUP"
        });
        createRecordEvent.fire();
    },
    getRecord : function(component, event, helper){
        component.set("v.revert",false);
        var PageAPI=event.currentTarget.dataset.recordId;
        var RecId=event.currentTarget.dataset.record;
       $A.createComponent("c:SupplierFieldSet",{
            RecordId : RecId, AccId :component.get("v.AccId"), ObName :"Contracts", PageLayoutName : "Contract"
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