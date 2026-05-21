({ 
   fetchRecords : function(component, event, helper) {
       var selectedItem = event.currentTarget;
       var Name = selectedItem.dataset.record;
       var Order=event.currentTarget.dataset.service; 
       if(Order=='ASC') component.set("v.Order",'DESC'); //fetchRecords
       else if(Order=='DESC') component.set("v.Order",'ASC');
	   helper.fetchRecords(component,event,helper,Order);
       component.set("v.currentVisId",Name);
	},
    
    mouseOver : function(component, event){
        //alert('Over');
        var selectedItem = event.currentTarget;
        var Name = selectedItem.dataset.record;
        //var currDiv = document.getElementById(Name);
        document.getElementById(Name).style.visibility = "visible";
        /*$A.util.removeClass(currDiv,'edit_hover_class');
        $A.util.addClass(currDiv,'edit_hover_class_hover');*/
        
    },
    
    mouseOut : function(component, event){
        //alert('Out');
        var selectedItem = event.currentTarget;
        var Name = selectedItem.dataset.record;
        //var currDiv = document.getElementById(Name);
        //alert(component.get("v.currentVisId"));
        //alert(Name);
        if(component.get("v.currentVisId") != Name) document.getElementById(Name).style.visibility = "hidden";
        /*$A.util.removeClass(currDiv,'edit_hover_class_hover');
        $A.util.addClass(currDiv,'edit_hover_class');*/
        
    },
})