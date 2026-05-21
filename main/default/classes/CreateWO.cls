public with sharing class CreateWO {
        public WO__c WO                                                    { get; set; }
        public List<Work_Order_Line_Items__c> Wolis                        { get; set; }
        public static Integer addRow                                      { get; set; }
        public Integer nextIdent                                           { get; set; }     
        public static Integer toDelIdent                                   { get; set; } 
        public List<ID> soIds;                                             
        public List<Sales_Order_Line_Item__c> soliList                     { get; set; }                   
        public String SOLIFields                                           { get; set; }
        public String retUrl                                               { get; set; }
        public Boolean flag                                                { get; set; }
        public Boolean sflag                                               { get; set; }
        public String SOID;
        public List<Id> getsoIds(){ return soIds;
        }
        public void setsoIds(List<Id> s){ try{ soIds = s;if(flag != null && !flag){ init();}  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
        }
         public String getSOID(){  try{ return SOID; } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
          }
           public void setSOID(String s){
           try{
                    SOID = s;
                  if(sflag != null && !sflag){ doInit();sflag=true;} } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
                    
        }
       
        public CreateWO() {
        try{
            retUrl = String.escapeSingleQuotes(ApexPages.Currentpage().getParameters().get('retUrl'));
            nextIdent =0;
            flag=false;
            sflag=false;
            soIds = new List<ID>();
            soliList = new List<Sales_Order_Line_Item__c>();
             woliWrapperList = new List<newWrapper>();
             WO = new WO__c(Status__c='New');  
             if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible())
            SOLIFields = UtilClass.selectStarFromSObject('Sales_Order_Line_Item__c');
            UtilClass.FlSCheck(SOLIFields.split(',') ,'Sales_Order_Line_Item__c'); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
           
        }
    
       public void doInit(){
       try{
            if(SOID != null && String.isNotEmpty(SOID)){flag=true;soIds.add(SOID); if(Schema.sObjectType.WO__c.fields.Sales_Order__c.isAccessible()) Wo.Sales_Order__c = String.escapeSingleQuotes(SOID);init();}  } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
            
       } 
        public void init(){
        try{
             if(soIds!= null && soIds.size() > 0) { 
            flag=true;
            if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible())
                soliList = Database.query('select ' + String.escapeSingleQuotes(SOLIFields) + ' ,Sales_Order__r.Name, Sales_Order__r.Order_Date__c, Sales_Order__r.Customer__r.Name, Sales_Order__r.Channel__c, '+
                           +'Product__r.Name, Product__r.Preview_Image__c, Product__r.Picture__c, Sales_Order__r.Authorised__c from Sales_Order_Line_Item__c '+
                           +'where (Sales_Order__c In : soIds) order by Sales_Order__c ASC');                       
    
            }
    
             if(soliList.size() > 0) { for(Sales_Order_Line_Item__c solis: soliList) { newWrapper nwrap = new newWrapper(nextIdent++); if(Schema.sObjectType.Work_Order_Line_Items__c.fields.Active__c.isAccessible()) nwrap.woli.Active__c = true; if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Product__c.isAccessible()) nwrap.woli.Product__c = solis.Product__c; if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Quantity__c.isAccessible()) nwrap.woli.Quantity__c = solis.Quantity__c; if(Schema.sObjectType.Sales_Order_Line_Item__c.isAccessible()) nwrap.woli.Sales_Order_Line_Item__c = solis.Id; if(Schema.sObjectType.Sales_Order_Line_Item__c.fields.Sales_Order__c.isAccessible()) nwrap.woli.Sales_Order__c = solis.Sales_Order__c;woliWrapperList.add(nwrap);
                }
               
            }
            } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
           
        }
        public PageReference back() {
        try{
            return new PageReference(retUrl);} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
        } 
         public PageReference addWoliWrapperRows() { try{ for(Integer i=0; i<addRow; i++) { woliWrapperList.add(new newWrapper(nextIdent++)); } } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
        }
          public PageReference delWoliWrapperRow() { try{ Integer delPos = -1; for(Integer i=0; i<woliWrapperList.size(); i++) {  if (woliWrapperList[i].ident == toDelIdent) delPos = i;
                } if (-1 != delPos) newWrapper poliDel = woliWrapperList.remove(delPos);} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
            }
        public PageReference saveWO() {
        try{
            if(Schema.sObjectType.WO__c.isCreateable() && Schema.sObjectType.WO__c.isUpdateable()){ DMLManager.upsertAsUser(WO); }else{ }
            Wolis = new List<Work_Order_Line_Items__c>();       
            for(newWrapper nwrp: woliWrapperList) { Work_Order_Line_Items__c woli = new Work_Order_Line_Items__c();if(Schema.sObjectType.Work_Order_Line_Items__c.isAccessible()) woli = nwrp.woli; if(Schema.sObjectType.WO__c.isCreateable() && Schema.sObjectType.WO__c.isUpdateable()) woli.Work_Orders__c = WO.Id; Wolis.add(woli);
            }        
            if(Wolis.size() > 0 && Schema.sObjectType.Work_Order_Line_Items__c.isCreateable() && Schema.sObjectType.Work_Order_Line_Items__c.isUpdateable()) DMLManager.upsertAsUser(Wolis);        
            return new PageReference(retUrl); } catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); } return null;
        }
      
        public List<newWrapper> woliWrapperList                   { get; set; }
        public class newWrapper {
                public Purchase_Line_Items__c poli                { get; set; }
                public Work_Order_Line_Items__c woli              { get; set; }  
                public Integer ident                              { get; set; } 
        
                public newWrapper(Integer inIdent) {
                try{
                    ident = inIdent;
                    poli = new Purchase_Line_Items__c();
                    woli = new Work_Order_Line_Items__c();} catch(Exception e) { ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage() +'Line Number @ : '+ e.getLineNumber())); }
                }
            }
        }