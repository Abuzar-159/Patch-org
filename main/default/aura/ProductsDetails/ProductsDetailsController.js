({
     FetchAttachmentBody:function(comp, event, helper){
        var MediaBody=event.getParam("Body");
        comp.set("v.MediaBody",MediaBody);
        comp.set("v.ParentId",event.getParam("ParentId"));  
        comp.set("v.FileName",event.getParam("FileName"));  
        comp.set("v.ContentType",event.getParam("ContentType"));
    },

	doInit : function(comp, event, helper) {
        comp.set("v.showMainSpin",true);
        var Clone=false; Clone=getQueryVariable("Clone");           
        function getQueryVariable(variable) {
            var query = window.location.search.substring(1);
            var vars = query.split("&");
            for (var i=0;i<vars.length;i++) {
                var pair = vars[i].split("=");
                if (pair[0] == variable) {
                    return pair[1];
                }
            }             
        }
        if(Clone==true) comp.set("v.showCancelButton",false); 
        comp.set("v.showCancelButton",true);
        
        if(Clone==undefined) comp.set("v.Clone",false); 
        else comp.set("v.Clone",Clone);  
        
        helper.fetchRecordList(comp, event, helper);
        helper.fetchPicklistValues(comp, event, helper);
        comp.set("v.CloneURL","/apex/ProductsDetails?id="+comp.get("v.VersionId")+"&Clone=true");
        
        if(Clone==true) comp.set("v.reRenderEventField",false);
        var id=getQueryVariable("id");           
        function getQueryVariable(variable) {
            var query = window.location.search.substring(1);
            var vars = query.split("&");
            for (var i=0;i<vars.length;i++) {
                var pair = vars[i].split("=");
                if (pair[0] == variable) {
                    return pair[1];
                }
            }             
        }
        if(!$A.util.isUndefined(id)) comp.set("v.isFromButton",true);  
    },
    
    getTab:function(comp, event, helper){
        var Tab=event.currentTarget.dataset.name;
        var TabIndex=event.currentTarget.dataset.service; 
        var TabElem=comp.find("TabId");  
        comp.set("v.Tab",event.currentTarget.dataset.name);
        
        for(var i=0; i<TabElem.length; i++){
            $A.util.removeClass(TabElem[i].getElement(),'active');
            if(i==TabIndex)  $A.util.addClass(TabElem[TabIndex].getElement(),'active');
        }  
        comp.set("v.showPopup",false);   comp.set("v.seBool",false); 
    },
    
    getRecord:function(comp, event, helper){
        comp.set("v.showPopup",true);   
        var action=event.currentTarget.dataset.name;
        var index=event.currentTarget.dataset.service; 
        comp.set("v.action",action);
        if(comp.get("v.Tab")=='med') {
            comp.set("v.attachId",event.target.id);   
            helper.AttachmentmentDetails(comp, event, helper, event.target.id);   
        }   
        helper.setRecord(comp, event, helper, comp.get("v.Tab"),event.currentTarget.dataset.service);        
    },
    
    showNewPopup:function(comp, event, helper){
        comp.set("v.Tab",event.currentTarget.dataset.name);  
        comp.set("v.showPopup",true);   comp.set("v.seBool",false); 
        comp.set("v.action",event.currentTarget.dataset.service);   
    },
    
    HideNewPopup:function(comp, event, helper){
        comp.set("v.showPopup",false);  comp.set("v.seBool",false); 
        helper.getInstances(comp, event, helper, comp.get("v.Tab"));
    },
    
    saveRecord:function(comp, event, helper){
        helper.saveRecord(comp, event, helper);  
    },
    
    getDelete:function(comp, event, helper){
        comp.set("v.action",event.currentTarget.dataset.name);    
        $A.util.removeClass(comp.find("deleteConfirmId").getElement(),'slds-hide');  
        comp.set("v.Index",event.currentTarget.dataset.service);
        helper.setRecord(comp, event, helper, comp.get("v.Tab"),event.currentTarget.dataset.service);
    },
    
    cancelDelete:function(comp, event, helper){
        $A.util.addClass(comp.find("deleteConfirmId").getElement(),'slds-hide');  
    },
    
    getNotificationHide:function(comp, event, helper){
        comp.set("v.SaveMsg",""); comp.set("v.seBool",false); 
    }, 
    
    createRecord : function(component,event,helper){
        component.set("v.Tab",event.currentTarget.dataset.name);         
        helper.createRecord(component,event,'ERP7__Routing__c'); 
    },
    
    handleSaveSuccess : function(cmp, event) {  
    },
    
    searchEventHandler : function(cmp,event,helper){
        var searchString = event.getParam("searchString").toString();
        if(searchString.length>1){
            if(cmp.get("v.Tab")=='med'){ 
                var MediaMap =[]; MediaMap=cmp.get("v.MediaMap");
                var MediaMap=[]; MediaMap=cmp.get("v.MediaMap");   
                var Medias=[]; var MediaList=[];  
                for(var i in MediaMap) {
                    var nameStr=MediaMap[i].value.Name;   
                    if(nameStr.toLowerCase().indexOf(searchString.toLowerCase()) != -1) {
                        Medias.push({
                            key:MediaMap[i].key,
                            value:MediaMap[i].value
                        }); 
                    }         
                }
                cmp.set("v.MediaMap",Medias);
            }else if(cmp.get("v.Tab")=='rou'){ 
                var RoutingList = cmp.get("v.RoutingList");
                RoutingList = RoutingList.filter(function (el) {
                    var cond1=false;   
                    if(el.ERP7__BOM_Version__c!=undefined){ 
                        el.ERP7__BOM_Version__r.Name=(el.ERP7__BOM_Version__r.Name).toString();                
                        cond1=el.ERP7__BOM_Version__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                    }
                    var cond2=false;   
                    if(el.ERP7__Process__c!=undefined){ 
                        el.ERP7__Process__r.Name=(el.ERP7__Process__r.Name).toString();                 
                        cond2=el.ERP7__Process__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;               
                    }   
                    return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1 || cond2);
                });
                cmp.set("v.RoutingList",RoutingList);
            }else if(cmp.get("v.Tab")=='bom'){ 
                var BOMList = cmp.get("v.BOMList");
                BOMList = BOMList.filter(function (el) {                        
                    var cond1=false;            
                    if(el.ERP7__Quantity__c!=undefined){ 
                        var Quantity=(el.ERP7__Quantity__c).toString();
                        cond1=Quantity.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                    } 
                    var cond2=false;            
                    if(el.ERP7__Type__c!=undefined){                             
                        cond2=el.ERP7__Type__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                    }
                    
                    return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1 || cond2);
                });
                cmp.set("v.BOMList",BOMList);
                
            }
        }else{
            cmp.set("v.MediaMap",cmp.get("v.MediaMapD")); 
            cmp.set("v.RoutingList",cmp.get("v.RoutingListD"));
            cmp.set("v.BOMList",cmp.get("v.BOMListD"));                              
        }
    },
    
    cancelRecord:function(comp, event, helper){  
        $A.createComponent(
            "c:ProductLifecycleManagement", {
                "ProductId":comp.get("v.ProductId"),
                "Tab":'ver'
            },
            function(newComp) {
                var content = comp.find("body");
                content.set("v.body", newComp);
            }
        ); 
    },
    
})