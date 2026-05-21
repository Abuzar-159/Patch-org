({
    setTOStatus: function(component, event) {
        console.log('setTOStatus Called');
        component.set("v.showSpinner", true);
        var action = component.get("c.getTOStatuspickval");
        var inputsel = component.find("toStatus");
        var opts = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.toStatusOptions", response.getReturnValue());
                if (component.get("v.toStatusOptions").length > 0) {
                    component.set("v.TO.ERP7__Status__c", component.get("v.toStatusOptions")[0].value);
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    setTOShipmenttype: function(component, event) {
        console.log('setTOShipmenttype Called');
        component.set("v.showSpinner", true);
        var action = component.get("c.getTOshipmenttype");
        var opts = [];
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                for (var i = 0; i < response.getReturnValue().length; i++) {
                    opts.push({
                        "class": "optionClass",
                        label: response.getReturnValue()[i],
                        value: response.getReturnValue()[i]
                    });
                }
                component.set("v.toShipmentype", opts);
                if (component.get("v.toShipmentype").length > 0) {
                    component.set("v.TO.ERP7__Shipment_type__c", component.get("v.toShipmentype")[0].value);
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    setChannelandDC: function(component, event) {
        console.log('setChannelandDC Called');
        component.set("v.showSpinner", true);
        var action = component.get("c.fetchChannelandDC");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var empData = response.getReturnValue();
                console.log('response : ', response.getReturnValue());
                var transfer = component.get("v.TO");
                transfer.ERP7__Channel__c = empData.channel;
                if (empData.dontdefaultDC == false) transfer.ERP7__Distribution_Channel__c = empData.distributionChannel.Id;
                transfer.ERP7__From_Site__c = empData.distributionChannel.ERP7__Site__c;
                transfer.ERP7__From_Address__c = empData.distributionChannel.ERP7__Site__r.ERP7__Address__c;
                component.set("v.TO", transfer);
                component.set("v.showToChannel", empData.showToChannel);
                component.set("v.showDCbelow", empData.showDCbelow);
                component.set("v.showTOName", empData.showTOName);
                component.set("v.processSNBatch", empData.processSNBatch);
                component.set("v.showReadyPickPickTO", empData.showReadyPickPickTO);
                if (empData.showToChannel == false && !$A.util.isEmpty(empData.channel) && !$A.util.isUndefinedOrNull(empData.channel)) {
                    component.set("v.TO.ERP7__To_Channel__c", empData.channel);
                }
                if ($A.util.isEmpty(component.get("v.TO.ERP7__To_Channel__c")) || $A.util.isUndefinedOrNull(component.get("v.TO.ERP7__To_Channel__c"))) {
                    component.set("v.showToChannel", true);
                }
                component.set("v.showSpinner", false);
            } else {
                component.set("v.showSpinner", false);
                var errors = response.getError();
                console.log('errors~>', errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        setTimeout(function() {
                            component.set("v.exceptionError", errors[0].message);
                        }, 5000);
                    }
                } else {
                    setTimeout(function() {
                        component.set("v.exceptionError", "Unknown error");
                    }, 5000);
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    
    saveTOandTOLI: function(component, event) {
        console.log('saveTOandTOLI helper called');
        var action = component.get("c.save_TO");
        action.setParams({
            "newTO": JSON.stringify(component.get("v.TO")),
            "toliList": JSON.stringify(component.get("v.TOLI"))
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                console.log('success in saveTOandTOLI');
                this.showToast($A.get('$Label.c.Success'), "success", $A.get('$Label.c.Transfer_Order_created_successfully'));
                var res = response.getReturnValue();
                if (res.ERP7__Tasks__c != null && res.ERP7__Tasks__c != undefined && res.ERP7__Tasks__c != "")
                    this.goBackTask(component, event);
                else {
                    var recordId = res.Id;
                    var RecUrl = "/lightning/r/ERP7__Transfer_Order__c/" + recordId + "/view";
                    window.open(RecUrl, '_parent');
                }
            } else {
                var errors = response.getError();
                console.log('error in saveTOandTOLI~>', errors);
                component.set("v.showSpinner", false);
                component.set("v.disaSave", false);
                component.set("v.exceptionError", errors[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    goBackTask: function(component, event) {
        $A.createComponent("c:AddMilestoneTask", {
            "aura:id": "taskCmp",
            "projectId": component.get("v.projectId"),
            "taskId": component.get("v.Mtask.Id"),
            "newTask": component.get("v.Mtask"),
            "currentMilestones": component.get("v.currentMilestones"),
            "currentProject": component.get("v.currentProject")
        }, function(newCmp, status, errorMessage) {
            if (status === "SUCCESS") {
                var body = component.find("body");
                body.set("v.body", newCmp);
            }
        });
    },
    
    validateFromChannel: function(component, event) {
        var NOerrors = true;
        var fromCh = component.find("toFromChannel");
        if (!$A.util.isUndefined(fromCh) || !$A.util.isEmpty(fromCh))
            NOerrors = this.checkvalidationLookup(fromCh);
        return NOerrors;
    },
    
    validateToChannel: function(component, event) {
        var NOerrors = true;
        var toCh = component.find("tochannelId");
        if (!$A.util.isUndefined(toCh) || !$A.util.isEmpty(toCh))
            NOerrors = this.checkvalidationLookup(toCh);
        return NOerrors;
    },
    
    validateFromDC: function(component, event) {
        var NOerrors = true;
        var fromDC = component.find("toFromDC");
        if (!$A.util.isUndefined(fromDC) || !$A.util.isEmpty(fromDC))
            NOerrors = this.checkvalidationLookup(fromDC);
        return NOerrors;
    },
    
    validateToDC: function(component, event) {
        var NOerrors = true;
        var toDC = component.find("toDC");
        if (!$A.util.isUndefined(toDC) || !$A.util.isEmpty(toDC))
            NOerrors = this.checkvalidationLookup(toDC);
        return NOerrors;
    },
    
    validateTOLIProduct: function(component, event) {
        var NOerrors = true;
        var toliList = component.find("TOLIcmp");
        if (!$A.util.isUndefined(toliList)) {
            if (toliList.length > 0) {
                let flag = true;
                for (let x in toliList)
                    flag = toliList[x].callProdValidate();
                if (!flag) return false;
            } else {
                NOerrors = toliList.callProdValidate();
            }
        } else
            NOerrors = false;
        return NOerrors;
    },
    
    validateTOLIQuantity: function(component, event) {
        var NOerrors = true;
        var toliList = component.find("TOLIcmp");
        if (!$A.util.isUndefined(toliList)) {
            if (toliList.length > 0) {
                let flag = true;
                for (let x in toliList)
                    flag = toliList[x].callQtyValidate();
                if (!flag) return false;
            } else {
                NOerrors = toliList.callQtyValidate();
            }
        } else
            NOerrors = false;
        return NOerrors;
    },
    
    validateTOLISerBat: function(component, event) {
        var NOerrors = true;
        var toliList = component.find("TOLIcmp");
        if (!$A.util.isUndefined(toliList)) {
            if (toliList.length > 0) {
                let flag = true;
                for (let x in toliList)
                    flag = toliList[x].callSerBatValidate();
                if (!flag) return false;
            } else {
                NOerrors = toliList.callSerBatValidate();
            }
        } else
            NOerrors = false;
        return NOerrors;
    },
    
    checkvalidationLookup: function(cmp) {
        if ($A.util.isEmpty(cmp.get("v.selectedRecord.Id"))) {
            cmp.set("v.inputStyleclass", "hasError");
            return false;
        } else {
            cmp.set("v.inputStyleclass", "");
            return true;
        }
    },
    
    checkValidationField: function(cmp) {
        if ($A.util.isEmpty(cmp.get("v.value"))) {
            cmp.set("v.class", "hasError");
            return false;
        } else {
            cmp.set("v.class", "");
            return true;
        }
    },
    
    showToast: function(title, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent != undefined) {
            toastEvent.setParams({
                "mode": "dismissible",
                "title": title,
                "type": type,
                "message": message
            });
            toastEvent.fire();
        }
    },
    
    getDependentPicklists: function(component, event, helper) {
        console.log('getDependentPicklists called');
        var action = component.get("c.getDependentPicklistMap");
        action.setParams({
            ObjectName: component.get("v.objDetail"),
            parentField: component.get("v.controllingFieldAPI"),
            childField: component.get("v.dependingFieldAPI")
        });
        
        action.setCallback(this, function(response) {
            var status = response.getState();
            console.log('status : ', status);
            if (status === "SUCCESS") {
                var pickListResponse = response.getReturnValue();
                console.log('pickListResponse : ', response.getReturnValue());
                component.set("v.depnedentFieldMap", pickListResponse.pickListMap);
                
                var parentkeys = [];
                var parentField = [];
                
                for (var pickKey in pickListResponse.pickListMap) {
                    parentkeys.push(pickKey);
                }
                
                if (parentkeys != undefined && parentkeys.length > 0) {
                    parentField.push('--None--');
                }
                
                for (var i = 0; i < parentkeys.length; i++) {
                    parentField.push(parentkeys[i]);
                }
                component.set("v.listControllingValues", parentField);
                console.log('listControllingValues : ', component.get("v.listControllingValues"));
            } else {
                console.log('err : ', response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getProductDetails: function(component, helper) {
        var action = component.get("c.getProdDetails");
        action.setParams({
            "prodId": component.get('v.prodRecordId'),
            "DCId": component.get("v.TO.ERP7__Distribution_Channel__c")
        });
        action.setCallback(this, function(response) {
            console.log('response.getState() getProductDetails: ', response.getState());
            if (response.getState() === 'SUCCESS') {
                if (response.getReturnValue() != null) {
                    console.log('response : ', response.getReturnValue());
                    var standProds = response.getReturnValue();
                    let productsToAdd = [];
                    let poliadd = {};
                    poliadd.availableQty = standProds.stock;
                    poliadd.ERP7__Products__c = standProds.product.Id;
                    if (component.get("v.processSNBatch")) {
                        poliadd.Serial = standProds.product.ERP7__Serialise__c;
                        poliadd.batch = standProds.product.ERP7__Lot_Tracked__c;
                        if (poliadd.Serial) poliadd.ERP7__Quantity_requested__c = 1;
                    } else {
                        poliadd.Serial = false;
                        poliadd.batch = false;
                    }
                    poliadd.Name = standProds.product.Name;
                    poliadd.ERP7__Description__c = standProds.product.Description;
                    productsToAdd.push(poliadd);
                    component.set('v.TOLI', productsToAdd);
                    if (standProds.errMsg != null && standProds.errMsg != '' && standProds.errMsg != undefined) {
                        helper.showToast($A.get('$Label.c.warning_UserAvailabilities'), 'warning', standProds.errMsg);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})
s