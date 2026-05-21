({
    FetchAttachmentBody:function(comp, event, helper){
        var MediaBody=event.getParam("Body");
        comp.set("v.MediaBody",MediaBody);
        comp.set("v.ParentId",event.getParam("ParentId"));  
        comp.set("v.FileName",event.getParam("FileName"));  
        comp.set("v.ContentType",event.getParam("ContentType"));  
    },
    
    doInit : function(comp, event, helper) {
        // var doInitExecute=comp.get("v.doInitExecute"); 
       
        comp.set("v.showMainSpin",true);
        
        var Clone = false;
        Clone = getQueryVariable("Clone");           
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
        if(Clone==true) {
            comp.set("v.showCancelButton",false); 
            comp.set("v.disabled",true);
        }
        comp.set("v.showCancelButton",true);
        
        if(Clone==undefined) comp.set("v.Clone",false); 
        else comp.set("v.Clone",Clone); 
        
        helper.fetchPicklistValues(comp, event, helper);
        helper.fetchRecordList(comp, event, helper);
        comp.set("v.CloneURL","/apex/ERP7__ProductLifecycleManagement?id="+comp.get("v.ProductId")+"&Clone=true"+"&disabled=true");
        if(Clone==true) comp.set("v.reRenderEventField",false);
        var id=getQueryVariableFuction("id");           
        function getQueryVariableFuction(variable) {
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
    
    gotoClone:function(comp,event,helper){
        //var cUrl = comp.get("v.CloneURL");
        var myWindow = window.open(comp.get("v.CloneURL"), "_self");
    },
    
    backToProductDetail:function(comp, event, helper){ 
    	if(comp.get("v.disabled")){
        	window.history.go(-2); 
        }else {
        	history.back();
        }
    },
    
    getTab:function(comp, event, helper){
        if(comp.get("v.disabled") && ( comp.get("v.Clone") || comp.get("v.Clone")==undefined) ){
            
        }else{  
            var Tab=event.currentTarget.dataset.name;
            var TabIndex=event.currentTarget.dataset.service; 
            var TabElem=comp.find("TabId");  
            comp.set("v.Tab",event.currentTarget.dataset.name);
            
            for(var i=0; i<TabElem.length; i++){
                $A.util.removeClass(TabElem[i].getElement(),'active');
                if(i==TabIndex)  $A.util.addClass(TabElem[TabIndex].getElement(),'active');
            }  
            comp.set("v.showPopup",false);   comp.set("v.seBool",false); 
        }
    },
    getRecord:function(comp, event, helper){
        if(comp.get("v.Tab")!='ver' && comp.get("v.Tab")!='rou') { 
            
            comp.set("v.showPopup",true);   
            var action=event.currentTarget.dataset.name;
            var index=event.currentTarget.dataset.service; 
            comp.set("v.action",action);  
            helper.setRecord(comp, event, helper, comp.get("v.Tab"),event.currentTarget.dataset.service);
        }
        if(comp.get("v.Tab")=='med') {
            
            comp.set("v.attachId",event.target.id);   helper.AttachmentmentDetails(comp, event, helper, event.target.id);   
        }                               
        
        if(comp.get("v.Tab")=='ver') {
            
            $A.createComponent(
                "c:ProductsDetails", {
                    "VersionId":event.target.id,
                    "ProductId":comp.get("v.Product.Id")
                },
                function(newComp) {
                    var content = comp.find("body");
                    content.set("v.body", newComp);
                }
            );                
                                     } 
        else   if(comp.get("v.Tab")=='rou') {  
            $A.createComponent(
                "c:RoutingDetails", {
                    "RoutingId":event.target.id,
                    "ProductId":comp.get("v.Product.Id")               
                },
                function(newComp) {
                    var content = comp.find("body");
                    content.set("v.body", newComp);
                }
            );                
        }  
        
    },
    
    
    
    showNewPopup:function(comp, event, helper){
        comp.set("v.Tab",event.currentTarget.dataset.name);       
        comp.set("v.seBool",false); 
        comp.set("v.action",event.currentTarget.dataset.service);  
        comp.set("v.fileNameVal",'');
        
        if(event.currentTarget.dataset.name=='ver') {
            $A.createComponent(
                "c:ProductsDetails", {
                    "VersionId":'',
                    "ProductId":comp.get("v.Product.Id")
                },
                function(newComp) {
                    var content = comp.find("body"); 
                    content.set("v.body", newComp);
                }
            );
        }
        else if(event.currentTarget.dataset.name=='rou') {
            $A.createComponent(
                "c:RoutingDetails", {
                    "VersionId":'',
                    "ProductId":comp.get("v.Product.Id")
                },
                function(newComp) {
                    var content = comp.find("body"); 
                    content.set("v.body", newComp);
                }
            );
        }
            else comp.set("v.showPopup",true); 
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
        helper.createRecord(component,event,'ERP7__Routing__c'); //,defaults  ERP7__Routing__c Product2
    },
    
    handleSaveSuccess : function(cmp, event) {  
        // Display the save status
        // cmp.set("v.saveState", "SAVED");
    },
    
    searchEventHandler : function(cmp,event,helper){
        var searchString = event.getParam("searchString").toString();
        if(searchString.length>1){
            if(cmp.get("v.Tab")=='med'){ 
                var MediaMap =[]; MediaMap=cmp.get("v.MediaMap");
                /* MediaList = MediaList.filter(function (el) {          
             return (el.value.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
            });*/
            
            var MediaMap=[]; MediaMap=cmp.get("v.MediaMap");   
            var Medias=[]; var MediaList=[];  
            for(var i in MediaMap) {
                var nameStr=MediaMap[i].value.Name;   
                
                if(nameStr.toLowerCase().indexOf(searchString.toLowerCase()) != -1) { 
                    
                    Medias.push({
                        key:MediaMap[i].key,
                        value:MediaMap[i].value
                    }); 
                    // MediaList.push(MediaMap[i]);  
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
            
        }
            else if(cmp.get("v.Tab")=='ver'){ 
                var VersionList = cmp.get("v.VersionList");
                VersionList = VersionList.filter(function (el) {                        
                    var cond2=false;            
                    if(el.ERP7__Category__c!=undefined){                             
                        cond2=el.ERP7__Category__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                    } 
                    
                    return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond2);
                });
                cmp.set("v.VersionList",VersionList);
                
            }
                else if(cmp.get("v.Tab")=='wr'){ 
                    var WarrantyRPList = cmp.get("v.WarrantyRPList");
                    WarrantyRPList = WarrantyRPList.filter(function (el) { 
                        
                        var cond1=false;               
                        if(el.ERP7__Return_Policy_Refund_Option__c !=undefined){ 
                            el.ERP7__Return_Policy_Refund_Option__c=(el.ERP7__Return_Policy_Refund_Option__c).toString();                
                            cond1=el.ERP7__Return_Policy_Refund_Option__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                        }
                        
                        var cond2=false;               
                        if(el.ERP7__Days_of_Warranty__c !=undefined){ 
                            el.ERP7__Days_of_Warranty__c=(el.ERP7__Days_of_Warranty__c).toString();                
                            cond2=el.ERP7__Days_of_Warranty__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                        }
                        
                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1 || cond2);
                    });
                    cmp.set("v.WarrantyRPList",WarrantyRPList);            
                }
                    else if(cmp.get("v.Tab")=='co'){  
                        var ChangeOrderList = cmp.get("v.ChangeOrderList");
                        ChangeOrderList = ChangeOrderList.filter(function (el) { 
                            var cond1=false;    
                            
                            if(el.ERP7__Category__c!=undefined){             
                                cond1=el.ERP7__Category__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;
                            }
                            
                            var cond2=false;    
                            if(el.ERP7__type__c!=undefined){                          
                                cond1=el.ERP7__type__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;            
                            }    
                            return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1 || cond2);
                        });
                        cmp.set("v.ChangeOrderList",ChangeOrderList);
                        
                    }
        
                        else if(cmp.get("v.Tab")=='qua'){ 
                            var QualityOrderList = cmp.get("v.QualityOrderList");
                            QualityOrderList = QualityOrderList.filter(function (el) {            
                                return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1);
                            });
                            cmp.set("v.QualityOrderList",QualityOrderList);            
                        } 
                            else if(cmp.get("v.Tab")=='pbe'){ 
                                var PBEList = cmp.get("v.PBEList");
                                PBEList = PBEList.filter(function (el) {
                                    var cond1=false; 
                                    if(el.Pricebook2!=undefined){   
                                        if(el.Pricebook2.Name!=undefined){             
                                            cond1=el.Pricebook2.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;                
                                        }
                                    }    
                                    return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1);
                                });
                                cmp.set("v.PBEList",PBEList);            
                            }	
                                else if(cmp.get("v.Tab")=='av'){ 
                                    var AVendorList = cmp.get("v.AVendorList");
                                    AVendorList = AVendorList.filter(function (el) {
                                        var cond1=false; 
                                        if(el.ERP7__Vendor__c!=undefined){   
                                            if(el.ERP7__Vendor__r.Name!=undefined){             
                                                cond1=el.ERP7__Vendor__r.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;                
                                            }
                                        } 
                                        var cond2=false; 
                                        if(el.ERP7__Type__c!=undefined){   
                                            if(el.ERP7__Type__c!=undefined){             
                                                cond2=el.ERP7__Type__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;                
                                            }
                                        }    
                                        return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1 || cond2);
                                    });
                                    cmp.set("v.AVendorList",AVendorList);            
                                }  
        
                                    else if(cmp.get("v.Tab")=='wip'){ 
                                        var WIPList = cmp.get("v.WIPList");
                                        WIPList = WIPList.filter(function (el) {
                                            var cond1=false; 
                                            if(el.ERP7__Version__c!=undefined){   
                                                if(el.ERP7__Version__c.Name!=undefined){             
                                                    cond1=el.ERP7__Version__c.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;                
                                                }
                                            } 
                                            var cond2=false; 
                                            if(el.ERP7__Type__c!=undefined){   
                                                if(el.ERP7__Type__c!=undefined){             
                                                    cond2=el.ERP7__Type__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;                
                                                }
                                            }    
                                            return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1 || cond2);
                                        });
                                        cmp.set("v.WIPList",WIPList);            
                                    }
                                        else if(cmp.get("v.Tab")=='bom'){ 
                                            var BOMList = cmp.get("v.BOMList");
                                            BOMList = BOMList.filter(function (el) {
                                                var cond1=false; 
                                                if(el.ERP7__BOM_Version__c!=undefined){   
                                                    if(el.ERP7__BOM_Version__c.Name!=undefined){             
                                                        cond1=el.ERP7__BOM_Version__c.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1;                
                                                    }
                                                } 
                                                var cond2=false; 
                                                if(el.ERP7__Type__c!=undefined){   
                                                    if(el.ERP7__Type__c!=undefined){             
                                                        cond2=el.ERP7__Type__c.toLowerCase().indexOf(searchString.toLowerCase()) != -1;                
                                                    }
                                                }    
                                                return (el.Name.toLowerCase().indexOf(searchString.toLowerCase()) != -1 || cond1 || cond2);
                                            });
                                            cmp.set("v.BOMList",BOMList);            
                                        }
    }else{
        cmp.set("v.MediaMap",cmp.get("v.MediaMapD")); 
        //cmp.set("v.MediaList",cmp.get("v.MediaListD"));
        cmp.set("v.RoutingList",cmp.get("v.RoutingListD"));
        cmp.set("v.VersionList",cmp.get("v.VersionListD"));
        cmp.set("v.WarrantyRPList",cmp.get("v.WarrantyRPListD"));
        cmp.set("v.ChangeOrderList",cmp.get("v.ChangeOrderListD"));
        cmp.set("v.QualityOrderList",cmp.get("v.QualityOrderListD"));
        cmp.set("v.PBEList",cmp.get("v.PBEListD"));
        cmp.set("v.AVendorList",cmp.get("v.AVendorListD"));
        cmp.set("v.BOMList",cmp.get("v.BOMListD"));
        cmp.set("v.WIPList",cmp.get("v.WIPListD"));
    }     
       
   },
    
    
    
    
    
})