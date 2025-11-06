({
    fetchRecordList:function(comp, event, helper){
        var action = comp.get("c.getRecords");  
        
        action.setParams({"ProductId":comp.get("v.ProductId")});   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") { 
                                                        
                if(this.trim(comp.get("v.ProductId"))==false){                                          
                    var TabElem=comp.find("TabId");
                    for(var i=0; i<TabElem.length; i++){
                        $A.util.removeClass(TabElem[i].getElement(),'active');
                        $A.util.addClass(TabElem[0].getElement(),'active');
                    }  
                }                                            
                var response=response.getReturnValue();
                if(response!=null && response!=undefined && comp.get("v.Clone")==false){                                         
                    comp.set("v.Product",response.Product);                                        
                    comp.set("v.Media",response.Media);  
                    comp.set("v.Routing",response.Routing);
                    comp.set("v.Version",response.Version);  
                    comp.set("v.WarrantyRP",response.WarrantyRP);  
                    comp.set("v.ChangeOrder",response.ChangeOrder);  
                    comp.set("v.QualityOrder",response.QualityOrder);  
                    comp.set("v.PBE",response.PBE);
                    comp.set("v.AVendor",response.AVendor);  
                    comp.set("v.WIP",response.WIP);
                    comp.set("v.BOM",response.BOM);
                    
                    // comp.set("v.MediaList",response.MediaList);  
                    comp.set("v.RoutingList",response.RoutingList);  
                    comp.set("v.VersionList",response.VersionList);                                        
                    comp.set("v.WarrantyRPList",response.WarrantyRPList);
                    comp.set("v.ChangeOrderList",response.ChangeOrderList);  
                    comp.set("v.QualityOrderList",response.QualityOrderList);  
                    comp.set("v.PBEList",response.PBEList);
                    comp.set("v.AVendorList",response.AVendorList);  
                    comp.set("v.WIPList",response.WIPList);
                    comp.set("v.BOMList",response.BOMList);
                    
                    // comp.set("v.MediaListD",response.MediaList);  
                    comp.set("v.RoutingListD",response.RoutingList);  
                    comp.set("v.VersionListD",response.VersionList);                                        
                    comp.set("v.WarrantyRPListD",response.WarrantyRPList);
                    comp.set("v.ChangeOrderListD",response.ChangeOrderList);  
                    comp.set("v.QualityOrderListD",response.QualityOrderList);  
                    comp.set("v.PBEListD",response.PBEList);  
                    comp.set("v.AVendorListD",response.AVendorList);
                    comp.set("v.WIPListD",response.WIPList);
                    comp.set("v.BOMListD",response.BOMList);  
                    // comp.set("v.MediaList",response.MediaList);  
                    
                    var MediaMap=[]; MediaMap=response.MediaMap;   
                    var Medias=[]; var MediaList=[];  
                    for(var i in MediaMap) {  
                        Medias.push({
                            key:[i],
                            value:MediaMap[i]
                        }); 
                        MediaList.push(MediaMap[i]);     
                    }     
                    comp.set("v.MediaMap",Medias);  comp.set("v.MediaMapD",Medias); 
                    comp.set("v.MediaList",MediaList);  comp.set("v.MediaListD",MediaList);     
                    
                }else{
                    comp.set("v.Product",response.Product); comp.set("v.Product.Id",""); //comp.set("v.ProductId","");  
                    comp.set("v.Clone","false"); //response.Product.Id  
                }                                          
                
                comp.set("v.showMainSpin",false); 
                if(this.trim(response.Product.ERP7__Status__c)==false) comp.set("v.Product.ERP7__Status__c",'Released'); 
                
                if(this.trim(comp.get("v.ProductId"))==false) {  
                    if(comp.get("v.Tab")!='rou' && comp.get("v.Tab")!='ver'){    
                        // this.getProductInstance(comp, event, helper);               
                        comp.set("v.Tab",'med'); 
                        comp.set("v.Tab",'pro');
                        
                    } 
                    if(comp.get("v.Tab")!='pro'){   
                        var TabElem=comp.find("TabId");
                        for(var i=0; i<TabElem.length; i++){  
                            $A.util.removeClass(TabElem[i].getElement(),'active');
                            if(comp.get("v.Tab")=='ver') $A.util.addClass(TabElem[2].getElement(),'active');
                            else if(comp.get("v.Tab")=='rou') $A.util.addClass(TabElem[3].getElement(),'active');
                            
                        }
                    }    
                }                                                
                
            }else{
                //('getRecords Exception Occured');
            }
                          
        });
        $A.enqueueAction(action);  
    },
    
    
    getProductInstance : function(component, event, helper) {                                                             
        var action = component.get("c.getProduct");         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {  
                component.set("v.Product",response.getReturnValue());
                component.set("v.Tab",'med'); 
                component.set("v.Tab",'pro'); 
                
            }        
        });
        $A.enqueueAction(action);        
    },
    
    
    fetchPicklistValues:function(comp, event, helper){
        var action = comp.get("c.getPicklistValues");   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") {  
                var response=response.getReturnValue();
                
                comp.set("v.ProductFamilyList",response.ProductFamilyList);  
                comp.set("v.ProductTypeList",response.ProductTypeList);                                          
                comp.set("v.ProductCategoryList",response.ProductCategoryList);                                          
                comp.set("v.ProductTaxCodeList",response.ProductTaxCodeList);                                         
                comp.set("v.ProductSubCategoryList",response.ProductSubCategoryList);                                         
                comp.set("v.ProductUoMList",response.ProductUoMList);                                         
                comp.set("v.ProductQuantityUnitOfMeasureList",response.ProductQuantityUnitOfMeasureList);  
                comp.set("v.ProductStatusList",response.ProductStatusList);  
                comp.set("v.ProductWeightDimensionsList",response.ProductWeightDimensionsList);
                comp.set("v.RoutingStatusList",response.RoutingStatusList);
                comp.set("v.RoutingTypeList",response.RoutingTypeList);  
                
                comp.set("v.VersionStatusList",response.VersionStatusList);
                comp.set("v.VersionTypeList",response.VersionTypeList);
                comp.set("v.VersionCategoryList",response.VersionCategoryList);
                comp.set("v.ReturnPolicyRefundOptionList",response.ReturnPolicyRefundOptionList);
                comp.set("v.MediaTypeList",response.MediaTypeList);  
                
                comp.set("v.COCategoryList",response.COCategoryList);  
                comp.set("v.COTypeList",response.COTypeList);  
                comp.set("v.COStatusList",response.COStatusList);  
                comp.set("v.COProjectList",response.COProjectList);  
                comp.set("v.WarrantyRPRO",response.WarrantyRPRO);  
                comp.set("v.AVendorTypeList",response.AVendorTypeList);  
                comp.set("v.AVendorStatusList",response.AVendorStatusList);  
                comp.set("v.WIPTypeList",response.WIPTypeList); 
                comp.set("v.WIPUoMList",response.WIPUoMList);
                comp.set("v.BOMStatusList",response.BOMStatusList);                                      
                comp.set("v.BOMTypeList",response.BOMTypeList);
                comp.set("v.BOMComponentTypeList",response.BOMComponentTypeList); 
                comp.set("v.BOMUoMList",response.BOMUoMList);
                
                if(comp.get("v.Tab")=='ver'){  
                    $A.util.removeClass(comp.find("TabId")[0].getElement(),'active');
                    $A.util.addClass(comp.find("TabId")[2].getElement(),'active');            
                }
                if(comp.get("v.Tab")=='rou'){  
                    $A.util.removeClass(comp.find("TabId")[0].getElement(),'active');
                    $A.util.addClass(comp.find("TabId")[3].getElement(),'active');            
                }                                          
            }          
        });
        $A.enqueueAction(action);  
    },
    
    saveRecord:function(comp, event, helper){
        var restrict = false;
        var Tab=comp.get("v.Tab");
        var Record;
        if(!restrict){
            restrict = true;
            //alert('restrict : '+restrict);
        	if(Tab=='pro') Record=comp.get("v.Product");
            else if(Tab=='med') Record=comp.get("v.Media");
            else if(Tab=='rou') Record=comp.get("v.Routing");
            else if(Tab=='ver') Record=comp.get("v.Version"); 
            else if(Tab=='wr') Record=comp.get("v.WarrantyRP");
            else if(Tab=='co') Record=comp.get("v.ChangeOrder");
            else if(Tab=='qua') Record=comp.get("v.QualityOrder");
            else if(Tab=='pbe') Record=comp.get("v.PBE");
            else if(Tab=='av') Record=comp.get("v.AVendor");
            else if(Tab=='bom') Record=comp.get("v.BOM");
            else if(Tab=='wip') Record=comp.get("v.WIP");
            
            var checkMandatoryFieldsBool=false; 
            checkMandatoryFieldsBool=this.checkMandatoryFields(comp, event, helper, Tab); 
            comp.set("v.priceBookMsg",'');
            comp.set("v.priceBookMsg",'');
            
            if(checkMandatoryFieldsBool){
                if(Tab=='pbe') comp.set("v.PBE.Product2Id",comp.get("v.ProductId"));
                else if(Tab=='rou') comp.set("v.Routing.ERP7__Product__c",comp.get("v.ProductId"));
                else if(Tab=='ver') comp.set("v.Version.ERP7__Product__c",comp.get("v.ProductId"));
                else if(Tab=='wr') comp.set("v.WarrantyRP.ERP7__Product__c",comp.get("v.ProductId"));
                else if(Tab=='pbe') comp.set("v.PBE.Product2Id",comp.get("v.ProductId"));
                else if(Tab=='med') comp.set("v.Media.ERP7__Product__c",comp.get("v.ProductId"));
                else if(Tab=='av') comp.set("v.AVendor.ERP7__Product__c",comp.get("v.ProductId"));
                else if(Tab=='bom') comp.set("v.BOM.ERP7__BOM_Product__c",comp.get("v.ProductId"));
                else if(Tab=='wip') comp.set("v.WIP.ERP7__Product__c",comp.get("v.ProductId"));
                
                var Product=comp.get("v.Product");
                var ProductIDold=null; if(Product.Id!=undefined && Product.Id!='') ProductIDold=Product.Id;
                
                var isClone=false;
                if(comp.get("v.Clone")){ 
                    Product.Id=null;  isClone=true;              
                }
                
                var action = comp.get("c.getCreateRecord");
                var act=comp.get("v.action");                      
                var RecordJSON=JSON.stringify(Record);        
                
                action.setParams({
                    "Record":RecordJSON,
                    "Action":act,
                    "Tab":Tab,
                    "ProductId" :comp.get("v.ProductId"),
                    "ParentId" :comp.get("v.ParentId"),
                    "FileName" :comp.get("v.FileName"),
                    "MediaBody" :comp.get("v.MediaBody"),
                    "ContentType" :comp.get("v.ContentType")
                }); 
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (comp.isValid() && state === "SUCCESS") {
                        
                        if(comp.get("v.Clone"))comp.set("v.disabled", false);
                        
                        var response=response.getReturnValue();
                        comp.set("v.showPopup",false); 
                        $A.util.addClass(comp.find("deleteConfirmId").getElement(),'slds-hide'); 
                        
                        if(Tab=='pro'){
                            comp.set("v.Product",response.Product); 
                            comp.set("v.ProductId",response.Product.Id);
                            var savedStr='Saved.'; 
                            comp.set("v.Clone",false); 
                            if(response.Product.Id==undefined || response.Product.Id=='') savedStr='Created.'                                              
                            var SaveEventMsgStr='Product '+'"'+response.Product.Name+'" was '+savedStr;                                                
                            comp.set("v.SaveMsg",SaveEventMsgStr);
                            setTimeout(
                                $A.getCallback(function() {
                                    comp.set("v.SaveMsg",""); comp.set("v.seBool",false); 
                                    comp.find("skuid").set("v.errors",null);
                                }), 3000
                            );
                            comp.set("v.Productname",response.Product.Name); 
                            if(isClone){
                                var ProductIdOld= this.getProductId(comp, helper);
                                if(ProductIdOld!=response.Product.Id && comp.get("v.isRelatedRecordCreated"))
                                this.CloneRelatedRecords(comp,response.Product.Id,ProductIdOld);
                            }  
                        } 
                        else if(Tab=='med') {
                            // comp.set("v.MediaList",response.MediaList); comp.set("v.MediaListD",response.MediaList);
                            
                            var MediaMap=[]; MediaMap=response.MediaMap;   
                            var Medias=[]; var MediaList=[];  
                            for(var i in MediaMap) {  
                                Medias.push({
                                    key:[i],
                                    value:MediaMap[i]
                                }); 
                                MediaList.push(MediaMap[i]);     
                            }     
                            comp.set("v.MediaMap",Medias);  comp.set("v.MediaMapD",Medias); 
                            comp.set("v.MediaList",MediaList);  comp.set("v.MediaListD",MediaList);     
                        } 
                            else if(Tab=='rou'){ 
                                comp.set("v.RoutingList",response.RoutingList); 
                                comp.set("v.RoutingListD",response.RoutingList); 
                            }  //MediaList
                                else if(Tab=='ver') { 
                                    comp.set("v.VersionList",response.VersionList); 
                                    comp.set("v.VersionListD",response.VersionList);
                                }                                        
                                    else if(Tab=='wr') {
                                        comp.set("v.WarrantyRPList",response.WarrantyRPList); 
                                        comp.set("v.WarrantyRPListD",response.WarrantyRPList); 
                                    }
                                        else if(Tab=='co') { 
                                            comp.set("v.ChangeOrderList",response.ChangeOrderList); 
                                            comp.set("v.ChangeOrderListD",response.ChangeOrderList); 
                                        } 
                                            else if(Tab=='qua') {
                                                comp.set("v.QualityOrderList",response.QualityOrderList); 
                                                comp.set("v.QualityOrderListD",response.QualityOrderList);
                                            }  
                                                else if(Tab=='pbe') { 
                                                    comp.set("v.PBEList",response.PBEList);  
                                                    comp.set("v.PBEListD",response.PBEList); 
                                                }
                                                    else if(Tab=='av') { 
                                                        comp.set("v.AVendorList",response.AVendorList);  
                                                        comp.set("v.AVendorListD",response.AVendorList); 
                                                    }                 
                                                        else if(Tab=='wip') { 
                                                            comp.set("v.WIPList",response.WIPList);  
                                                            comp.set("v.WIPListD",response.WIPList); 
                                                        }
                        this.getInstances(comp, event, helper, Tab);
                    }else{                        
                        if(Tab=='pbe') this.showToast('dismissible','', 'Error','Error: This price definition already exists in this price book.',comp); // comp.set("v.priceBookMsg",' This price definition already exists in this price book');
                        else if(Tab=='pro') this.showToast('dismissible','', 'Error','Error: A Product with this SKU already exists.',comp); 
                        comp.find("skuid").set("v.errors",[{message:'A Product with this SKU already exists.'}]);
                    }
                });
                $A.enqueueAction(action);  
            }
        }    
    },
    CloneRelatedRecords:function(comp, ProductIdNew,ProductIdOld) {
        var action = comp.get("c.getCloneRelatedRecords");    
        action.setParams({
            "ProductIdOld":ProductIdOld,
            "ProductIdNew":ProductIdNew});
        action.setCallback(this, function(response) {
            var state=response.getState(); if (comp.isValid() && state === "SUCCESS") { 
                var response=response.getReturnValue();
                //comp.set("v.ProductId","");
                comp.set("v.ProductId",ProductIdNew );
                
                if(response!=null){
                    var MediaMap=[]; MediaMap=response.MediaMap;  
                    var Medias=[]; var MediaList=[];  
                    for(var i in MediaMap) {  
                        Medias.push({
                            key:[i],
                            value:MediaMap[i]
                        }); 
                        MediaList.push(MediaMap[i]);     
                    }     
                    comp.set("v.MediaMap",Medias);  comp.set("v.MediaMapD",Medias); 
                    comp.set("v.MediaList",MediaList);  comp.set("v.MediaListD",MediaList);     
                    
                    comp.set("v.RoutingList",response.RoutingList); comp.set("v.RoutingListD",response.RoutingList);//MediaList   
                    comp.set("v.VersionList",response.VersionList); comp.set("v.VersionListD",response.VersionList);
                    comp.set("v.WarrantyRPList",response.WarrantyRPList); comp.set("v.WarrantyRPListD",response.WarrantyRPList); 
                    comp.set("v.ChangeOrderList",response.ChangeOrderList); comp.set("v.ChangeOrderListD",response.ChangeOrderList); 
                    comp.set("v.QualityOrderList",response.QualityOrderList); comp.set("v.QualityOrderListD",response.QualityOrderList);  
                    comp.set("v.PBEList",response.PBEList);  comp.set("v.PBEListD",response.PBEList); 
                    comp.set("v.AVendorList",response.AVendorList);  comp.set("v.AVendorListD",response.AVendorList); 
                    comp.set("v.BOMList",response.BOMList);  comp.set("v.BOMListD",response.BOMList);  
                    comp.set("v.WIPList",response.WIPList);  comp.set("v.WIPListD",response.WIPList);  
                    //this.getInstances(comp, event, helper, Tab);
                }
            }
        });
        $A.enqueueAction(action); 
        
    },
    getProductId:function(component, helper) {
        var id = getQueryVariable("id");           
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
        return id; 
    },
    
    
    showToast : function(modeType,title, type, message,component) {	
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != undefined){
            toastEvent.setParams({
                "mode":modeType,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }else{
            let msg = component.get('v.message');
            msg['Title'] = title;
            msg['Severity']=type;
            msg['Text'] = message;
            component.set('v.message',msg);
        }
    },
    
    
    handleErrors : function(comp,errors) {
        
        // Configure error toast
        let toastParams = {
            title: "Error",
            message: "Unknown error", // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        let msg = comp.get('v.message');
        msg['Title'] = 'Error';
        msg['Severity']='error';
        msg['Text'] = toastParams.message;
        comp.set('v.message',msg);     
    },
    
    
    getInstances:function(comp, event, helper, Tab){
        if(Tab=='med'){   
            var action = comp.get("c.getMed");         
            action.setCallback(this, function(response) {
                if (comp.isValid() && response.getState() === "SUCCESS") {
                    
                    comp.set("v.Media",response.getReturnValue());           
                }       
            });
            $A.enqueueAction(action);
        }
        
        else if(Tab=='rou'){   
            var action = comp.get("c.getRou");         
            action.setCallback(this, function(response) {
                if (comp.isValid() && response.getState() === "SUCCESS") {
                    comp.set("v.Routing",response.getReturnValue());           
                }       
            });
            $A.enqueueAction(action);
        }
            else if(Tab=='ver'){   
                var action = comp.get("c.getVer");         
                action.setCallback(this, function(response) {
                    if (comp.isValid() && response.getState() === "SUCCESS") { 
                        
                        comp.set("v.Version",response.getReturnValue());           
                    }       
                });
                $A.enqueueAction(action);
            }
        
                else if(Tab=='wr'){   
                    var action = comp.get("c.getWR");         
                    action.setCallback(this, function(response) {
                        if (comp.isValid() && response.getState() === "SUCCESS") {  
                            comp.set("v.WarrantyRP",response.getReturnValue());           
                        }       
                    });
                    $A.enqueueAction(action);
                }
        
        if(Tab=='co'){   
            var action = comp.get("c.getCO");         
            action.setCallback(this, function(response) {
                if (comp.isValid() && response.getState() === "SUCCESS") {  
                    comp.set("v.ChangeOrder",response.getReturnValue());           
                }       
            });
            $A.enqueueAction(action);
        }
        
        if(Tab=='qua'){   
            var action = comp.get("c.getQua");         
            action.setCallback(this, function(response) {
                if (comp.isValid() && response.getState() === "SUCCESS") {
                    comp.set("v.QualityOrder",response.getReturnValue());           
                }       
            });
            $A.enqueueAction(action);
        }
        
        if(Tab=='pbe'){   
            var action = comp.get("c.getPriceBookEntry");         
            action.setCallback(this, function(response) {
                if (comp.isValid() && response.getState() === "SUCCESS") {  
                    comp.set("v.PBE",response.getReturnValue());           
                }       
            });
            $A.enqueueAction(action);
        }
        if(Tab=='av'){   
            var action = comp.get("c.getAVendor");         
            action.setCallback(this, function(response) {
                if (comp.isValid() && response.getState() === "SUCCESS") {  
                    comp.set("v.AVendor",response.getReturnValue());           
                }       
            });
            $A.enqueueAction(action);
        } 
        if(Tab=='wip'){   
            var action = comp.get("c.getwip");         
            action.setCallback(this, function(response) {
                if (comp.isValid() && response.getState() === "SUCCESS") {  
                    comp.set("v.WIP",response.getReturnValue());
                }       
            });
            $A.enqueueAction(action);
        }
        if(Tab=='bom'){   
            var action = comp.get("c.getBom");         
            action.setCallback(this, function(response) {
                if (comp.isValid() && response.getState() === "SUCCESS") {  
                    comp.set("v.BOM",response.getReturnValue());           
                }       
            });
            $A.enqueueAction(action);
        }
    },
    
    setRecord:function(comp, event, helper, Tab, index){
        if(comp.get("v.Tab")=='rou'){
            var RoutingList=[]; RoutingList=comp.get("v.RoutingList");
            comp.set("v.Routing",RoutingList[index]); 
            
        } 
        else if(comp.get("v.Tab")=='ver'){ 
            var VersionList=[]; VersionList=comp.get("v.VersionList");
            comp.set("v.Version",VersionList[index]); 
        }
        else if(comp.get("v.Tab")=='wr'){
            var WarrantyRPList=[]; WarrantyRPList=comp.get("v.WarrantyRPList");
            comp.set("v.WarrantyRP",WarrantyRPList[index]); 
        }   
        
        else if(comp.get("v.Tab")=='co'){
            var ChangeOrderList=[]; ChangeOrderList=comp.get("v.ChangeOrderList");
            comp.set("v.ChangeOrder",ChangeOrderList[index]); 
        }   
        else if(comp.get("v.Tab")=='qua'){
            var QualityOrderList=[]; QualityOrderList=comp.get("v.QualityOrderList");
            comp.set("v.QualityOrder",QualityOrderList[index]); 
        }   
        else if(comp.get("v.Tab")=='pbe'){
            var PBEList=[]; PBEList=comp.get("v.PBEList");
            comp.set("v.PBE",PBEList[index]); 
        }
        else if(comp.get("v.Tab")=='av'){
            var AVendorList=[]; AVendorList=comp.get("v.AVendorList");
            comp.set("v.AVendor",AVendorList[index]); 
        }
        else if(comp.get("v.Tab")=='wip'){
            var WIPList=[]; WIPList=comp.get("v.WIPList");
            comp.set("v.WIP",WIPList[index]); 
        }
        else if(comp.get("v.Tab")=='bom'){ 
            var BOMList=[]; BOMList=comp.get("v.BOMList");
            comp.set("v.BOM",BOMList[index]); 
        }
        else  if(comp.get("v.Tab")=='med'){
            var MediaList=[]; MediaList=comp.get("v.MediaList");
            comp.set("v.Media",MediaList[index]);
            //comp.set('v.fileNameVal', 'Rakib File');
            //  this.AttachmentmentDetails(comp, event, helper);  
        }
    },
    
    AttachmentmentDetails : function(comp, event, helper, attachId) {     
        var action = comp.get("c.AttachmentmentDetails");    
        action.setParams({
            atId:attachId //comp.get("v.attachId") //'00P1o00000yrThK'             
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") {  
                comp.set("v.fileNameVal",response.getReturnValue().Name);           
            }        
        });
        $A.enqueueAction(action);        
    },
    
    checkMandatoryFields:function(comp, event, helper, Tab){ //, index
        comp.set("v.seBool",false);  
        if(comp.get("v.Tab")=='pro'){
            var Product=comp.get("v.Product"); 
            if(this.trim(Product.Name)==false){
                comp.set("v.seBool",true); return false; 
            } 
            else{
                comp.set("v.seBool",false);  return true; 
            }             
        }  
        else if(comp.get("v.Tab")=='med'){
            var Media=comp.get("v.Media"); 
            if(comp.get("v.FileName") !='' && comp.get("v.FileName") != undefined) 
                comp.set("v.fileNameVal",comp.get("v.FileName"))
                
                if(this.trim(Media.Name) == false){ // || this.trim(comp.get("v.fileNameVal")) == false 
                    //+'  ,FileName==>'+comp.get("v.FileName")
                    comp.set("v.seBool",true); return false; 
                } 
            else{
                comp.set("v.seBool",false);  return true; 
            }  
        }
            else if(comp.get("v.Tab")=='rou'){
                var Routing=comp.get("v.Routing"); 
                if(this.trim(Routing.Name)==false || this.trim(Routing.ERP7__Process__c)==false  || this.trim(Routing.ERP7__Finished_Products_Site__c)==false  || this.trim(Routing.ERP7__Raw_Materials_Site__c)==false){
                    comp.set("v.seBool",true); return false; 
                } 
                else{
                    comp.set("v.seBool",false);  return true; 
                }  
            } 
                else if(comp.get("v.Tab")=='ver'){
                    var Version=comp.get("v.Version")  
                    if(this.trim(Version.Name)==false){
                        comp.set("v.seBool",true); return false; 
                    } 
                    else{
                        comp.set("v.seBool",false);  return true; 
                    }  
                }
                    else if(comp.get("v.Tab")=='wr'){
                        var WarrantyRP=comp.get("v.WarrantyRP")  
                        if(this.trim(WarrantyRP.Name)==false){
                            comp.set("v.seBool",true); return false; 
                        } 
                        else{
                            comp.set("v.seBool",false);  return true; 
                        } 
                    }   
        
                        else if(comp.get("v.Tab")=='co'){
                            var ChangeOrder=comp.get("v.ChangeOrder")  
                            if(this.trim(ChangeOrder.Name)==false){
                                comp.set("v.seBool",true); return false; 
                            } 
                            else{
                                comp.set("v.seBool",false);  return true; 
                            } 
                            
                        }   
        
                            else if(comp.get("v.Tab")=='qua'){
                                var QualityOrder=comp.get("v.QualityOrder")  
                                if(this.trim(QualityOrder.Name)==false){
                                    comp.set("v.seBool",true); return false; 
                                } 
                                else{
                                    comp.set("v.seBool",false);  return true; 
                                }
                            }   
                                else if(comp.get("v.Tab")=='pbe'){
                                    var PBE=comp.get("v.PBE")  
                                    if(this.trim(PBE.UnitPrice)==false || this.trim(PBE.Pricebook2Id)==false){
                                        comp.set("v.seBool",true); return false; 
                                    } 
                                    else{
                                        comp.set("v.seBool",false);  return true; 
                                    }
                                }
                                    else if(comp.get("v.Tab")=='av'){
                                        var AVendor=comp.get("v.AVendor")  
                                        if(this.trim(AVendor.Name)==false){
                                            comp.set("v.seBool",true); return false; 
                                        } 
                                        else{
                                            comp.set("v.seBool",false);  return true; 
                                        }
                                    }  
                                        else if(comp.get("v.Tab")=='wip'){
                                            var WIP=comp.get("v.WIP")  
                                            if(this.trim(WIP.Name)==false){
                                                comp.set("v.seBool",true); return false; 
                                            } 
                                            else{
                                                comp.set("v.seBool",false);  return true; 
                                            }
                                        }
                                            else if(comp.get("v.Tab")=='bom'){
                                                var BOM=comp.get("v.BOM")  
                                                if(this.trim(BOM.Name)==false){
                                                    comp.set("v.seBool",true); 
                                                    //comp.find("mid").set("v.errors",[{message:'Maximum Variance must be > than Minimum Variance.'}]);
                                                    return false;
                                                } 
                                                else{
                                                    comp.set("v.seBool",false);  return true;
                                                    // comp.find("mid").set("v.errors", null);
                                                }  
                                            }
                                                else  return false;           
    },
    
    
    
    trim: function(value){  
        if(value !=undefined ) return ((value.toString()).trim() !=''?true:false);
        else return false;
    },  
    
    createRecord :function(component,event,sObject){ 
                                                              
        var windowHash = window.location.hash;
        var createRecordEvent = $A.get("e.force:createRecord");
        if(!$A.util.isUndefined(createRecordEvent)){
            createRecordEvent.setParams({
                "entityApiName": sObject,
                "panelOnDestroyCallback": function(event) {
                    window.location.hash=history.back();
                }
            });
            createRecordEvent.fire();
        }   
        //"defaultFieldValues":defaultvalues,   windowHash window.history.back()       
    },
    
    doInitNew:function(comp, event, helper){
        var action = comp.get("c.RetriveAttachmentRecord");    
        /* action.setParams({
            "Allocation":component.get("v.param")             
      });  */
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") { 
                
                var res=response.getReturnValue();                                        
                for(var i in res){
                    
                    comp.set("v.AttachmentBody",i);  
                }                                        
                
                //comp.set("v.AttachmentRecord",response.getReturnValue());
                // comp.set("v.AttachmentBody",response.getReturnValue());                                        
            }          
        });
        $A.enqueueAction(action);        
    },
    
    
    
    getCreateAttachment : function(component, event, helper) {                                                             
        var action = component.get("c.getCreateAttachment");    
        action.setParams({
            "Allocation":component.get("v.param")             
        });  
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {  
                component.set("v.AllocationList",response.getReturnValue());           
            }          
        });
        $A.enqueueAction(action);        
    },
    
    
    
})