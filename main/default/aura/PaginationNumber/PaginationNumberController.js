({
	doinit : function(component, event, helper) {
    var RecordList=[]; RecordList=component.get("v.RecordList");
    var Entries=component.get("v.Entries");    
    
    var PageNumbers=(RecordList.length)/Entries;                         
    var PageNumbersArray = new Array(); 
    for(var i=0;i<PageNumbers; i++ ){         
        PageNumbersArray.push(i+1);          
    }
    if(PageNumbersArray.length==0) PageNumbersArray.push(1);
    component.set("v.pageNumbers",PageNumbersArray);
    
     if(PageNumbersArray.length==1) component.set("v.nextDisa",true); 
     else  component.set("v.nextDisa",false);     
    var RecordListNew=[]; 
    var counter=component.get("v.counter");    
    if(Entries<=RecordList.length){  counter=counter+Entries;
         for(var i=0;i<Entries; i++) RecordListNew.push(RecordList[i]);
    }  
    else{ counter=RecordList.length;
         for(var i=0;i<RecordList.length; i++) RecordListNew.push(RecordList[i]);
   }   
   component.set("v.counter",counter);
        
    var e = $A.get("e.c:PaginationEvent"); //  component.getEvent("PaginationEvent");                                                       
    e.setParams({
          "RecordList":RecordListNew
    });
    e.fire(); 
  
        setTimeout(
            $A.getCallback(function() {
                if(component.find("PNIds")!=undefined)
                    if(component.find("PNIds")[0]!=undefined) $A.util.addClass(component.find("PNIds")[0].getElement(),"pageNumberClass"); 
                // if(RecordList.length<=Entries) component.set("v.nextDisa",true);              
            }), 2000
        );      
  },
    
  next:function(component,event,helper){
   try{  
    var RecordList=[]; RecordList=component.get("v.RecordList");
    var Entries=component.get("v.Entries");    
    var RecordListNew=[]; 
    var counter=component.get("v.counter");  
          
    if(counter+Entries <=RecordList.length){  
         for(var i=counter; i<counter+Entries; i++) RecordListNew.push(RecordList[i]);
         component.set("v.counter",counter+Entries);
    }  
    else{
         component.set("v.counter",RecordList.length);
         for(var i=counter;i<RecordList.length; i++) RecordListNew.push(RecordList[i]);
         component.set("v.nextDisa",true);
   }   
   
    component.set("v.prevDisa",false);
      
    var e = $A.get("e.c:PaginationEvent"); //  component.getEvent("PaginationEvent");                                                       
    e.setParams({
          "RecordList":RecordListNew
    });
    e.fire();  
    
      
     //@FOR INDICATE CURRENT PAGE RECORDS        
           var idx = parseInt(counter)/parseInt(Entries);          
           var pIds = component.find("PNIds");
           for(var i=0;i<pIds.length; i++){                     
             if(pIds[i]!=undefined) $A.util.removeClass(pIds[i].getElement(),"pageNumberClass");                
           } 
          var ele = pIds[idx].getElement();
          $A.util.addClass(ele,"pageNumberClass"); 
    }catch(ex){
    }   
  },
    
  //##FOR PREVIOUS OF ALL  
  previous : function(component,event,helper){
   try{   
    var RecordList=[]; RecordList=component.get("v.RecordList");
    var Entries=component.get("v.Entries");    
    var RecordListNew=[]; 
    var counter=component.get("v.counter");  
          
    if(counter-Entries <=RecordList.length){  
         var init=parseInt(counter)-parseInt(Entries)-1;
         var des=counter-1;
        
         for(var i=init; i<des; i++) RecordListNew.push(RecordList[i]);
         component.set("v.counter",des);
    }  
    else{ 
        /*
         for(var i=counter-Entries;i<RecordList.length-Entries; i++) RecordListNew.push(RecordList[i]);
         component.set("v.counter",counter-Entries);
         
         */
       // component.set("v.prevDisa",true);  component.set("v.nextDisa",false); 
    }   
   
    if(parseInt(counter)-parseInt(Entries)-1<=0) component.set("v.prevDisa",true);
    component.set("v.nextDisa",false); 
      
    var e = $A.get("e.c:PaginationEvent"); //  component.getEvent("PaginationEvent");                                                       
    e.setParams({
          "RecordList":RecordListNew
    });
       e.fire(); 
       
       //@FOR INDICATE CURRENT PAGE RECORDS 
       try{ 
           var idx = parseInt(counter)/parseInt(Entries);        
           var pIds = component.find("PNIds");
           for(var i=0;i<pIds.length; i++){          
               if(pIds[i]!=undefined) $A.util.removeClass(pIds[i].getElement(),"pageNumberClass");                
           }     
           $A.util.addClass(pIds[parseInt(idx)-1].getElement(),"pageNumberClass"); 
       }catch(ex){
       }
   }catch(ex){
   }    
  }, 
 
})