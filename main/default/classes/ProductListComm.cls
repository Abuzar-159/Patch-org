public with sharing class ProductListComm {
    
    public ERP7__Invoice__c InvoiceDownload                  { get; set; } 
    public list<ERP7__Invoice_Line_Item__c> invlist    		 {get; set; }
    public void getInvoiceListDownload(){
        String pId = apexpages.currentpage().getparameters().get('Id');
        
        InvoiceDownload=[select Id,RecordType.Name,Name,ERP7__Order__r.Contact__r.Name,Account__r.Company__c,ERP7__Order__r.Bill_To_Address__r.Address_Line1__c,ERP7__Order__r.Bill_To_Address__r.Address_Line2__c,ERP7__Order__r.Bill_To_Address__r.Address_Line3__c,ERP7__Order__r.Bill_To_Address__r.City__c,ERP7__Order__r.Bill_To_Address__r.State__c,ERP7__Order__r.Bill_To_Address__r.Postal_Code__c,ERP7__Order__r.Bill_To_Address__r.Country__c,ERP7__Order__r.Contact__r.Phone,ERP7__Order__r.Ship_To_Address__r.Address_Line1__c,ERP7__Order__r.Ship_To_Address__r.Address_Line2__c,ERP7__Order__r.Ship_To_Address__r.Address_Line3__c,ERP7__Order__r.Ship_To_Address__r.City__c,ERP7__Order__r.Ship_To_Address__r.State__c,ERP7__Order__r.Ship_To_Address__r.Postal_Code__c,ERP7__Order__r.Ship_To_Address__r.Country__c,ERP7__Order__r.ERP7__Total_Shipping_Amount__c,ERP7__Final_Due_Amount__c,ERP7__Order__r.ERP7__Sales_Order_Amount__c,ERP7__Order__r.ERP7__Sub_Total__c,ERP7__Order__r.ERP7__TotalDiscount__c,ERP7__Invoice_Date__c,ERP7__Order__r.Name, ERP7__Organisation__r.Name,ERP7__Organisation__r.BillingCountry,ERP7__Organisation__r.Phone,ERP7__Organisation__r.Fax,ERP7__Organisation__r.BillingStreet,ERP7__Organisation__r.BillingCity,ERP7__Organisation__r.BillingState,ERP7__Organisation__r.ERP7__VAT_registration_number__c  FROM ERP7__Invoice__c WHERE Id =:pId];
        invlist=[select id,Name,ERP7__Product__r.Name,ERP7__Product__r.ProductCode,ERP7__Quantity__c,ERP7__Base_Price__c,ERP7__Discount_Amount__c,ERP7__VAT_Amount__c,ERP7__Other_Tax__c,ERP7__Return_Quantity__c,Total_Price__c from ERP7__Invoice_Line_Item__c where ERP7__Invoice__c =:pId];//EmployeeRequester__r.First_Name__c,EmployeeRequester__r.Last_Name__c,
        
    }
    
    @AuraEnabled
    public static Profile getProfileId(){
        profile pr=new profile();
        Id profileId= userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Id;
        //pr.profId=profileId;
        pr.profId=profileName;
        String name = userinfo.getFirstName()+' '+userinfo.getLastName();//Mohemmad Akhtar
        pr.name=name;
        
        //String guestProfile=[Select Id,Name from Profile where Name='ERP Product catalog Community Profile'].Id;
        String guestProfile;
        if (Test.isRunningTest()) {guestProfile = UserInfo.getProfileId();}
        else {	guestProfile = [SELECT Id FROM Profile WHERE Name = 'ERP Product catalog Community Profile' LIMIT 1].Id;}
       
        if(pr.profId != guestProfile){	//profileId of "ERP Product catalog Community Profile"	(Guest user)
            String userId=userinfo.getUserId();
            pr.user1=[Select Id, Name, CommunityNickname,ContactId from User where id =:userId and IsActive=true Limit 1];
            if(pr.user1.ContactId != null){                List<Contact> conList=[Select Id, Name,AccountId from Contact where Id=:pr.user1.ContactId Limit 1];
                pr.acc=[Select Id, Name from Account where Id =:conList[0].AccountId Limit 1];
                List<ERP7__Cart__c> cart=[Select Id, Name from ERP7__Cart__c where ERP7__Account__c =:pr.acc.Id Limit 1];
                if(cart.size() == 0){
                    ERP7__Cart__c ct=new ERP7__Cart__c();                    ct.Name='Product Cart';                    ct.ERP7__Account__c = pr.acc.Id;
                    if(Schema.sObjectType.ERP7__Cart__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Cart__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Cart__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Cart__c.fields.ERP7__Account__c.isUpdateable()){upsert ct;}else{/*'User have not permission to update or create ERP7__Cart__c FLS')*/}
                }
            }
        }
        
        return pr;
    }
    
    @AuraEnabled
    public static productWrapper getAllProducts(){
        productWrapper allProducts=new productWrapper();
        allProducts.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
        Set<Id> pricebookIds = new Set<Id>();
        for(PriceBook2 pb: allProducts.pricebook)  pricebookIds.add(pb.Id);         
        allProducts.allProd = Database.query('Select Id,Name,CreatedDate, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family,Product2.ERP7__Category__c,Product2.ERP7__Sub_Category__c from PricebookEntry where Pricebook2Id In :pricebookIds AND Product2Id IN (Select Id From Product2 where IsActive=TRUE)');        
        return allProducts;
    }
    
    @AuraEnabled
    public static List<AggregateResult> getFamilyList(){
        List<AggregateResult> familyList = [Select Count(Id) total,Family type FROM Product2  Group by Family limit 10000];
        return familyList;
    }
    
    @AuraEnabled
    public static productWrapper getCatList(String accId, List<Id> guestProds){
        productWrapper category=new productWrapper();
        
        category.cartList = [Select Id, Name from ERP7__Cart__c where ERP7__Account__c=:accId];
        if(category.cartList.size() > 0)
            category.cartpickitemList = [Select Id, Name, ERP7__Product__c, ERP7__Quantity__c from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =:category.cartList[0].Id];
        
        //=============================================
        Set<Id> pricebookIds = new Set<Id>();
        List<PricebookEntry> pbe;
        if(accId != ''){
            category.acc=[Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id =: accId];
            if(category.acc.ERP7__Order_Profile__c != null){
                category.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:category.acc.ERP7__Order_Profile__c];
                for(ERP7__Profiling__c profile: category.profiling){
                pricebookIds.add(profile.ERP7__Price_Book__c);
            } 
            }else{
                category.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
                for(PriceBook2 pb: category.pricebook){
                    pricebookIds.add(pb.Id);
                }
            }
             
            Set<Id> proId =new Set<Id>();
            for(ERP7__Cart_Picked_Item__c cpi : category.cartpickitemList)	proId.add(cpi.ERP7__Product__c);            
            pbe = Database.query('Select Id,Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND Product2Id IN (Select Id From Product2 where Id In :proId AND IsActive=TRUE)');
            
        }else{
            //===============Guest User================= 
            category.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
            for(PriceBook2 pb: category.pricebook){
                pricebookIds.add(pb.Id);
            }
            pbe = Database.query('Select Id,Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND Product2Id IN (Select Id From Product2 where Id In :guestProds AND IsActive=TRUE)');
            
        }
        List <Id> productIds = new List <Id>();
        for(PricebookEntry IPE: pbe)   
            productIds.add(IPE.Product2Id);
        
        
        category.media=[Select Id, Name, ERP7__Active__c,ERP7__File__c,ERP7__Product__c,ERP7__Type__c from ERP7__Media__c where ERP7__Product__c In :productIds];	// and ERP7__Type__c ='Picture'
        /* //commented 02-11-2022 Nayeem for Media Images 
        Map<String,Id> prodMedia =new Map<String,Id>();
        Set<Id> parentIdList=new Set<Id>();
        for(ERP7__Media__c media1 : category.media){
            parentIdList.add(media1.Id);
            prodMedia.put(media1.ERP7__Product__c, media1.Id);
        }
        
        List<Attachment> attList=new List<Attachment>();
        for(Id parentList:parentIdList){
            List<Attachment> att=[select Id, Name, ParentId from Attachment where ParentId =:parentList and ContentType in ('image/jpeg', 'image/gif') Limit 1]; 
            if(att.size() > 0) attList.addAll(att);            
        }
        
        
        Map<String,Attachment> mapList=new Map<String,Attachment>();//Map<ProductId,List<Attachment>>
        for(integer i=0; i<attList.size(); i++){
            for(String objVar : prodMedia.keySet()){
                if(attList[i].ParentId == prodMedia.get(objVar)) mapList.put(objVar,attList[i]);            	
            }            
        }   
        */
        
        Map<String,Id> prodMedia =new Map<String,Id>();
            Set<Id> LinkedEntityId=new Set<Id>();
            for(ERP7__Media__c media1 : category.media){
                LinkedEntityId.add(media1.Id); 
                prodMedia.put(media1.ERP7__Product__c, media1.Id);
            }
            List<ContentDocumentLink> conDocLink=new List<ContentDocumentLink>();
            if(LinkedEntityId.size() > 0) conDocLink = [select Id, ContentDocumentId, LinkedEntityId, Visibility From ContentDocumentLink where LinkedEntityId In :LinkedEntityId]; 
            system.debug('LinkedEntityId'+LinkedEntityId.size());
            system.debug('conDocLink'+conDocLink);
            
            Map<String,ContentDocumentLink> mapList=new Map<String,ContentDocumentLink>();//Map<ProductId,List<Attachment>>
            for(integer i=0; i<conDocLink.size(); i++){
                for(String objVar : prodMedia.keySet()){
                    if(conDocLink[i].LinkedEntityId == prodMedia.get(objVar)){                        mapList.put(objVar,conDocLink[i]);
                    }
                }            
            }
        
        for(PricebookEntry pbe1 : pbe){
            PriceBookWrapper wrapper=new PriceBookWrapper();
            wrapper.pbe= pbe1;
            if(mapList.get(pbe1.Product2Id) != null) wrapper.ContentDoc=mapList.get(pbe1.Product2Id);   
            category.prodList.add(wrapper);
        }   
        //=============================================
        return category;
    }
    
    @AuraEnabled
    public static productWrapper productFetch(String accId, String sortOrd){
        
        productWrapper prod=new productWrapper();      
        List<String> family = new List<String>();
        Schema.DescribeFieldResult fieldResult1 = product2.Family.getDescribe();
        List < Schema.PicklistEntry > ple1 = fieldResult1.getPicklistValues();
        for(Schema.PicklistEntry f: ple1){ 
            if(f.isActive())  family.add(f.getValue());            
        }
        
        Set<Id> pricebookIds = new Set<Id>();
        List <Id> siteIds = new List <Id> ();
        
        if(accId != ''){
            prod.acc=[Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id =: accId];            
            if(prod.acc.ERP7__Order_Profile__c != null){
                prod.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:prod.acc.ERP7__Order_Profile__c];            
                for(ERP7__Profiling__c profile: prod.profiling){
                    pricebookIds.add(profile.ERP7__Price_Book__c);
                }
                prod.channel = [Select Id, Name from ERP7__Channel__c where Id=:prod.profiling[0].ERP7__Channel__c and ERP7__Active__c=true];
                
                prod.DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                             where ERP7__Channel__c=:prod.channel.Id and ERP7__Active__c=true];
                
                if(prod.DistributionChannels.size() > 0) {
                    for(Distribution_Channel__c DC: prod.DistributionChannels) {
                        siteIds.add(DC.Site__c);
                    }
                }
            }else{
                prod.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
                for(PriceBook2 pb: prod.pricebook){
                    pricebookIds.add(pb.Id);
                }
                List<ERP7__Site__c> siteList=[Select Id,Name,ERP7__Address__c,ERP7__Address__r.ERP7__Country__c from ERP7__Site__c where ERP7__Active__c =true AND ERP7__Address__c !=null Limit 2];
                for(ERP7__Site__c st:siteList){                    siteIds.add(st.Id);
                }
            }
			system.debug('siteIds'+siteIds.size());            
        }else{
            //===============Guest User================= 
            prod.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
            for(PriceBook2 pb: prod.pricebook){
                pricebookIds.add(pb.Id);
            }
            List<ERP7__Site__c> siteList=[Select Id,Name,ERP7__Address__c,ERP7__Address__r.ERP7__Country__c from ERP7__Site__c where ERP7__Active__c =true AND ERP7__Address__c !=null Limit 2];  
            for(ERP7__Site__c st:siteList){                siteIds.add(st.Id);
            }
            //===============/Guest User=================
        }
        List<PricebookEntry> pbe;
        pbe = Database.query('Select Id,Name,CreatedDate, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family,Product2.ERP7__Category__c,Product2.ERP7__Sub_Category__c from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where Family In :family AND IsActive=TRUE) order By '+String.escapeSingleQuotes(sortOrd)+' desc');
        
        List <Id> productIds = new List <Id>();
        for(PricebookEntry IPE: pbe)   productIds.add(IPE.Product2Id);
        
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
        if(productIds.size() > 0) {
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                            Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,
                                            Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                            From Inventory_Stock__c
                                            Where product__c In: productIds And
                                            Active__c = true And
                                            Warehouse__c In: siteIds And                                                 
                                            Number_of_Item_In_Stock__c > 0
                                           ];
        }
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){            stockView.put(inven.product__c, inven.Number_of_Item_In_Stock__c);
        }        
        
        //====================Meadia fetch=========================
       
        prod.media=[Select Id, Name, ERP7__Active__c,ERP7__File__c,ERP7__Product__c,ERP7__Type__c from ERP7__Media__c where ERP7__Product__c In :productIds];	// and ERP7__Type__c ='Picture'
        /* //commented 02-11-2022 Nayeem for Media Images 
        Map<String,Id> prodMedia =new Map<String,Id>();
        Set<Id> parentIdList=new Set<Id>();
        for(ERP7__Media__c media1 : prod.media){
            parentIdList.add(media1.Id);
            prodMedia.put(media1.ERP7__Product__c, media1.Id);
        }
        List<Attachment> attList=new List<Attachment>();
        for(Id parentList:parentIdList){
            List<Attachment> att=[select Id, Name, ParentId from Attachment where ParentId =:parentList and ContentType in ('image/jpeg', 'image/gif') Limit 1]; 
            if(att.size() > 0) attList.addAll(att);            
        }
        
        Map<String,Attachment> mapList=new Map<String,Attachment>();//Map<ProductId,List<Attachment>>
        for(integer i=0; i<attList.size(); i++){
            for(String objVar : prodMedia.keySet()){
                if(attList[i].ParentId == prodMedia.get(objVar)){
                    mapList.put(objVar,attList[i]);
                }
            }            
        }   */
        
        Map<String,Id> prodMedia =new Map<String,Id>();
            Set<Id> LinkedEntityId=new Set<Id>();
            for(ERP7__Media__c media1 : prod.media){
                LinkedEntityId.add(media1.Id); 
                prodMedia.put(media1.ERP7__Product__c, media1.Id);
            }
            List<ContentDocumentLink> conDocLink=new List<ContentDocumentLink>();
            if(LinkedEntityId.size() > 0) conDocLink = [select Id, ContentDocumentId, LinkedEntityId, Visibility From ContentDocumentLink where LinkedEntityId In :LinkedEntityId]; 
            system.debug('LinkedEntityId'+LinkedEntityId.size());
            system.debug('conDocLink'+conDocLink);
            
            Map<String,ContentDocumentLink> mapList=new Map<String,ContentDocumentLink>();//Map<ProductId,List<Attachment>>
            for(integer i=0; i<conDocLink.size(); i++){
                for(String objVar : prodMedia.keySet()){
                    if(conDocLink[i].LinkedEntityId == prodMedia.get(objVar)){                        mapList.put(objVar,conDocLink[i]);
                    }
                }            
            }
        
        //=============================================          
        for(PricebookEntry pbe1 : pbe){
            PriceBookWrapper wrapper=new PriceBookWrapper();
            wrapper.pbe= pbe1;
            if(mapList.get(pbe1.Product2Id) != null) wrapper.ContentDoc=mapList.get(pbe1.Product2Id);            
            wrapper.stock = (stockView.get(pbe1.Product2Id)!= null)? stockView.get(pbe1.Product2Id):0.00;
            prod.prodList.add(wrapper);
        }
        return prod;
    }
    
    @AuraEnabled
    public static productWrapper fetchProdByCat(String accId, List<String> catogeries, String sortOrd, String searchText, String catSel){
        String searchText1= '%'+searchText+'%';
        productWrapper prod=new productWrapper();
        Set<Id> pricebookIds = new Set<Id>();
        List <Id> siteIds = new List <Id> ();        
        String catog=null;
        
        if(accId != ''){
            prod.acc=[Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id =: accId];
            if(prod.acc.ERP7__Order_Profile__c != null){
            	prod.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:prod.acc.ERP7__Order_Profile__c];
                for(ERP7__Profiling__c profile: prod.profiling){
                    pricebookIds.add(profile.ERP7__Price_Book__c);
                }
                prod.channel = [Select Id, Name from ERP7__Channel__c where Id=:prod.profiling[0].ERP7__Channel__c and ERP7__Active__c=true];
                
                prod.DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                             where ERP7__Channel__c=:prod.channel.Id and ERP7__Active__c=true];
                
                if(prod.DistributionChannels.size() > 0) {
                    for(Distribution_Channel__c DC: prod.DistributionChannels) {
                        siteIds.add(DC.Site__c);
                    }
                }
            }else{
                prod.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
                for(PriceBook2 pb: prod.pricebook){
                    pricebookIds.add(pb.Id);
                }
                List<ERP7__Site__c> siteList=[Select Id,Name,ERP7__Address__c,ERP7__Address__r.ERP7__Country__c from ERP7__Site__c where ERP7__Active__c =true AND ERP7__Address__c !=null Limit 2];
                for(ERP7__Site__c st:siteList){                    siteIds.add(st.Id);
                }
            }
        }else{
            //===============Guest User================= 
            prod.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
            for(PriceBook2 pb: prod.pricebook){
                pricebookIds.add(pb.Id);
            }      
            List<ERP7__Site__c> siteList=[Select Id,Name,ERP7__Address__c,ERP7__Address__r.ERP7__Country__c from ERP7__Site__c where ERP7__Active__c=true AND ERP7__Address__c !=null Limit 2];
            for(ERP7__Site__c st:siteList){                siteIds.add(st.Id);
            }
            //===============/Guest User=================
        }
        
        for(String cat:catogeries){
            if(cat =='All') catog='All';
            else if(cat != 'All') catog=null;
        }
        
        List<PricebookEntry> pbe;
        
        if(catSel != ''){
            if(sortOrd == 'CreatedDate')
                pbe = Database.query('Select Id,Name,CreatedDate, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c,Product2.ERP7__Category__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND ERP7__Category__c =\''+String.escapeSingleQuotes(catSel)+'\') order By '+String.escapeSingleQuotes(sortOrd)+' desc');
            else if(sortOrd == 'price')
                pbe = [Select Id,Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND ERP7__Category__c =:catSel) Order By UnitPrice ASC];
            else if(sortOrd == 'pricedesc')
                pbe = [Select Id,Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND ERP7__Category__c =:catSel) Order By UnitPrice Desc];           
        }
        else if(searchText != ''){
                                  if(sortOrd == 'CreatedDate')
                                      pbe = Database.query('Select Id,Name,CreatedDate, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name Like : searchText1) order By '+String.escapeSingleQuotes(sortOrd)+' desc');
                                  else if(sortOrd == 'price')
                                      pbe = Database.query('Select Id,Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name Like : searchText1) Order By UnitPrice ASC');
                                  else if(sortOrd == 'pricedesc')
                                      pbe = Database.query('Select Id,Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name Like : searchText1) Order By UnitPrice Desc');
                                  
                                 }
        else if(catogeries.IsEmpty() || catog == 'All'){
            List<String> family = new List<String>();
            Schema.DescribeFieldResult fieldResult1 = product2.Family.getDescribe();
            List < Schema.PicklistEntry > ple1 = fieldResult1.getPicklistValues();
            for(Schema.PicklistEntry f: ple1){ 
                if(f.isActive())  family.add(f.getValue());            
            }
            
            if(sortOrd == 'CreatedDate')
                pbe = Database.query('Select Id,Name,CreatedDate, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where Family In :family AND IsActive=TRUE) order By '+String.escapeSingleQuotes(sortOrd)+' desc');
            else if(sortOrd == 'price')
                pbe = [Select Id, Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where Family In :family AND IsActive=TRUE) Order By UnitPrice ASC];
            else if(sortOrd == 'pricedesc')
                pbe = [Select Id, Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where Family In :family AND IsActive=TRUE) Order By UnitPrice Desc];
            
        }
        else{
            if(sortOrd == 'CreatedDate')
                pbe = Database.query('Select Id,Name,CreatedDate, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where Family In :catogeries AND IsActive=TRUE) order By '+String.escapeSingleQuotes(sortOrd)+' desc');
            else if(sortOrd == 'price')
                pbe = [Select Id,Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where Family In :catogeries AND IsActive=TRUE) Order By UnitPrice ASC];
            else if(sortOrd == 'pricedesc')
                pbe = [Select Id,Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND IsActive=TRUE AND Product2Id IN (Select Id From Product2 where Family In :catogeries AND IsActive=TRUE) Order By UnitPrice Desc];
        }
        
        List <Id> productIds = new List <Id>();
        for(PricebookEntry IPE: pbe)   productIds.add(IPE.Product2Id);
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
        if(productIds.size() > 0) {
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                            Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,
                                            Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                            From Inventory_Stock__c
                                            Where product__c In: productIds And
                                            Active__c = true And
                                            Warehouse__c In: siteIds And
                                            Number_of_Item_In_Stock__c > 0
                                           ];
        }            
        
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
            stockView.put(inven.product__c, inven.Number_of_Item_In_Stock__c);
        }
        //====================Meadia fetch=========================
        
        prod.media=[Select Id, Name, ERP7__Active__c,ERP7__File__c,ERP7__Product__c,ERP7__Type__c from ERP7__Media__c where ERP7__Product__c In :productIds];	// and ERP7__Type__c ='Picture'
        
        /* //commented 02-11-2022 Nayeem for Media Images 
        Map<String,Id> prodMedia =new Map<String,Id>();
        Set<Id> parentIdList=new Set<Id>();
        for(ERP7__Media__c media1 : prod.media){
            parentIdList.add(media1.Id);
            prodMedia.put(media1.ERP7__Product__c, media1.Id);
        }
        
        List<Attachment> attList=new List<Attachment>();
        for(Id parentList:parentIdList){
            List<Attachment> att=[select Id, Name, ParentId from Attachment where ParentId =:parentList and ContentType in ('image/jpeg', 'image/gif') Limit 1]; 
            if(att.size() > 0) attList.addAll(att);            
        }
        
        Map<String,Attachment> mapList=new Map<String,Attachment>();
        for(integer i=0; i<attList.size(); i++){
            for(String objVar : prodMedia.keySet()){
                if(attList[i].ParentId == prodMedia.get(objVar)){
                    mapList.put(objVar,attList[i]);
                }
            }            
        }
	*/
         Map<String,Id> prodMedia =new Map<String,Id>();
            Set<Id> LinkedEntityId=new Set<Id>();
            for(ERP7__Media__c media1 : prod.media){
                LinkedEntityId.add(media1.Id); 
                prodMedia.put(media1.ERP7__Product__c, media1.Id);
            }
            List<ContentDocumentLink> conDocLink=new List<ContentDocumentLink>();
            if(LinkedEntityId.size() > 0) conDocLink = [select Id, ContentDocumentId, LinkedEntityId, Visibility From ContentDocumentLink where LinkedEntityId In :LinkedEntityId]; 
            system.debug('LinkedEntityId'+LinkedEntityId.size());
            system.debug('conDocLink'+conDocLink);
            
            Map<String,ContentDocumentLink> mapList=new Map<String,ContentDocumentLink>();//Map<ProductId,List<Attachment>>
            for(integer i=0; i<conDocLink.size(); i++){
                for(String objVar : prodMedia.keySet()){
                    if(conDocLink[i].LinkedEntityId == prodMedia.get(objVar)){                        mapList.put(objVar,conDocLink[i]);
                    }
                }            
            }
        
        //===================/Meadia fetch==========================
        for(PricebookEntry pbe1 : pbe){
            PriceBookWrapper wrapper=new PriceBookWrapper();
            wrapper.pbe= pbe1;
            if(mapList.get(pbe1.Product2Id) != null) wrapper.ContentDoc=mapList.get(pbe1.Product2Id); 
            wrapper.stock = (stockView.get(pbe1.Product2Id)!= null)? stockView.get(pbe1.Product2Id):0.00;
            prod.prodList.add(wrapper);
        }
        
        return prod;
    }    
    
    @AuraEnabled
    public static productWrapper saveCarts(String accId, String prodId){
        productWrapper saveCart=new productWrapper();        Set<Id> pricebookIds = new Set<Id>();
        
        if(accId != ''){
            saveCart.acc = [Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id=:accId];
            if(saveCart.acc.ERP7__Order_Profile__c != null){
                saveCart.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:saveCart.acc.ERP7__Order_Profile__c];
                for(ERP7__Profiling__c profile: saveCart.profiling){                    pricebookIds.add(profile.ERP7__Price_Book__c);
                }
            }else{
                saveCart.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
                for(PriceBook2 pb: saveCart.pricebook){                    pricebookIds.add(pb.Id);
                } 
            }
        }
        else{
            //=========Guest user=========
            saveCart.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
            for(PriceBook2 pb: saveCart.pricebook){                pricebookIds.add(pb.Id);
            }
        }
        
        saveCart.cartList = [Select Id, Name, ERP7__Account__c, ERP7__Account__r.ERP7__Order_Profile__c,ERP7__Account__r.ERP7__Order_Profile__r.ERP7__Price_Book__c, ERP7__Channel__c, 
                             ERP7__Site__c from ERP7__Cart__c where ERP7__Account__c=:accId];
        saveCart.pricebook = [Select Id, Name, isActive from PriceBook2 where isActive=true and Id in: pricebookIds];
        List<PricebookEntry> pbe = [Select Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c from PricebookEntry where Pricebook2Id in: pricebookIds AND Product2Id IN (Select Id From Product2 where Id =: prodId AND IsActive=TRUE)];//  
        
        List<ERP7__Cart_Picked_Item__c> cpiProd=[Select Id,Name,ERP7__Cart__c,ERP7__Product__c,ERP7__Quantity__c from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =:saveCart.cartList[0].Id AND ERP7__Product__c =:prodId];
        
        ERP7__Cart_Picked_Item__c cpi;
        if(cpiProd.size() != 0){
            for(ERP7__Cart_Picked_Item__c cpi1:cpiProd){
                if(cpi1.ERP7__Product__c ==  prodId){                    cpi1.ERP7__Quantity__c +=1;
                    if(Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isUpdateable()){update cpi1;}else{/*'User have not permission to insert or create ERP7__Cart_Picked_Item__c FLS'*/}
                }
            }
        }
        else{
            for(PricebookEntry pbe1 :pbe){
                cpi = new ERP7__Cart_Picked_Item__c();
                cpi.Name= pbe1.Product2.Name;                cpi.ERP7__Cart__c = saveCart.cartList[0].Id;                cpi.ERP7__Product__c = pbe1.Product2Id;                cpi.ERP7__Quantity__c = 1;
            }
            // && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Cart__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Cart__c.isUpdateable()		//FLS Not working on lookup fields            
            if(Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isUpdateable()){upsert cpi;}else{/*('User have not permission to update or insert in ERP7__Cart_Picked_Item__c FLS')*/}
        }
        saveCart.cartpickitemList = [Select Id,Name,ERP7__Cart__c,ERP7__Product__c,ERP7__Quantity__c from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =:saveCart.cartList[0].Id];
        return saveCart;
    }
    
    @AuraEnabled
    public static productWrapper addTocart(String accId, String prodId, Decimal quant){
        productWrapper addCart=new productWrapper();
        Set<Id> pricebookIds = new Set<Id>();
        
        if(accId != ''){
            addCart.acc = [Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id=:accId];
            if(addCart.acc.ERP7__Order_Profile__c != null){
                addCart.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:addCart.acc.ERP7__Order_Profile__c];
                for(ERP7__Profiling__c profile: addCart.profiling){
                    pricebookIds.add(profile.ERP7__Price_Book__c);
                }
            }else{
                addCart.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
                for(PriceBook2 pb: addCart.pricebook){
                    pricebookIds.add(pb.Id);
                }
            }
        }
        else{
            //=========Guest user=========
            addCart.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
            for(PriceBook2 pb: addCart.pricebook){                pricebookIds.add(pb.Id);
            }
        }
        
        addCart.cartList = [Select Id, Name, ERP7__Account__c, ERP7__Account__r.ERP7__Order_Profile__c,ERP7__Account__r.ERP7__Order_Profile__r.ERP7__Price_Book__c, ERP7__Channel__c, 
                            ERP7__Site__c from ERP7__Cart__c where ERP7__Account__c=:accId];
        addCart.pricebook = [Select Id, Name, isActive from PriceBook2 where isActive=true and Id in: pricebookIds];
        List<PricebookEntry> pbe = [Select Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c from PricebookEntry where Pricebook2Id in: pricebookIds AND Product2Id IN (Select Id From Product2 where Id =: prodId AND IsActive=TRUE)];
        
        
        List<ERP7__Cart_Picked_Item__c> cpiProd=[Select Id,Name,ERP7__Cart__c,ERP7__Product__c,ERP7__Quantity__c from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =:addCart.cartList[0].Id AND ERP7__Product__c =:prodId];
        ERP7__Cart_Picked_Item__c cpi;
        if(cpiProd.size() != 0){
            for(ERP7__Cart_Picked_Item__c cpi1:cpiProd){
                if(cpi1.ERP7__Product__c ==  prodId){
                    cpi1.ERP7__Quantity__c +=quant;
                    if(Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isUpdateable()){update cpi1;}else{/*'User have not permission to insert or create ERP7__Cart_Picked_Item__c FLS');*/}
                }
            }
        }
        else{
            for(PricebookEntry pbe1 :pbe){
                cpi = new ERP7__Cart_Picked_Item__c();
                cpi.Name= pbe1.Product2.Name;                cpi.ERP7__Cart__c = addCart.cartList[0].Id;                cpi.ERP7__Product__c = pbe1.Product2Id;                cpi.ERP7__Quantity__c = quant;
            }//Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Cart__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Cart__c.isUpdateable() &&
            if(Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isUpdateable()){upsert cpi;}else{/*'User have not permission to update or insert in ERP7__Cart_Picked_Item__c FLS2');*/}
        }
        addCart.cartpickitemList = [Select Id,Name,ERP7__Cart__c,ERP7__Product__c,ERP7__Quantity__c from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =:addCart.cartList[0].Id];
        
        return addCart;
    }
    
    @AuraEnabled
    public static productWrapper addTocartForConf(String accId, String prodId, Decimal quant, String newVId){
        productWrapper addCart=new productWrapper();
        Set<Id> pricebookIds = new Set<Id>();
        
        if(accId != ''){
            addCart.acc = [Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id=:accId];
            if(addCart.acc.ERP7__Order_Profile__c != null){
                addCart.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:addCart.acc.ERP7__Order_Profile__c];
                for(ERP7__Profiling__c profile: addCart.profiling){
                    pricebookIds.add(profile.ERP7__Price_Book__c);
                }
            }else{
                addCart.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
                for(PriceBook2 pb: addCart.pricebook){
                    pricebookIds.add(pb.Id);
                }
            }
        }
        else{
            //=========Guest user=========
            addCart.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
            for(PriceBook2 pb: addCart.pricebook){                pricebookIds.add(pb.Id);
            }
        }
        
        addCart.cartList = [Select Id, Name, ERP7__Account__c, ERP7__Account__r.ERP7__Order_Profile__c,ERP7__Account__r.ERP7__Order_Profile__r.ERP7__Price_Book__c, ERP7__Channel__c, 
                            ERP7__Site__c from ERP7__Cart__c where ERP7__Account__c=:accId];
        addCart.pricebook = [Select Id, Name, isActive from PriceBook2 where isActive=true and Id in: pricebookIds];
        List<PricebookEntry> pbe = [Select Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c from PricebookEntry where Pricebook2Id in: pricebookIds AND Product2Id IN (Select Id From Product2 where Id =: prodId AND IsActive=TRUE)];
        
        
        List<ERP7__Cart_Picked_Item__c> cpiProd=[Select Id,Name,ERP7__Cart__c,ERP7__Product__c,ERP7__Quantity__c from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =:addCart.cartList[0].Id AND ERP7__Product__c =:prodId];
        ERP7__Cart_Picked_Item__c cpi;
        if(cpiProd.size() != 0){
            for(ERP7__Cart_Picked_Item__c cpi1:cpiProd){
                if(cpi1.ERP7__Product__c ==  prodId){
                    cpi1.ERP7__Quantity__c +=quant;
                    cpi1.ERP7__Product_Version__c=newVId;
                    if(Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product_Version__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product_Version__c.isUpdateable()){update cpi1;}else{/*'User have not permission to insert or create ERP7__Cart_Picked_Item__c FLS');*/}
                }
            }
        }
        else{
            for(PricebookEntry pbe1 :pbe){
                cpi = new ERP7__Cart_Picked_Item__c();
                cpi.Name= pbe1.Product2.Name;                cpi.ERP7__Cart__c = addCart.cartList[0].Id;                cpi.ERP7__Product__c = pbe1.Product2Id;                cpi.ERP7__Quantity__c = quant;                cpi.ERP7__Product_Version__c=newVId;
            }//&& Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Cart__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Cart__c.isUpdateable()
            if(Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product_Version__c.isCreateable() && Schema.sObjectType.ERP7__Cart_Picked_Item__c.fields.ERP7__Product_Version__c.isUpdateable()){upsert cpi;}else{/*('User have not permission to update or insert in ERP7__Cart_Picked_Item__c FLS')*/}
        }
        addCart.cartpickitemList = [Select Id,Name,ERP7__Cart__c,ERP7__Product__c,ERP7__Quantity__c from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =:addCart.cartList[0].Id];
        
        return addCart;
    }
    
    @AuraEnabled
    public static productWrapper viewCart(String accId, List<Id> guestProds){
        productWrapper viewCart=new productWrapper();
        Set<Id> pricebookIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        List<ERP7__Cart_Picked_Item__c> cpiList =new List<ERP7__Cart_Picked_Item__c>();
        if(accId != ''){
            viewCart.acc = [Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id=:accId];
            if(viewCart.acc.ERP7__Order_Profile__c != null){
                viewCart.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:viewCart.acc.ERP7__Order_Profile__c];
                for(ERP7__Profiling__c profile: viewCart.profiling){
                    pricebookIds.add(profile.ERP7__Price_Book__c);
                }
            }else{
                viewCart.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
                for(PriceBook2 pb: viewCart.pricebook){
                    pricebookIds.add(pb.Id);
                } 
            }
            viewCart.cartList = [Select Id, Name, ERP7__Account__c, ERP7__Account__r.ERP7__Order_Profile__c,ERP7__Account__r.ERP7__Order_Profile__r.ERP7__Price_Book__c, ERP7__Channel__c, 
                                 ERP7__Site__c from ERP7__Cart__c where ERP7__Account__c=:accId];
            viewCart.cartpickitemList = [Select Id, Name, ERP7__Product__c, ERP7__Quantity__c,ERP7__Product_Version__c from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =:viewCart.cartList[0].Id];
            
            for(ERP7__Cart_Picked_Item__c cpi : viewCart.cartpickitemList){
                productIds.add(cpi.ERP7__Product__c);
                //prodQuan.put(cpi.ERP7__Product__c, cpi.ERP7__Quantity__c);
                cpiList.add(cpi);
            }  
        }
        else{
            //=========Guest user=========  
            viewCart.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
            for(PriceBook2 pb: viewCart.pricebook){
                pricebookIds.add(pb.Id);
            }    
            productIds = new Set<Id>(guestProds);            
        }
        viewCart.cartproduct = [Select Id, Name, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family from PricebookEntry where Pricebook2Id In :pricebookIds AND Product2Id IN (Select Id From Product2 where Id In :productIds AND IsActive=TRUE)];
        
        //========================================
        viewCart.media=[Select Id, Name, ERP7__Active__c,ERP7__File__c,ERP7__Product__c,ERP7__Type__c from ERP7__Media__c where ERP7__Product__c In :productIds];	// and ERP7__Type__c ='Picture'
        /* //commented 02-11-2022 Nayeem for Media Images 
        Map<String,Id> prodMedia =new Map<String,Id>();
        Set<Id> parentIdList=new Set<Id>();
        for(ERP7__Media__c media1 : viewCart.media){
            parentIdList.add(media1.Id);
            prodMedia.put(media1.ERP7__Product__c, media1.Id);
        }
        
        List<Attachment> attList=new List<Attachment>();
        for(Id parentList:parentIdList){
            List<Attachment> att=[select Id, Name, ParentId from Attachment where ParentId =:parentList and ContentType in ('image/jpeg', 'image/gif') Limit 1]; 
            if(att.size() > 0) attList.addAll(att);            
        }
        
        
        Map<String,Attachment> mapList=new Map<String,Attachment>();//Map<ProductId,List<Attachment>>
        
        for(integer i=0; i<attList.size(); i++){
            for(String objVar : prodMedia.keySet()){ if(attList[i].ParentId == prodMedia.get(objVar)) mapList.put(objVar,attList[i]);            	
                                                   }            
        } */
        
        Map<String,Id> prodMedia =new Map<String,Id>();
            Set<Id> LinkedEntityId=new Set<Id>();
            for(ERP7__Media__c media1 : viewCart.media){
                LinkedEntityId.add(media1.Id); 
                prodMedia.put(media1.ERP7__Product__c, media1.Id);
            }
            List<ContentDocumentLink> conDocLink=new List<ContentDocumentLink>();
            if(LinkedEntityId.size() > 0) conDocLink = [select Id, ContentDocumentId, LinkedEntityId, Visibility From ContentDocumentLink where LinkedEntityId In :LinkedEntityId]; 
            system.debug('LinkedEntityId'+LinkedEntityId.size());
            system.debug('conDocLink'+conDocLink);
            
            Map<String,ContentDocumentLink> mapList=new Map<String,ContentDocumentLink>();//Map<ProductId,List<Attachment>>
            for(integer i=0; i<conDocLink.size(); i++){
                for(String objVar : prodMedia.keySet()){
                    if(conDocLink[i].LinkedEntityId == prodMedia.get(objVar)){                        mapList.put(objVar,conDocLink[i]);
                    }
                }            
            }
        
        //========================================
        if(accId != ''){
            for(PricebookEntry pbe : viewCart.cartproduct){
                cartProdWrapper cpw = new cartProdWrapper();
                cpw.cartproduct= pbe;
                for(ERP7__Cart_Picked_Item__c cpiLi:cpiList){
                    if(cpiLi.ERP7__Product__c == pbe.Product2Id)    cpw.cpiList = cpiLi;
                    if(mapList.get(pbe.Product2Id) != null) cpw.ContentDoc=mapList.get(pbe.Product2Id);
                }
                viewCart.cartproductWrapper.add(cpw);
            }
        }else{
            for(PricebookEntry pbe : viewCart.cartproduct){
                cartProdWrapper cpw = new cartProdWrapper();
                cpw.cartproduct= pbe;
                if(mapList.get(pbe.Product2Id) != null) cpw.ContentDoc=mapList.get(pbe.Product2Id);
                viewCart.cartproductWrapper.add(cpw);
            }
        }
        
        return viewCart;
    }
    
    @AuraEnabled
    public static productWrapper cartUpdate(String accId, List<sObject> itemsToUpdate, List<String> itemsToDelete){
        productWrapper updatecart=new productWrapper();
        List<ERP7__Cart_Picked_Item__c> cpi=new List<ERP7__Cart_Picked_Item__c>();
        for(sObject ob:itemsToUpdate){
            ERP7__Cart_Picked_Item__c cp=(ERP7__Cart_Picked_Item__c)ob;
            cpi.add(cp);
        }
        if(cpi.size() > 0 && Schema.SObjectType.ERP7__Cart_Picked_Item__c.isUpdateable()) update cpi;
        updatecart.cartList = [Select Id, Name from ERP7__Cart__c where ERP7__Account__c=:accId];
        List<ERP7__Cart_Picked_Item__c> selforDel=[Select Id,Name from ERP7__Cart_Picked_Item__c where ERP7__Cart__c =:updatecart.cartList[0].Id AND Id IN :itemsToDelete]; 
        if((selforDel.size() > 0) && ERP7__Cart_Picked_Item__c.sObjectType.getDescribe().isDeletable()) delete selforDel; 
        return updatecart;
    }
    
    @AuraEnabled
    public static productWrapper productDetails(String accId, String prodId){
        productWrapper prodDetails=new productWrapper();
        Set<Id> proId = new Set<Id>();
        Set<String> family =new Set<String>();        
        Set<Id> pricebookIds = new Set<Id>();
        List <Id> siteIds = new List <Id> ();
        
        if(accId != ''){
            prodDetails.acc=[Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id =: accId];
            if(prodDetails.acc.ERP7__Order_Profile__c != null){
                prodDetails.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:prodDetails.acc.ERP7__Order_Profile__c];
                for(ERP7__Profiling__c profile: prodDetails.profiling){
                    pricebookIds.add(profile.ERP7__Price_Book__c);
                }            
                prodDetails.channel = [Select Id, Name from ERP7__Channel__c where Id=:prodDetails.profiling[0].ERP7__Channel__c and ERP7__Active__c=true];
                
                prodDetails.DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                    where ERP7__Channel__c=:prodDetails.channel.Id and ERP7__Active__c=true];
                
                if(prodDetails.DistributionChannels.size() > 0) {
                    for(Distribution_Channel__c DC: prodDetails.DistributionChannels) {
                        siteIds.add(DC.Site__c);
                    }
                }
            }else{
                prodDetails.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
                for(PriceBook2 pb: prodDetails.pricebook){
                    pricebookIds.add(pb.Id);
                }      
                List<ERP7__Site__c> siteList=[Select Id,Name,ERP7__Address__c,ERP7__Address__r.ERP7__Country__c from ERP7__Site__c where ERP7__Active__c=true AND ERP7__Address__c !=null Limit 2];
                for(ERP7__Site__c st:siteList) siteIds.add(st.Id);                                              
            }            
        }else{
            //===============Guest User===============
            prodDetails.pricebook =[Select Id,Name from Pricebook2 where IsStandard = true Limit 1];
            for(PriceBook2 pb: prodDetails.pricebook){
                pricebookIds.add(pb.Id);
            }      
            List<ERP7__Site__c> siteList=[Select Id,Name,ERP7__Address__c,ERP7__Address__r.ERP7__Country__c from ERP7__Site__c where ERP7__Active__c=true AND ERP7__Address__c !=null Limit 2];
            for(ERP7__Site__c st:siteList) siteIds.add(st.Id);                                          
            //===============/Guest User=================
        }
        List<PricebookEntry> pbe = [Select Id,Name,CreatedDate, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family,Product2.ERP7__Category__c,Product2.ERP7__Sub_Category__c,Product2.ERP7__Configure__c,Product2.ERP7__Routing__c from PricebookEntry where Pricebook2Id In :pricebookIds AND Product2Id =: prodId];
        
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
        if(pbe.size() > 0) {
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                            Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,
                                            Number_of_Items_Dispatched__c, No_of_Items_Sold__c
                                            From Inventory_Stock__c
                                            Where product__c =:prodId And
                                            Active__c = true And
                                            Warehouse__c In: siteIds And                                                 
                                            Number_of_Item_In_Stock__c > 0
                                           ];
        }
        
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){  stockView.put(inven.product__c, inven.Number_of_Item_In_Stock__c);
                                                                    }        
        for(PricebookEntry pbe1 : pbe){
            family.add(pbe1.Product2.family);
            proId.add(pbe1.Product2Id);
            PriceBookWrapper wrapper=new PriceBookWrapper();
            wrapper.pbe= pbe1;
            wrapper.stock = (stockView.get(pbe1.Product2Id)!= null)? stockView.get(pbe1.Product2Id):0.00;
            prodDetails.prodList.add(wrapper);
        }
        
        if(family.size() > 0 ){
            List<PricebookEntry> pbeForRelList=[Select Id,Name,CreatedDate, IsActive, UnitPrice, Product2Id, Pricebook2Id, Product2.Name, Product2.ERP7__Picture__c, ERP7__Selling_Price__c, Product2.Description, Product2.ERP7__SKU__c, Product2.ERP7__MOQ__c, Product2.family,Product2.ERP7__Category__c,Product2.ERP7__Sub_Category__c from PricebookEntry where Pricebook2Id In :pricebookIds AND Product2Id In (Select Id from Product2 where Id not in :proId AND Family In :family) order by CreatedDate desc];
            
            List <Inventory_Stock__c> WarehouseItemInventoryStocks2 = new List <Inventory_Stock__c>();
            Set<Id> prodIdRelList=new Set<Id>();
            for(PricebookEntry pbe2:pbeForRelList){  prodIdRelList.add(pbe2.Product2Id);
                                                  }
            if(pbeForRelList.size() > 0) {  WarehouseItemInventoryStocks2 = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,Number_of_Item_In_Stock__c, Number_of_Item_Purchased_In__c, ERP7__Version__c,Number_of_Items_Dispatched__c, No_of_Items_Sold__c From Inventory_Stock__c Where product__c In :prodIdRelList And Active__c = true And  Warehouse__c In: siteIds And Number_of_Item_In_Stock__c > 0];
                                         }
            Map<String, Decimal> stockView2 = new Map<String, Decimal>();
            for(Inventory_Stock__c inven : WarehouseItemInventoryStocks2){ stockView2.put(inven.product__c, inven.Number_of_Item_In_Stock__c);
                                                                         }        
            
            //============================media start=================================
            prodDetails.media=[Select Id, Name, ERP7__Active__c,ERP7__File__c,ERP7__Product__c,ERP7__Type__c from ERP7__Media__c where ERP7__Product__c In :prodIdRelList];	// and ERP7__Type__c ='Picture'
            /* //commented 02-11-2022 Nayeem for Media Images 
            Map<String,Id> prodMedia =new Map<String,Id>();
            Set<Id> parentIdList=new Set<Id>();
            for(ERP7__Media__c media1 : prodDetails.media){ parentIdList.add(media1.Id); prodMedia.put(media1.ERP7__Product__c, media1.Id);
            }
            
            List<Attachment> attList=new List<Attachment>();
            for(Id parentList:parentIdList){ List<Attachment> att=[select Id, Name, ParentId from Attachment where ParentId =:parentList and ContentType in ('image/jpeg', 'image/gif') Limit 1]; 
                if(att.size() > 0) attList.addAll(att);            
            }
            Map<String,Attachment> mapList=new Map<String,Attachment>();//Map<ProductId,List<Attachment>>
            for(integer i=0; i<attList.size(); i++){
                for(String objVar : prodMedia.keySet()){  if(attList[i].ParentId == prodMedia.get(objVar)) mapList.put(objVar,attList[i]);            	
                }            
            } 
			*/
            Map<String,Id> prodMedia =new Map<String,Id>();
            Set<Id> LinkedEntityId=new Set<Id>();
            for(ERP7__Media__c media1 : prodDetails.media){
                LinkedEntityId.add(media1.Id); 
                prodMedia.put(media1.ERP7__Product__c, media1.Id);
            }
            List<ContentDocumentLink> conDocLink=new List<ContentDocumentLink>();
            if(LinkedEntityId.size() > 0) conDocLink = [select Id, ContentDocumentId, LinkedEntityId, Visibility From ContentDocumentLink where LinkedEntityId In :LinkedEntityId]; 
            system.debug('LinkedEntityId'+LinkedEntityId.size());
            system.debug('conDocLink'+conDocLink);
            
            Map<String,ContentDocumentLink> mapList=new Map<String,ContentDocumentLink>();//Map<ProductId,List<Attachment>>
            for(integer i=0; i<conDocLink.size(); i++){
                for(String objVar : prodMedia.keySet()){
                    if(conDocLink[i].LinkedEntityId == prodMedia.get(objVar)){                        mapList.put(objVar,conDocLink[i]);
                    }
                }            
            }
            //=============================================================
            
            for(PricebookEntry pbe2 : pbeForRelList){
                PriceBookWrapper wrapper1=new PriceBookWrapper(); wrapper1.pbe= pbe2; 
                wrapper1.stock = (stockView2.get(pbe2.Product2Id)!= null)? stockView2.get(pbe2.Product2Id):0.00;
                if(mapList.get(pbe2.Product2Id) != null) wrapper1.ContentDoc=mapList.get(pbe2.Product2Id);  prodDetails.relatedProd.add(wrapper1);
            }
        }
        //====================Meadia fetch=========================
        prodDetails.media=[Select Id, Name, ERP7__Active__c,ERP7__File__c,ERP7__Product__c,ERP7__Type__c from ERP7__Media__c where ERP7__Product__c =:prodId and ERP7__Type__c ='Picture'];
       
         Set<Id> MediaLinkedId=new Set<Id>();
        for(ERP7__Media__c media : prodDetails.media){ MediaLinkedId.add(media.Id);
                                                     }
        
        if(MediaLinkedId.size() > 0) prodDetails.conDocFile = [select Id, ContentDocumentId, LinkedEntityId, Visibility From ContentDocumentLink where LinkedEntityId In :MediaLinkedId];
        
        /* 
        Set<Id> parentIdList=new Set<Id>();
        for(ERP7__Media__c media : prodDetails.media){ parentIdList.add(media.Id);
                                                     }
        prodDetails.attFile = [select Name,ParentId from Attachment where ParentId In :parentIdList and ContentType in ('image/jpeg', 'image/gif')];  // GROUP BY ParentId
        */
        return prodDetails;
    }
    
    //===============Product Configurator start=================
    @AuraEnabled
    public static OptionProd getOptionProd(String proforConfig){
        OptionProd optPr=new OptionProd();
        List<Product_Feature__c> pfList=[Select Id,Name,ERP7__Product__c from Product_Feature__c where ERP7__Product__c =:proforConfig];
        List<ERP7__Product_Option__c> optprodsList=[Select Id,Name,ERP7__Product_Feature__r.Name,ERP7__Configured_SKU__c,ERP7__Optional_SKU__r.Name,ERP7__Optional_SKU__r.ERP7__Picture__c from ERP7__Product_Option__c where ERP7__Configured_SKU__c =:proforConfig];
        Set<Id> proFeatureIds=new Set<Id>();
        for(Product_Feature__c pf : pfList){      
            FeatureWrapper fw=new FeatureWrapper();
            for(Product_Option__c po : optprodsList){
                if(pf.Name == po.Product_Feature__r.Name){
                    proFeatureIds.add(pf.Id);                  
                    fw.feature = pf;
                    fw.featOpt.add(po);
                }
            }
            if(fw.featOpt.size() > 0)
                optPr.featrWrapper.add(fw);
        }
        FeatureWrapper fw1=new FeatureWrapper();
        List<Product_Option__c> otherOpt=[Select Id,Name,Product_Feature__r.Name,Configured_SKU__c,Optional_SKU__r.Name,Optional_SKU__r.ProductCode from Product_Option__c where Configured_SKU__c =:proforConfig AND Product_Feature__c NOT IN :proFeatureIds];
        if(otherOpt.size() > 0){ fw1.othersPro.addAll(otherOpt); optPr.featrWrapper.add(fw1);
                                //optPr.othersPro = otherOpt;            
                               }
        return optPr;
    }
    
    @AuraEnabled
    public static OptionProd getAllOptionRules(String proId){
        OptionProd optRule=new OptionProd();
        optRule.optionRules = [Select Id,Name,Configured_SKU__c,Active__c,Parent_Option__c,Parent_Option__r.Optional_SKU__r.Name,Child_Option__c,Type__c from Rule__c where Configured_SKU__c =:proId AND Active__c =true];
        return optRule;
    }
    
    @AuraEnabled
    public static String createVersion(List<String> selectedProds, String prodId){	//, String proOptions
        //List<FeatureWrapper> proOptions1=(List<FeatureWrapper>) JSON.deserialize(proOptions, List<FeatureWrapper> .class);
        Date dToday = Date.today();
        Date toDate = Date.today()+30;
       // String dateStr = dToday.day() + '/' + dToday.month() + '/' + dToday.year();
        //String toDateStr = toDate.day() + '/' + toDate.month() + '/' + toDate.year();
        Product2 mainPro=[Select Id,Name from Product2 where Id =:prodId];

        Id RT; RT = Schema.SObjectType.ERP7__Version__c.getRecordTypeInfosByDeveloperName().get('Catalog').getRecordTypeId();
        Id BOMRt; BOMRt = Schema.SObjectType.ERP7__BOM__c.getRecordTypeInfosByDeveloperName().get('Catalog_BOM').getRecordTypeId();

        Boolean isVersAvailable=false;
        String existingVersion='';
        //========Search for version with available with related BOM============
        List<ERP7__Version__c> verList=[Select Id,Name from ERP7__Version__c where RecordTypeId =:RT AND ERP7__Product__c =:prodId AND ERP7__Active__c=true
                                        AND ERP7__Start_Date__c <= Today AND ERP7__To_Date__c >= Today];
        
        if(verList.size() > 0){
            for(ERP7__Version__c vr:verList){
                List<ERP7__BOM__c> bomList=[Select Id,Name,ERP7__BOM_Product__c,ERP7__BOM_Component__c,RecordTypeId,ERP7__BOM_Version__c,ERP7__Type__c,ERP7__Status__c from ERP7__BOM__c where 
                                            ERP7__BOM_Product__c =:mainPro.Id AND
                                            RecordTypeId =:BOMRt AND
                                            ERP7__BOM_Version__c =:vr.Id AND
                                            ERP7__Type__c ='Alternate' AND 
                                            ERP7__Status__c ='Certified'];
                
                if(bomList.size() > 0){
                    List<String> verBOMComps=new List<String>();
                    for(ERP7__BOM__c bom1:bomList){
                        verBOMComps.add(bom1.ERP7__BOM_Component__c);
                    }
                    if(verBOMComps.equals(selectedProds)){ isVersAvailable=true; existingVersion = vr.Id;
                                                         }
                }
                
            }
        }
        //========/Search for version with available with related BOM===========
        if(isVersAvailable){ return existingVersion;
                           }else{
                               ERP7__Version__c version=new ERP7__Version__c(RecordTypeId = RT,Name='Customer Portal Version',ERP7__Product__c=prodId,
                                                                             ERP7__Active__c=true,ERP7__Type__c='Alternate',ERP7__Status__c='Certified',
                                                                             ERP7__Quantity__c=1,ERP7__Start_Date__c=dToday,ERP7__To_Date__c=toDate,ERP7__Unit_of_Measure__c='Each',
                                                                             ERP7__Sales_Ready__c=true);
                               if(Schema.sObjectType.ERP7__Version__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Start_Date__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__To_Date__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Unit_of_Measure__c.isCreateable() && Schema.sObjectType.ERP7__Version__c.fields.ERP7__Sales_Ready__c.isCreateable()){insert version;}else{/*not allowed to insert version*/}
                               
                               for(String sp:selectedProds){
                                   Product2 pro=[Select Id,Name from Product2 where Id=:sp];
                                   ERP7__BOM__c bom=new ERP7__BOM__c(RecordTypeId=BOMRt,Name=pro.Name,ERP7__BOM_Product__c=mainPro.Id,ERP7__Active__c=true,
                                                                     ERP7__BOM_Version__c=version.Id,ERP7__Type__c='Alternate',ERP7__Status__c='Certified',
                                                                     ERP7__Unit_of_Measure__c='Each',ERP7__BOM_Component__c=pro.Id,ERP7__Quantity__c=1);
                                   if(Schema.sObjectType.ERP7__BOM__c.fields.RecordTypeId.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Process_Cycle__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Routing_Link__c.isCreateable()){insert bom;}else{/*Not allowed to insert BOM*/}                     
                               }
                               return version.Id;
                           }
    }
    
    public class FeatureWrapper{
        @AuraEnabled public Product_Feature__c feature				{ get ; set ; }
        @AuraEnabled public List<Product_Option__c> featOpt			{ get ; set ; }
        @AuraEnabled public List<Product_Option__c> othersPro			{ get ; set ; }
        public FeatureWrapper(){
            feature = new Product_Feature__c();
            featOpt = new List<Product_Option__c>();
            othersPro = new List<Product_Option__c>();
        }
    }
    
    public class OptionProd{
        @AuraEnabled public List<FeatureWrapper> featrWrapper				{ get ; set ; }
        @AuraEnabled public List<Rule__c> optionRules					{ get ; set ; }
        
        public OptionProd(){
            featrWrapper=new List<FeatureWrapper>();
            optionRules = new List<Rule__c>();
        }
    }
    
    //===============Product Configurator end=================
    
    @AuraEnabled
    public static ERP7__Coupon_Redemption__c applyCoupons(String Coupon, Decimal totalPrice, String accID){
        List<ERP7__Coupon_Issued__c> CI = [Select Id, Name, ERP7__Product__c, ERP7__Account__c, ERP7__Coupon__c, ERP7__Coupon__r.ERP7__Maximum_Allocated_Vouchers__c, ERP7__Coupon__r.Name, ERP7__Coupon__r.ERP7__Value__c, ERP7__Coupon__r.ERP7__Value_In_Percent__c, ERP7__Coupon__r.ERP7__Start_Date__c, ERP7__Coupon__r.ERP7__End_Date__c, ERP7__Coupon__r.ERP7__Account__c, ERP7__Issued_Date__c, ERP7__Value__c, ERP7__Voucher_Amount__c, ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c, ERP7__Coupon__r.RecordType.Name, ERP7__Coupon__r.ERP7__Pre_Tax_Discount__c
                                           From ERP7__Coupon_Issued__c 
                                           Where ERP7__Coupon__r.Name =:Coupon And ERP7__Coupon__r.ERP7__Account__c=:accID And
                                           ERP7__Coupon__r.ERP7__Start_Date__c <= Today And 
                                           ERP7__Coupon__r.ERP7__End_Date__c >= Today 
                                           Limit 1];//And (ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c = Null Or ERP7__Coupon__r.ERP7__Minimum_Order_Amount__c <= :totalPrice) 
        if(CI.size()>0){ ERP7__Coupon_Issued__c cissued = CI[0]; ERP7__Coupon_Redemption__c cr = new ERP7__Coupon_Redemption__c(ERP7__Coupon__c =cissued.ERP7__Coupon__c, ERP7__Coupon_Issued__c=cissued.Id, ERP7__Account__c=accID, ERP7__Redemption_Date__c=cissued.ERP7__Issued_Date__c,ERP7__Value__c= totalPrice * (cissued.ERP7__Coupon__r.ERP7__Value_In_Percent__c/100)); return cr;          	
                       }
        return null;
    }   
    
    @AuraEnabled									//List<ERP7__Coupon_Redemption__c>		, String coupon
    public static productWrapper createSO(String AccId, String cartProducts,String coupon){
        try{
        productWrapper salseOrder =new productWrapper();
        List<cartProdWrapper> selectedProducts = (List<cartProdWrapper>) JSON.deserialize(cartProducts, List<cartProdWrapper>.class);
        
        salseOrder.acc=[Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id =: accId];
        if(salseOrder.acc.ERP7__Order_Profile__c != null){
        salseOrder.profiling = [Select Id, Name, ERP7__Price_Book__c, ERP7__Channel__c, ERP7__Default__c from ERP7__Profiling__c where Id=:salseOrder.acc.ERP7__Order_Profile__c];
        }
        Contact contactList = [Select Id, Name, AccountId, Email, ERP7__Primary__c from Contact where AccountId =:AccId order by ERP7__Primary__c Desc Limit 1];
        
        List <ERP7__Address__c> billingAddresses = [Select id,Name, ERP7__Active__c, ERP7__Address_Line1__c, ERP7__Address_Line2__c, ERP7__Address_Line3__c, ERP7__City__c, ERP7__Contact__c, ERP7__Country__c, ERP7__Customer__c,
                                                    ERP7__Is_Billing_Address__c, ERP7__Is_Shipping_Address__c, ERP7__Primary__c, ERP7__State__c, ERP7__Postal_Code__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c
                                                    From ERP7__Address__c Where ERP7__Customer__c = : AccId AND ERP7__Is_Billing_Address__c =true];
        
        List<ERP7__Sales_Order__c> soList=[Select Id,Name,ERP7__Account__c,ERP7__Status__c from ERP7__Sales_Order__c where ERP7__Account__c =:AccId AND ERP7__Status__c ='Booked' AND ERP7__Order_Status__c ='Entered' AND ERP7__Payments_Status__c =: System.Label.Not_Paid order by ERP7__Order_Date__c desc];	//Limit 1
        
        if(soList.size() > 0){
            if(coupon != null){
                List<ERP7__Coupon_Redemption__c> coupon1 = (List<ERP7__Coupon_Redemption__c>) JSON.deserialize(coupon, List<ERP7__Coupon_Redemption__c>.class);
                List<ERP7__Coupon_Redemption__c> CRList =(List<ERP7__Coupon_Redemption__c>)coupon1;
                if(CRList != null && CRList.size()>0){
                    for(Integer i=0;i<CRList.size();i++)
                        CRList[i].ERP7__Sales_Order__c=soList[0].Id;
                    if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Sales_Order__c.isUpdateable()){upsert CRList;}else{/*('User have not permission to update or insert ERP7__Coupon_Redemption__c FLS');*/}
                }            
                soList[0].ERP7__Coupon_Discount__c=coupon1[0].ERP7__Value__c;
                if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Coupon_Discount__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Coupon_Discount__c.isUpdateable() && Schema.SObjectType.ERP7__Sales_Order__c.isCreateable() && Schema.SObjectType.ERP7__Sales_Order__c.isUpdateable()) upsert soList[0];
                
            }
            system.debug('soList[0].Id '+soList[0].Id);
            list<ERP7__Invoice__c> invc= new list<ERP7__Invoice__c>();
            invc=[Select Id,Name from ERP7__Invoice__c where ERP7__Order__c =:soList[0].Id Limit 1];
            if(invc.size() > 0) {if(ERP7__Invoice__c.sObjectType.getDescribe().isDeletable()) delete invc;}
                soList[0].ERP7__Status__c='Draft';
                soList[0].ERP7__Issue_Invoice__c=false;
                if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Issue_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Issue_Invoice__c.isUpdateable()) upsert soList[0]; else{/*'User is not allowed to update or create record'*/}
            
            list<ERP7__Sales_Order_Line_Item__c> Existing_soli=new List<ERP7__Sales_Order_Line_Item__c>();
            Existing_soli=[select id,Name, ERP7__Product__c from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c=:soList[0].Id];
            if((Existing_soli.size() > 0) && ERP7__Sales_Order_Line_Item__c.sObjectType.getDescribe().isDeletable())
                delete Existing_soli;
            List<ERP7__Sales_Order_Line_Item__c> soli2Insert = new List<ERP7__Sales_Order_Line_Item__c>();
            
            for(cartProdWrapper pdw : selectedProducts){                
                ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c(ERP7__Sales_Order__c=soList[0].Id);
                soli.ERP7__Product__c = pdw.cpiList.ERP7__Product__c;
                soli.ERP7__Quantity__c = pdw.cpiList.ERP7__Quantity__c;
                soli.ERP7__Base_Price__c = pdw.cartproduct.UnitPrice;
                soli.ERP7__Order_Line_Status__c = 'Reserved';
                soli.ERP7__Total_Price__c = pdw.cartproduct.UnitPrice * pdw.cpiList.ERP7__Quantity__c;
                soli.ERP7__Inventory_Tracked__c = true;
                //soli.ERP7__Invoice__c=invc.Id;
                soli2Insert.add(soli);
            }
            if((soli2Insert.size() > 0) && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Base_Price__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Base_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Order_Line_Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Order_Line_Status__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Total_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Inventory_Tracked__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Inventory_Tracked__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Invoice__c.isUpdateable()) upsert soli2Insert; else{/*('User have not permission to update or insert SOLineItems FLS'*/}
            //=====================================
            salseOrder.so=[Select Id,Name,ERP7__Status__c,ERP7__Due_Amount__c,ERP7__Order_Status__c,ERP7__Channel__c,ERP7__Account__c,ERP7__Order_Profile__c,ERP7__Contact__c,ERP7__Authorised__c,ERP7__Customer_Email__c,ERP7__Bill_To_Address__c,ERP7__Ship_To_Address__c from ERP7__Sales_Order__c where Id =:soList[0].Id AND ERP7__Account__c =:AccId AND ERP7__Contact__c =:contactList.Id];
            salseOrder.ivc=[Select Id, ERP7__Name__c,ERP7__Invoice_Date__c,ERP7__Account__c,ERP7__Order__c,ERP7__Sales_Order_Amount__c from ERP7__Invoice__c where ERP7__Order__c =:soList[0].Id AND ERP7__Account__c =:AccId];
          	soList[0].ERP7__Status__c='Booked';
                soList[0].ERP7__Issue_Invoice__c=true;
                if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Issue_Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Issue_Invoice__c.isUpdateable()) upsert soList[0];else{/*'User in not allowed to update or create record of Order'*/}
            /* List<ERP7__Invoice_Line_Item__c> ivc2Del=new List<ERP7__Invoice_Line_Item__c>();
            ivc2Del = [Select Id,Name from ERP7__Invoice_Line_Item__c where ERP7__Invoice__c =:salseOrder.ivc[0].Id];
            if((ivc2Del.size() > 0) && ERP7__Invoice_Line_Item__c.sObjectType.getDescribe().isDeletable())
                delete ivc2Del; 
            List<ERP7__Invoice_Line_Item__c> ivc2Insert = new List<ERP7__Invoice_Line_Item__c>();
            for(cartProdWrapper pdw : selectedProducts){
                ERP7__Invoice_Line_Item__c ivc1 = new ERP7__Invoice_Line_Item__c(ERP7__Sales_Order_Line_Item__c=soli2Insert[0].Id);
                ivc1.ERP7__Invoice__c=salseOrder.ivc[0].Id;            
                ivc1.ERP7__Product__c = pdw.cpiList.ERP7__Product__c;
                ivc1.ERP7__Quantity__c = pdw.cpiList.ERP7__Quantity__c;
                ivc1.ERP7__Unit_Price__c = pdw.cartproduct.UnitPrice;
                ivc1.ERP7__Total_Price__c = pdw.cartproduct.UnitPrice * pdw.cpiList.ERP7__Quantity__c;
                ivc2Insert.add(ivc1);
            }//Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Invoice__c.isUpdateable() ======>FLS not on ERP7__Invoice__c
            if((ivc2Insert.size() > 0) && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Unit_Price__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Unit_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Total_Price__c.isUpdateable()) upsert ivc2Insert;
            else{//'User have not permission to create or update Invoice line items FLS');}
            ERP7__Invoice__c  ivDate= new ERP7__Invoice__c(Id=salseOrder.ivc[0].Id);
            ivDate.ERP7__Invoice_Date__c=Date.parse(system.today().format());
            if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Date__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Date__c.isUpdateable()){upsert ivDate;}else{//User have not permission to create or update Invoice FLS');}*/
            
        }else{
            ERP7__Sales_Order__c so=new ERP7__Sales_Order__c();
            if(salseOrder.acc.ERP7__Order_Profile__c != null){
                so = new ERP7__Sales_Order__c(ERP7__Issue_Invoice__c=true, ERP7__Status__c='Booked', ERP7__Order_Status__c='Entered',ERP7__Channel__c=salseOrder.profiling[0].ERP7__Channel__c, ERP7__Account__c=AccId, ERP7__Order_Profile__c=salseOrder.profiling[0].Id, ERP7__Contact__c=contactList.Id,ERP7__Customer_Email__c=contactList.Email, ERP7__Bill_To_Address__c=billingAddresses[0].Id, ERP7__Ship_To_Address__c=billingAddresses[0].Id);
            }else{//assign channel here, other wise shipping service will not work
                so = new ERP7__Sales_Order__c(ERP7__Issue_Invoice__c=true, ERP7__Status__c='Booked', ERP7__Order_Status__c='Entered', ERP7__Account__c=AccId, ERP7__Contact__c=contactList.Id,ERP7__Customer_Email__c=contactList.Email, ERP7__Bill_To_Address__c=billingAddresses[0].Id, ERP7__Ship_To_Address__c=billingAddresses[0].Id);
            }
            if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Ship_To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Bill_To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Order_Profile__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Customer_Email__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Contact__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Account__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Channel__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Order_Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Issue_Invoice__c.isCreateable() && Schema.SObjectType.ERP7__Sales_Order__c.isCreateable()){insert so;}else{/*not allowed to insert SO*/}
            if(coupon != null){
                List<ERP7__Coupon_Redemption__c> coupon1 = (List<ERP7__Coupon_Redemption__c>) JSON.deserialize(coupon, List<ERP7__Coupon_Redemption__c>.class);
                List<ERP7__Coupon_Redemption__c> CRList =(List<ERP7__Coupon_Redemption__c>)coupon1;
                if(CRList != null && CRList.size()>0){  for(Integer i=0;i<CRList.size();i++)  CRList[i].ERP7__Sales_Order__c=so.Id;  if(Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Sales_Order__c.isCreateable() && Schema.sObjectType.ERP7__Coupon_Redemption__c.fields.ERP7__Sales_Order__c.isUpdateable() && Schema.SObjectType.ERP7__Coupon_Redemption__c.isCreateable() && Schema.SObjectType.ERP7__Coupon_Redemption__c.isUpdateable()){upsert CRList;}else{}
                }  
                so.ERP7__Coupon_Discount__c=coupon1[0].ERP7__Value__c; 
                if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Ship_To_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Bill_To_Address__c.isUpdateable()  && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Order_Profile__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Customer_Email__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Contact__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Account__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Channel__c.isUpdateable()  && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Order_Status__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Issue_Invoice__c.isUpdateable() && Schema.SObjectType.ERP7__Sales_Order__c.isUpdateable()){update so;}else{/*not allowed to update SO*/}
            }//else{  insert so; }
            
            /*ERP7__Invoice__c invc=new ERP7__Invoice__c();
            invc=[Select Id,Name from ERP7__Invoice__c where ERP7__Order__c =:so.Id Limit 1];   
              */    
            List<ERP7__Sales_Order_Line_Item__c> soli2Insert = new List<ERP7__Sales_Order_Line_Item__c>();
            for(cartProdWrapper pdw : selectedProducts){
                ERP7__Sales_Order_Line_Item__c soli = new ERP7__Sales_Order_Line_Item__c(ERP7__Sales_Order__c=so.Id);soli.ERP7__Product__c = pdw.cpiList.ERP7__Product__c; soli.ERP7__Quantity__c = pdw.cpiList.ERP7__Quantity__c;soli.ERP7__Base_Price__c = pdw.cartproduct.UnitPrice; soli.ERP7__Order_Line_Status__c = 'Reserved';soli.ERP7__Total_Price__c = pdw.cartproduct.UnitPrice * pdw.cpiList.ERP7__Quantity__c;
                if(pdw.cpiList.ERP7__Product_Version__c != null) soli.ERP7__Version__c = pdw.cpiList.ERP7__Product_Version__c;
                //soli.ERP7__Inventory_Tracked__c = true;
                //soli.ERP7__Invoice__c=invc.Id;
                soli2Insert.add(soli);
            }  
            if(Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Version__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Total_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Base_Price__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Base_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order_Line_Item__c.fields.ERP7__Product__c.isUpdateable() && Schema.SObjectType.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.SObjectType.ERP7__Sales_Order_Line_Item__c.isUpdateable()){insert soli2Insert; }else{/*not allowed to isnert SOLI*/}
            
            salseOrder.so=[Select Id,Name,ERP7__Status__c,ERP7__Due_Amount__c,ERP7__Order_Status__c,ERP7__Channel__c,ERP7__Account__c,ERP7__Order_Profile__c,ERP7__Contact__c,ERP7__Authorised__c,ERP7__Customer_Email__c,ERP7__Bill_To_Address__c,ERP7__Ship_To_Address__c from ERP7__Sales_Order__c where Id =:so.Id AND ERP7__Account__c =:AccId AND ERP7__Contact__c =:contactList.Id Limit 1];
            salseOrder.ivc=[Select Id, ERP7__Name__c,ERP7__Invoice_Date__c,ERP7__Account__c,ERP7__Order__c,ERP7__Sales_Order_Amount__c from ERP7__Invoice__c where ERP7__Order__c =:so.Id AND ERP7__Account__c =:AccId Limit 1];
            List<ERP7__Invoice_Line_Item__c> ivc2Insert = new List<ERP7__Invoice_Line_Item__c>();
            for(cartProdWrapper pdw : selectedProducts){
                ERP7__Invoice_Line_Item__c ivc1 = new ERP7__Invoice_Line_Item__c(ERP7__Sales_Order_Line_Item__c=soli2Insert[0].Id);
                if(salseOrder.ivc.size()>0){
                    ivc1.ERP7__Invoice__c=salseOrder.ivc[0].Id;                    ivc1.ERP7__Product__c = pdw.cpiList.ERP7__Product__c;ivc1.ERP7__Quantity__c = pdw.cpiList.ERP7__Quantity__c;                    ivc1.ERP7__Unit_Price__c = pdw.cartproduct.UnitPrice;ivc1.ERP7__Total_Price__c = pdw.cartproduct.UnitPrice * pdw.cpiList.ERP7__Quantity__c;  ivc2Insert.add(ivc1);
                }
                
            } 
            if(Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Total_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Invoice__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Invoice__c.isUpdateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isCreateable() && Schema.sObjectType.ERP7__Invoice_Line_Item__c.fields.ERP7__Sales_Order_Line_Item__c.isUpdateable() && Schema.SObjectType.ERP7__Invoice_Line_Item__c.isCreateable() && Schema.SObjectType.ERP7__Invoice_Line_Item__c.isUpdateable()){insert ivc2Insert;}else{/*not allowed to insert INV LINE*/}
            if(salseOrder.ivc.size()>0){
            ERP7__Invoice__c  ivDate= new ERP7__Invoice__c(Id=salseOrder.ivc[0].Id); ivDate.ERP7__Invoice_Date__c=Date.parse(system.today().format());            
            if(Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Date__c.isCreateable() && Schema.sObjectType.ERP7__Invoice__c.fields.ERP7__Invoice_Date__c.isUpdateable()){upsert ivDate;}else{/*'User have not permission to create or update Invoice FLS');*/}
            }
        }  
            return salseOrder;
        }catch(Exception e){
            system.debug(e.getMessage()+'at line~>'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    public static productWrapper getAddresses(String accId){
        productWrapper getAdd=new productWrapper();
        getAdd.acc=[Select Id,Name from Account where Id =:accId];
        getAdd.con=[Select Id,Name,Email,MobilePhone from Contact where AccountId =:accId];
        getAdd.addList=[Select Id,Name,ERP7__Customer__r.Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__Address_Line3__c,ERP7__City__c,ERP7__Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Phone,ERP7__Country__c,ERP7__Is_Billing_Address__c,ERP7__Is_Shipping_Address__c,ERP7__County__c,ERP7__State__c,ERP7__Zip_4__c,ERP7__Postal_Code__c,ERP7__Primary__c from ERP7__Address__c where ERP7__Customer__c =:accId];
        
        Schema.DescribeFieldResult fieldResult = ERP7__Address__c.ERP7__State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            //StateList.add(pickListVal.getLabel());
            getAdd.State.add(pickListVal.getValue());
        }  
        
        Schema.DescribeFieldResult fieldResult1 = ERP7__Address__c.ERP7__Country__c.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        getAdd.country.add('--None--');
        for( Schema.PicklistEntry pickListVal1 : ple1){
            //StateList.add(pickListVal.getLabel());			
            getAdd.country.add(pickListVal1.getValue());
        }  
        return getAdd;
    }
    
    @AuraEnabled
    public static String updateAddress1(String accId,String name,String mobile,String add1,String add2,String add3,String city,String country,String state,String zip,String addId,String conId){
        if(mobile != ''){
            Contact cn=new Contact(AccountId = accId);
            cn.Id=conId;
            cn.MobilePhone = mobile;
            if(Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() && Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable()){upsert cn;}else{/*'User have not permission to update or create Contacts FLS');*/}        
        }
        system.debug('accId'+accId+ name+ mobile+ add1+ add2+ add3+ city+ country+ state+ zip+ addId+ conId);
        List<ERP7__Address__c> addList=[Select Id,Name,ERP7__Customer__c from ERP7__Address__c where ERP7__Customer__c =:accId];
        
        ERP7__Address__c add=new ERP7__Address__c(ERP7__Customer__c = accId);
        
        if(addList.size() == 0){
            add.Name=name;
            add.ERP7__Address_Line1__c=add1;
            add.ERP7__Address_Line2__c=add2;
            add.ERP7__Address_Line3__c=add3;
            add.ERP7__City__c = city;
            add.ERP7__State__c = state;
            add.ERP7__Country__c = country;
            add.ERP7__Postal_Code__c =zip;
            add.ERP7__Is_Billing_Address__c=true;
            add.ERP7__Is_Shipping_Address__c=true;
            add.ERP7__Primary__c=true;            
        }else{
            if(addId != '') 
                add.Id = addId;
            add.Name=name;
            add.ERP7__Address_Line1__c=add1;
            add.ERP7__Address_Line2__c=add2;
            add.ERP7__Address_Line3__c=add3;
            add.ERP7__City__c = city;
            add.ERP7__State__c = state;
            add.ERP7__Country__c = country;
            add.ERP7__Postal_Code__c =zip;
            //add.ERP7__Is_Billing_Address__c=true;
            add.ERP7__Is_Shipping_Address__c=true;
            //add.ERP7__Primary__c=true;
        }
        if(Schema.sObjectType.ERP7__Address__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line1__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line2__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line3__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line3__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__City__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__City__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Primary__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Primary__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Shipping_Address__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Shipping_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Billing_Address__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Billing_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Postal_Code__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Postal_Code__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isUpdateable()){upsert add;}else{/*('User have not permission to update or insert Addresses FLS');*/}
        return add.Id;
    }
    
    @AuraEnabled
    public static void delAddress(Id addForDel){
        ERP7__Address__c add=[Select Id, Name from ERP7__Address__c where Id =:addForDel];
        if(ERP7__Address__c.sObjectType.getDescribe().isDeletable()) delete add;
    }
    
    @AuraEnabled
    public static String delShipAddress(Id addForDel){
        ERP7__Address__c add=[Select Id,Name,ERP7__Primary__c,ERP7__Is_Billing_Address__c from ERP7__Address__c where Id =:addForDel Limit 1];
        if(add.ERP7__Primary__c || add.ERP7__Is_Billing_Address__c)
            return 'You can\'t delete default or billing address';
        else{
            if(ERP7__Address__c.sObjectType.getDescribe().isDeletable()) delete add;
            return '';
        }        
    }
    
    @AuraEnabled
    public static void addAddrToSO(String SOId, String addId){
        ERP7__Sales_Order__c so1=[Select Id,Name,ERP7__Bill_To_Address__c,ERP7__Ship_To_Address__c from ERP7__Sales_Order__c where Id =:SOId];
        ERP7__Sales_Order__c so=new ERP7__Sales_Order__c(Id = SOId);
        if(so1.ERP7__Bill_To_Address__c == null){
            so.ERP7__Bill_To_Address__c=addId;
            so.ERP7__Ship_To_Address__c=addId;
        }
        else{
            so.ERP7__Ship_To_Address__c=addId;
        }        
        if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Bill_To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Bill_To_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Ship_To_Address__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Ship_To_Address__c.isUpdateable()){upsert so;}else{/*('User have not permission to update or insert record in ERP7__Sales_Order__c FLS');*/}
    }
    
    @AuraEnabled
    public static profile getUserDetails(){
        profile pr=new profile();
        pr.user1=[Select Id,Name,ContactId, isActive From User where id=:UserInfo.getUserId() Limit 1];
        Contact con=[Select Id,Account.Subscribe_To_NewsLetters__c,Subscribe_To_NewsLetters__c From Contact where id=:pr.user1.ContactId]; 
        pr.newsLetter=con.Subscribe_To_NewsLetters__c;         
        return pr;        
    }
    
    @AuraEnabled
    public static void updateSPNCheckbox(Boolean subsActive){
        List<User> curUser=[Select Id,Name,isActive,ContactId From User where id=:UserInfo.getUserId() Limit 1];
        Contact con=[Select Id,AccountId,Subscribe_To_NewsLetters__c From Contact where id=:curUser[0].ContactId];
        con.Subscribe_To_NewsLetters__c=subsActive; 
        if(Schema.sObjectType.Contact.fields.Subscribe_To_NewsLetters__c.isUpdateable()){update con;}else{/*'User have not permission to update Contact FLS');*/}
    } 
    
    @AuraEnabled
    public static productWrapper myOrders(String accId, String tillDate){
        productWrapper myOrdr=new productWrapper();
        myOrdr.acc=[Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id=:accId];
        if(tillDate == 'one')
            myOrdr.so=[Select Id, Name,ERP7__Name__c,ERP7__Order_Date__c,ERP7__Cancelled_Date__c,ERP7__Total_Due__c,ERP7__Due_Amount__c,ERP7__Fulfilled_Date__c,ERP7__Status__c,ERP7__Active__c from ERP7__Sales_Order__c where ERP7__Account__c =:myOrdr.acc.Id AND ERP7__Payments_Status__c =:System.Label.Paid Order By ERP7__Order_Date__c desc Limit 30];
        else if(tillDate == 'six')
            myOrdr.so=[Select Id, Name,ERP7__Name__c,ERP7__Order_Date__c,ERP7__Cancelled_Date__c,ERP7__Total_Due__c,ERP7__Due_Amount__c,ERP7__Fulfilled_Date__c,ERP7__Status__c,ERP7__Active__c from ERP7__Sales_Order__c where ERP7__Account__c =:myOrdr.acc.Id AND ERP7__Payments_Status__c =:System.Label.Paid Order By ERP7__Order_Date__c desc Limit 180];
        else if(tillDate == 'year')
            myOrdr.so=[Select Id, Name,ERP7__Name__c,ERP7__Order_Date__c,ERP7__Cancelled_Date__c,ERP7__Total_Due__c,ERP7__Due_Amount__c,ERP7__Fulfilled_Date__c,ERP7__Status__c,ERP7__Active__c from ERP7__Sales_Order__c where ERP7__Account__c =:myOrdr.acc.Id AND ERP7__Payments_Status__c =:System.Label.Paid Order By ERP7__Order_Date__c desc Limit 365];
        else
            myOrdr.so=[Select Id, Name,ERP7__Name__c,ERP7__Order_Date__c,ERP7__Cancelled_Date__c,ERP7__Total_Due__c,ERP7__Due_Amount__c,ERP7__Fulfilled_Date__c,ERP7__Status__c,ERP7__Active__c from ERP7__Sales_Order__c where ERP7__Account__c =:myOrdr.acc.Id AND ERP7__Payments_Status__c =:System.Label.Paid Order By ERP7__Order_Date__c desc];
        
        Set<Id> soId=new Set<Id>();
        for(ERP7__Sales_Order__c so:myOrdr.so) soId.add(so.Id);
        List<ERP7__Sales_Order_Line_Item__c> soliList=[Select Id,Name,ERP7__Active__c,ERP7__Sales_Order__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Base_Price__c,ERP7__Quantity__c  from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c In :soId];
        
        Set<Id> productIds=new Set<Id>();
        for(ERP7__Sales_Order_Line_Item__c soli1:soliList)	productIds.add(soli1.ERP7__Product__c);        
        myOrdr.media=[Select Id, Name, ERP7__Active__c,ERP7__File__c,ERP7__Product__c,ERP7__Type__c from ERP7__Media__c where ERP7__Product__c In :productIds];
        
        /* //commented 02-11-2022 Nayeem for Media Images 
        Map<String,Id> prodMedia =new Map<String,Id>();
        Set<Id> parentIdList=new Set<Id>();
        for(ERP7__Media__c media1 : myOrdr.media){  parentIdList.add(media1.Id); prodMedia.put(media1.ERP7__Product__c, media1.Id);
        }
        List<Attachment> attList=new List<Attachment>();
        for(Id parentList:parentIdList){ List<Attachment> att=[select Id, Name, ParentId from Attachment where ParentId =:parentList and ContentType in ('image/jpeg', 'image/gif') Limit 1]; 
                                        if(att.size() > 0) attList.addAll(att);            
                                       }
        Map<String,Attachment> mapList=new Map<String,Attachment>();
        for(integer i=0; i<attList.size(); i++){ 
            for(String objVar : prodMedia.keySet()){  if(attList[i].ParentId == prodMedia.get(objVar)) mapList.put(objVar,attList[i]);
            }            
        } */
        
        Map<String,Id> prodMedia =new Map<String,Id>();
            Set<Id> LinkedEntityId=new Set<Id>();
            for(ERP7__Media__c media1 : myOrdr.media){
                LinkedEntityId.add(media1.Id);                 prodMedia.put(media1.ERP7__Product__c, media1.Id);
            }
            List<ContentDocumentLink> conDocLink=new List<ContentDocumentLink>();
            if(LinkedEntityId.size() > 0) conDocLink = [select Id, ContentDocumentId, LinkedEntityId, Visibility From ContentDocumentLink where LinkedEntityId In :LinkedEntityId]; 
            system.debug('LinkedEntityId'+LinkedEntityId.size());
            system.debug('conDocLink'+conDocLink);
            
            Map<String,ContentDocumentLink> mapList=new Map<String,ContentDocumentLink>();//Map<ProductId,List<Attachment>>
            for(integer i=0; i<conDocLink.size(); i++){
                for(String objVar : prodMedia.keySet()){
                    if(conDocLink[i].LinkedEntityId == prodMedia.get(objVar)){                        mapList.put(objVar,conDocLink[i]);
                    }
                }            
            }
        
        List<ERP7__Invoice__c> inv=[Select Id,Name,ERP7__Account__c,ERP7__Total_Due__c,ERP7__Invoice_Amount__c,ERP7__Invoice_Date__c,ERP7__Order__c from ERP7__Invoice__c where ERP7__Order__c In:soId]; 
        for(ERP7__Sales_Order__c soList:myOrdr.so){ 
            myOrderWrapper mow=new myOrderWrapper();            
            mow.inv=inv; mow.so=soList;
            List<ERP7__Sales_Order_Line_Item__c> allSoli=new List<ERP7__Sales_Order_Line_Item__c>();            
            for(ERP7__Sales_Order_Line_Item__c soli:soliList){ if(soList.Id == soli.ERP7__Sales_Order__c)	 allSoli.add(soli);
            }
            mow.conDoc=mapList;//sending Map
            mow.soliList = allSoli; myOrdr.myord.add(mow);
        }        
        return myOrdr;        
    }
    
    @AuraEnabled
    public static productWrapper searchOrder(String accId, String searchsales, String searchInvoice){
        
        productWrapper searchResult=new productWrapper();
        searchResult.acc=[Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id=:accId];
        List<ERP7__Invoice__c> inv = new List<ERP7__Invoice__c>();
        Set<Id> soId=new Set<Id>();
        if(searchsales != ''){            
            String searchsales1='%'+searchsales+'%';
            searchResult.so=[Select Id, Name,ERP7__Name__c,ERP7__Order_Date__c,ERP7__Cancelled_Date__c,ERP7__Total_Due__c,ERP7__Due_Amount__c,ERP7__Fulfilled_Date__c,ERP7__Status__c,ERP7__Active__c from ERP7__Sales_Order__c where ERP7__Account__c =:searchResult.acc.Id AND ERP7__Payments_Status__c =:System.Label.Paid AND Name Like :searchsales1];
            
        }
        else if(searchInvoice != ''){
            String searchInvoice1='%'+searchInvoice+'%';
            inv=[Select Id,Name,ERP7__Account__c,ERP7__Total_Due__c,ERP7__Invoice_Amount__c,ERP7__Invoice_Date__c,ERP7__Order__c from ERP7__Invoice__c where ERP7__Account__c =:accId AND Name Like :searchInvoice1];            
            for(ERP7__Invoice__c iv:inv)	soId.add(iv.ERP7__Order__c);
            searchResult.so=[Select Id, Name,ERP7__Name__c,ERP7__Order_Date__c,ERP7__Cancelled_Date__c,ERP7__Total_Due__c,ERP7__Due_Amount__c,ERP7__Fulfilled_Date__c,ERP7__Status__c,ERP7__Active__c from ERP7__Sales_Order__c where ERP7__Account__c =:searchResult.acc.Id AND Id in:soId AND ERP7__Payments_Status__c =:System.Label.Paid Order By ERP7__Order_Date__c desc];
        }
        else{ searchResult.so=[Select Id, Name,ERP7__Name__c,ERP7__Order_Date__c,ERP7__Cancelled_Date__c,ERP7__Total_Due__c,ERP7__Due_Amount__c,ERP7__Fulfilled_Date__c,ERP7__Status__c,ERP7__Active__c from ERP7__Sales_Order__c where ERP7__Account__c =:searchResult.acc.Id AND ERP7__Payments_Status__c =:System.Label.Paid Order By ERP7__Order_Date__c desc Limit 30];   
        }            
        for(ERP7__Sales_Order__c so:searchResult.so)	 soId.add(so.Id);
        List<ERP7__Sales_Order_Line_Item__c> soliList=[Select Id,Name,ERP7__Active__c,ERP7__Sales_Order__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Base_Price__c,ERP7__Quantity__c  from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c In :soId];
        
        Set<Id> productIds=new Set<Id>();
        for(ERP7__Sales_Order_Line_Item__c soli1:soliList)	productIds.add(soli1.ERP7__Product__c);        
        searchResult.media=[Select Id, Name, ERP7__Active__c,ERP7__File__c,ERP7__Product__c,ERP7__Type__c from ERP7__Media__c where ERP7__Product__c In :productIds];
        
        Map<String,Id> prodMedia =new Map<String,Id>();
        Set<Id> parentIdList=new Set<Id>();
        for(ERP7__Media__c media1 : searchResult.media){
            parentIdList.add(media1.Id); prodMedia.put(media1.ERP7__Product__c, media1.Id);
        }
        List<Attachment> attList=new List<Attachment>();
        for(Id parentList:parentIdList){
            List<Attachment> att=[select Id, Name, ParentId from Attachment where ParentId =:parentList and ContentType in ('image/jpeg', 'image/gif') Limit 1]; 
            if(att.size() > 0) attList.addAll(att);            
        }
        Map<String,Attachment> mapList=new Map<String,Attachment>();
        for(integer i=0; i<attList.size(); i++){
            for(String objVar : prodMedia.keySet()){if(attList[i].ParentId == prodMedia.get(objVar)){ mapList.put(objVar,attList[i]);
                }
            }            
        } 
        
        if(searchsales != '')
            inv=[Select Id,Name,ERP7__Account__c,ERP7__Total_Due__c,ERP7__Invoice_Amount__c,ERP7__Invoice_Date__c,ERP7__Order__c from ERP7__Invoice__c where ERP7__Order__c In:soId]; 
        else if(searchsales == '' && searchsales == '')
            inv=[Select Id,Name,ERP7__Account__c,ERP7__Total_Due__c,ERP7__Invoice_Amount__c,ERP7__Invoice_Date__c,ERP7__Order__c from ERP7__Invoice__c where ERP7__Order__c In:soId]; 
        for(ERP7__Sales_Order__c soList:searchResult.so){
            myOrderWrapper mow=new myOrderWrapper();
            
            mow.inv=inv; mow.so=soList;
            List<ERP7__Sales_Order_Line_Item__c> allSoli=new List<ERP7__Sales_Order_Line_Item__c>();            
            for(ERP7__Sales_Order_Line_Item__c soli:soliList){ if(soList.Id == soli.ERP7__Sales_Order__c)	 allSoli.add(soli);                   
            }
            mow.att=mapList;					//sending Map<ProductId, Attachment>
            mow.soliList = allSoli; searchResult.myord.add(mow);
        } 
        return searchResult;
    }
    
    @AuraEnabled
    public static void cancelOrder(String soId){
        ERP7__Sales_Order__c soUpdate=new ERP7__Sales_Order__c();
        soUpdate.Id=soId;
        soUpdate.ERP7__Status__c='Cancelled';
        soUpdate.ERP7__Cancelled_Date__c=system.today();
        if(Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Status__c.isUpdateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Cancelled_Date__c.isCreateable() && Schema.sObjectType.ERP7__Sales_Order__c.fields.ERP7__Cancelled_Date__c.isUpdateable()){upsert soUpdate;}else{/*('User have not permission to update or create SO FLS');*/}
    }
    
    @AuraEnabled
    public static productWrapper orderDetails(String inv){
        try{
            productWrapper ordDetails=new productWrapper();
            List<ERP7__Invoice__c> invc=[Select Id,Name,ERP7__Account__c,ERP7__Total_Due__c,ERP7__Invoice_Amount__c,ERP7__Invoice_Date__c,ERP7__Order__c from ERP7__Invoice__c where Id =:inv Limit 1];            
            ordDetails.so=[Select Id, Name,ERP7__Name__c,ERP7__Order_Date__c,ERP7__Cancelled_Date__c,ERP7__Total_Due__c,ERP7__Due_Amount__c,ERP7__Fulfilled_Date__c,ERP7__Status__c,ERP7__Active__c from ERP7__Sales_Order__c where Id =:invc[0].ERP7__Order__c];
            ordDetails.acc=[Select Id, Name, ERP7__Active__c, ERP7__Account_Type__c, ERP7__Order_Profile__c, Type from Account where Id=:invc[0].ERP7__Account__c];
            ordDetails.con=[Select Id, Name,AccountId,Email,MobilePhone,Phone,ERP7__Primary__c from Contact where AccountId =:invc[0].ERP7__Account__c Limit 1];
            ordDetails.add=[Select Id,Name,ERP7__Customer__r.Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__Address_Line3__c,ERP7__City__c,ERP7__Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Phone,ERP7__Country__c,ERP7__Is_Billing_Address__c,ERP7__Is_Shipping_Address__c,ERP7__Primary__c,ERP7__County__c,ERP7__State__c,ERP7__Zip_4__c,ERP7__Postal_Code__c from ERP7__Address__c where ERP7__Customer__c =:ordDetails.acc.Id Limit 1];
            
            List<ERP7__Sales_Order_Line_Item__c> soliList=[Select Id,Name,ERP7__Active__c,ERP7__Sales_Order__c,ERP7__Product__c,ERP7__Product__r.Name,ERP7__Base_Price__c,ERP7__Quantity__c  from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__c =:ordDetails.so[0].Id];
            
            Set<Id> productIds=new Set<Id>();
            for(ERP7__Sales_Order_Line_Item__c soli1:soliList)	productIds.add(soli1.ERP7__Product__c);        
            ordDetails.media=[Select Id, Name, ERP7__Active__c,ERP7__File__c,ERP7__Product__c,ERP7__Type__c from ERP7__Media__c where ERP7__Product__c In :productIds];
            /* //commented 02-11-2022 Nayeem for Media Images 
Map<String,Id> prodMedia =new Map<String,Id>();
Set<Id> parentIdList=new Set<Id>();
for(ERP7__Media__c media1 : ordDetails.media){
parentIdList.add(media1.Id);
prodMedia.put(media1.ERP7__Product__c, media1.Id);
}
List<Attachment> attList=new List<Attachment>();
for(Id parentList:parentIdList){
List<Attachment> att=[select Id, Name, ParentId from Attachment where ParentId =:parentList and ContentType in ('image/jpeg', 'image/gif') Limit 1]; 
if(att.size() > 0) attList.addAll(att);            
}
Map<String,Attachment> mapList=new Map<String,Attachment>();
for(integer i=0; i<attList.size(); i++){
for(String objVar : prodMedia.keySet()){ if(attList[i].ParentId == prodMedia.get(objVar)){ mapList.put(objVar,attList[i]);
}
}            
} 
*/    
            
            Map<String,Id> prodMedia =new Map<String,Id>();
            Set<Id> LinkedEntityId=new Set<Id>();
            for(ERP7__Media__c media1 : ordDetails.media){
                LinkedEntityId.add(media1.Id); 
                prodMedia.put(media1.ERP7__Product__c, media1.Id);
            }
            List<ContentDocumentLink> conDocLink=new List<ContentDocumentLink>();
            if(LinkedEntityId.size() > 0) conDocLink = [select Id, ContentDocumentId, LinkedEntityId, Visibility From ContentDocumentLink where LinkedEntityId In :LinkedEntityId]; 
            system.debug('LinkedEntityId'+LinkedEntityId.size());
            system.debug('conDocLink'+conDocLink);
            
            Map<String,ContentDocumentLink> mapList=new Map<String,ContentDocumentLink>();//Map<ProductId,List<Attachment>>
            for(integer i=0; i<conDocLink.size(); i++){
                for(String objVar : prodMedia.keySet()){
                    if(conDocLink[i].LinkedEntityId == prodMedia.get(objVar)){                        mapList.put(objVar,conDocLink[i]);
                    }
                }            
            }
            
            for(ERP7__Sales_Order__c soList:ordDetails.so){
                myOrderWrapper mow=new myOrderWrapper();                
                mow.inv=invc;
                mow.so=soList;
                List<ERP7__Sales_Order_Line_Item__c> allSoli=new List<ERP7__Sales_Order_Line_Item__c>();            
                for(ERP7__Sales_Order_Line_Item__c soli:soliList){
                    if(soList.Id == soli.ERP7__Sales_Order__c)	 allSoli.add(soli);                    
                }
                mow.conDoc=mapList;					//sending Map<ProductId, Attachment>
                mow.soliList = allSoli;
                ordDetails.myord.add(mow);
            } 
            return ordDetails;
        }
        catch(Exception e){
            system.debug(e.getMessage()+'at line~>'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static productWrapper fetchAdd(String accId){
        productWrapper fetAdd=new productWrapper();
        List<ERP7__Address__c> add1=[Select Id,Name,ERP7__Customer__r.Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__Address_Line3__c,ERP7__City__c,ERP7__Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Phone,ERP7__Country__c,ERP7__Is_Billing_Address__c,ERP7__Is_Shipping_Address__c,ERP7__Primary__c,ERP7__County__c,ERP7__State__c,ERP7__Zip_4__c,ERP7__Postal_Code__c from ERP7__Address__c where ERP7__Customer__c =:accId AND ERP7__Primary__c =true Limit 1];
        List<ERP7__Address__c> add2=[Select Id,Name,ERP7__Customer__r.Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__Address_Line3__c,ERP7__City__c,ERP7__Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Phone,ERP7__Country__c,ERP7__Is_Billing_Address__c,ERP7__Is_Shipping_Address__c,ERP7__Primary__c,ERP7__County__c,ERP7__State__c,ERP7__Zip_4__c,ERP7__Postal_Code__c from ERP7__Address__c where ERP7__Customer__c =:accId AND ERP7__Is_Billing_Address__c =true Limit 1];
        fetAdd.acc=[Select Id,Name from Account where Id =:accId];
        fetAdd.con=[Select Id,Name,Email,MobilePhone from Contact where AccountId =:accId];
        if(add1.size() > 0)
            fetAdd.addPrimary=[Select Id,Name,ERP7__Customer__r.Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__Address_Line3__c,ERP7__City__c,ERP7__Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Phone,ERP7__Country__c,ERP7__Is_Billing_Address__c,ERP7__Is_Shipping_Address__c,ERP7__County__c,ERP7__State__c,ERP7__Zip_4__c,ERP7__Postal_Code__c,ERP7__Primary__c from ERP7__Address__c where ERP7__Customer__c =:accId AND ERP7__Primary__c =true Limit 1];
        if(add2.size() > 0)
            fetAdd.addBilling=[Select Id,Name,ERP7__Customer__r.Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__Address_Line3__c,ERP7__City__c,ERP7__Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Phone,ERP7__Country__c,ERP7__Is_Billing_Address__c,ERP7__Is_Shipping_Address__c,ERP7__County__c,ERP7__State__c,ERP7__Zip_4__c,ERP7__Postal_Code__c,ERP7__Primary__c from ERP7__Address__c where ERP7__Customer__c =:accId AND ERP7__Is_Billing_Address__c =true Limit 1];
        fetAdd.addShipping=[Select Id,Name,ERP7__Customer__r.Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__Address_Line3__c,ERP7__City__c,ERP7__Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Phone,ERP7__Country__c,ERP7__Is_Billing_Address__c,ERP7__Is_Shipping_Address__c,ERP7__County__c,ERP7__State__c,ERP7__Zip_4__c,ERP7__Postal_Code__c,ERP7__Primary__c from ERP7__Address__c where ERP7__Customer__c =:accId AND ERP7__Is_Shipping_Address__c =true];
        fetAdd.addList=[Select Id,Name,ERP7__Customer__r.Name,ERP7__Address_Line1__c,ERP7__Address_Line2__c,ERP7__Address_Line3__c,ERP7__City__c,ERP7__Code__c,ERP7__Contact__r.Name,ERP7__Contact__r.Email,ERP7__Contact__r.MobilePhone,ERP7__Contact__r.Phone,ERP7__Country__c,ERP7__Is_Billing_Address__c,ERP7__Is_Shipping_Address__c,ERP7__County__c,ERP7__State__c,ERP7__Zip_4__c,ERP7__Postal_Code__c,ERP7__Primary__c from ERP7__Address__c where ERP7__Customer__c =:accId];
        Schema.DescribeFieldResult fieldResult = ERP7__Address__c.ERP7__State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            //StateList.add(pickListVal.getLabel());
            fetAdd.State.add(pickListVal.getValue());
        }  
        
        Schema.DescribeFieldResult fieldResult1 = ERP7__Address__c.ERP7__Country__c.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        fetAdd.country.add('--None--');
        for( Schema.PicklistEntry pickListVal1 : ple1){
            //StateList.add(pickListVal.getLabel());
            fetAdd.country.add(pickListVal1.getValue());
        }          
        return fetAdd;
    }
    
    @AuraEnabled
    public static String updatePriAddress(String accId,String name,String mobile,String add1,String add2,String add3,String city,String country,String state,String zip,String addId,String conId){
        
        Contact cn=new Contact(AccountId = accId);
        cn.Id=conId;
        cn.MobilePhone = mobile;
        if(Schema.sObjectType.Contact.fields.MobilePhone.isCreateable() && Schema.sObjectType.Contact.fields.MobilePhone.isUpdateable()){upsert cn;}else{/*'User have not permission to update or create Contacts FLS');*/}          
        ERP7__Address__c add=new ERP7__Address__c(ERP7__Customer__c = accId);
        
        add.Id = addId;
        add.Name=name;
        add.ERP7__Address_Line1__c=add1;
        add.ERP7__Address_Line2__c=add2;
        add.ERP7__Address_Line3__c=add3;
        add.ERP7__City__c = city;
        add.ERP7__State__c = state;
        add.ERP7__Country__c = country;
        add.ERP7__Postal_Code__c =zip;
        add.ERP7__Primary__c=true;
        if(Schema.sObjectType.ERP7__Address__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line1__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line2__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line3__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line3__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__City__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__City__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Primary__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Primary__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Shipping_Address__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Shipping_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Billing_Address__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Billing_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Postal_Code__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Postal_Code__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isUpdateable()){upsert add;}else{/*('User have not permission to update or insert Addresses FLS')*/}
        return null;
    }
    
    @AuraEnabled
    public static String updateBillAddress(String accId,String name,String add1,String add2,String add3,String city,String country,String state,String zip,String addId){
        ERP7__Address__c billAdd=[Select Id,Name,ERP7__Is_Billing_Address__c,ERP7__Active__c,ERP7__Customer__c from ERP7__Address__c where ERP7__Is_Billing_Address__c =true AND ERP7__Active__c =true AND ERP7__Customer__c =:accId Limit 1];
        billAdd.ERP7__Is_Billing_Address__c =false;
        if(Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Billing_Address__c.isUpdateable()){update billAdd;}else{/*'User have not permission to update Address FLS');*/}
        
        ERP7__Address__c add=new ERP7__Address__c(ERP7__Customer__c = accId);
        /**Create new address where billing=true and shipping=true**/          
        
        add.Name=name;
        add.ERP7__Address_Line1__c=add1;
        add.ERP7__Address_Line2__c=add2;
        add.ERP7__Address_Line3__c=add3;
        add.ERP7__City__c = city;
        add.ERP7__State__c = state;
        add.ERP7__Country__c = country;
        add.ERP7__Postal_Code__c =zip;
        add.ERP7__Is_Billing_Address__c=true;
        add.ERP7__Is_Shipping_Address__c=true;
        //add.ERP7__Primary__c=true;
        if(Schema.sObjectType.ERP7__Address__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line1__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line2__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line3__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line3__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__City__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__City__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Primary__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Primary__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Shipping_Address__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Shipping_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Billing_Address__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Billing_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Postal_Code__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Postal_Code__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isUpdateable()){upsert add;}else{/*('User have not permission to update or insert Addresses FLS')*/}
        return null;
    }
    
    @AuraEnabled
    public static String updateShipAddress(String accId,String name,String add1,String add2,String add3,String city,String country,String state,String zip,String addId){
        ERP7__Address__c add=new ERP7__Address__c(ERP7__Customer__c = accId);
        
        if(addId != '')
            add.Id = addId;        
        add.Name=name;
        add.ERP7__Active__c =true;
        add.ERP7__Address_Line1__c=add1;
        add.ERP7__Address_Line2__c=add2;
        add.ERP7__Address_Line3__c=add3;
        add.ERP7__City__c = city;
        add.ERP7__State__c = state;
        add.ERP7__Country__c = country;
        add.ERP7__Postal_Code__c =zip;
        add.ERP7__Is_Shipping_Address__c=true;
        if(Schema.sObjectType.ERP7__Address__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line1__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line1__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line2__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line2__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line3__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Address_Line3__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__City__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__City__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__State__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Primary__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Primary__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Shipping_Address__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Shipping_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Billing_Address__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Is_Billing_Address__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Postal_Code__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Postal_Code__c.isUpdateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isCreateable() && Schema.sObjectType.ERP7__Address__c.fields.ERP7__Country__c.isUpdateable()){upsert add;}else{/*'User have not permission to update or insert Addresses FLS')*/}
        return null;
    }
    
    public class myOrderWrapper{
        @AuraEnabled public List<ERP7__Invoice__c> inv	      					{ get; set; }
        @AuraEnabled public ERP7__Sales_Order__c so      					{ get; set; }
        @AuraEnabled public List<ERP7__Sales_Order_Line_Item__c> soliList 	{ get; set; }
        
        @AuraEnabled public Map<String,Attachment>	att				{ get; set; }
        @AuraEnabled public Map<String,ContentDocumentLink>	conDoc							{ get; set; }
        public myOrderWrapper(){
            inv = new List<ERP7__Invoice__c>();
            so = new ERP7__Sales_Order__c();
            soliList = new List<ERP7__Sales_Order_Line_Item__c>();            
        }
    }
    
    public class profile{
        @AuraEnabled public String profId 				{ get; set; }
        @AuraEnabled public String name 				{ get; set; }
        @AuraEnabled public User user1					{ get; set; }
        @AuraEnabled public Account acc					{ get; set; }
        @AuraEnabled public Boolean newsLetter			{ get; set; }
        public profile(){
            profId = '';
            name = '';
            user1=new User();
            acc= new Account();
            newsLetter= false;
        }
    }
    
    public class PriceBookWrapper{
        @AuraEnabled public PricebookEntry pbe          { get; set; }
        @AuraEnabled public Attachment media            { get; set; }
        @AuraEnabled public ContentDocumentLink ContentDoc     { get; set; }
        @AuraEnabled public Decimal stock               { get; set; }
        public PriceBookWrapper(){
            pbe=new PricebookEntry();
            media=new Attachment();
            ContentDoc=new ContentDocumentLink();
            stock = 0.00;
        }
    }
    public class cartProdWrapper{
        @AuraEnabled public PricebookEntry cartproduct      		{ get; set; }
        @AuraEnabled public ERP7__Cart_Picked_Item__c cpiList       { get; set; }
        @AuraEnabled public ContentDocumentLink ContentDoc     { get; set; }
        @AuraEnabled public Attachment media            			{ get; set; }
        public cartProdWrapper(){
            cartproduct = new PricebookEntry();
            cpiList = new ERP7__Cart_Picked_Item__c();
            media = new Attachment();
            ContentDoc = new ContentDocumentLink();
        }
    }
    
    public class productWrapper{
        @AuraEnabled public Account acc                                         { get; set; }
        @AuraEnabled public Contact con                                         { get; set; }
        @AuraEnabled public ERP7__Address__c add                                { get; set; }
        @AuraEnabled public ERP7__Address__c addPrimary                         { get; set; }
        @AuraEnabled public ERP7__Address__c addBilling                         { get; set; }
        @AuraEnabled public List<ERP7__Address__c> addShipping                  { get; set; }
        @AuraEnabled public List<ERP7__Address__c> addList                      { get; set; }
        @AuraEnabled public List<ERP7__Profiling__c> profiling                  { get; set; }
        @AuraEnabled public ERP7__Channel__c channel                            { get; set; }
        @AuraEnabled public List <Distribution_Channel__c> DistributionChannels { get; set; }
        @AuraEnabled public List<ERP7__Cart__c> cartList                        { get; set; }
        @AuraEnabled public List<ERP7__Cart_Picked_Item__c> cartpickitemList    { get; set; }
        @AuraEnabled public List<PriceBook2> pricebook                          { get; set; }
        @AuraEnabled public List<PricebookEntry> cartproduct                    { get; set; }
        @AuraEnabled public List<PriceBookWrapper> prodList                     { get; set; }
        @AuraEnabled public List<cartProdWrapper> cartproductWrapper            { get; set; }
        @AuraEnabled public List<AggregateResult> catList                       { get; set; }
        @AuraEnabled public List<ERP7__Media__c> media                          { get; set; }
        @AuraEnabled public List<ContentDocumentLink> conDocFile                { get; set; }
        @AuraEnabled public List<Attachment> attFile                            { get; set; }
        @AuraEnabled public List<PriceBookWrapper> relatedProd                  { get; set; }
        @AuraEnabled public List<ERP7__Sales_Order__c> so						{ get; set; }
        @AuraEnabled public List<myOrderWrapper> myord							{ get; set; }
        @AuraEnabled public List<ERP7__Invoice__c> ivc							{ get; set; }
        @AuraEnabled public List<String> State 									{ get; set; }
        @AuraEnabled public List<String> country								{ get; set; }
        @AuraEnabled public List<PricebookEntry> allProd                    	{ get; set; }
        @AuraEnabled public String errorMsg                                     { get ; set; }
        public productWrapper(){
            con=new Contact();
            add=new ERP7__Address__c();
            addPrimary=new ERP7__Address__c();
            addBilling=new ERP7__Address__c();
            cartpickitemList = new List<ERP7__Cart_Picked_Item__c>();
            cartproduct = new List<PricebookEntry>();
            prodList = new List<PriceBookWrapper>();
            cartproductWrapper = new List<cartProdWrapper>();
            catList = new List<AggregateResult>();
            media= new List<ERP7__Media__c>();
            attFile = new List<Attachment>();
            conDocFile = new List<ContentDocumentLink>();
            relatedProd = new List<PriceBookWrapper>();
            so = new List<ERP7__Sales_Order__c>();
            myord=new List<myOrderWrapper>();
            ivc = new List<ERP7__Invoice__c>();
            State= new List<String>();
            country = new List<String>();
            errorMsg='';
        }
    }
    
    //===================shipping======================
    // For FedEx     
    @AuraEnabled public static String resStatus                     { get; set; }    @AuraEnabled public static String request_1                     { get; set; } @AuraEnabled public static String response_1                    { get; set; }    @AuraEnabled public static String Key                           { get; set; }@AuraEnabled public static String password                      { get; set; }  
    
    @AuraEnabled
    public static upsWrap UPSServices(String soId, String packType, Decimal packNo, String shipDate) {
            upsWrap upsWrapp = new upsWrap();String salesorderId = soId;   String pkgType;                
            if(packType != null && packType != '--None--') pkgType = packType; else pkgType = 'Package';
            String shipperProvinceCode = '', errorMsg = '', shipAddress_Street = '', shipAddress_ProvinceCode = '', shipAddress_CountryCode = '', shipperCountryCode = '', sp_ProvinceCode = '', sp_CountryCode = '';
            Decimal soVolume = 0, soWeight = 0; Decimal pkgLength = 0, totalWeight = 0, pkgWidth = 0, pkgHeight = 0, pkgWeight = 0, additionalPercent = 0, totalPkgVolume = 0;Decimal totalWeightperPackage = 0;Decimal noOfPackages = 0;                   
            ERP7__Package__c pkg = new ERP7__Package__c();ERP7__Sales_Order__c so = new ERP7__Sales_Order__c();List<Selectoptions> packTypeListOption = new List<Selectoptions>();
            
            if(salesorderId != null) {                                        
                ERP7__Sales_Order__c currentSalesOrder = [select Id, Name, ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__Bill_To_Address__r.ERP7__Address_Line2__c, ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, 
                                     ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__Total_Shipping_Amount__c, ERP7__Bill_To_Address__r.ERP7__State__c, ERP7__Bill_To_Address__r.ERP7__Country__c, 
                                     ERP7__Bill_To_Address__r.ERP7__Postal_Code__c, ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, 
                                     ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c, ERP7__Ship_To_Address__r.ERP7__State__c, ERP7__Issue_Invoice__c,
                                     ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Channel__c from ERP7__Sales_Order__c where Id =: salesorderId];
                
                ERP7__Channel__c currentSalepoint = [Select Id, Name, ERP7__Active__c, ERP7__City__c, ERP7__Country__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Site__c,
                                    ERP7__State_Province__c, ERP7__Street__c, ERP7__Tax__c, ERP7__Zip_Postal_Code__c, ERP7__Shipper_Name__c, ERP7__Company__c, 
                                    ERP7__Phone__c From ERP7__Channel__c Where Id = : currentSalesorder.ERP7__Channel__c Limit 1];
                
                for(ERP7__Sales_Order_Line_Item__c soli : [select Id, Name, ERP7__product__c, ERP7__product__r.ERP7__Length__c, ERP7__product__r.ERP7__Width__c, ERP7__product__r.ERP7__Height__c, ERP7__product__r.ERP7__Weight__c, 
                                                                ERP7__Quantity__c from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__r.Id =: currentSalesorder.Id]) {
                    
                    if(soli.ERP7__product__r.ERP7__Length__c != Null && soli.ERP7__product__r.ERP7__Width__c != Null && soli.ERP7__product__r.ERP7__Height__c != Null) soVolume += soli.ERP7__product__r.ERP7__Length__c * soli.ERP7__product__r.ERP7__Width__c * soli.ERP7__product__r.ERP7__Height__c * soli.ERP7__Quantity__c;    
                    if(soli.ERP7__product__r.ERP7__Weight__c != Null) soWeight += soli.ERP7__product__r.ERP7__Weight__c * soli.ERP7__Quantity__c;
                }                                                            
                          
                ERP7__Credentials__c credentials = [Select Id, Name, ERP7__Active__c, ERP7__UPS_Account_Number__c, ERP7__Encrypted_Key__c, ERP7__End_Point__c, ERP7__URL__c, ERP7__Username_Login__c, ERP7__Key__c, ERP7__Password_Transkey__c, //ERP7__Meter_Number__c, 
                               ERP7__Shipper_Name__c, ERP7__Shipper_Company_Name__c, ERP7__Shipper_Email__c, ERP7__Shipper_Phone_Number__c, ERP7__Shipper_Street__c, 
                               ERP7__Shipper_City__c, ERP7__Shipper_Postal_Code__c, ERP7__Shipper_Country__c, ERP7__Shipper_Province__c 
                               From ERP7__Credentials__c 
                               Where Name = 'UPS' And ERP7__Active__c = true And ERP7__UPS_Account_Number__c != null And ERP7__UPS_Account_Number__c != '' And //ERP7__End_Point__c != null And ERP7__End_Point__c != '' And
                               ERP7__Key__c != null And ERP7__Key__c != '' Limit 1];                       
                if(credentials != null) {
                    Blob cryptoKey, userData, passwordData;cryptoKey = encodingUtil.convertFromHex(credentials.ERP7__Encrypted_Key__c);userData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentials.ERP7__Username_Login__c));passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(credentials.ERP7__Password_Transkey__c));
                    if(userData != null) credentials.ERP7__Username_Login__c = userData.toString();
                    if(passwordData != null) credentials.ERP7__Password_Transkey__c = passwordData.toString();
                    
                    List<ERP7__Province_Codes__c> recProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : credentials.ERP7__Shipper_Province__c Limit 1];  
                if(recProvinceCodes.Size() > 0) shipperProvinceCode = recProvinceCodes[0].ERP7__Code__c; 
                else errorMsg = 'UPS Shipping Service Unavailable : Shipper Province Code not found';} else errorMsg = 'UPS Shipping Service Unavailable : Please setup UPS credentials';
                            
                if(credentials != null && currentSalesOrder != null) { 
                    List<ERP7__Country_Codes__c> countryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Country__c Or 
                                                                                                                          ERP7__Country__c =: currentSalepoint.ERP7__Country__c Or ERP7__Country__c =: credentials.ERP7__Shipper_Country__c Limit 3];            
                    if(countryCodes != null && countryCodes.size() == 0) errorMsg = 'UPS Shipping Service Unavailable : Country Code not found'; 
                    else { 
                        if(currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != Null && currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != '') {              
                                                 shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c + ', ' + 
                                                     currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c; } else{ shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c; }  
                        
                        List<ERP7__Province_Codes__c> shipProvinceCode = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__State__c Limit 1];                     
                        if(shipProvinceCode != null && shipProvinceCode.Size() > 0) shipAddress_ProvinceCode = shipProvinceCode[0].ERP7__Code__c;
                        else errorMsg = 'UPS Shipping Service Unavailable : Shipping Address Province Code not found';
                        
                        if(countryCodes != null && countryCodes.size() > 0){
                            for(ERP7__Country_Codes__c c : countryCodes){
                                if(c.ERP7__Country__c == currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Country__c) shipAddress_CountryCode = c.ERP7__Code__c;
                                if(c.ERP7__Country__c == credentials.ERP7__Shipper_Country__c) shipperCountryCode = c.ERP7__Code__c;
                            }
                        }
                        if(shipAddress_CountryCode == null || shipAddress_CountryCode == '') errorMsg = 'UPS Shipping Service Unavailable : Shipping Address Country Code not found';
                        
                        List<ERP7__Province_Codes__c> recProvinceCode = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentSalepoint.ERP7__State_Province__c Limit 1]; 
                        if(recProvinceCode != null && recProvinceCode.Size() > 0) sp_ProvinceCode = recProvinceCode[0].ERP7__Code__c;
                        else errorMsg = 'UPS Shipping Service Unavailable : Salepoint Province Code not found';
                                 
                        if(countryCodes != null && countryCodes.size() > 0) {
                            for(ERP7__Country_Codes__c c :countryCodes) { if(c.ERP7__Country__c == currentSalepoint.ERP7__Country__c) sp_CountryCode = c.ERP7__Code__c; }
                        } 
                        if(sp_CountryCode == null || sp_CountryCode == ''){ errorMsg = 'UPS Shipping Service Unavailable : Salepoint Country Code not found'; } 
                        
                        List<ERP7__Package_Details__c> pkgDetailLists = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Weight__c, ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c Where ERP7__Type__c = 'UPS']; 
                        boolean packageExist = false;
                        for(ERP7__Package_Details__c pkgDetailListt : pkgDetailLists) {
                            packageExist = true;
                            packTypeListOption.add(new selectOptions(pkgDetailListt.ERP7__Package_Type__c, pkgDetailListt.ERP7__Package_Type__c)); 
                        } 
                        if(!packageExist) errorMsg = 'Package Details not found'; 
                        upsWrapp.UPSErrorMsg = errorMsg;
                    
                         if(errorMsg == '' || Test.isRunningTest()){
            
                            if(pkgType != null && pkgType != '--None--') { 
                            List<ERP7__Package_Details__c> pkgDetailList = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Additional_Percentage__c, Weight__c, 
                                               ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c where ERP7__Package_Type__c =: pkgType limit 1];                                             
                            
                            if(pkgDetailList.size() > 0) {
                                pkg.ERP7__Length__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Length__c;pkg.ERP7__Width__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Width__c;            pkg.ERP7__Height__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Height__c;pkg.ERP7__Weight__c = pkgDetailList[pkgDetailList.size() - 1].Weight__c;pkg.ERP7__Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Weight_Unit__c;pkgLength = pkg.ERP7__Length__c;                                 pkgWidth = pkg.ERP7__Width__c;                                      pkgHeight = pkg.ERP7__Height__c;                                     pkgWeight = pkg.ERP7__Weight__c;                                    
                                additionalPercent = Integer.valueof(pkgDetailList[pkgDetailList.size() - 1].Additional_Percentage__c);totalPkgVolume = (pkg.ERP7__Length__c * pkg.ERP7__Width__c * pkg.ERP7__Height__c).setscale(2);noOfPackages = Integer.valueof(soVolume / totalPkgVolume);
                                if(math.mod(Integer.valueof(soVolume),Integer.valueof(totalPkgVolume)) > 0) noOfPackages++;
                                //if(packNo != Null && packNo > noOfPackages) noOfPackages = packNo;
                                soVolume = soVolume.setscale(2);soWeight = soWeight.setscale(2);totalWeight = (soWeight + (noOfPackages * pkg.ERP7__Weight__c)).setscale(2);totalWeightperPackage = (noOfPackages > 0)? (totalWeight / noOfPackages).setscale(2) : totalWeight;
                                
                                
                                upsWrapp.PackageType  = pkgType;                    
                                upsWrapp.PackageTypes = packTypeListOption;    
                                if(shipDate != Null && shipDate != '') 
                                    upsWrapp.ShipmentDate = Date.valueOf(shipDate);
                                else upsWrapp.ShipmentDate = System.Today();                     
                                upsWrapp.Length = pkgLength;                      upsWrapp.Width = pkgWidth;                          upsWrapp.Height = pkgHeight;                         upsWrapp.Weight = pkgWeight;                          upsWrapp.NoofPackage = noOfPackages;                    upsWrapp.Additional = additionalPercent;                      upsWrapp.PackageVolume = totalPkgVolume;                  upsWrapp.SOVolume = soVolume;                       upsWrapp.SOWeight = soWeight;                        upsWrapp.TotalWeight = totalWeight;                    upsWrapp.WeightPerPack = totalWeightperPackage;                 
                                //serviceRequest();                    
                                
                                
                                try {
                                    string soapXML = '<?xml version="1.0"?>';
                                    soapXML += '<AccessRequest xml:lang="en-US">';soapXML += '<AccessLicenseNumber>'+ credentials.ERP7__Key__c +'</AccessLicenseNumber>';soapXML += '<UserId>'+ credentials.ERP7__Username_Login__c +'</UserId>';soapXML += '<Password>'+ credentials.ERP7__Password_Transkey__c +'</Password>';soapXML += '</AccessRequest>';
                                
                                    soapXML += '<?xml version="1.0"?>';soapXML += '<RatingServiceSelectionRequest>';soapXML += '<Request>';soapXML += '<RequestAction>Rate</RequestAction>';soapXML += '<RequestOption>Shop</RequestOption>';soapXML += '</Request>';
                                    
                                    soapXML += '<Shipment>';
                                        soapXML += '<Shipper>';soapXML += '<ShipperNumber>'+ credentials.ERP7__UPS_Account_Number__c +'</ShipperNumber>';soapXML += '<Address>';soapXML += '<AddressLine1>'+ credentials.ERP7__Shipper_Street__c +'</AddressLine1>';soapXML += '<City>'+ credentials.ERP7__Shipper_City__c +'</City>';soapXML += '<StateProvinceCode>'+ shipperProvinceCode +'</StateProvinceCode>';soapXML += '<PostalCode>'+ credentials.ERP7__Shipper_Postal_Code__c +'</PostalCode>';soapXML += '<CountryCode>'+ shipperCountryCode +'</CountryCode>';soapXML += '</Address>';soapXML += '</Shipper>';                                    soapXML += '<ShipTo>';soapXML += '<Address>';
                                        soapXML += '<AddressLine1>'+ shipAddress_Street +'</AddressLine1>';
                                        if(currentSalesOrder != null) soapXML += '<City>'+ currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__City__c +'</City>';
                                        if(currentSalesOrder != null) soapXML += '<PostalCode>'+ currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c +'</PostalCode>';
                                        soapXML += '<CountryCode>'+ shipAddress_CountryCode +'</CountryCode>';soapXML += '</Address>';soapXML += '</ShipTo>';
                                        
                                        soapXML += '<ShipFrom>';soapXML += '<Address>';
                                        if(currentSalepoint != null) {
                                            soapXML += '<AddressLine1>'+ currentSalepoint.ERP7__Street__c +'</AddressLine1>';soapXML += '<City>'+ currentSalepoint.ERP7__City__c +'</City>';soapXML += '<StateProvinceCode>'+ sp_ProvinceCode +'</StateProvinceCode>';soapXML += '<PostalCode>'+ currentSalepoint.ERP7__Zip_Postal_Code__c +'</PostalCode>';soapXML += '<CountryCode>'+ sp_CountryCode +'</CountryCode>';
                                        }
                                        soapXML += '</Address>';soapXML += '</ShipFrom>';soapXmL += '<RateInformation>';soapXmL += '<NegotiatedRatesIndicator>Y</NegotiatedRatesIndicator>';soapXmL += '</RateInformation>'; 
                                        
                                        Map<String, ERP7__UPS_Package_Type__c> packageTypeMap = new Map<String, ERP7__UPS_Package_Type__c>();              
                                        List <ERP7__UPS_Package_Type__c> packageType = [select Id, Name, ERP7__Package_Code__c, ERP7__Package_Description__c from ERP7__UPS_Package_Type__c limit 12];                                                                      
                                        for(ERP7__UPS_Package_Type__c upt : packageType) { packageTypeMap.put(upt.ERP7__Package_Description__c, upt); }
                                        
                                        for(Integer i=0; i<noOfPackages; i++) {
                                            soapXML += '<Package>';soapXML += '<PackagingType>';soapXML += '<Code>'+ packageTypeMap.get('Package').ERP7__Package_Code__c +'</Code>';soapXML += '</PackagingType>';
                                            
                                            soapXML += '<Dimensions>'; soapXML += '<UnitOfMeasurement>';
                                            if(pkg.ERP7__Weight_Unit__c == 'KGS')  soapXMl += '<Code>CM</Code>';
                                            else soapXMl += '<Code>IN</Code>';
                                                         
                                            soapXML += '</UnitOfMeasurement>';          soapXMl += '<Length>'+ pkg.ERP7__Length__c +'</Length>';soapXML += '<Width>'+ pkg.ERP7__Width__c +'</Width>';soapXML += '<Height>'+ pkg.ERP7__Height__c +'</Height>';
                                            soapXML += '</Dimensions>';soapXML += '<PackageWeight>';soapXML += '<UnitOfMeasurement>';soapXML += '<Code>'+ pkg.ERP7__Weight_Unit__c +'</Code>';            soapXML += '</UnitOfMeasurement>';soapXML += '<Weight>'+ totalWeightperPackage +'</Weight>';soapXML += '</PackageWeight>';                                   soapXML += '</Package>';
                                        }                            
                                    soapXML += '</Shipment>';soapXML += '</RatingServiceSelectionRequest>';
                                    
                                    HttpRequest req = new HttpRequest(); Http h = new Http();
                                    req.setBody(soapXML); req.setMethod('POST');
                                    //req.setEndpoint('https://onlinetools.ups.com/ups.app/xml/Rate');
                                    String myEndPoint = credentials.ERP7__URL__c + '/ups.app/xml/Rate'; req.setEndpoint(myEndPoint);HttpResponse res = new HttpResponse();
                                    if(!Test.isRunningTest()) res = h.send(req);
                                    String Result = '';
                                    
                                    if(res.getStatus() == 'OK') {
                                        XmlStreamReader reader1 = res.getXmlStreamReader();String msg = readXMLResponse(reader1, 'ResponseStatusDescription');
                                        if (msg != Null && (msg == 'SUCCESS' || msg == 'WARNING')) {
                                            XmlStreamReader reader = res.getXmlStreamReader();String sxmltag = 'RatedShipment';rateWrapper rw; List<rateWrapper> rateWrapperList = new List<rateWrapper>();            
                                            while(reader.hasNext()) {
                                                if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == sxmltag) { rw = new rateWrapper();                    
                                                    while(reader.hasNext()) {
                                                        //ups service
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Service') {
                                                            reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Code') { reader.next(); rw.ServiceCode = reader.getText(); }
                                
                                                            List <ERP7__UPS_Service_Codes__c> serviceCodes = [select Id, Name, ERP7__Service__c, ERP7__ServiceCode__c, ERP7__Service_Code_With_Trade_Mark__c, ERP7__Service_Asia_International__c,
                                                                                                                    ERP7__Service_Canada_Domestic__c, ERP7__Service_Canada_International__c, ERP7__Service_Europe__c, ERP7__Service_Mexico_Domestic__c,
                                                                                                                    ERP7__Service_Mexico_International__c, ERP7__Service_USA_Domestic__c from ERP7__UPS_Service_Codes__c limit 22];
                                                            if(sp_CountryCode == 'CA' && shipAddress_CountryCode == 'CA') { 
                                                                for(Integer i=0;i<serviceCodes.size();i++) {if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Canada_Domestic__c; }}
                                                            } else if(sp_CountryCode == 'CA' && shipAddress_CountryCode != 'CA') {                                
                                                                for(Integer i=0;i<serviceCodes.size();i++) {if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Canada_International__c; }                                                       }
                                                            } else if(sp_CountryCode == 'MX' && shipAddress_CountryCode == 'MX') {            
                                                                for(Integer i=0;i<serviceCodes.size();i++) {if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Mexico_Domestic__c; }                                                       }
                                                            } else if(sp_CountryCode == 'MX' && shipAddress_CountryCode != 'MX') {  
                                                                for(Integer i=0;i<serviceCodes.size();i++) {if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Mexico_International__c; }                                                       }
                                                            } else { for(Integer i=0;i<serviceCodes.size();i++) {if(rw.ServiceCode == serviceCodes[i].ERP7__ServiceCode__c) { rw.ServiceManual = serviceCodes[i].ERP7__Service_Code_With_Trade_Mark__c; }   }
                                                            }
                                                        }
                                                        // transport charges
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TransportationCharges') {  reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 
                                                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next();
                                                                if(reader.hasText() && rw.TransportationCharges == '') rw.TransportationCharges = reader.getText(); }          
                                                        }
                                                        // services charges
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceOptionsCharges') { reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 
                                                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next(); 
                                                                if(reader.hasText() && rw.ServiceOptionsCharges == '') rw.ServiceOptionsCharges = reader.getText(); } 
                                                        }
                                                        // total charges
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalCharges') { reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 
                                                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next(); 
                                                                if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText(); }
                                                        }
                                                        // days to deliver
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'GuaranteedDaysToDelivery') { reader.next();
                                                            if(reader.hasText()) {  rw.GuaranteedDaysToDelivery = reader.getText(); 
                                                                                    rw.DeliveryDate = upsWrapp.ShipmentDate + Integer.valueof(rw.GuaranteedDaysToDelivery);
                                                            } else { rw.GuaranteedDaysToDelivery = '-'; rw.DeliveryDateS = '-'; }
                                                        }                        
                                                        // time to deliver           
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ScheduledDeliveryTime') { reader.next();                        
                                                            if(reader.hasText()) { rw.ScheduledDeliveryTime = reader.getText(); }
                                                            else { rw.ScheduledDeliveryTime = '-'; }
                                                        }          
                                                        // negotiated charges                                       
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'NegotiatedRates') { reader.next(); reader.next(); reader.next();
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'CurrencyCode') { reader.next(); 
                                                                if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();  
                                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'MonetaryValue') { reader.next(); 
                                                                if(reader.hasText() && rw.negotiatedCharges == '') rw.negotiatedCharges = reader.getText(); }    
                                                        }                        
                                                        if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == sxmltag) break; else reader.next();
                                                    } rateWrapperList.add(rw);               
                                                } reader.next();
                                            }            
                                            Integer n = rateWrapperList.size();            
                                            for(Integer c = 0 ; c < ( n - 1 ); c++) {
                                                for (Integer d = 0 ; d < n - c - 1; d++) {
                                                    if(Decimal.valueof(rateWrapperList[d].totalCharges) > Decimal.valueof(rateWrapperList[d+1].totalCharges)) { // For decreasing order use < 
                                                        rateWrapper swap = rateWrapperList[d]; rateWrapperList[d] = rateWrapperList[d+1]; rateWrapperList[d+1] = swap;
                                                    }
                                                }
                                            }       
                                            upsWrapp.Services = rateWrapperList;
                                            upsWrapp.UPSErrorMsg = 'Available Services For The Selected Location';
                                        } else { XmlStreamReader reader3 = res.getXmlStreamReader();
                                            String msg1 = readXMLResponse(reader3, 'ErrorDescription');
                                            if (msg1 != Null && msg1 != '') upsWrapp.UPSErrorMsg = 'Shipping Rate Service Is Not Available : ' + msg1;
                                            else upsWrapp.UPSErrorMsg = 'Request To Rate Shipment Cannot Be Processed';
                                        }    
                                    } else upsWrapp.UPSErrorMsg = 'Result not available';            
                                } catch(Exception E) { upsWrapp.UPSErrorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); } 
                            }
                        }
                    } 
                }
            }                                    
        }
        return upsWrapp;
    }    
    
     @AuraEnabled
    public static Decimal UPSServiceSave(String soId, String rateWrapperSelected, String shipDate, Decimal additionalPercent) {
        rateWrapper rateWrap = (rateWrapper) JSON.deserialize(rateWrapperSelected, rateWrapper .class);
        //String SalesOrderFields = UtilClass.selectStarFromSObject('Sales_Order__c');
        String SalesOrderFields = 'id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, erp7__expected_date__c, erp7__active__c, erp7__amount__c, erp7__barcode__c, erp7__book_date__c, erp7__customer_email__c, erp7__customer_purchase_order_date__c, erp7__employee_email__c, erp7__hold_status__c, erp7__is_back_order__c, erp7__is_invoice_sent__c, erp7__loyalty_amount__c, erp7__loyalty_points__c, erp7__name_link__c, erp7__name__c, erp7__order_date__c, erp7__order_status__c, erp7__payment_mode__c, erp7__purchase_order_number__c, erp7__request_date__c, erp7__special_instructions__c, erp7__status_timestamp__c, erp7__status__c, erp7__code__c, erp7__bill_to_address__c, erp7__contact__c, erp7__customer_name__c, erp7__organisation_business_unit__c, erp7__organisation__c, erp7__payment_method__c, erp7__channel__c, erp7__ship_to_address__c, erp7__status_duration__c, erp7__total_tax_amount__c, erp7__authorised__c, erp7__sub_total__c, erp7__total_discount__c, erp7__total_due__c, erp7__total_other_tax__c, erp7__total_vat__c, erp7__ready_to_receive__c, erp7__employee_name__c, erp7__employees__c, erp7__shipment_type__c, erp7__ready_to_pick_pack__c, erp7__subscription__c, erp7__customer_id__c, erp7__due_amount__c, erp7__payments_status__c, erp7__sales_order_amount__c, erp7__fulfilled__c, erp7__ready_to_ship__c, erp7__number_of_back_order_items__c, erp7__total_shipping_amount__c, erp7__redeem_voucher_amount__c, erp7__amount_paid__c, erp7__is_pre_order__c, erp7__number_of_fulfilled_items__c, erp7__total_number_of_items__c, erp7__estimated_delivery_date__c, erp7__fulfilled_date__c, erp7__estimated_delivery_month__c, erp7__is_converted__c, erp7__is_closed__c, erp7__account__c, erp7__returnamount__c, erp7__rmalines_to_process__c, erp7__total_quantity__c, erp7__picked_quantity__c, erp7__packed_quantity__c, erp7__quotes__c, erp7__tracking_number__c, erp7__shipped_quantity__c, erp7__shipping_vat__c, erp7__estimated_shipping_amount__c, erp7__ups_service__c, erp7__order_profile__c, erp7__description__c, erp7__source__c, erp7__eorder_id__c, erp7__shipping_discount__c, erp7__cancelled_reason__c, erp7__ship_from_address__c, erp7__cost_price__c, erp7__logistic_cost__c';String AllSalesOrderFields = SalesOrderFields + ',Contact__r.Email,Account__r.Name,Channel__r.Name,Employees__r.Email__c ';String SalesOrderSoql = 'SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + ' FROM Sales_Order__c where Name=:soId or Id=:soId Limit 1'; // hande escape
        Sales_Order__c currentSalesOrder = Database.query(SalesOrderSoql);
        if(rateWrap.negotiatedCharges != null && rateWrap.negotiatedCharges != '' && rateWrap.negotiatedCharges != '-') {
            Decimal negotiatedCharge = (Decimal.valueof(rateWrap.negotiatedCharges) + ((Decimal.valueof(rateWrap.negotiatedCharges) * additionalPercent) / 100));
            currentSalesOrder.Estimated_Shipping_Amount__c = negotiatedCharge.setscale(2);currentSalesOrder.ERP7__Total_Shipping_Amount__c = negotiatedCharge.setscale(2); 
        
        } else if(rateWrap.totalCharges != null && rateWrap.totalCharges != '' && rateWrap.totalCharges != '-') { 
            Decimal totalCharge = (Decimal.valueof(rateWrap.totalCharges) + ((Decimal.valueof(rateWrap.totalCharges) * additionalPercent) / 100));
            currentSalesOrder.Estimated_Shipping_Amount__c = totalCharge.setscale(2);currentSalesOrder.ERP7__Total_Shipping_Amount__c = totalCharge.setscale(2); 
        }
        
        currentSalesOrder.ERP7__Shipment_Type__c = 'UPS';
        if(rateWrap.ServiceManual != null) currentSalesOrder.UPS_Service__c = rateWrap.ServiceManual;
        if(rateWrap.GuaranteedDaysToDelivery != null && rateWrap.GuaranteedDaysToDelivery != '' && rateWrap.GuaranteedDaysToDelivery != '-') 
            currentSalesOrder.ERP7__Estimated_Delivery_Date__c = Date.valueOf(shipDate) + Integer.valueof(rateWrap.GuaranteedDaysToDelivery); 
        else currentSalesOrder.ERP7__Estimated_Delivery_Date__c = null;
        if(Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.UPS_Service__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.UPS_Service__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Estimated_Delivery_Date__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Estimated_Delivery_Date__c.isUpdateable()){upsert currentSalesOrder;}else{/*('User have not permission to update or create record in SO FLS')*/}     
        return currentSalesOrder.ERP7__Total_Shipping_Amount__c;
    }
    
    @AuraEnabled
    public static upsWrap FedServices(String soId, String packType, Decimal packNo, String shipDate) {
        
        upsWrap upsWrapp = new upsWrap();
        
        String salesorderId = soId;   String pkgType;                
        if(packType != null && packType != '--None--') pkgType = packType; else pkgType = 'YOUR_PACKAGING';
        String shipperProvinceCode = '', errorMsg = '', shipAddress_Street = '', shipAddress_ProvinceCode = '', shipAddress_CountryCode = '', shipperCountryCode = '', sp_ProvinceCode = '', sp_CountryCode = '';
        Decimal soVolume = 0, soWeight = 0; Decimal pkgLength = 0, totalWeight = 0, pkgWidth = 0, pkgHeight = 0, pkgWeight = 0, additionalPercent = 0, totalPkgVolume = 0;Decimal totalWeightperPackage = 0;Decimal noOfPackages = 0;                    
        ERP7__Package__c pkg = new ERP7__Package__c();ERP7__Sales_Order__c so = new ERP7__Sales_Order__c();List<Selectoptions> packTypeListOption = new List<Selectoptions>();List<ERP7__Sales_Order_Line_Item__c> lstSoli = new List<ERP7__Sales_Order_Line_Item__c>();
        
        if(salesorderId != null) {                                        
            ERP7__Sales_Order__c currentSalesOrder = [select Id, Name, ERP7__Bill_To_Address__r.ERP7__Address_Line1__c, ERP7__Bill_To_Address__r.ERP7__Address_Line2__c, ERP7__Bill_To_Address__r.ERP7__Address_Line3__c, 
                                 ERP7__Bill_To_Address__r.ERP7__City__c, ERP7__Total_Shipping_Amount__c, ERP7__Bill_To_Address__r.ERP7__State__c, ERP7__Bill_To_Address__r.ERP7__Country__c, 
                                 ERP7__Bill_To_Address__r.ERP7__Postal_Code__c, ERP7__Ship_To_Address__r.ERP7__Address_Line1__c, ERP7__Ship_To_Address__r.ERP7__Address_Line2__c, 
                                 ERP7__Ship_To_Address__r.ERP7__Address_Line3__c, ERP7__Ship_To_Address__r.ERP7__City__c, ERP7__Ship_To_Address__r.ERP7__State__c, 
                                 ERP7__Ship_To_Address__r.ERP7__Country__c, ERP7__Ship_To_Address__r.ERP7__Postal_Code__c, ERP7__Channel__c, ERP7__Issue_Invoice__c,
                                 ERP7__Contact__r.Name, ERP7__Contact__r.Company__c , ERP7__Contact__r.Phone from ERP7__Sales_Order__c where Id =: salesorderId];
            
            ERP7__Channel__c currentSalepoint = [Select Id, Name, ERP7__Active__c, ERP7__City__c, ERP7__Country__c, ERP7__Organisation__c, ERP7__Organisation_Business_Unit__c, ERP7__Site__c,
                                ERP7__State_Province__c, ERP7__Street__c, ERP7__Tax__c, ERP7__Zip_Postal_Code__c, ERP7__Shipper_Name__c, ERP7__Company__c, 
                                ERP7__Phone__c From ERP7__Channel__c Where Id = : currentSalesorder.ERP7__Channel__c Limit 1];
            
            for(ERP7__Sales_Order_Line_Item__c soli : [select Id, Name, ERP7__product__c, ERP7__product__r.ERP7__Length__c, ERP7__product__r.ERP7__Width__c, ERP7__product__r.ERP7__Height__c, ERP7__product__r.ERP7__Weight__c, 
                                                       ERP7__product__r.ERP7__Description__c, ERP7__Quantity__c from ERP7__Sales_Order_Line_Item__c where ERP7__Sales_Order__r.Id =: currentSalesorder.Id]) {
                
                if(soli.ERP7__product__r.ERP7__Length__c != Null && soli.ERP7__product__r.ERP7__Width__c != Null && soli.ERP7__product__r.ERP7__Height__c != Null) soVolume += soli.ERP7__product__r.ERP7__Length__c * soli.ERP7__product__r.ERP7__Width__c * soli.ERP7__product__r.ERP7__Height__c * soli.ERP7__Quantity__c;    
                if(soli.ERP7__product__r.ERP7__Weight__c != Null) soWeight += soli.ERP7__product__r.ERP7__Weight__c * soli.ERP7__Quantity__c;
                lstSoli.add(soli);
            } 
             
            ERP7__Credentials__c fedExCre = [Select Id, Name, ERP7__Active__c, ERP7__Parent_Key__c, ERP7__Parent_Password__c, ERP7__Key__c, ERP7__Password_Transkey__c, 
                                              ERP7__Meter_Number__c, ERP7__URL__c, ERP7__UPS_Account_Number__c, ERP7__Shipper_Name__c, ERP7__Shipper_Company_Name__c, 
                                              ERP7__Shipper_Street__c, ERP7__Shipper_Postal_Code__c,  ERP7__Shipper_City__c, ERP7__Shipper_Province__c, ERP7__Shipper_Country__c,
                                              ERP7__Encrypted_Key__c, ERP7__Shipper_Email__c, ERP7__Shipper_Phone_Number__c
                                              From ERP7__Credentials__c     
                                              Where Name = 'FedEx' And ERP7__Active__c = true Limit 1]; 
            
            
            if(fedExCre != null){
                Blob cryptoKey, passwordData;cryptoKey = encodingUtil.convertFromHex(fedExCre.Encrypted_Key__c);
                passwordData = Crypto.decryptWithManagedIV('AES256', cryptoKey, encodingUtil.convertFromHex(fedExCre.Password_Transkey__c));
                if(passwordData != null) fedExCre.Password_Transkey__c = passwordData.toString();
                
                List<ERP7__Province_Codes__c> lstProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : fedExCre.ERP7__Shipper_Province__c Limit 1];  
                if(lstProvinceCodes.Size() > 0) shipperProvinceCode = lstProvinceCodes[0].ERP7__Code__c; 
                //else errorMsg = 'FedEx Shipping Service Unavailable : Shipper Province Code not found';
                
                List<ERP7__Country_Codes__c> lstcountryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: fedExCre.ERP7__Shipper_Country__c Limit 1];            
                if(lstcountryCodes.size() > 0) shipperCountryCode = lstcountryCodes[0].ERP7__Code__c;
                else errorMsg = 'FedEx Shipping Service Unavailable : Shipper Country Code not found';
            } else errorMsg = 'FedEx Shipping Service Unavailable : Please setup FedEx credentials';
            
            if(currentSalesOrder != null){
                if(currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != Null && currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c != '') {              
                    shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line3__c; 
                } else if(currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != Null && currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c != '') { 
                    shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c + ', ' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line2__c; 
                } else { shipAddress_Street = currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Address_Line1__c; }
            
                List<ERP7__Province_Codes__c> lstToProvinceCodes = [Select Id, Name, ERP7__Code__c, ERP7__Province__c From ERP7__Province_Codes__c Where ERP7__Province__c = : currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__State__c Limit 1];  
                if(lstToProvinceCodes.Size() > 0) shipAddress_ProvinceCode = lstToProvinceCodes[0].ERP7__Code__c; 
                //else errorMsg = 'FedEx Shipping Service Unavailable : Shipping Address Province Code not found';
                
                List<ERP7__Country_Codes__c> lstTocountryCodes = [Select Id, Name, ERP7__Code__c, ERP7__Country__c From ERP7__Country_Codes__c Where ERP7__Country__c =: currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Country__c Limit 1];            
                if(lstTocountryCodes.size() > 0) shipAddress_CountryCode = lstTocountryCodes[0].ERP7__Code__c;
                else errorMsg = 'FedEx Shipping Service Unavailable : Shipping Address Country Code not found';
            } 
                
            List<ERP7__Package_Details__c> pkgDetailLists = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Weight__c, ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c Where ERP7__Type__c = 'FEDEX' Order by CreatedDate Asc]; 
            boolean packageExist = false;
            
            for(ERP7__Package_Details__c pkgDetailListt : pkgDetailLists) { packageExist = true; packTypeListOption.add(new selectOptions(pkgDetailListt.ERP7__Package_Type__c, pkgDetailListt.ERP7__Package_Type__c)); 
            }
             
            if(!packageExist) errorMsg = 'Package Details not found'; 
            upsWrapp.UPSErrorMsg = errorMsg;
            
            if(errorMsg == '' || Test.isRunningTest()){
                if(pkgType != null && pkgType != '--None--') { 
                    List<ERP7__Package_Details__c> pkgDetailList = [select Id, Name, ERP7__Length__c, ERP7__Width__c, ERP7__Height__c, Additional_Percentage__c, Weight__c, 
                                                               ERP7__Weight_Unit__c, ERP7__Package_Type__c, ERP7__Type__c from ERP7__Package_Details__c where ERP7__Package_Type__c =: pkgType limit 1]; 
                                                               
                    if(pkgDetailList.size() > 0) {
                        pkg.ERP7__Length__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Length__c;pkg.ERP7__Width__c  = pkgDetailList[pkgDetailList.size() - 1].ERP7__Width__c;            pkg.ERP7__Height__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Height__c;pkg.ERP7__Weight__c = pkgDetailList[pkgDetailList.size() - 1].Weight__c;pkg.ERP7__Weight_Unit__c = pkgDetailList[pkgDetailList.size() - 1].ERP7__Weight_Unit__c;
                        pkgLength = pkg.ERP7__Length__c;                                 pkgWidth  = pkg.ERP7__Width__c;                                      pkgHeight = pkg.ERP7__Height__c;                                     pkgWeight = pkg.ERP7__Weight__c;                                    
                        additionalPercent = Integer.valueof(pkgDetailList[pkgDetailList.size() - 1].Additional_Percentage__c);
                        totalPkgVolume = (pkg.ERP7__Length__c * pkg.ERP7__Width__c * pkg.ERP7__Height__c).setscale(2);
                        noOfPackages = Integer.valueof(soVolume / totalPkgVolume);
                        if(math.mod(Integer.valueof(soVolume),Integer.valueof(totalPkgVolume)) > 0) noOfPackages++;
                        soVolume = soVolume.setscale(2);soWeight = soWeight.setscale(2);totalWeight = (soWeight + (noOfPackages * pkg.ERP7__Weight__c)).setscale(2);totalWeightperPackage = (noOfPackages > 0)? (totalWeight / noOfPackages).setscale(2) : totalWeight;
                        
                        upsWrapp.PackageType  = pkgType;                    upsWrapp.PackageTypes = packTypeListOption;    
                        if(shipDate != Null && shipDate != '') { upsWrapp.ShipmentDate = Date.valueOf(shipDate); DateTime dt = upsWrapp.ShipmentDate; shipDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'); }
                        else {  DateTime dt = System.now(); shipDate = dt.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'', 'GMT'); upsWrapp.ShipmentDate = System.Today(); }
                        upsWrapp.Length = pkgLength;                      upsWrapp.Width = pkgWidth;                          upsWrapp.Height = pkgHeight;                         upsWrapp.Weight = pkgWeight;                          upsWrapp.NoofPackage = noOfPackages;                    upsWrapp.Additional = additionalPercent;                      upsWrapp.PackageVolume = totalPkgVolume;                  upsWrapp.SOVolume = soVolume;                       upsWrapp.SOWeight = soWeight;                        upsWrapp.TotalWeight = totalWeight;                    upsWrapp.WeightPerPack = totalWeightperPackage;
                        
                        try {
                            String soapXML = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="'+Label.POSLightningLabel3+'/soap/envelope/" xmlns:SOAP-ENC="'+Label.POSLightningLabel3+'/soap/encoding/" xmlns:xsi="'+Label.POSLightningLabel2+'-instance" xmlns:xsd="'+Label.POSLightningLabel2+'" xmlns="'+Label.POSLightningLabel4+'/ws/rate/v20">';
                            soapXML += '<SOAP-ENV:Body>';soapXML += '<RateRequest>';
                                
                                soapXML += '<WebAuthenticationDetail>';
                                    soapXML += '<UserCredential>';  soapXML += '<Key>' + fedExCre.key__c + '</Key>';soapXML += '<Password>'+ fedExCre.Password_Transkey__c +'</Password>';
                                        //soapXML += '<Password>STlrFA84EzdzSOWfrW35xEIlE</Password>';
                                    soapXML += '</UserCredential>';
                                soapXML += '</WebAuthenticationDetail>';
                                
                                soapXML += '<ClientDetail>';soapXML += '<AccountNumber>'+ fedExCre.ERP7__UPS_Account_Number__c +'</AccountNumber>';soapXML += '<MeterNumber>'+ fedExCre.ERP7__Meter_Number__c +'</MeterNumber>';soapXML += '</ClientDetail>';
                                
                                soapXML += '<TransactionDetail>';soapXML += '<CustomerTransactionId>Rate Request</CustomerTransactionId>';soapXML += '</TransactionDetail>';
                                
                                soapXML += '<Version>';soapXML += '<ServiceId>crs</ServiceId>';soapXML += '<Major>20</Major>';soapXML += '<Intermediate>0</Intermediate>';soapXML += '<Minor>0</Minor>';soapXML += '</Version>';
                                 
                                soapXML += '<RequestedShipment>';
                                    soapXML += '<ShipTimestamp>'+ shipDate +'</ShipTimestamp>';soapXML += '<DropoffType>REGULAR_PICKUP</DropoffType>';soapXML += '<PackagingType>'+ pkgType +'</PackagingType>';
                                    
                                    soapXML+= '<TotalWeight>';
                                        if(pkg.ERP7__Weight_Unit__c == 'KGS') soapXMl += '<Units>KG</Units>';
                                        else soapXMl += '<Units>LB</Units>';                         
                                        soapXML += '<Value>'+ totalWeight +'</Value>';
                                    soapXML += '</TotalWeight>';
                                    
                                    if(fedExCre != null) {   
                                        soapXML += '<Shipper>';                        
                                            soapXML += '<Contact>';soapXML += '<PersonName>'+ fedExCre.ERP7__Shipper_Name__c.escapeXml() +'</PersonName>';soapXML += '<CompanyName>'+ fedExCre.ERP7__Shipper_Company_Name__c.escapeXml() +'</CompanyName>';soapXML += '<PhoneNumber>'+ fedExCre.ERP7__Shipper_Phone_Number__c.escapeXml() +'</PhoneNumber>';soapXML += '</Contact>';soapXML += '<Address>';
                                                soapXML += '<StreetLines>' + fedExCre.ERP7__Shipper_Street__c.escapeXml() + '</StreetLines>';
                                                soapXML += '<City>'+ fedExCre.ERP7__Shipper_City__c.escapeXml() +'</City>';
                                                if(shipperProvinceCode != null) soapXML += '<StateOrProvinceCode>'+ shipperProvinceCode.escapeXml() +'</StateOrProvinceCode>';
                                                soapXML += '<PostalCode>'+ fedExCre.ERP7__Shipper_Postal_Code__c.escapeXml() +'</PostalCode>';
                                                if(shipperCountryCode != null) soapXML += '<CountryCode>'+ shipperCountryCode.escapeXml() +'</CountryCode>';
                                            soapXML += '</Address>';soapXML += '</Shipper>';
                                    }
                                    if(currentSalesOrder != null) {
                                        soapXML += '<Recipient>';soapXML += '<Contact>';
                                                soapXML += '<PersonName>'+ currentSalesOrder.ERP7__Contact__r.Name.escapeXml() +'</PersonName>';
                                                if(currentSalesOrder.ERP7__Contact__r.Company__c != null) soapXML += '<CompanyName>'+ currentSalesOrder.ERP7__Contact__r.Company__c.escapeXml() +'</CompanyName>';
                                                if(currentSalesOrder.ERP7__Contact__r.Phone != null) soapXML += '<PhoneNumber>'+ currentSalesOrder.ERP7__Contact__r.Phone.escapeXml() +'</PhoneNumber>';
                                            soapXML += '</Contact>'; soapXML += '<Address>';soapXML += '<StreetLines>' + shipAddress_Street.escapeXml() + '</StreetLines>';soapXML += '<City>' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__City__c.escapeXml() + '</City>';
                                                if(shipAddress_ProvinceCode != null) soapXML += '<StateOrProvinceCode>' + shipAddress_ProvinceCode.escapeXml() + '</StateOrProvinceCode>';
                                                soapXML += '<PostalCode>' + currentSalesOrder.ERP7__Ship_To_Address__r.ERP7__Postal_Code__c .escapeXml() + '</PostalCode>';
                                                if(shipAddress_CountryCode != null)  soapXML += '<CountryCode>' + shipAddress_CountryCode.escapeXml() + '</CountryCode>';
                                            soapXML += '</Address>';soapXML += '</Recipient>';
                                    }
                                    soapXML += '<ShippingChargesPayment>';
                                        soapXML += '<PaymentType>SENDER</PaymentType>';soapXML += '<Payor>';soapXML += '<ResponsibleParty>';
                                                if(fedExCre != null) soapXML += '<AccountNumber>'+ fedExCre.ERP7__UPS_Account_Number__c +'</AccountNumber>';
                                            soapXML += '</ResponsibleParty>';soapXML += '</Payor>';                         soapXML += '</ShippingChargesPayment>';
                                    
                                    soapXML += '<RateRequestTypes>LIST</RateRequestTypes>';soapXML += '<PackageCount>'+ noOfPackages +'</PackageCount>';
                                    
                                    for(Integer i=0; i<=noOfPackages; i++) {
                                        soapXML += '<RequestedPackageLineItems>';
                                            soapXML += '<SequenceNumber>'+ i+1 +'</SequenceNumber>';soapXML += '<GroupNumber>1</GroupNumber>';soapXML += '<GroupPackageCount>1</GroupPackageCount>';
                                            
                                            soapXML += '<Weight>';
                                                if(pkg.ERP7__Weight_Unit__c == 'KGS') soapXMl += '<Units>KG</Units>';
                                                else soapXMl += '<Units>LB</Units>';    
                                                soapXML += '<Value>' + totalWeightperPackage + '</Value>';                        
                                            soapXML += '</Weight>';
                                            
                                            /*
                                            soapXML += '<ContentRecords>';
                                                if(lstSoli.size()>0){
                                                    soapXML += '<PartNumber>'+ lstSoli[i].Name +'</PartNumber>';
                                                    soapXML += '<ItemNumber>'+ lstSoli[i].Name +'</ItemNumber>'; 
                                                    soapXML += '<ReceivedQuantity>'+ Integer.valueof(lstSoli[i].ERP7__Quantity__c) +'</ReceivedQuantity>';
                                                    soapXML += '<Description>'+ lstSoli[i].ERP7__product__r.ERP7__Description__c +'</Description>';
                                                }
                                            soapXML += '</ContentRecords>';
                                            */
                                        soapXML += '</RequestedPackageLineItems>';
                                    }         
                                soapXML += '</RequestedShipment>';                
                            soapXML += '</RateRequest>';soapXML += '</SOAP-ENV:Body>';soapXML += '</SOAP-ENV:Envelope>';
                            HttpRequest req = new HttpRequest();Http h = new Http();
                            
                            req.setBody(soapXML);req.setMethod('POST');String myEndPoint = fedExCre.ERP7__URL__c; req.setEndpoint(myEndPoint);req.setHeader('Content-length', '175');req.setHeader('Content-Type', 'text/xml');req.setHeader('SOAPAction', '');req.setHeader('Host', 'wsbeta.fedex.com');
                            
                            HttpResponse res = h.send(req);            request_1 = soapXML;response_1 = res.getBody(); resStatus = res.getStatus();
                            
                            if(res.getStatus() == 'OK') { XmlStreamReader reader1 = res.getXmlStreamReader(); String msg = readXMLResponse(reader1, 'Severity');
                                if(msg != Null && msg == 'SUCCESS' || msg == 'WARNING') {
                                    XmlStreamReader reader2 = res.getXmlStreamReader(); 
                                    String resMesage = readXMLResponse(reader2, 'Code');
                                    if (resMesage == '556') {
                                        upsWrapp.UPSErrorMsg = 'There are no valid services available.';
                                    }else{
                                        XmlStreamReader reader = res.getXmlStreamReader();
                                        rateWrapper rw; List<rateWrapper> rateWrapperLst = new List<rateWrapper>(); 
                                        while(reader.hasNext()) {
                                            if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'RateReplyDetails') {  rw = new rateWrapper();
                                                while(reader.hasNext()) {
                                                    // service type
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'ServiceType') { reader.next();
                                                        rw.service = reader.getText(); }
                                                    // sur charges
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalSurcharges') { reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next(); 
                                                            if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next(); 
                                                            if(reader.hasText() && rw.totalSurcharges == '') rw.totalSurcharges = reader.getText(); /*+' '+ rw.currencyCode;*/ } }
                                                    // total charges
                                                    if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'TotalNetCharge') { reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Currency') { reader.next(); 
                                                            if(reader.hasText() && rw.CurrencyCode == '') rw.CurrencyCode = reader.getText(); } reader.next(); reader.next();
                                                        if(reader.getEventType() == XmlTag.START_ELEMENT && reader.getLocalName() == 'Amount') { reader.next(); 
                                                            if(reader.hasText() && rw.totalCharges == '') rw.totalCharges = reader.getText(); /* +' '+ rw.currencyCode;*/ } }    
                                                    if(reader.getEventType() == XmlTag.END_ELEMENT && reader.getLocalName() == 'RateReplyDetails') break; else reader.next();
                                                } rateWrapperLst.add(rw);
                                            } reader.next();
                                        }
                                          upsWrapp.Services = rateWrapperLst;upsWrapp.UPSErrorMsg = 'Available Services For The Selected Location';
                                          //time_in_cost_tab = true;
                                    }                                
                                } else { XmlStreamReader reader3 = res.getXmlStreamReader();String msg2 = readXMLResponse(reader3, 'Message');upsWrapp.UPSErrorMsg = 'Shipping Rate Service Is Not Available : ' + msg2;
                                }  
                            } else upsWrapp.UPSErrorMsg = 'Result not available';
                            
                        } catch(Exception e) { upsWrapp.UPSErrorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
                    } 
                }  
            }
        }
        return upsWrapp;
    }
    
    @AuraEnabled
    public static Decimal FedServicesSave(String soId, String rateWrapperSelected, Decimal additionalPercent) {
        
        if(additionalPercent == null) additionalPercent = 0.00;
        
        rateWrapper rateWrap = (rateWrapper) JSON.deserialize(rateWrapperSelected, rateWrapper .class);
        String SalesOrderFields = 'id, ownerid, isdeleted, name, createddate, createdbyid, lastmodifieddate, lastmodifiedbyid, systemmodstamp, lastactivitydate, lastvieweddate, lastreferenceddate, erp7__expected_date__c, erp7__active__c, erp7__amount__c, erp7__barcode__c, erp7__book_date__c, erp7__customer_email__c, erp7__customer_purchase_order_date__c, erp7__employee_email__c, erp7__hold_status__c, erp7__is_back_order__c, erp7__is_invoice_sent__c, erp7__loyalty_amount__c, erp7__loyalty_points__c, erp7__name_link__c, erp7__name__c, erp7__order_date__c, erp7__order_status__c, erp7__payment_mode__c, erp7__purchase_order_number__c, erp7__request_date__c, erp7__special_instructions__c, erp7__status_timestamp__c, erp7__status__c, erp7__code__c, erp7__bill_to_address__c, erp7__contact__c, erp7__customer_name__c, erp7__organisation_business_unit__c, erp7__organisation__c, erp7__payment_method__c, erp7__channel__c, erp7__ship_to_address__c, erp7__status_duration__c, erp7__total_tax_amount__c, erp7__authorised__c, erp7__sub_total__c, erp7__total_discount__c, erp7__total_due__c, erp7__total_other_tax__c, erp7__total_vat__c, erp7__ready_to_receive__c, erp7__employee_name__c, erp7__employees__c, erp7__shipment_type__c, erp7__ready_to_pick_pack__c, erp7__subscription__c, erp7__customer_id__c, erp7__due_amount__c, erp7__payments_status__c, erp7__sales_order_amount__c, erp7__fulfilled__c, erp7__ready_to_ship__c, erp7__number_of_back_order_items__c, erp7__total_shipping_amount__c, erp7__redeem_voucher_amount__c, erp7__amount_paid__c, erp7__is_pre_order__c, erp7__number_of_fulfilled_items__c, erp7__total_number_of_items__c, erp7__estimated_delivery_date__c, erp7__fulfilled_date__c, erp7__estimated_delivery_month__c, erp7__is_converted__c, erp7__is_closed__c, erp7__account__c, erp7__returnamount__c, erp7__rmalines_to_process__c, erp7__total_quantity__c, erp7__picked_quantity__c, erp7__packed_quantity__c, erp7__quotes__c, erp7__tracking_number__c, erp7__shipped_quantity__c, erp7__shipping_vat__c, erp7__estimated_shipping_amount__c, erp7__ups_service__c, erp7__order_profile__c, erp7__description__c, erp7__source__c, erp7__eorder_id__c, erp7__shipping_discount__c, erp7__cancelled_reason__c, erp7__ship_from_address__c, erp7__cost_price__c, erp7__logistic_cost__c, erp7__Coupon_Discount__c, erp7__Product_Coupon_Discount__c';
        String AllSalesOrderFields = SalesOrderFields + ',Contact__r.Email,Account__r.Name,Channel__r.Name,Employees__r.Email__c ';
        String SalesOrderSoql = 'SELECT ' + String.escapeSingleQuotes(AllSalesOrderFields) + ' FROM Sales_Order__c where Name=:soId or Id=:soId Limit 1'; // hande escape
        Sales_Order__c currentSalesOrder = Database.query(SalesOrderSoql);
        
        if(rateWrap.totalCharges != null && rateWrap.totalCharges != '' && rateWrap.totalCharges != '-') { 
            Decimal totalCharge = (Decimal.valueof(rateWrap.totalCharges) + ((Decimal.valueof(rateWrap.totalCharges) * additionalPercent) / 100));currentSalesOrder.Estimated_Shipping_Amount__c = totalCharge.setscale(2);currentSalesOrder.ERP7__Total_Shipping_Amount__c = totalCharge.setscale(2); 
        }
        
        currentSalesOrder.ERP7__Shipment_Type__c = 'FedEx';
        if(rateWrap.service != null && rateWrap.service != '') { 
            currentSalesOrder.ERP7__UPS_Service__c = rateWrap.service;
        }
        if(Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.Estimated_Shipping_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Total_Shipping_Amount__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__Shipment_Type__c.isUpdateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__UPS_Service__c.isCreateable() && Schema.sObjectType.Sales_Order__c.fields.ERP7__UPS_Service__c.isUpdateable()){upsert currentSalesOrder;}else{/*('User have not permission to update or create records FLS');*/}     
        return currentSalesOrder.ERP7__Total_Shipping_Amount__c;
    }
    
    public static String readXMLResponse(XmlStreamReader reader, String sxmltag) {
        string retValue;    // Read through the XML
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {if (reader.getLocalName() == sxmltag) {reader.next();if (reader.getEventType() == XmlTag.characters) { retValue = reader.getText();}}} reader.next();
        }
        return retValue;//retValue.escapeXml();
    }
    
    public class selectOptions {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        @AuraEnabled public Boolean selected { get; set; }
        
        public selectOptions(String lab, string val) {
            label = lab;
            value = val;
            //selected = false;
        }
        public selectOptions(String lab, string val, Boolean sel) {
            label = lab;
            value = val;
            selected = sel;
        }
    }
    
    @AuraEnabled public List<rateWrapper> rateWrapperList       { get; set; }
    public class rateWrapper {
        @AuraEnabled public String Service                      { get; set; }                   
        @AuraEnabled public String ServiceName                  { get; set; }                   
        @AuraEnabled public Date DeliveryDate                   { get; set; }
        @AuraEnabled public String ServiceCode                  { get; set; }
        @AuraEnabled public String totalCharges                 { get; set; }
        @AuraEnabled public String totalSurcharges              { get; set; }
        @AuraEnabled public String currencyCode                 { get; set; }
        @AuraEnabled public String CommitmentDate               { get; set; }   
        @AuraEnabled public String DeliveryDateS                { get; set; }
        @AuraEnabled public String ServiceManual                { get; set; }
        @AuraEnabled public String negotiatedCharges            { get; set; }   
        @AuraEnabled public String TransportationCharges        { get; set; }   
        @AuraEnabled public String ServiceOptionsCharges        { get; set; } 
        @AuraEnabled public String ScheduledDeliveryTime        { get; set; }
        @AuraEnabled public String GuaranteedDaysToDelivery     { get; set; }  
        @AuraEnabled public Boolean Selected                    { get; set; }                 
        
        public rateWrapper() {  
            Service = '';
            ServiceName = '';
            currencyCode = '';
            CommitmentDate = '';
            DeliveryDate = null;
            DeliveryDateS = '';            
            ServiceManual = '';
            ServiceCode = '';
            totalCharges = '';
            totalSurcharges = ''; 
            negotiatedCharges = '';
            TransportationCharges = '';
            ServiceOptionsCharges = '';            
            GuaranteedDaysToDelivery = '';
            ScheduledDeliveryTime = '';  
            Selected = false;      
        }           
    }
    
    public class upsWrap {
        @AuraEnabled public String PackageType                      { get; Set; } 
        @AuraEnabled public List<selectOptions> PackageTypes        { get; Set; }
        @AuraEnabled public Date ShipmentDate                       { get; Set; } 
        @AuraEnabled public Decimal Length                          { get; Set; } 
        @AuraEnabled public Decimal Width                           { get; Set; } 
        @AuraEnabled public Decimal Height                          { get; Set; } 
        @AuraEnabled public Decimal Weight                          { get; Set; } 
        @AuraEnabled public Decimal NoofPackage                     { get; Set; } 
        @AuraEnabled public Decimal Additional                      { get; Set; } 
        @AuraEnabled public Decimal PackageVolume                   { get; Set; } 
        @AuraEnabled public Decimal SOVolume                        { get; Set; } 
        @AuraEnabled public Decimal SOWeight                        { get; Set; } 
        @AuraEnabled public Decimal TotalWeight                     { get; Set; } 
        @AuraEnabled public Decimal WeightPerPack                   { get; Set; }
        @AuraEnabled public String UPSErrorMsg                      { get; Set; }
        @AuraEnabled public String Result                           { get; Set; }
        @AuraEnabled public List<rateWrapper> Services              { get; Set; }
        public upsWrap() {
            PackageType = Null;
            UPSErrorMsg = Null;
            Result = Null;
            WeightPerPack = Null; 
            SOWeight = Null; SOVolume = Null;
            PackageVolume = Null;
            Additional = Null;
            NoofPackage = Null;
            Weight = Null;
            Height = Null;
            Width = Null;
            Length = Null;
            ShipmentDate  = Null;   
            Services = new List<rateWrapper>(); 
        }
    }     
    
    //===================shipping======================
    
}