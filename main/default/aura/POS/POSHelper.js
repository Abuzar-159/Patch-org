({
	
    hideSpinner : function (component, event) {
        var spinner = component.find('blueSpin');
        $A.util.addClass(spinner, "slds-hide");    
    },
    
    // automatically call when the component is waiting for a response to a server request.
    showSpinner : function (component, event) {
        var spinner = component.find('blueSpin');
         $A.util.removeClass(spinner, "slds-hide");   
    },
    
    toggleHelper : function(component,event) {
        //alert('1');
        var target = event.getSource().get("v.name");
        //var RecId = target.getElement().parentElement.id;
        //var RecName = target.get("v.value");
        //var nm = component.get("v.name");
        alert(target);
        //var toggleText = component.find(target);
        //var togglec = component.find(target).class;
        //alert('togglec : '+togglec);
        document.getElementById(target).style.display = "block";
        //$A.util.toggleClass(toggleText, "toggle");
        //alert('3');
    },
    
    toggleDiv : function(component,event) {
        $(document).ready(function () {
            $("#toggle").click(function () {
                if ($(this).data('name') == 'show') {
                    $("#sidebar").animate({
                        width: '0%'
                    }).hide()
                    $("#map").animate({
                        width: '100%'
                    });
                    $(this).data('name', 'hide')
                } else {
                    $("#sidebar").animate({
                        width: '19%'
                    }).show()
                    $("#map").animate({
                        width: '80%'
                    });
                    $(this).data('name', 'show')
                }
            });
        });
    },
    
    toggleHelperIn : function(component,event) {
        var target = event.getSource().get("v.name");
        component.set("v.serialShow",true)
        document.getElementById(target).style.display = "block";
    },
    
    toggleHelperOut : function(component,event) {
        var target = event.getSource().get("v.name");
        if(component.get("v.serialShow")){
            document.getElementById(target).style.display = "none";
            component.set("v.serialShow",false)
        }
    },
    
    fetchPaymentType : function(cmp, event, helper) {
        try{
        	var action = cmp.get("c.getPaymentType");
            var inputsel = cmp.find("accountType");
            var opts=[];
            opts.push({"class": "optionClass", label: '--None--', value: ''});
            action.setCallback(this, function(a) {
                for(var i=0;i< a.getReturnValue().length;i++){
                    opts.push({"class": "optionClass", label: a.getReturnValue()[i], value: a.getReturnValue()[i]});
                }
                inputsel.set("v.options", opts);
            });
            $A.enqueueAction(action); 
        } catch(err) {
    		//alert("Exception : "+err.message);
		}
    },
    
    fetchCRUD: function(cmp, event, helper) {
        var action = cmp.get("c.getCRUD");
        action.setCallback(this, function(a) {
            cmp.set("v.crudValues", a.getReturnValue());
        });
        $A.enqueueAction(action);
    }
})