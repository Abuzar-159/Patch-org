({
    fetchRecordList:function(comp, event, helper){
        var action = comp.get("c.getVersionRecordDetails");  
        action.setParams({
            "VersionId":comp.get("v.VersionId")
        });   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (comp.isValid() && state === "SUCCESS") { 
                var response=response.getReturnValue();
                if(response !=null && response !=undefined && comp.get("v.Clone")==false){ 
                    comp.set("v.Version",response.Version);   
                    comp.set("v.Media",response.Media);  
                    comp.set("v.Routing",response.Routing);
                    comp.set("v.BOM",response.BOM); 
                    comp.set("v.RoutingList",response.RoutingList);                                        
                    comp.set("v.BOMList",response.BOMList);
                    comp.set("v.RoutingListD",response.RoutingList);  
                    comp.set("v.BOMListD",response.BOMList);   
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
                    comp.set("v.Product",response.Product); 
                    comp.set("v.Product.Id",""); 
                    comp.set("v.Version",response.Version); 
                    comp.set("v.Version.Id","");
                    comp.set("v.Clone","false");
                }                                          
                comp.set("v.showMainSpin",false);                                          
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
             comp.set("v.RoutingRTList",response.RoutingRTList);  
                                                  
            comp.set("v.VersionStatusList",response.VersionStatusList);
            comp.set("v.VersionTypeList",response.VersionTypeList);
            comp.set("v.VersionCategoryList",response.VersionCategoryList);
            comp.set("v.VersionRTList",response.VersionRTList);                                          
                                                  
            comp.set("v.ReturnPolicyRefundOptionList",response.ReturnPolicyRefundOptionList);
            comp.set("v.MediaTypeList",response.MediaTypeList);  
                                                  
            comp.set("v.COCategoryList",response.COCategoryList);  
            comp.set("v.COTypeList",response.COTypeList);  
            comp.set("v.COStatusList",response.COStatusList);  
            comp.set("v.COProjectList",response.COProjectList);  
            comp.set("v.WarrantyRPRO",response.WarrantyRPRO);  
                                                  
            comp.set("v.BOMTypeList",response.BOMTypeList);  
            comp.set("v.BOMComponentTypeList",response.BOMComponentTypeList);  
            comp.set("v.BOMStatusList",response.BOMStatusList);
            comp.set("v.BOMUoMList",response.BOMUoMList);                                      
                                           
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
            if(Tab=='bom') Record=comp.get("v.BOM");
            else if(Tab=='med') Record=comp.get("v.Media");
            else if(Tab=='rou') Record=comp.get("v.Routing");
            else if(Tab=='ver') Record=comp.get("v.Version"); 
            
            var checkMandatoryFieldsBool=false; checkMandatoryFieldsBool=this.checkMandatoryFields(comp, event, helper, Tab); 
            comp.set("v.priceBookMsg",'');
            comp.set("v.priceBookMsg",'');
            
            if(checkMandatoryFieldsBool){
                if(Tab=='ver') comp.set("v.Version.ERP7__Product__c",comp.get("v.ProductId"));
                else if(Tab=='rou'){ comp.set("v.Routing.ERP7__Product__c",comp.get("v.ProductId")); comp.set("v.Routing.ERP7__BOM_Version__c",comp.get("v.VersionId")); }       
                else if(Tab=='med') { comp.set("v.Media.ERP7__Product__c",comp.get("v.ProductId")); comp.set("v.Media.ERP7__Version__c",comp.get("v.VersionId"));}
                else if(Tab=='bom') { comp.set("v.BOM.ERP7__BOM_Product__c",comp.get("v.ProductId")); comp.set("v.BOM.ERP7__BOM_Version__c",comp.get("v.VersionId"));} 
                
                var Version=comp.get("v.Version");
                var VersionIDold=null; if(Version.Id!=undefined && Version.Id!='') VersionIDold=Version.Id;
                
                var isClone=false;
                if(comp.get("v.Clone")){ 
                    Version.Id=null;  isClone=true;              
                }
                
                var action = comp.get("c.getCreateVersionRecord");
                var act=comp.get("v.action");                      
                var RecordJSON=JSON.stringify(Record);        
                action.setParams({
                    "Record":RecordJSON,
                    "Action":act,
                    "Tab":Tab,
                    "VersionId" :comp.get("v.VersionId"),
                    "ParentId" :comp.get("v.ParentId"),
                    "FileName" :comp.get("v.FileName"),
                    "MediaBody" :comp.get("v.MediaBody"),
                    "ContentType" :comp.get("v.ContentType")   
                });  
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (comp.isValid() && state === "SUCCESS") {  
                        var response=response.getReturnValue();
                        comp.set("v.showPopup",false); 
                        $A.util.addClass(comp.find("deleteConfirmId").getElement(),'slds-hide'); 
                        
                        if(Tab=='ver'){
                            comp.set("v.Version",response.Version); comp.set("v.VersionId",response.Version.Id);
                            var savedStr='Saved.'; 
                            comp.set("v.Clone",false); 
                            if(response.Version.Id==undefined || response.Version.Id=='') savedStr='Created.'                                              
                            var SaveEventMsgStr='Version '+'"'+response.Version.Name+'" was '+savedStr;                                                
                            comp.set("v.SaveMsg",SaveEventMsgStr);
                            setTimeout(
                                $A.getCallback(function() {
                                    comp.set("v.SaveMsg",""); comp.set("v.seBool",false);
                                }), 3000
                            );
                            
                            if(isClone){
                                var VersionIdOld= this.getVersionId(comp, helper);
                                if(VersionIdOld!=response.Version.Id && comp.get("v.isRelatedRecordCreated")) {
                                    //('VersionId==>'+response.Version.Id);
                                } 
                                this.VersionCloneRelatedRecords(comp,response.Version.Id,VersionIdOld);
                            }
                        } 
                        else if(Tab=='med') {
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
                            else if(Tab=='rou'){ comp.set("v.RoutingList",response.RoutingList); comp.set("v.RoutingListD",response.MediaList); }  
                                else if(Tab=='bom'){ comp.set("v.BOMList",response.BOMList); comp.set("v.BOMListD",response.BOMList); }                                          
                        
                        
                        this.getInstances(comp, event, helper, Tab);
                    }else{
                        if(Tab=='pbe') comp.set("v.priceBookMsg",' This price definition already exists in this price book');             
                    }
                });
                $A.enqueueAction(action);  
            } 
        }
    },
    VersionCloneRelatedRecords:function(comp, VersionIdNew,VersionIdOld) {
       var action = comp.get("c.getVersionCloneRelatedRecords"); 
        action.setParams({
          "VersionIdOld":VersionIdOld,
          "VersionIdNew":VersionIdNew});
         action.setCallback(this, function(response) {
           var state=response.getState(); if (comp.isValid() && state === "SUCCESS") {
                       
           var response=response.getReturnValue();
           //comp.set("v.ProductId",response.Product.Id);                                                                           
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
            comp.set("v.RoutingList",response.RoutingList); comp.set("v.RoutingListD",response.MediaList);  
            comp.set("v.BOMList",response.BOMList); comp.set("v.BOMListD",response.BOMList);
               }
           }
           });
       $A.enqueueAction(action); 

      },
    getVersionId:function(component, helper) {
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
      if(comp.get("v.Tab")=='med'){
        var MediaList=[]; MediaList=comp.get("v.MediaList");
        comp.set("v.Media",MediaList[index]); 
      }
      else if(comp.get("v.Tab")=='rou'){
         var RoutingList=[]; RoutingList=comp.get("v.RoutingList");
         comp.set("v.Routing",RoutingList[index]); 
          
      } 
      else if(comp.get("v.Tab")=='bom'){ 
         var BOMList=[]; BOMList=comp.get("v.BOMList");
         comp.set("v.BOM",BOMList[index]); 
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
          if(comp.get("v.FileName")!='' && comp.get("v.FileName")!=undefined) comp.set("v.fileNameVal",comp.get("v.FileName"))
          
          if(this.trim(Media.Name)==false || this.trim(comp.get("v.fileNameVal"))==false){ //+'  ,FileName==>'+comp.get("v.FileName")
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
      else if(comp.get("v.Tab")=='bom'){
        var BOM=comp.get("v.BOM")  
        if(this.trim(BOM.Name)==false){
              comp.set("v.seBool",true); return false; 
          } 
          else{
            comp.set("v.seBool",false);  return true; 
          }  
      }   
     else  return false;           
    },
    
    
    
   trim: function(value){  
        if(value !=undefined ) return ((value.toString()).trim() !=''?true:false);
        else return false;
    },  
    
   createRecord :function(component,event,sObject){ //,defaultvalues                                                    
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
    
})