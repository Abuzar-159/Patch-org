({
    doInit : function(component, event, helper)
    {
        /*BoM Type Picklist*/
        var action = component.get("c.getpickvalBomType");
        var inputselBoMType = component.find("BomType");
        var bomType = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                bomType.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputselBoMType.set("v.options", bomType);
            component.set("v.BomTypeOptions",bomType);
        });
        $A.enqueueAction(action);
        
        
        /*BoM Phase Picklist*/
        var action = component.get("c.getpickvalBomPhase");
        var inputselBoMPhase = component.find("BomPhase");
        var bomPhase = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                bomPhase.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputselBoMPhase.set("v.options", bomPhase);
            component.set("v.BomPhaseOptions",bomPhase);
        });
        $A.enqueueAction(action);
        
        /*BoM UnitOfMeasure Picklist*/
        var action = component.get("c.getpickvalBomUoM");
        var inputselBoMUoM = component.find("BomUoM");
        var bomUom = [];
        action.setCallback(this, function(a) {
            for (var i = 0; i < a.getReturnValue().length; i++) {
                bomUom.push({
                    "class": "optionClass",
                    label: a.getReturnValue()[i],
                    value: a.getReturnValue()[i]
                });
            }
            //inputselBoMUoM.set("v.options", bomUom);
            component.set("v.BomUoMOptions",bomUom);
        });
        $A.enqueueAction(action);
    },
    
    handleDelClick: function(component, event, helper) {
        
        var recId = component.get("v.verBOM.Id");
        
        var result = confirm("Are you sure you want to delete this item?");
        if (result) {
            if (recId != null && recId != undefined) {
                var self = this;
                var deleteAction = component.get("c.deleteBOMVersions");
                deleteAction.setParams({
                    "recordId": recId
                });
                deleteAction.setCallback(self, function(a) {
                    var recordId = a.getReturnValue();
                    if (recordId == null) {} else {
                        var deleteEvent = component.getEvent("delete");
                        deleteEvent.setParams({
                            "listIndex": event.target.dataset.index,
                            "oldRecord": recId 
                        }).fire();
                    }
                });
                $A.enqueueAction(deleteAction);
            } else {
                component.destroy('null');
            }
            return true;
        } else {
            return false;
        }
    },
    handleBOMDelete: function(component, event, helper) {
        component.destroy('null');
    }
})