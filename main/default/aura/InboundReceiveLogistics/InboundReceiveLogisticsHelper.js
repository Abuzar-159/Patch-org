({
    
    focusTOscan: function (component, event) {
        console.log('focusTOscan helper called');
        $(document).ready(function () {
            component.set("v.scanValue", '');
            var barcode = "";
            var pressed = false;
            var chars = [];
            $(window).keypress(function (e) {
                
                $(".scanMN").keypress(function (e) {
                    e.stopPropagation()
                });
                
                chars.push(String.fromCharCode(e.which));
                if (pressed == false) {
                    setTimeout(
                        function () {
                            pressed = false;
                            if (chars.length >= 3) {
                                var barcode = chars.join("");
                                barcode = barcode.trim();
                                chars = [];
                                pressed = false;
                                component.set("v.scanValue", barcode);
                                console.log('scanValue : ',component.get("v.scanValue"));
                                chars = [];
                                pressed = false;
                            }
                            chars = [];
                            pressed = false;
                        }, 500);
                }
                pressed = true;
            }); // end of window key press function         
            
            $(window).keydown(function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                }
            });
        });
    },
    
    getLogisticRecords : function(component, event, helper) {
        //$A.util.removeClass(component.find('mainSpin'), "slds-hide");//1
        component.set("v.showSpinner",true);
        
        var action = component.get("c.fetchSortedLogistics");
        action.setParams({
            "OrderBy":component.get("v.OrderBy"),
            "SortOrder":component.get("v.Order"),
            'Site' : component.get("v.selectedSite"),
            'Channel' : component.get("v.currentEmployee.ERP7__Channel__c"),
            'Show' : component.get("v.show"),
            'Offset' : 0,
            'filterType' : component.get('v.filtertype'),
            'accId' : component.get('v.selectedAccount')
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.PreventChange", true);
                component.set("v.Container", response.getReturnValue());
                console.log('logistics-->'+JSON.stringify(response.getReturnValue().LogisticWrapperList));
                component.set("v.currentEmployee", response.getReturnValue().Employee);
                //component.find("Site").set("v.options", response.getReturnValue().channelSites);
                component.set("v.SiteOptions",response.getReturnValue().channelSites);
                component.set("v.selectedSite", response.getReturnValue().selectedSite);
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
                component.set("v.PreventChange", false);
                //$A.util.addClass(component.find('mainSpin'), "slds-hide");//2
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    //new helper method for multiple files upload arshad 30/03/23
    finishAllFilesUpload : function(parentId,fileNameList,base64DataList,contentTypeList,component, event, helper) {
        try{
            console.log('finishAllFilesUpload parentId~>'+parentId);
            console.log('finishAllFilesUpload fileNameList~>'+fileNameList.length);
            console.log('finishAllFilesUpload base64DataList~>'+base64DataList.length);
            console.log('finishAllFilesUpload contentTypeList~>'+contentTypeList.length);
            var action = component.get("c.uploadMultipleFiles");
            
            action.setParams({
                parent: parentId,
                fileName: fileNameList,
                base64Data: base64DataList,
                contentType: contentTypeList,
            });
            
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    console.log("finishAllFilesUpload resp: ", JSON.stringify(response.getReturnValue()));
                    if(component.get('v.enableQAforMO') && component.get('v.filtertype') == 'QualityCheckMO'){
                        var obj1 = component.get("v.Container.MOWrapperList");
                        for(var x in obj1){
                            if(obj1[x].MOrders.Id == parentId){
                                obj1[x].Attachments = response.getReturnValue();
                                break;
                            }
                        }
                        component.set("v.Container.MOWrapperList",obj1);
                    }
                    else{
                        var obj = component.get("v.Container.LogisticWrapperList");
                        for(var x in obj){
                            if(obj[x].Logistic.Id == parentId){
                                obj[x].Attachments = response.getReturnValue();
                                break;
                            }
                        }
                        component.set("v.Container.LogisticWrapperList",obj);
                    
                    }
                   
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");//3
                    component.set("v.showSpinner",false);
                }
                else{
                    //$A.util.addClass(component.find('mainSpin'), "slds-hide");//4
                    component.set("v.showSpinner",false);
                    var errors = response.getError();
                    console.log("server error in doInit : ", JSON.stringify(errors));
                    component.set("v.exceptionError", errors[0].message);
                }
            });
            $A.enqueueAction(action);
            
            setTimeout($A.getCallback(function () {
                console.log('setTimeout'); 
            }), 1000);   //dont remove setTimeout - for loading issue fix for upload files
        }catch(e){
            console.log('finishAllFilesUpload err',e);
            //$A.util.addClass(component.find('mainSpin'), "slds-hide");//5
            component.set("v.showSpinner",false);
        }
    },
    getQAMOs : function(component,event,helper){
        component.set("v.showSpinner",true);
        var searchtext = component.get("v.searchText");
        var channel = component.get("v.currentEmployee.ERP7__Channel__c");
        var site = component.get("v.selectedSite");
        var show = component.get("v.show");
        var offset = component.get("v.Container.Offset");
        if(channel == undefined) { channel = ""; site = ""; }
        if(searchtext == undefined) searchtext = "";
        component.set("v.checkAll",false);
        component.set("v.Container.LogisticWrapperList",[]);
        var action = component.get('c.getQualityCheckMOs');
        action.setParams({searchText:searchtext, Channel:channel, Site:site, Offset:offset, Show:show});
  
        action.setCallback(this, function(response) {
            
            if (response.getState() === "SUCCESS") {
                console.log('res QA :',response.getReturnValue());
                component.set("v.Container", response.getReturnValue());
                console.log('Container QA :',JSON.stringify(component.get("v.Container.MOWrapperList")));
                component.set("v.exceptionError", response.getReturnValue().exceptionError);
            }
        });
        $A.enqueueAction(action);
        component.set("v.showSpinner",false);
    },
    showToast: function (title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams({
                "title": title,
                "message": message,
                "type": type
            });
            toastEvent.fire();
        } else {
            console.error("Toast event not supported.");
        }
    }
    
})