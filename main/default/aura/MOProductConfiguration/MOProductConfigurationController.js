({
    doInit : function(component, event, helper) {
        var listPROJ = [];
        component.set("v.prodlst",listPROJ);
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var offsetval = component.get('v.Offset');
        var showval = component.get('v.show');
        var action = component.get('c.getProducts');
        action.setParams({
            "pjtOffset":offsetval,
            "RecordLimit":showval,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                if(result.length == 0) component.set('v.exceptionError',$A.get('$Label.c.Sorry_no_Products_avilable'));
                else component.set('v.prodlst',result);
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                console.log('today : ',today);
                component.set('v.today',today);
                var pdt = component.get("v.prodlst");
              /*  var returndetails = component.get('v.CurrProdLst');
                console.log('returndetails : ',returndetails);
                for(var i in pdt){
                    component.set("v.recSize",pdt[i].recSize);
                    if(returndetails != '' && returndetails != null){
                        if(pdt[i].prod.Id == returndetails.Product.Id){
                            console.log('returndetails here~>'+JSON.stringify(returndetails));
                            pdt[i].version = returndetails.version;
                            pdt[i].Process = returndetails.process;
                        }
                    }
                    
                    
                }*/
                component.set('v.prodlst',pdt);
                if(component.get("v.prodlst").length>0){
                    var startCount = component.get("v.Offset") + 1;
                    var endCount = component.get("v.Offset") + component.get("v.prodlst").length;
                    component.set("v.startCount", startCount);
                    
                    component.set("v.endCount", endCount);
                    //component.set("v.PageNum",1);
                    var myPNS = [];
                    var ES = component.get("v.recSize");
                    var i=0;
                    var show=component.get('v.show');
                    while(ES >= show){
                        i++; myPNS.push(i); ES=ES-show;
                    } 
                    if(ES > 0) myPNS.push(i+1);
                    component.set("v.PNS", myPNS);
                }
                helper.productStatusCount(component,event);
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
                
            }
            
            
            else{
                var err = response.getError();
                component.set('v.exceptionError',err);
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
        var getStatus = component.get('c.getVerStatus');
        getStatus.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.VerStatus',response.getReturnValue());
            }
        });
        $A.enqueueAction(getStatus);
        var getType = component.get('c.getVerType');
        getType.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.VerType',response.getReturnValue());
            }
        });
        $A.enqueueAction(getType);
        var ProdUOMpicklists= component.get('c.getProductUOMPicklist');
        ProdUOMpicklists.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result BomUom'+JSON.stringify(result));
                component.set('v.ProdUom',result);
            }
        });
        $A.enqueueAction(ProdUOMpicklists);
        
    },
    searchProducts :function(component, event, helper) {
        
        var listPROJ = [];
        
        //if(event.which == 13){
            
            var currentText = component.get("v.searchProduct");
            if(currentText != null && currentText != undefined && currentText != ""){
                component.set("v.prodlst",listPROJ);
                helper.searchProd(component, event,currentText);
            }
            
        //}
        //if(event.which == undefined){
            if(component.get("v.searchProduct") == null || component.get("v.searchProduct") == undefined || component.get("v.searchProduct") == "")
                component.popInit();
        //}
        
    },
    closeError : function(component, event, helper) {
        component.set('v.exceptionError','');
    },
    toggleSearch : function(component, event){
        component.set("v.showSearch", !component.get("v.showSearch"));
    },
    OfsetChange : function(component,event,helper){
        
        var Offsetval = component.find("pageId").get("v.value");
        if(Offsetval != '' && Offsetval != null && Offsetval != undefined){
            var curOffset = component.get("v.Offset");
            var show = parseInt(component.get("v.show"));
            if(Offsetval > 0 && Offsetval <= component.get("v.PNS").length){
                if(((curOffset+show)/show) != Offsetval){
                    var newOffset = (show*Offsetval)-show;
                    component.set("v.Offset", newOffset);
                    //component.set("v.CheckOffset",true);
                    var pageNum = (newOffset + show)/show;
                    component.set("v.PageNum",pageNum);
                }
                component.popInit();
            } 
            else component.set("v.PageNum",((curOffset+show)/show));
        }
        
    },
    setShow : function(cmp,event,helper){
        cmp.set("v.startCount", 0);
        cmp.set("v.endCount", 0);
        cmp.set("v.Offset", 0);
        cmp.set("v.PageNum", 1);
        cmp.popInit();
    },
    
    
    Next : function(component,event,helper){
        if(component.get("v.endCount") != component.get("v.recSize")){
            var Offsetval = component.get("v.Offset") + parseInt(component.get('v.show')); 
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")+1));
            component.popInit();
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
            component.popInit();
        }
    },
    
    Previous : function(component,event,helper){
        if(component.get("v.startCount") > 1){
            var Offsetval = component.get("v.Offset") - parseInt(component.get('v.show'));
            //alert(Offsetval);    
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",(component.get("v.PageNum")-1));
            component.popInit();            }
    },
    
    PreviousFirst : function(component,event,helper){
        var show = parseInt(component.get("v.show"));
        if(component.get("v.startCount") > 1){
            var Offsetval = 0;
            component.set("v.Offset", Offsetval);
            //component.set("v.CheckOffset",true);
            component.set("v.PageNum",((component.get("v.Offset")+show)/show));
            component.popInit();
        }
    },
    
    //chnaged by arshad 28 july
    getProcesses : function(component, event, helper) {
        try{
            console.log('getProcesses called');
            
            var selectedVer = event.currentTarget.name;
            var ProdId = event.currentTarget.dataset.recordId;
            
            console.log('selectedVer~>'+selectedVer);
            console.log('ProdId~>'+ProdId);
            
            if(!$A.util.isEmpty(selectedVer) && !$A.util.isEmpty(ProdId)){
                console.log('inhere0');
                //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
                component.set("v.showSpinner",true);
                var action = component.get('c.getProcess');
                action.setParams({'VerId' : selectedVer, 'ProductId' : ProdId});
                action.setCallback(this,function(response){
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        var result = response.getReturnValue();
                        console.log('getProcesses result~>',result);
                        
                        var allprods = component.get('v.prodlst');
                        for(var x in allprods){
                            if(allprods[x].prod.Id == ProdId && allprods[x].version.Id == selectedVer){
                                console.log('allprods[x] before 1~>'+JSON.stringify(allprods[x]));
                                allprods[x] = result;
                                if(allprods[x].Process != null && allprods[x].Process != '' && allprods[x].Process != undefined && allprods[x].Process.Id != undefined && allprods[x].Process.Id != null && allprods[x].Process.Id != '') {
                                    allprods[x].hideProcessRemove = true;
                                    allprods[x].disableclone = true;
                                    allprods[x].disableEdit = false;
                                }
                                else {
                                    allprods[x].hideProcessRemove = false;
                                    allprods[x].disableclone = false;
                                    allprods[x].disableEdit = true;
                                }
                                console.log('allprods[x] after 1~>'+JSON.stringify(allprods[x]));
                            }
                        }
                        component.set('v.prodlst',allprods);
                        
                        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
                        component.set("v.showSpinner",false);
                    }else{
                        var errors = response.getError();
                        console.log("server error in getProcesses : ", JSON.stringify(errors));
                    }
                });
                $A.enqueueAction(action);
            }
            else if($A.util.isEmpty(selectedVer)){
                console.log('inhere1');
                var allprods = component.get('v.prodlst');
                for(var x in allprods){
                    if(allprods[x].prod.Id == ProdId && allprods[x].version.Id == ''){
                        console.log('allprods[x] before~>'+JSON.stringify(allprods[x]));
                        var process = {'Id':''};
                        allprods[x].Process = process;
                        console.log('allprods[x] after~>'+JSON.stringify(allprods[x]));
                    }
                }
                component.set('v.prodlst',allprods);
                console.log('inhere2');
            }
        }catch(e){
            console.log('excpetion err~>'+e);
        }
    },
    
    CloneProcess : function(component, event, helper) {
        var ProcessId = event.currentTarget.dataset.recordId;
        console.log('ProcessId Asra~>',ProcessId);
        var index = event.currentTarget.dataset.index;
        if(!$A.util.isEmpty(ProcessId) || !$A.util.isEmpty(index)){
            //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
            component.set("v.showSpinner",true);
            var Version; 
            var Product; 
            var selectedprocess;
            var allprods = component.get('v.prodlst');
            console.log('allprods',allprods);
            for(var x in allprods){
                if(allprods[x].Process.Id == ProcessId && x == index){
                    selectedprocess = allprods[x].Process;
                    Version = allprods[x].version;
                    Product = allprods[x].prod;
                }
            }
           console.log('selectedprocess Asra~>',selectedprocess);
            console.log('Version ~>',Version);
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");
            component.set("v.showSpinner",false);
            var err = false;
            if(Version.Id == '' || Version.Id == null || Version.Id == undefined){
                component.set('v.exceptionError',$A.get('$Label.c.Select_version_to_Proceed'));
                err = true;
            }
            else if(selectedprocess.Id == '' || selectedprocess.Id == null || selectedprocess.Id == undefined){
                component.set('v.exceptionError',$A.get('$Label.c.Select_Process_to_Proceed'));
                err = true;
            }
            if(!err) 
                helper.navigatetosetup(selectedprocess,Version,Product,'clone',component);
            
        }
        
        
    },
    UpdateProcess : function(component, event, helper) {
        var ProcessId = event.currentTarget.dataset.recordId;
        var index = event.currentTarget.dataset.index;
        if(!$A.util.isEmpty(ProcessId) && !$A.util.isEmpty(index)){
            //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
            component.set("v.showSpinner",true);
            var Version; 
            var Product; 
            var selectedprocess;
            var allprods = component.get('v.prodlst');
            for(var x in allprods){
                if(allprods[x].Process.Id == ProcessId && x == index){
                    selectedprocess = allprods[x].Process;
                    Version = allprods[x].version;
                    Product = allprods[x].prod;
                }
            }
           
            var err = false;
            if(Version.Id == '' || Version.Id == null || Version.Id == undefined){
                component.set('v.exceptionError',$A.get('$Label.c.Select_version_to_Proceed'));
                err = true;
            }
            if(!err)  helper.navigatetosetup(selectedprocess,Version,Product,'Edit',component);
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");
            component.set("v.showSpinner",false);
        }
        
    },
    
    editProduct : function(component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var prodId = event.currentTarget.dataset.recordId;
        var windowHash = window.location.hash;
        if(!$A.util.isUndefined(prodId)){
            var editRecordEvent = $A.get("e.force:editRecord");
            editRecordEvent.setParams({
                "recordId" : prodId,
                "panelOnDestroyCallback": function(event) {
                    window.location.hash = windowHash;
                }
            });
            editRecordEvent.fire();
            
        }  
        //$A.util.addClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",false);
    },
    
    CreateProcess : function(component, event, helper){
         var index = event.currentTarget.dataset.index;
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
        var Version; 
        var Product; 
        var selectedprocess;
        var allprods = component.get('v.prodlst');
        for(var x in allprods){
            if(x == index){
                selectedprocess = allprods[x].Process;
                Version = allprods[x].version;
                Product = allprods[x].prod;
            }
        }  
        var err = false;
        
        /* if(Version.Id == '' || Version.Id == null || Version.Id == undefined){
            component.set('v.exceptionError','Select version to Proceed');
            err = true;
        }*/
        if(!err) {
            if(selectedprocess.Id == '' || selectedprocess.Id == null || selectedprocess.Id == undefined){
                helper.navigatetosetup('',Version,Product,'New',component);
            } 
            else if((selectedprocess.Id == '' || selectedprocess.Id == null || selectedprocess.Id == undefined) && (Version.Id == '' || Version.Id == null || Version.Id == undefined)){
                helper.navigatetosetup('','',Product,'New',component);
            }
        }
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");
        component.set("v.showSpinner",true);
    },
    
    lookupClickVersion : function(component, event, helper) {
        var prodId = event.currentTarget.dataset.recordId;
        console.log('prodId : '+prodId);
        var qry = 'And ERP7__Active__c=true And ERP7__Status__c = \'Certified\' And ERP7__Product__c = \''+prodId+'\' and ERP7__Start_Date__c <\=\ TODAY and ERP7__To_Date__c >\=\ TODAY  ';
        console.log('qry : '+qry);
        component.set('v.verQry',qry);
    },
    
    createProduct: function(component, event, helper) {
        console.log('createProduct called');
        try{
            component.set("v.showSpinner", true);
            helper.getFieldsSetApiNameHandler(component,'Product2','ERP7__MO_Product_Configuration');
            setTimeout(function(){
                component.set("v.showSpinner", false);
                component.set("v.isCreateOrUpdate", true);
            }, 1500);
        }
        catch(e){
            console.log('Error in createProduct : ',e);
        }
    },
    
    closeCreateOrUpdate : function(component, event, helper) {
        component.set("v.isCreateOrUpdate", false);
    },
    
    closeConfirm : function(component, event, helper) {
        component.set("v.NavtoSetupComp", false);
        $A.get('e.force:refreshView').fire();
    },
    
    handleCreateOrUpdateSuccess: function(component, event, helper) {
        component.set("v.showSpinner", true);
        component.set("v.isCreateOrUpdate", false);
        component.set('v.NewProdId', event.getParams().response.id);
        console.log('New Product Id: ' + component.get('v.NewProdId'));
        var action = component.get("c.updateProd");
        action.setParams({ prodId: component.get('v.NewProdId') });
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                console.log('Sucessfully Updated Product:',response.getReturnValue());
                if(response.getReturnValue().msg == 'Updated'){
                    component.set("v.isCreateOrUpdate", false);
                    var Product = response.getReturnValue().productDetails;
                    component.set("v.UpdatedProdetails", Product);
                    setTimeout(function(){component.set("v.showSpinner", false);}, 1400);
                   	component.set("v.NavtoSetupComp", true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    ProceedVersionCreate : function(component, event, helper) {
    	component.set("v.NavtoSetupComp", false);
    	var Product = component.get("v.UpdatedProdetails");
    	helper.navigatetosetup('','',Product,'New',component);
    	
    },

    
})