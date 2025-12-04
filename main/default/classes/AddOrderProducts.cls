public with sharing class AddOrderProducts {
	
    @AuraEnabled
    public static void savePriBook(Id selRecord, String pricebook){
        Pricebook2 pb = [Select Id from Pricebook2 where Name like :pricebook Limit 1];
        Order ord=new Order();
        ord.Id=selRecord;
        if(Schema.sObjectType.Order.fields.Pricebook2Id.isCreateable() && Schema.sObjectType.Order.fields.Pricebook2Id.isUpdateable()) ord.Pricebook2Id = pb.Id;
        if(Schema.sObjectType.Order.isCreateable() && Schema.sObjectType.Order.isUpdateable()) upsert ord; else{ }
    }
    
    @AuraEnabled
    public static ProWrapper fetchOrder(String OrderId){
        ProWrapper OrdWpr=new ProWrapper();
        try{
            OrdWpr.ord=[Select Id,Name,OrderNumber,ERP7__Bill_To_Address__c,ERP7__Ship_To_Address__c,ERP7__Channel__c,AccountId,EffectiveDate,ERP7__Order_Profile__c,Status,ERP7__Contact__c from Order where Id =:OrderId Limit 1];
            
            if(OrdWpr.ord.AccountId == null) OrdWpr.errorMsg='Account was not found on '+OrdWpr.ord.OrderNumber;
            if(OrdWpr.ord.ERP7__Order_Profile__c == null) OrdWpr.errorMsg='Order Profile was not found on '+OrdWpr.ord.OrderNumber;
            if(OrdWpr.ord.ERP7__Bill_To_Address__c == null) OrdWpr.errorMsg='Bill To Address was not found on '+OrdWpr.ord.OrderNumber;
            if(OrdWpr.ord.ERP7__Ship_To_Address__c == null) OrdWpr.errorMsg='Ship To Address was not found on '+OrdWpr.ord.OrderNumber;
            if(OrdWpr.ord.ERP7__Contact__c == null) OrdWpr.errorMsg='Contact was not found on '+OrdWpr.ord.OrderNumber;
            Schema.DescribeFieldResult fieldResult1 = product2.Family.getDescribe();
            List < Schema.PicklistEntry > ple1 = fieldResult1.getPicklistValues();
            OrdWpr.prodFam.add(new SelectOptions1('None','None'));
            for(Schema.PicklistEntry f: ple1) OrdWpr.prodFam.add(new SelectOptions1(f.getLabel(), f.getValue()));
            
            Schema.DescribeFieldResult fieldResult2 = product2.ERP7__Category__c.getDescribe();
            List < Schema.PicklistEntry > ple2 = fieldResult2.getPicklistValues();
            OrdWpr.prodCat.add(new SelectOptions1('None','None'));
            for(Schema.PicklistEntry f: ple2) OrdWpr.prodCat.add(new SelectOptions1(f.getLabel(), f.getValue())); 
            
            //isPBAssign
            Order ord = [Select Id, Name, Pricebook2.Name From Order Where Id =: OrderId];
            if(ord.Pricebook2.Name != null){ OrdWpr.isPBAssign=true;}else{ List<Pricebook2> priBooks = [Select Id,Name from Pricebook2 where IsActive=true];  for(Pricebook2 pb : priBooks) OrdWpr.allpriBook.add(new SelectOptions1(pb.Name, pb.Name));    }
        }catch(Exception e) { OrdWpr.errorMsg = e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }     
        return OrdWpr;
    }
    
    @AuraEnabled
    public static List<pbeWrapper> initialProducts(String orderId,Integer currentQuantity){
        //ProWrapper initialPro=new ProWrapper();
        //try{
            String pricebookId='';
        	String profileId='';
        	ERP7__Profiling__c profile;
        	Set<Id> siteIds=new Set<Id>();
            Order ord=[Select Id,Name,OrderNumber,ERP7__Bill_To_Address__c,ERP7__Ship_To_Address__c,ERP7__Channel__c,AccountId,EffectiveDate,ERP7__Order_Profile__c,Status,ERP7__Contact__c from Order where Id =:OrderId Limit 1];
        
        if(ord.ERP7__Order_Profile__c != null){
                profile=[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Tax_Sourcing_Rules__c from ERP7__Profiling__c where Id =:ord.ERP7__Order_Profile__c Limit 1];
                profileId=profile.Id;
                pricebookId = profile.ERP7__Price_Book__c;
                ERP7__Channel__c channel = [Select Id, Name from ERP7__Channel__c where Id=:profile.ERP7__Channel__c and ERP7__Active__c=true Limit 1];                
                List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                             where ERP7__Channel__c=:channel.Id and ERP7__Active__c=true];                
                if(DistributionChannels.size() > 0) {
                    for(Distribution_Channel__c DC: DistributionChannels) {
                        siteIds.add(DC.Site__c);
                    }
                }
            }else if(ord.AccountId != null){
                Account Customer=[Select Id,Name,ERP7__Order_Profile__c from Account where Id =:ord.AccountId Limit 1];
                profile=[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Tax_Sourcing_Rules__c from ERP7__Profiling__c where ERP7__Organisation__c =:Customer.Id Limit 1];
                profileId=profile.Id;
                pricebookId = profile.ERP7__Price_Book__c;
                ERP7__Channel__c channel = [Select Id, Name from ERP7__Channel__c where Id=:profile.ERP7__Channel__c and ERP7__Active__c=true Limit 1];                
                List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                             where ERP7__Channel__c=:channel.Id and ERP7__Active__c=true];                
                if(DistributionChannels.size() > 0) {
                    for(Distribution_Channel__c DC: DistributionChannels) {
                        siteIds.add(DC.Site__c);
                    }
                }
            }else{
                Pricebook2 pricebook=[Select Id,Name,IsStandard from Pricebook2 where IsStandard=true Limit 1];   pricebookId=pricebook.Id;
                List<ERP7__Site__c> siteList=[Select Id,Name,ERP7__Address__c,ERP7__Address__r.ERP7__Country__c from ERP7__Site__c where ERP7__Active__c =true AND ERP7__Address__c !=null AND ERP7__Address__r.ERP7__Country__c =:'United Kingdom' Limit 2];
                for(ERP7__Site__c st:siteList){ siteIds.add(st.Id); }
            }            
            List<PricebookEntry> pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE) AND IsActive=TRUE Limit 12];
        	Set<Id> productIds=new Set<Id>();            
        	for(PricebookEntry pb1 : pbe) productIds.add(pb1.Product2.Id);
        	List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
            if(productIds.size() > 0) {
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                                Where product__c In: productIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds And                                                 
                                                ERP7__Number_of_Item_In_Stock__c > 0
                                               ];
            }	
        	Map<String, Decimal> stockView = new Map<String, Decimal>();
            for(Id prId:productIds){
                Decimal stock=0;
                for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                    if(prId == inven.product__c){
                        stock += inven.ERP7__Number_of_Item_In_Stock__c;
                    }
                }
                stockView.put(prId,stock);                
            }
        	
        	//=========Discount Plan==============
        	
        	List <Tier_Discount_Allocation__c> TDAS= new List <Tier_Discount_Allocation__c>();
            TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, 
                    product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                    Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                    Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                    From Tier_Discount_Allocation__c
                    Where Order_Profile__c = : profileId And
                    product__c In: productIds And
                    Tier__r.Floor_Unit__c <= : currentQuantity And
                    Tier__r.Ceiling_Unit__c >= : currentQuantity And
                    Tier__r.Active__c = true And
                    Discount_Plan__r.Active__c = true And
                    Active__c = true
                ];
        
        	List <Id> discountPlanIds = new List <Id>();
            for(Tier_Discount_Allocation__c TDA: TDAS) {
                if(TDA.Discount_Plan__c != Null) discountPlanIds.add(TDA.Discount_Plan__c);
            }
            List <Discount_Plan__c> discounts = new List <Discount_Plan__c>();
            discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,
                    Status__c, Default_Discount_Value__c, Ceiling_Discount_Value__c, Floor_Discount_Value__c
                    From Discount_Plan__c
                    Where Id In: discountPlanIds And
                    Active__c = True
                ];
        
            Map <Id,Discount_Plan__c> discountMap = new Map <Id,Discount_Plan__c>();
            for(Discount_Plan__c dis: discounts) {
                discountMap.put(dis.id, dis);
            }
        
        	Map <Id,List <Discount_Plan__c>> discountPlans = new Map <Id,List <Discount_Plan__c>>();
        	Map <Id,List <Tier_Discount_Allocation__c>> tierDiscAllocation = new Map <Id,List <Tier_Discount_Allocation__c>>();
        	for(PricebookEntry pbPro: pbe) {           
                List <Discount_Plan__c> myDiscountPlans = new List <Discount_Plan__c>();
                List <Tier_Discount_Allocation__c> myTierDiscAlc = new List <Tier_Discount_Allocation__c>();
                for(Tier_Discount_Allocation__c TDA: TDAS) {
                    if(pbPro.Product2.Id == TDA.product__c && TDA.Discount_Plan__c != Null) {
                        myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                        myTierDiscAlc.add(TDA);
                    }
                }
                discountPlans.put(pbPro.Product2.Id, myDiscountPlans);  
                tierDiscAllocation.put(pbPro.Product2.Id, myTierDiscAlc);
            }
        
        //==============/Discount Plan===========================
        
        //=============Taxex Calculation start=====================
        Date todayDate = system.today();
        List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>();
        profileTax=[Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where ERP7__Account_Profile__c =:profileId AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Tax_Rate__c != Null AND ERP7__Product__c = Null AND ERP7__Active__c=true Order By ERP7__Province__c DESC];
        
        List<ERP7__Tax__c> productprofileTax = new List<ERP7__Tax__c>();
        productprofileTax=[Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where ERP7__Account_Profile__c =:profileId AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Tax_Rate__c != Null AND ERP7__Product__c != Null AND ERP7__Product__c In : productIds AND ERP7__Active__c=true Order By ERP7__Province__c DESC];
        
        ERP7__Address__c ordBillToAdd;
        ERP7__Address__c ordShipToAdd;
        if(ord.ERP7__Bill_To_Address__c != Null) ordBillToAdd=[Select Id,Name,ERP7__Active__c,ERP7__City__c,ERP7__Country__c,ERP7__State__c,ERP7__Postal_Code__c from ERP7__Address__c where Id =:ord.ERP7__Bill_To_Address__c AND ERP7__Active__c=true Limit 1];
        if(ord.ERP7__Ship_To_Address__c != Null) ordShipToAdd=[Select Id,Name,ERP7__Active__c,ERP7__City__c,ERP7__Country__c,ERP7__State__c,ERP7__Postal_Code__c from ERP7__Address__c where Id =:ord.ERP7__Ship_To_Address__c AND ERP7__Active__c=true Limit 1];
        
        String TaxPostalCode = '';
        String TaxCity = '';
        String TaxProvince = '';
        String TaxCountry = '';
        if(ordBillToAdd != Null){
            if(profile.ERP7__Tax_Sourcing_Rules__c =='Origin'){
                if(ordBillToAdd.ERP7__Postal_Code__c != Null && ordBillToAdd.ERP7__Postal_Code__c != '') TaxPostalCode = ordBillToAdd.ERP7__Postal_Code__c;
                if(ordBillToAdd.ERP7__City__c != Null && ordBillToAdd.ERP7__City__c != '') TaxCity = ordBillToAdd.ERP7__City__c;
                if(ordBillToAdd.ERP7__State__c != Null && ordBillToAdd.ERP7__State__c != '') TaxProvince = ordBillToAdd.ERP7__State__c;
                if(ordBillToAdd.ERP7__Country__c != Null && ordBillToAdd.ERP7__Country__c != '') TaxCountry = ordBillToAdd.ERP7__Country__c;
            }
        }        
        
        if(ordShipToAdd != Null){
            if(profile.ERP7__Tax_Sourcing_Rules__c =='Destination'){
                if(ordShipToAdd.ERP7__Postal_Code__c != Null && ordShipToAdd.ERP7__Postal_Code__c != '') TaxPostalCode = ordShipToAdd.ERP7__Postal_Code__c;
                if(ordShipToAdd.ERP7__City__c != Null && ordShipToAdd.ERP7__City__c != '') TaxCity = ordShipToAdd.ERP7__City__c;
                if(ordShipToAdd.ERP7__State__c != Null && ordShipToAdd.ERP7__State__c != '') TaxProvince = ordShipToAdd.ERP7__State__c;
                if(ordShipToAdd.ERP7__Country__c != Null && ordShipToAdd.ERP7__Country__c != '') TaxCountry = ordShipToAdd.ERP7__Country__c;
            }
        }        
        
        //=============Taxex Calculation end=====================
        
        List<pbeWrapper> pbe1=new List<pbeWrapper>();
        for(PricebookEntry pb : pbe){
        /*List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        if(discountPlans.get(pb.Product2.Id) != null) {
        for(Discount_Plan__c dis: discountPlans.get(pb.Product2.Id)) {
        options.add(new SelectOption(dis.Id,dis.Name));
        }
        }  */
        
            List<selectOptions1> options = new List<selectOptions1>();
            options.add(new selectOptions1('--None--',''));
            if(discountPlans.get(pb.Product2.Id) != null) {
                for(Discount_Plan__c dis: discountPlans.get(pb.Product2.Id)) {
                    options.add(new selectOptions1(dis.Name,dis.Id));
                }
            }            
            
            //=============taxes start==================
            ERP7__Tax__c tax;//=new ERP7__Tax__c();            
            Boolean taxFound = false;
            Decimal vatAmount=0;
            Decimal anotherTax=0;
            String taxId='';
            
            //Product Taxes
            if(productprofileTax.size() > 0){
                for(ERP7__Tax__c ProductTax : productprofileTax){                    
                    if(pb.Product2.Id == ProductTax.ERP7__Product__c){
                        
                        if((TaxPostalCode != Null && TaxPostalCode != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (ProductTax.ERP7__Postal_Code__c == TaxPostalCode && ProductTax.ERP7__Province__c == TaxProvince && ProductTax.ERP7__Country__c == TaxCountry)){
                            tax=ProductTax; taxId=ProductTax.Id; taxFound = true; break;                            
                            //if(ProductTax.ERP7__Tax_Rate__c != null) vatAmount=(ProductTax.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (ProductTax.ERP7__Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (ProductTax.ERP7__Tax_Rate__c / 100 * pb.UnitPrice).setScale(2);
                            //if(ProductTax.ERP7__Other_Tax_Rate__c != null) anotherTax=(ProductTax.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (ProductTax.ERP7__Other_Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (ProductTax.ERP7__Other_Tax_Rate__c / 100 * pb.UnitPrice).setScale(2);                                                        
                        }
                        if(!taxFound){
                            if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (ProductTax.ERP7__Postal_Code__c == Null && ProductTax.ERP7__Province__c == TaxProvince && ProductTax.ERP7__Country__c == TaxCountry)){
                                tax=ProductTax;
                                taxId=ProductTax.Id;
                                //if(ProductTax.ERP7__Tax_Rate__c != null) vatAmount=(ProductTax.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (ProductTax.ERP7__Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (ProductTax.ERP7__Tax_Rate__c / 100 * pb.UnitPrice).setScale(2);
                            	//if(ProductTax.ERP7__Other_Tax_Rate__c != null) anotherTax=(ProductTax.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (ProductTax.ERP7__Other_Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (ProductTax.ERP7__Other_Tax_Rate__c / 100 * pb.UnitPrice).setScale(2);
                                taxFound = true;
                                break;
                            }
                        }
                        if(!taxFound){
                            if((TaxCountry != Null && TaxCountry != '') && (ProductTax.ERP7__Postal_Code__c == Null && ProductTax.ERP7__City__c == Null && ProductTax.ERP7__Province__c == Null && ProductTax.ERP7__Country__c == TaxCountry)){
                                tax=ProductTax;
                                taxId=ProductTax.Id;
                                //if(ProductTax.ERP7__Tax_Rate__c != null) vatAmount=(ProductTax.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (ProductTax.ERP7__Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (ProductTax.ERP7__Tax_Rate__c / 100 * pb.UnitPrice).setScale(2);
                            	//if(ProductTax.ERP7__Other_Tax_Rate__c != null) anotherTax=(ProductTax.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (ProductTax.ERP7__Other_Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (ProductTax.ERP7__Other_Tax_Rate__c / 100 * pb.UnitPrice).setScale(2);
                                taxFound = true;
                                break;
                            }
                        }
                        if(!taxFound){
                            if(ProductTax.ERP7__Postal_Code__c == Null && ProductTax.ERP7__City__c == Null && ProductTax.ERP7__Province__c == Null && ProductTax.ERP7__Country__c == Null){
                                tax=ProductTax;
                                taxId=ProductTax.Id;
                                //if(ProductTax.ERP7__Tax_Rate__c != null) vatAmount=(ProductTax.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (ProductTax.ERP7__Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (ProductTax.ERP7__Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                            	//if(ProductTax.ERP7__Other_Tax_Rate__c != null) anotherTax=(ProductTax.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (ProductTax.ERP7__Other_Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (ProductTax.ERP7__Other_Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                                taxFound = true;
                                break;
                            }
                        }
                    }
                }
            }
            //Profile Taxes
            if(!taxFound){										//When ProductTax will not available                
                if(profileTax.size() > 0){
                    for(ERP7__Tax__c profileTax1 : profileTax){
                        
                        if((TaxPostalCode != Null && TaxPostalCode != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (profileTax1.ERP7__Postal_Code__c == TaxPostalCode && profileTax1.ERP7__Province__c == TaxProvince && profileTax1.ERP7__Country__c == TaxCountry)){
                           tax=profileTax1; taxId=profileTax1.Id; taxFound = true; break;                            
                            //if(profileTax1.ERP7__Tax_Rate__c != Null) vatAmount = (profileTax1.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (profileTax1.ERP7__Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (profileTax1.ERP7__Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                            //if(profileTax1.ERP7__Other_Tax_Rate__c != Null) anotherTax = (profileTax1.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (profileTax1.ERP7__Other_Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (profileTax1.ERP7__Other_Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                        }
                        if(!taxFound){
                            if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (profileTax1.ERP7__Postal_Code__c == Null && profileTax1.ERP7__Province__c == TaxProvince && profileTax1.ERP7__Country__c == TaxCountry)){
                                tax=profileTax1;
                                taxId=profileTax1.Id;
                                //if(profileTax1.ERP7__Tax_Rate__c != Null) vatAmount = (profileTax1.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (profileTax1.ERP7__Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (profileTax1.ERP7__Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                                //if(profileTax1.ERP7__Other_Tax_Rate__c != Null) anotherTax = (profileTax1.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (profileTax1.ERP7__Other_Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (profileTax1.ERP7__Other_Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                                taxFound = true;
                                break;
                            }
                        }
                        if(!taxFound){
                            if((TaxCountry != Null && TaxCountry != '') && (profileTax1.ERP7__Postal_Code__c == Null && profileTax1.ERP7__City__c == Null && profileTax1.ERP7__Province__c == Null && profileTax1.ERP7__Country__c == TaxCountry)){
                                tax=profileTax1;
                                taxId=profileTax1.Id;
                                //if(profileTax1.ERP7__Tax_Rate__c != Null) vatAmount = (profileTax1.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (profileTax1.ERP7__Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (profileTax1.ERP7__Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                                //if(profileTax1.ERP7__Other_Tax_Rate__c != Null) anotherTax = (profileTax1.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (profileTax1.ERP7__Other_Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (profileTax1.ERP7__Other_Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                                taxFound = true;
                                break;
                            }
                        }
                        if(!taxFound){
                            if(profileTax1.ERP7__Postal_Code__c == Null && profileTax1.ERP7__City__c == Null && profileTax1.ERP7__Province__c == Null && profileTax1.ERP7__Country__c == Null){
                                tax=profileTax1;
                                taxId=profileTax1.Id;
                                //if(profileTax1.ERP7__Tax_Rate__c != Null) vatAmount = (profileTax1.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (profileTax1.ERP7__Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (profileTax1.ERP7__Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                                //if(profileTax1.ERP7__Other_Tax_Rate__c != Null) anotherTax = (profileTax1.ERP7__Apply_Tax_On__c == 'Cost Price' && pb.ERP7__Cost_Price__c != Null)? (profileTax1.ERP7__Other_Tax_Rate__c / 100 * (pb.ERP7__Cost_Price__c)).setScale(2) : (profileTax1.ERP7__Other_Tax_Rate__c / 100 * (pb.UnitPrice)).setScale(2);
                                taxFound = true;
                                break;
                            }
                        }
                    }
                }                
            }
            //=============taxes end==================
            
            if(pb.Product2.ERP7__Version__c != null){ 
                pbe1.add(new pbeWrapper(pb,pb.Product2.ERP7__Version__c,options,(stockView.get(pb.Product2.Id)!= null)? stockView.get(pb.Product2.Id):0.00,(discountPlans.get(pb.Product2.Id)!= null)? discountPlans.get(pb.Product2.Id):new List<Discount_Plan__c>(),(tierDiscAllocation.get(pb.Product2.Id)!= null)? tierDiscAllocation.get(pb.Product2.Id):new List<Tier_Discount_Allocation__c>(),(tax != null)?tax:new ERP7__Tax__c(),taxId,vatAmount,anotherTax));           
            } 
            else{
                pbe1.add(new pbeWrapper(pb,'',options,(stockView.get(pb.Product2.Id)!= null)? stockView.get(pb.Product2.Id):0.00,(discountPlans.get(pb.Product2.Id)!= null)? discountPlans.get(pb.Product2.Id):new List<Discount_Plan__c>(),(tierDiscAllocation.get(pb.Product2.Id)!= null)? tierDiscAllocation.get(pb.Product2.Id):new List<Tier_Discount_Allocation__c>(),(tax != null)?tax:new ERP7__Tax__c(),taxId,vatAmount,anotherTax));    //      ,(discountPlans.get(pb.Product2.Id)!= null)? discountPlans.get(pb.Product2.Id):discountPlans.get(pb.Product2.Id),(tierDiscAllocation.get(pb.Product2.Id)!= null)? tierDiscAllocation.get(pb.Product2.Id):tierDiscAllocation.get(pb.Product2.Id)         
            } 
        }

        	/*List<pbeWrapper> pbe1=new List<pbeWrapper>();
            for(PricebookEntry pb : pbe){                
                if(pb.Product2.ERP7__Version__c != null){ 
                	pbe1.add(new pbeWrapper(pb,pb.Product2.ERP7__Version__c,(stockView.get(pb.Product2.Id)!= null)? stockView.get(pb.Product2.Id):0.00));                
                } 
                else{
                    pbe1.add(new pbeWrapper(pb,'',(stockView.get(pb.Product2.Id)!= null)? stockView.get(pb.Product2.Id):0.00));                   
                } 
            } */ 
            return pbe1;
        //}catch(Exception e) { /*'Error in initialProducts :'+e.getMessage() +' Line Number @ : '+ e.getLineNumber());*/ }        
        //return null;
    }
    
    @AuraEnabled
    public static OrdWrapper fetchOrderLine(String OrderId){
        OrdWrapper ordAndLine=new OrdWrapper();
        try{
            ordAndLine.ord=[Select Id,Name,OrderNumber,ERP7__Bill_To_Address__c,ERP7__Ship_To_Address__c,ERP7__Channel__c,AccountId,EffectiveDate,ERP7__Order_Profile__c,Status,ERP7__Contact__c from Order where Id =:OrderId Limit 1];
            
            ordAndLine.ordLine=[Select Id,UnitPrice,ListPrice,ERP7__Commission__c,ERP7__Discount_Amount__c,ERP7__Discount_Percent__c,ERP7__Discount_Plan__c,ERP7__Other_Tax__c,Product2Id,Product2.Name,Product2.ProductCode,Product2.ERP7__Picture__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Configure__c,Product2.ERP7__Version__c,Product2.ERP7__Serialise__c,ERP7__Version__c,Quantity,ERP7__Sort_Order__c,ERP7__VAT_Amount__c,ERP7__Tax__c,Description from OrderItem where OrderId =:OrderId order by ERP7__Sort_Order__c];
            
            Set<Id> productIds=new Set<Id>();
            for(OrderItem ordLine1:ordAndLine.ordLine){
                productIds.add(ordLine1.Product2Id);
            }
            
            //=============Stock start===========================
            String profileId='';
            if(ordAndLine.ord.AccountId != null){
                Account acc=[Select Id,Name,ERP7__Order_Profile__c from Account where Id =:ordAndLine.ord.AccountId];
                profileId=acc.ERP7__Order_Profile__c;
            }            	
            else{
                profileId=ordAndLine.ord.ERP7__Order_Profile__c;
            }
            ERP7__Profiling__c profile=[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Organisation__c,ERP7__Tax_Sourcing_Rules__c from ERP7__Profiling__c where Id =:profileId Limit 1];
            Set<Id> siteIds=new Set<Id>();
            ERP7__Channel__c channel = [Select Id, Name from ERP7__Channel__c where Id=:profile.ERP7__Channel__c and ERP7__Active__c=true Limit 1];                
            List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                                  where ERP7__Channel__c=:channel.Id and ERP7__Active__c=true];                
            if(DistributionChannels.size() > 0) {
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
            }
            List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
            if(productIds.size() > 0) {
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                                Where product__c In: productIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds And                                                 
                                                ERP7__Number_of_Item_In_Stock__c > 0
                                               ];
            }	
            Map<String, Decimal> stockView = new Map<String, Decimal>();
            for(Id prId:productIds){
                Decimal stock=0;
                for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                    if(prId == inven.product__c){
                        stock += inven.ERP7__Number_of_Item_In_Stock__c;
                    }
                }
                stockView.put(prId,stock);                
            }
            
            //=============Stock end===========================
            
            Set<Id> OrdLineTax=new set<Id>();
            set<Id> ordProd=new Set<Id>();
            for(OrderItem ordLine:ordAndLine.ordLine){
                ordProd.add(ordLine.Product2Id);
                if(ordLine.ERP7__Tax__c != null)OrdLineTax.add(ordLine.ERP7__Tax__c);
            }
            Date todayDate = system.today();
            Map<Id,ERP7__Tax__c> OrdLineTaxMap=new Map<Id,ERP7__Tax__c>([Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where Id In:OrdLineTax AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Active__c=true]);
            List <Tier_Discount_Allocation__c> TDASList=[Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, 
                                                     product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                                                     Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                                                     Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                                                     From Tier_Discount_Allocation__c
                                                     Where Order_Profile__c = : profileId And
                                                     ERP7__product__c In: ordProd And                                                     
                                                     Tier__r.Active__c = true And
                                                     Discount_Plan__r.Active__c = true And
                                                     Active__c = true
                                                    ];
            List <Id> discPlanIds = new List <Id>();
            for(Tier_Discount_Allocation__c TDA: TDASList) {
                if(TDA.Discount_Plan__c != Null) discPlanIds.add(TDA.Discount_Plan__c);
            }
            List <Discount_Plan__c> discList =  [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,
                                                 Status__c, Default_Discount_Value__c, Ceiling_Discount_Value__c, Floor_Discount_Value__c
                                                 From Discount_Plan__c
                                                 Where Id In: discPlanIds And
                                                 Active__c = True
                                                ];
            
            
            List<ordLineWrapper> ordlWprList=new List<ordLineWrapper>();
            
            for(OrderItem ordLine:ordAndLine.ordLine){
                ordLineWrapper ordlWpr=new ordLineWrapper();
                ordlWpr.ordLine=ordLine;
                if(ordLine.ERP7__Tax__c != null){ 
                    //Date todayDate = system.today();
                    //ordlWpr.tax = [Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where Id =:ordLine.ERP7__Tax__c AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Active__c=true Limit 1]; 
                    ordlWpr.tax=OrdLineTaxMap.get(ordLine.ERP7__Tax__c);
                    ordlWpr.taxId = ordLine.ERP7__Tax__c; 
                }
                if(ordLine.ERP7__VAT_Amount__c != null) ordlWpr.vatAmount=ordLine.ERP7__VAT_Amount__c;
                if(ordLine.ERP7__Other_Tax__c != null) ordlWpr.otherTax=ordLine.ERP7__Other_Tax__c;
                
                //================Discount Plan start===============
                Decimal currentQuantity=ordLine.Quantity;
                List <Tier_Discount_Allocation__c> TDAS= new List <Tier_Discount_Allocation__c>();
                for(Tier_Discount_Allocation__c TDA:TDASList){
                    if(TDA.product__c == ordLine.Product2Id && TDA.Tier__r.Floor_Unit__c <= currentQuantity && TDA.Tier__r.Ceiling_Unit__c >= currentQuantity)
                        TDAS.add(TDA);
                }
                /*TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, 
                        product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                        Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                        Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                        From Tier_Discount_Allocation__c
                        Where Order_Profile__c = : profileId And
                        product__c =: ordLine.Product2Id And
                        Tier__r.Floor_Unit__c <= : currentQuantity And
                        Tier__r.Ceiling_Unit__c >= : currentQuantity And
                        Tier__r.Active__c = true And
                        Discount_Plan__r.Active__c = true And
                        Active__c = true
                       ];*/
                
                List <Id> discountPlanIds = new List <Id>();
                for(Tier_Discount_Allocation__c TDA: TDAS) {
                    if(TDA.Discount_Plan__c != Null) discountPlanIds.add(TDA.Discount_Plan__c);
                }
                List <Discount_Plan__c> discounts = new List <Discount_Plan__c>();
                /*discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,
                             Status__c, Default_Discount_Value__c, Ceiling_Discount_Value__c, Floor_Discount_Value__c
                             From Discount_Plan__c
                             Where Id In: discountPlanIds And
                             Active__c = True
                            ];*/
                for(Id DPId:discountPlanIds){
                    for(ERP7__Discount_Plan__c DP:discList){
                        if(DP.Id==DPId){
                            discounts.add(DP);
                        }
                    }                    
                }
                
                Map <Id,Discount_Plan__c> discountMap = new Map <Id,Discount_Plan__c>();
                for(Discount_Plan__c dis: discounts) {
                    discountMap.put(dis.id, dis);
                }
                
                Map <Id,List <Discount_Plan__c>> discountPlans = new Map <Id,List <Discount_Plan__c>>();
                Map <Id,List <Tier_Discount_Allocation__c>> tierDiscAllocation = new Map <Id,List <Tier_Discount_Allocation__c>>();
                for(Id pbPro: productIds) {          
                    List <Discount_Plan__c> myDiscountPlans = new List <Discount_Plan__c>();
                    List <Tier_Discount_Allocation__c> myTierDiscAlc = new List <Tier_Discount_Allocation__c>();
                    for(Tier_Discount_Allocation__c TDA: TDAS) {
                        if(pbPro == TDA.product__c && TDA.Discount_Plan__c != Null) {
                            myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                            myTierDiscAlc.add(TDA);
                        }
                    }
                    discountPlans.put(pbPro, myDiscountPlans);  
                    tierDiscAllocation.put(pbPro, myTierDiscAlc);
                }
                
                List<selectOptions1> disPlans = new List<selectOptions1>();
                disPlans.add(new selectOptions1('--None--',''));
                if(discountPlans.get(ordLine.Product2Id) != null) {
                    for(Discount_Plan__c dis: discountPlans.get(ordLine.Product2Id)) {
                        disPlans.add(new selectOptions1(dis.Name,dis.Id));
                    }
                }                
                
                ordlWpr.CurrentDiscounts=disPlans;                
                ordlWpr.stock=(stockView.get(ordLine.Product2Id)!= null)? stockView.get(ordLine.Product2Id):0.00;
                ordlWpr.tierDists=(tierDiscAllocation.get(ordLine.Product2Id)!= null)?tierDiscAllocation.get(ordLine.Product2Id):new List<Tier_Discount_Allocation__c>();
                ordlWpr.disPlans=(discountPlans.get(ordLine.Product2Id)!= null)?discountPlans.get(ordLine.Product2Id):new List<Discount_Plan__c>();
                
                String discountPlan=ordLine.ERP7__Discount_Plan__c;
                if(discountPlan != null){
                    for(Discount_Plan__c disPlan:ordlWpr.disPlans){
                        
                        if(ordLine.ERP7__Discount_Plan__c != null){
                            if(ordLine.ERP7__Discount_Plan__c == disPlan.Id){
                                if(disPlan.ERP7__Default_Discount_Percentage__c != null){
                                    ordlWpr.isPercent=true;
                                    ordlWpr.minDiscount=disPlan.ERP7__Floor_Discount_Percentage__c;
                                    ordlWpr.maxDiscount=disPlan.ERP7__Ceiling_Discount_Percentage__c;
                                    ordlWpr.discountPercent=ordLine.ERP7__Discount_Percent__c;
                                    ordlWpr.discountPlan=ordLine.ERP7__Discount_Plan__c;
                                }else if(disPlan.ERP7__Default_Discount_Value__c != null){
                                    ordlWpr.isPercent=false;
                                    ordlWpr.minDiscount=disPlan.ERP7__Floor_Discount_Value__c;
                                    ordlWpr.maxDiscount=disPlan.ERP7__Ceiling_Discount_Value__c;
                                    ordlWpr.discountPercent=ordLine.ERP7__Discount_Amount__c;
                                    ordlWpr.discountPlan=ordLine.ERP7__Discount_Plan__c;
                                }else{
                                    ordlWpr.isPercent=true;  ordlWpr.minDiscount=0; ordlWpr.maxDiscount=0; ordlWpr.discountPercent=0; ordlWpr.discountPlan='';
                                }
                            }
                        }
                    }
                }else{
                    /*'inside when discount null');*/
                    if(ordLine.ERP7__Discount_Percent__c != null){ ordlWpr.isPercent=true; ordlWpr.minDiscount=0; ordlWpr.maxDiscount=0; ordlWpr.discountPercent=ordLine.ERP7__Discount_Percent__c; ordlWpr.discountPlan='';
                    }else if(ordLine.ERP7__Discount_Amount__c != null){ ordlWpr.isPercent=false; ordlWpr.minDiscount=0; ordlWpr.maxDiscount=0; ordlWpr.discountPercent=ordLine.ERP7__Discount_Amount__c; ordlWpr.discountPlan='';
                    }else{
                        ordlWpr.isPercent=true;
                        ordlWpr.minDiscount=0;
                        ordlWpr.maxDiscount=0;
                        ordlWpr.discountPercent=0;
                        ordlWpr.discountPlan='';
                    }
                }                
                ordlWprList.add(ordlWpr);
                //================Discount Plan end===============
            }
            
            ordAndLine.ordLineWapper=ordlWprList;
            
        }catch(Exception e){ ordAndLine.errorMsg=e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }        
        return ordAndLine;
        
    }
    
    @AuraEnabled
    public static List<pbeWrapper> fetchProducts(String OrderId, String name, String proCode, String proFamily, String proCat){
        
        String pricebookId='';
        String profileId='';
        Set<Id> siteIds=new Set<Id>();
        ERP7__Profiling__c profile;
        Order ord=[Select Id,Name,OrderNumber,ERP7__Bill_To_Address__c,ERP7__Ship_To_Address__c,ERP7__Channel__c,AccountId,EffectiveDate,ERP7__Order_Profile__c,Status,ERP7__Contact__c from Order where Id =:OrderId Limit 1];
        if(ord.ERP7__Order_Profile__c != null){
            profile=[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Tax_Sourcing_Rules__c from ERP7__Profiling__c where Id =:ord.ERP7__Order_Profile__c Limit 1];
            pricebookId = profile.ERP7__Price_Book__c;
            profileId=profile.Id;
            ERP7__Channel__c channel = [Select Id, Name from ERP7__Channel__c where Id=:profile.ERP7__Channel__c and ERP7__Active__c=true Limit 1];                
            List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                                  where ERP7__Channel__c=:channel.Id and ERP7__Active__c=true];                
            if(DistributionChannels.size() > 0) {
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
            }
        }else if(ord.AccountId != null){
            Account Customer=[Select Id,Name,ERP7__Order_Profile__c from Account where Id =:ord.AccountId Limit 1];
            profile=[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Organisation__c,ERP7__Tax_Sourcing_Rules__c from ERP7__Profiling__c where ERP7__Organisation__c =:Customer.Id Limit 1];
            pricebookId = profile.ERP7__Price_Book__c;
            profileId=profile.Id;
            ERP7__Channel__c channel = [Select Id, Name from ERP7__Channel__c where Id=:profile.ERP7__Channel__c and ERP7__Active__c=true Limit 1];                
            List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                                  where ERP7__Channel__c=:channel.Id and ERP7__Active__c=true];                
            if(DistributionChannels.size() > 0) {
                for(Distribution_Channel__c DC: DistributionChannels) {
                    siteIds.add(DC.Site__c);
                }
            }
        }else{
            Pricebook2 pricebook=[Select Id,Name,IsStandard from Pricebook2 where IsStandard=true Limit 1];  pricebookId=pricebook.Id;
            List<ERP7__Site__c> siteList=[Select Id,Name,ERP7__Address__c,ERP7__Address__r.ERP7__Country__c from ERP7__Site__c where ERP7__Active__c =true AND ERP7__Address__c !=null AND ERP7__Address__r.ERP7__Country__c =:'United Kingdom' Limit 2];
            for(ERP7__Site__c st:siteList){ siteIds.add(st.Id); }
        } 
        List<PricebookEntry> pbe=new List<PricebookEntry>();  
        String name1='%'+name+'%';
        String proCode1='%'+proCode+'%';
        if(name=='' && proCode=='' && proFamily=='' && proCat=='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE) AND IsActive=TRUE Limit 12];
        else if(name!='' && proCode=='' && proFamily=='' && proCat=='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name like :name1) AND IsActive=TRUE];
        else if(name=='' && proCode!='' && proFamily=='' && proCat=='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND ProductCode like :proCode1) AND IsActive=TRUE];
        else if(name=='' && proCode=='' && proFamily!='' && proCat=='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Family =:proFamily) AND IsActive=TRUE];
        else if(name=='' && proCode=='' && proFamily=='' && proCat!='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND ERP7__Category__c =:proCat) AND IsActive=TRUE];
        
        else if(name!='' && proCode!='' && proFamily=='' && proCat=='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name like :name1 AND ProductCode like :proCode1) AND IsActive=TRUE];
        else if(name!='' && proCode=='' && proFamily!='' && proCat=='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name like :name1 AND Family =:proFamily) AND IsActive=TRUE];
        else if(name!='' && proCode=='' && proFamily=='' && proCat!='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name like :name1 AND ERP7__Category__c =:proCat) AND IsActive=TRUE];
            
        else if(name!='' && proCode!='' && proFamily!='' && proCat=='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name like :name1 AND ProductCode like :proCode1 AND Family =:proFamily) AND IsActive=TRUE];
        else if(name!='' && proCode!='' && proFamily=='' && proCat!='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name like :name1 AND ProductCode like :proCode1 AND ERP7__Category__c =:proCat) AND IsActive=TRUE];
        
        else if(name!='' && proCode!='' && proFamily!='' && proCat!='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name like :name1 AND ProductCode like :proCode1 AND Family =:proFamily AND ERP7__Category__c =:proCat) AND IsActive=TRUE];
        else if(name!='' && proCode=='' && proFamily!='' && proCat!='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Name like :name1 AND Family =:proFamily AND ERP7__Category__c =:proCat) AND IsActive=TRUE];
        else if(name=='' && proCode!='' && proFamily!='' && proCat!='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND ProductCode like :proCode1 AND Family =:proFamily AND ERP7__Category__c =:proCat) AND IsActive=TRUE];
        else if(name=='' && proCode!='' && proFamily!='' && proCat=='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND ProductCode like :proCode1 AND Family =:proFamily) AND IsActive=TRUE];
        else if(name=='' && proCode=='' && proFamily!='' && proCat!='') pbe = [Select UnitPrice,ERP7__Purchase_Price__c,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Picture__c,Product2.ERP7__Serialise__c,Product2.ERP7__Is_Kit__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Family =:proFamily AND ERP7__Category__c =:proCat) AND IsActive=TRUE];
        
        Set<Id> productIds=new Set<Id>();            
        for(PricebookEntry pb1 : pbe) productIds.add(pb1.Product2.Id);
        List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
        if(productIds.size() > 0) {
            WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                            ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                            Where product__c In: productIds And
                                            Active__c = true And
                                            Warehouse__c In: siteIds And                                                 
                                            ERP7__Number_of_Item_In_Stock__c > 0
                                           ];
        }	
        Map<String, Decimal> stockView = new Map<String, Decimal>();
        for(Id prId:productIds){
            Decimal stock=0;
            for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                if(prId == inven.product__c){
                    stock += inven.ERP7__Number_of_Item_In_Stock__c;
                }
            }
            stockView.put(prId,stock);                
        }
        
        //=========Discount Plan==============
        Integer currentQuantity=1;
        List <Tier_Discount_Allocation__c> TDAS= new List <Tier_Discount_Allocation__c>();
        TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, 
                product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                From Tier_Discount_Allocation__c
                Where Order_Profile__c = : profileId And
                product__c In: productIds And
                Tier__r.Floor_Unit__c <= : currentQuantity And
                Tier__r.Ceiling_Unit__c >= : currentQuantity And
                Tier__r.Active__c = true And
                Discount_Plan__r.Active__c = true And
                Active__c = true
               ];
        
        List <Id> discountPlanIds = new List <Id>();
        for(Tier_Discount_Allocation__c TDA: TDAS) {
            if(TDA.Discount_Plan__c != Null) discountPlanIds.add(TDA.Discount_Plan__c);
        }
        List <Discount_Plan__c> discounts = new List <Discount_Plan__c>();
        discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,
                     Status__c, Default_Discount_Value__c, Ceiling_Discount_Value__c, Floor_Discount_Value__c
                     From Discount_Plan__c
                     Where Id In: discountPlanIds And
                     Active__c = True
                    ];
        
        Map <Id,Discount_Plan__c> discountMap = new Map <Id,Discount_Plan__c>();
        for(Discount_Plan__c dis: discounts) {
            discountMap.put(dis.id, dis);
        }
        
        Map <Id,List <Discount_Plan__c>> discountPlans = new Map <Id,List <Discount_Plan__c>>();
        Map <Id,List <Tier_Discount_Allocation__c>> tierDiscAllocation = new Map <Id,List <Tier_Discount_Allocation__c>>();
        for(PricebookEntry pbPro: pbe) {           
            List <Discount_Plan__c> myDiscountPlans = new List <Discount_Plan__c>();
            List <Tier_Discount_Allocation__c> myTierDiscAlc = new List <Tier_Discount_Allocation__c>();
            for(Tier_Discount_Allocation__c TDA: TDAS) {
                if(pbPro.Product2.Id == TDA.product__c && TDA.Discount_Plan__c != Null) {
                    myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                    myTierDiscAlc.add(TDA);
                }
            }
            discountPlans.put(pbPro.Product2.Id, myDiscountPlans);  
            tierDiscAllocation.put(pbPro.Product2.Id, myTierDiscAlc);
        }
        //=========Discount Plan end==============
        
        //=============Taxex Calculation start=====================
        Date todayDate = system.today();
        List<ERP7__Tax__c> profileTax = new List<ERP7__Tax__c>();
        profileTax=[Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where ERP7__Account_Profile__c =:profileId AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Tax_Rate__c != Null AND ERP7__Product__c = Null AND ERP7__Active__c=true Order By ERP7__Province__c DESC];
        
        List<ERP7__Tax__c> productprofileTax = new List<ERP7__Tax__c>();
        productprofileTax=[Select Id,Name,ERP7__Active__c,ERP7__Apply_Tax_On__c,ERP7__City__c,ERP7__Country__c,ERP7__Effective_Date__c,ERP7__Expiry_Date__c,ERP7__Other_Tax_Rate__c,ERP7__Other_Tax_Type__c,ERP7__Postal_Code__c,ERP7__Product__c,ERP7__Province__c,ERP7__Tax_Rate__c,ERP7__Type__c from ERP7__Tax__c where ERP7__Account_Profile__c =:profileId AND ERP7__Effective_Date__c <= :todayDate AND ERP7__Expiry_Date__c >= :todayDate AND ERP7__Type__c = :'Sales Tax' AND ERP7__Tax_Rate__c != Null AND ERP7__Product__c != Null AND ERP7__Product__c In : productIds AND ERP7__Active__c=true Order By ERP7__Province__c DESC];
        
        ERP7__Address__c ordBillToAdd;
        ERP7__Address__c ordShipToAdd;
        if(ord.ERP7__Bill_To_Address__c != Null) ordBillToAdd=[Select Id,Name,ERP7__Active__c,ERP7__City__c,ERP7__Country__c,ERP7__State__c,ERP7__Postal_Code__c from ERP7__Address__c where Id =:ord.ERP7__Bill_To_Address__c AND ERP7__Active__c=true Limit 1];
        if(ord.ERP7__Ship_To_Address__c != Null) ordShipToAdd=[Select Id,Name,ERP7__Active__c,ERP7__City__c,ERP7__Country__c,ERP7__State__c,ERP7__Postal_Code__c from ERP7__Address__c where Id =:ord.ERP7__Ship_To_Address__c AND ERP7__Active__c=true Limit 1];
        
        String TaxPostalCode = '';
        String TaxCity = '';
        String TaxProvince = '';
        String TaxCountry = '';
        if(ordBillToAdd != Null){
            if(profile.ERP7__Tax_Sourcing_Rules__c =='Origin'){
                if(ordBillToAdd.ERP7__Postal_Code__c != Null && ordBillToAdd.ERP7__Postal_Code__c != '') TaxPostalCode = ordBillToAdd.ERP7__Postal_Code__c;
                if(ordBillToAdd.ERP7__City__c != Null && ordBillToAdd.ERP7__City__c != '') TaxCity = ordBillToAdd.ERP7__City__c;
                if(ordBillToAdd.ERP7__State__c != Null && ordBillToAdd.ERP7__State__c != '') TaxProvince = ordBillToAdd.ERP7__State__c;
                if(ordBillToAdd.ERP7__Country__c != Null && ordBillToAdd.ERP7__Country__c != '') TaxCountry = ordBillToAdd.ERP7__Country__c;
            }
        }        
        
        if(ordShipToAdd != Null){
            if(profile.ERP7__Tax_Sourcing_Rules__c =='Destination'){
                if(ordShipToAdd.ERP7__Postal_Code__c != Null && ordShipToAdd.ERP7__Postal_Code__c != '') TaxPostalCode = ordShipToAdd.ERP7__Postal_Code__c;
                if(ordShipToAdd.ERP7__City__c != Null && ordShipToAdd.ERP7__City__c != '') TaxCity = ordShipToAdd.ERP7__City__c;
                if(ordShipToAdd.ERP7__State__c != Null && ordShipToAdd.ERP7__State__c != '') TaxProvince = ordShipToAdd.ERP7__State__c;
                if(ordShipToAdd.ERP7__Country__c != Null && ordShipToAdd.ERP7__Country__c != '') TaxCountry = ordShipToAdd.ERP7__Country__c;
            }
        }        
        
        //=============Taxex Calculation end=====================
        
        List<pbeWrapper> pbe1=new List<pbeWrapper>();
        for(PricebookEntry pb : pbe){
            List<selectOptions1> options = new List<selectOptions1>();
            options.add(new selectOptions1('--None--',''));
            if(discountPlans.get(pb.Product2.Id) != null) {
                for(Discount_Plan__c dis: discountPlans.get(pb.Product2.Id)) {
                    options.add(new selectOptions1(dis.Name,dis.Id));
                }
            }            
            
            //=============taxes start==================
            ERP7__Tax__c tax;//=new ERP7__Tax__c();            
            Boolean taxFound = false;
            Decimal vatAmount=0;
            Decimal anotherTax=0;
            String taxId='';
            
            //Product Taxes
            if(productprofileTax.size() > 0){
                for(ERP7__Tax__c ProductTax : productprofileTax){                    
                    if(pb.Product2.Id == ProductTax.ERP7__Product__c){
                        
                        if((TaxPostalCode != Null && TaxPostalCode != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (ProductTax.ERP7__Postal_Code__c == TaxPostalCode && ProductTax.ERP7__Province__c == TaxProvince && ProductTax.ERP7__Country__c == TaxCountry)){ tax=ProductTax; taxId=ProductTax.Id; taxFound = true;  break;
                        }
                        if(!taxFound){
                            if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (ProductTax.ERP7__Postal_Code__c == Null && ProductTax.ERP7__Province__c == TaxProvince && ProductTax.ERP7__Country__c == TaxCountry)){ tax=ProductTax; taxId=ProductTax.Id; taxFound = true;  break;
                            }
                        }
                        if(!taxFound){
                            if((TaxCountry != Null && TaxCountry != '') && (ProductTax.ERP7__Postal_Code__c == Null && ProductTax.ERP7__City__c == Null && ProductTax.ERP7__Province__c == Null && ProductTax.ERP7__Country__c == TaxCountry)){
                                tax=ProductTax;
                                taxId=ProductTax.Id;
                                taxFound = true;
                                break;
                            }
                        }
                        if(!taxFound){
                            if(ProductTax.ERP7__Postal_Code__c == Null && ProductTax.ERP7__City__c == Null && ProductTax.ERP7__Province__c == Null && ProductTax.ERP7__Country__c == Null){
                                tax=ProductTax;
                                taxId=ProductTax.Id;
                                taxFound = true;
                                break;
                            }
                        }
                    }
                }
            }
            
            //Profile Taxes
            if(!taxFound){										//When ProductTax will not available                
                if(profileTax.size() > 0){
                    for(ERP7__Tax__c profileTax1 : profileTax){
                        if((TaxPostalCode != Null && TaxPostalCode != '' && TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (profileTax1.ERP7__Postal_Code__c == TaxPostalCode && profileTax1.ERP7__Province__c == TaxProvince && profileTax1.ERP7__Country__c == TaxCountry)){
                            
                            tax=profileTax1; taxId=profileTax1.Id; taxFound = true; break;
                        }
                        if(!taxFound){
                            if((TaxProvince != Null && TaxProvince != '' && TaxCountry != Null && TaxCountry != '') && (profileTax1.ERP7__Postal_Code__c == Null && profileTax1.ERP7__Province__c == TaxProvince && profileTax1.ERP7__Country__c == TaxCountry)){
                                
                                tax=profileTax1;
                                taxId=profileTax1.Id;
                                taxFound = true;
                                break;
                            }
                        }
                        if(!taxFound){
                            if((TaxCountry != Null && TaxCountry != '') && (profileTax1.ERP7__Postal_Code__c == Null && profileTax1.ERP7__City__c == Null && profileTax1.ERP7__Province__c == Null && profileTax1.ERP7__Country__c == TaxCountry)){
                                tax=profileTax1;
                                taxId=profileTax1.Id;
                                taxFound = true;
                                break;
                            }
                        }
                        if(!taxFound){
                            if(profileTax1.ERP7__Postal_Code__c == Null && profileTax1.ERP7__City__c == Null && profileTax1.ERP7__Province__c == Null && profileTax1.ERP7__Country__c == Null){
                                tax=profileTax1;
                                taxId=profileTax1.Id;
                                taxFound = true;
                                break;
                            }
                        }
                    }
                }                
            }
            //=============taxes end==================
            
            if(pb.Product2.ERP7__Version__c != null){ 
                pbe1.add(new pbeWrapper(pb,pb.Product2.ERP7__Version__c,options,(stockView.get(pb.Product2.Id)!= null)? stockView.get(pb.Product2.Id):0.00,(discountPlans.get(pb.Product2.Id)!= null)? discountPlans.get(pb.Product2.Id):new List<Discount_Plan__c>(),(tierDiscAllocation.get(pb.Product2.Id)!= null)? tierDiscAllocation.get(pb.Product2.Id):new List<Tier_Discount_Allocation__c>(),(tax != null)?tax:new ERP7__Tax__c(),taxId,vatAmount,anotherTax));           
            } 
            else{
                pbe1.add(new pbeWrapper(pb,'',options,(stockView.get(pb.Product2.Id)!= null)? stockView.get(pb.Product2.Id):0.00,(discountPlans.get(pb.Product2.Id)!= null)? discountPlans.get(pb.Product2.Id):new List<Discount_Plan__c>(),(tierDiscAllocation.get(pb.Product2.Id)!= null)? tierDiscAllocation.get(pb.Product2.Id):new List<Tier_Discount_Allocation__c>(),(tax != null)?tax:new ERP7__Tax__c(),taxId,vatAmount,anotherTax));    //      ,(discountPlans.get(pb.Product2.Id)!= null)? discountPlans.get(pb.Product2.Id):discountPlans.get(pb.Product2.Id),(tierDiscAllocation.get(pb.Product2.Id)!= null)? tierDiscAllocation.get(pb.Product2.Id):tierDiscAllocation.get(pb.Product2.Id)         
            } 
        }
        
        
        /*List<pbeWrapper> pbe1=new List<pbeWrapper>();
        for(PricebookEntry pb : pbe){                
            if(pb.Product2.ERP7__Version__c != null){ 
                //pbe1.add(new pbeWrapper(pb,pb.Product2.ERP7__Version__c,(stockView.get(pb.Product2.Id)!= null)? stockView.get(pb.Product2.Id):0.00));                
            } 
            else{
                //pbe1.add(new pbeWrapper(pb,'',(stockView.get(pb.Product2.Id)!= null)? stockView.get(pb.Product2.Id):0.00));                   
            } 
        }  */
        return pbe1;
    }
    
    @AuraEnabled
    public static List<pbeWrapper> getDiscountPlan(String OrderId,String prodId, Integer quantity){
        Set<Id> productIds=new Set<Id>();            
        productIds.add(prodId);
        String profileId='';
        Order ord=[Select Id,Name,OrderNumber,ERP7__Bill_To_Address__c,ERP7__Ship_To_Address__c,ERP7__Channel__c,AccountId,EffectiveDate,ERP7__Order_Profile__c,Status,ERP7__Contact__c from Order where Id =:OrderId Limit 1];
        if(ord.ERP7__Order_Profile__c != null){
            ERP7__Profiling__c profile=[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c from ERP7__Profiling__c where Id =:ord.ERP7__Order_Profile__c Limit 1];
            profileId=profile.Id;            
        }else if(ord.AccountId != null){
            Account Customer=[Select Id,Name,ERP7__Order_Profile__c from Account where Id =:ord.AccountId Limit 1];
            ERP7__Profiling__c profile=[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Organisation__c from ERP7__Profiling__c where ERP7__Organisation__c =:Customer.Id Limit 1];
            profileId=profile.Id;
        }
        
        List <Tier_Discount_Allocation__c> TDAS= new List <Tier_Discount_Allocation__c>();
        TDAS = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, 
                product__c, Tier__c, Tier__r.Ceiling_Unit__c, Tier__r.Floor_Unit__c, Tier__r.Active__c, Discount_Plan__c, Discount_Plan__r.Name,
                Discount_Plan__r.Active__c, Default__c, Discount_Plan__r.Default_Discount_Percentage__c, Discount_Plan__r.Floor_Discount_Percentage__c, Discount_Plan__r.Ceiling_Discount_Percentage__c,
                Discount_Plan__r.Default_Discount_Value__c, Discount_Plan__r.Floor_Discount_Value__c, Discount_Plan__r.Ceiling_Discount_Value__c
                From Tier_Discount_Allocation__c
                Where Order_Profile__c = : profileId And
                product__c In: productIds And
                Tier__r.Floor_Unit__c <= : quantity And
                Tier__r.Ceiling_Unit__c >= : quantity And
                Tier__r.Active__c = true And
                Discount_Plan__r.Active__c = true And
                Active__c = true
               ];
        
        List <Id> discountPlanIds = new List <Id>();
        for(Tier_Discount_Allocation__c TDA: TDAS) {
            if(TDA.Discount_Plan__c != Null) discountPlanIds.add(TDA.Discount_Plan__c);
        }
        List <Discount_Plan__c> discounts = new List <Discount_Plan__c>();
        discounts = [Select id, Name, Active__c, Ceiling_Discount_Percentage__c, Default_Discount_Percentage__c, Description__c, Floor_Discount_Percentage__c,
                     Status__c, Default_Discount_Value__c, Ceiling_Discount_Value__c, Floor_Discount_Value__c
                     From Discount_Plan__c
                     Where Id In: discountPlanIds And
                     Active__c = True
                    ];
        
        Map <Id,Discount_Plan__c> discountMap = new Map <Id,Discount_Plan__c>();
        for(Discount_Plan__c dis: discounts) {
            discountMap.put(dis.id, dis);
        }
        
        Map <Id,List <Discount_Plan__c>> discountPlans = new Map <Id,List <Discount_Plan__c>>();
        Map <Id,List <Tier_Discount_Allocation__c>> tierDiscAllocation = new Map <Id,List <Tier_Discount_Allocation__c>>();
        //for(PricebookEntry pbPro: pbe) {
        List <Discount_Plan__c> myDiscountPlans = new List <Discount_Plan__c>();
        List <Tier_Discount_Allocation__c> myTierDiscAlc = new List <Tier_Discount_Allocation__c>();
        for(Tier_Discount_Allocation__c TDA: TDAS) {
            if(prodId == TDA.product__c && TDA.Discount_Plan__c != Null) {
                myDiscountPlans.add(discountMap.get(TDA.Discount_Plan__c));
                myTierDiscAlc.add(TDA);
            }
        }
        discountPlans.put(prodId, myDiscountPlans);  
        tierDiscAllocation.put(prodId, myTierDiscAlc);
        //}
        List<pbeWrapper> pbe1=new List<pbeWrapper>();
        //for(PricebookEntry pb : pbe){
            List<selectOptions1> options = new List<selectOptions1>();
            options.add(new selectOptions1('--None--',''));
            if(discountPlans.get(prodId) != null) {
                for(Discount_Plan__c dis: discountPlans.get(prodId)) {
                    options.add(new selectOptions1(dis.Name,dis.Id));
                }
            }
            
            pbe1.add(new pbeWrapper(new PricebookEntry(),'',options,0.00,(discountPlans.get(prodId)!= null)? discountPlans.get(prodId):new List<Discount_Plan__c>(),(tierDiscAllocation.get(prodId)!= null)? tierDiscAllocation.get(prodId):new List<Tier_Discount_Allocation__c>(),new ERP7__Tax__c(),'',0,0));    //      ,(discountPlans.get(pb.Product2.Id)!= null)? discountPlans.get(pb.Product2.Id):discountPlans.get(pb.Product2.Id),(tierDiscAllocation.get(pb.Product2.Id)!= null)? tierDiscAllocation.get(pb.Product2.Id):tierDiscAllocation.get(pb.Product2.Id)         
            
        //}
        return pbe1;
    }
    
    @AuraEnabled
    public static String saveOrderLine(String OrderId, String selectedProducts,List<String> itemsToDel){
        try{
            PricebookEntry pbe;
            ERP7__Profiling__c profile;
            Order ord1=[Select Id,Name,AccountId,ERP7__Order_Profile__c,ERP7__Organisation__c from Order where Id =:OrderId];            
            if(ord1.AccountId != null){
                Account acc=[Select Id,Name,ERP7__Order_Profile__c from Account where Id =:ord1.AccountId Limit 1];
                profile=[Select Id,Name,ERP7__Price_Book__c from ERP7__Profiling__c where Id =:acc.ERP7__Order_Profile__c Limit 1];
            }else{
                profile=[Select Id,Name,ERP7__Price_Book__c from ERP7__Profiling__c where Id =:ord1.ERP7__Order_Profile__c Limit 1];
            }
            if(itemsToDel.size() > 0){
                List<OrderItem> ordLineToDel=[Select Id from OrderItem where Id in:itemsToDel];
                if(OrderItem.sObjectType.getDescribe().isDeletable()) Delete ordLineToDel;
            }
            Boolean saveOrder=false;
            List<Integer> orderLineIndex=new List<Integer>();
            List<pbeWrapper> selectedProducts1 = (List<pbeWrapper>) JSON.deserialize(selectedProducts, List<pbeWrapper>.class);
            
            //Order ord=[Select Id,Name,Status from Order where Id =:OrderId Limit 1];
            //if(quote.ERP7__Order_Created__c && quote.ERP7__Order__c !=null){
                Order ord;
                for(Order record:[Select Id,Name,Status,StatusCode from Order where Id =:OrderId Limit 1])  ord=record;
                if(ord !=null){
                    if(ord.StatusCode =='Draft'){ saveOrder=true;
                    }else{
                        if(ord.StatusCode !='Draft'){  return 'Order was Activated. Not allowed to update or insert QuoteLineItems';   }
                    }
                }
            /*}else{                
                saveOrder=true;
            } */    
            Set<Id> prodIds=new Set<Id>();
            if(selectedProducts1.size() > 0){ for(Integer i=0;i<selectedProducts1.size();i++)  prodIds.add(selectedProducts1[i].pbe.Product2.Id); }
            //Map<Product2Id,Id> proPbeMap=new Map<Product2Id,Id>([Select Id,Name,Product2Id from PricebookEntry where Pricebook2Id =: profile.ERP7__Price_Book__c AND Product2Id =:prodIds]);
            List<PricebookEntry> pbeList=[Select Id,Name,Product2Id from PricebookEntry where Pricebook2Id =: profile.ERP7__Price_Book__c AND Product2Id =:prodIds];
            Map<Id,Id> proPbeMap=new Map<Id,Id>();
            for(PricebookEntry pb:pbeList) proPbeMap.put(pb.Product2Id,pb.Id);
            
            if((selectedProducts1.size() > 0) && saveOrder==true){
                List<OrderItem> ordLineList=new List<OrderItem>();
                for(Integer i=0;i<selectedProducts1.size();i++){
                    //pbe=[Select Id,Name from PricebookEntry where Pricebook2Id =: profile.ERP7__Price_Book__c AND Product2Id =:selectedProducts1[i].pbe.Product2.Id Limit 1];
                    Decimal discount=0;
                    OrderItem ordLine=new OrderItem(OrderId = OrderId);
                    if(selectedProducts1[i].orderLineId != '') ordLine.Id= selectedProducts1[i].orderLineId;
                    if(Schema.sObjectType.OrderItem.fields.ERP7__Sort_Order__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Sort_Order__c.isUpdateable()) ordLine.ERP7__Sort_Order__c = i; if(Schema.sObjectType.OrderItem.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Active__c.isUpdateable()) ordLine.ERP7__Active__c = true; if(Schema.sObjectType.OrderItem.fields.ERP7__Allocate_Stock__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Allocate_Stock__c.isUpdateable()) ordLine.ERP7__Allocate_Stock__c=true; if(Schema.sObjectType.OrderItem.fields.ERP7__Inventory_Tracked__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Inventory_Tracked__c.isUpdateable()) ordLine.ERP7__Inventory_Tracked__c=true;
                    if(ord1.ERP7__Organisation__c != null && Schema.sObjectType.OrderItem.fields.ERP7__Organisation__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Organisation__c.isUpdateable()) ordLine.ERP7__Organisation__c = ord1.ERP7__Organisation__c;
                    if(selectedProducts1[i].orderLineId == '' && Schema.sObjectType.OrderItem.fields.Product2Id.isCreateable() || Schema.sObjectType.OrderItem.fields.Product2Id.isUpdateable()) ordLine.Product2Id=selectedProducts1[i].pbe.Product2.Id;
                    //if(selectedProducts1[i].orderLineId == '') ordLine.PricebookEntryId=pbe.Id;
                    if(selectedProducts1[i].orderLineId == '' && Schema.sObjectType.OrderItem.fields.PricebookEntryId.isCreateable() || Schema.sObjectType.OrderItem.fields.PricebookEntryId.isUpdateable()) ordLine.PricebookEntryId=proPbeMap.get(selectedProducts1[i].pbe.Product2.Id);
                    if(selectedProducts1[i].orderLineId == '' && Schema.sObjectType.OrderItem.fields.ServiceDate.isCreateable() && Schema.sObjectType.OrderItem.fields.ServiceDate.isUpdateable()) ordLine.ServiceDate=System.today();
                    if(Schema.sObjectType.OrderItem.fields.UnitPrice.isCreateable() && Schema.sObjectType.OrderItem.fields.UnitPrice.isUpdateable()) ordLine.UnitPrice=selectedProducts1[i].pbe.UnitPrice; if(Schema.sObjectType.OrderItem.fields.Quantity.isCreateable() && Schema.sObjectType.OrderItem.fields.Quantity.isUpdateable()) ordLine.Quantity=selectedProducts1[i].quantity;
                    if(selectedProducts1[i].isPercent){
                        if(Schema.sObjectType.OrderItem.fields.ERP7__Discount_Percent__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Discount_Percent__c.isUpdateable()) ordLine.ERP7__Discount_Percent__c=selectedProducts1[i].discountPercent;
                        discount=(((selectedProducts1[i].pbe.UnitPrice*selectedProducts1[i].quantity)*selectedProducts1[i].discountPercent)/100);
                        if(Schema.sObjectType.OrderItem.fields.ERP7__Discount_Amount__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Discount_Amount__c.isUpdateable()) ordLine.ERP7__Discount_Amount__c=discount;
                    }else{
                        discount=selectedProducts1[i].quantity*selectedProducts1[i].discountPercent;
                        if(Schema.sObjectType.OrderItem.fields.ERP7__Discount_Amount__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Discount_Amount__c.isUpdateable()) ordLine.ERP7__Discount_Amount__c=discount;  Decimal total=ordLine.UnitPrice*ordLine.Quantity;
                        Decimal per=(discount/total)*100; if(Schema.sObjectType.OrderItem.fields.ERP7__Discount_Percent__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Discount_Percent__c.isUpdateable()) ordLine.ERP7__Discount_Percent__c=per;
                    }
                    
                    if(selectedProducts1[i].discountPlan != '' && Schema.sObjectType.OrderItem.fields.ERP7__Discount_Plan__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Discount_Plan__c.isUpdateable()) ordLine.ERP7__Discount_Plan__c=selectedProducts1[i].discountPlan;
                    if(selectedProducts1[i].version != '' && Schema.sObjectType.OrderItem.fields.ERP7__Version__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Version__c.isUpdateable()) ordLine.ERP7__Version__c=selectedProducts1[i].version;
                    if(selectedProducts1[i].taxId != '' && Schema.sObjectType.OrderItem.fields.ERP7__Tax__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Tax__c.isUpdateable()) ordLine.ERP7__Tax__c= selectedProducts1[i].taxId;
                    if(selectedProducts1[i].vatAmount != 0 && Schema.sObjectType.OrderItem.fields.ERP7__VAT_Amount__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__VAT_Amount__c.isUpdateable()) ordLine.ERP7__VAT_Amount__c = selectedProducts1[i].vatAmount;
                    if(selectedProducts1[i].otherTax != 0 && Schema.sObjectType.OrderItem.fields.ERP7__Other_Tax__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Other_Tax__c.isUpdateable()) ordLine.ERP7__Other_Tax__c = selectedProducts1[i].otherTax;
                    if(Schema.sObjectType.OrderItem.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.OrderItem.fields.ERP7__Total_Price__c.isUpdateable()) ordLine.ERP7__Total_Price__c=ordLine.UnitPrice*ordLine.Quantity-discount+selectedProducts1[i].vatAmount+selectedProducts1[i].otherTax;
                    //if(selectedProducts1[i].description != '') ordLine.Description=selectedProducts1[i].description;
                    if(selectedProducts1[i].pbe.Product2.Description != null && Schema.sObjectType.OrderItem.fields.Description.isCreateable() && Schema.sObjectType.OrderItem.fields.Description.isUpdateable()) ordLine.Description=selectedProducts1[i].pbe.Product2.Description;
                    ordLineList.add(ordLine);                
                }
                if(Schema.sObjectType.OrderItem.isCreateable() || Schema.sObjectType.OrderItem.isUpdateable()){ upsert ordLineList; }else{ return 'User is not allowed to create or update records of Order Line.'; }
                //upsert ordLineList;
            }
            
            //===========When QuoteLine already available, Quantity will increase=========
            /*if(quoteList.size() > 0){                
                for(ERP7__Quote_Line_Items__c qline : quoteList){
                    for(Integer i=0;i<selectedProducts1.size();i++){
                        if(qline.ERP7__Product__c == selectedProducts1[i].pbe.Product2.Id){
                            orderLineIndex.add(i);
                            qline.ERP7__List_Price__c=selectedProducts1[i].pbe.UnitPrice;
                            qline.ERP7__Quantity__c=qline.ERP7__Quantity__c+selectedProducts1[i].quantity;
                            if(selectedProducts1[i].isPercent){
                                qline.ERP7__Discount_Percent__c=selectedProducts1[i].discountPercent;
                                discount=(((selectedProducts1[i].pbe.UnitPrice*qline.ERP7__Quantity__c)*selectedProducts1[i].discountPercent)/100);
                                qline.ERP7__Discount_Amount__c=discount;
                            }else{
                                discount=qline.ERP7__Quantity__c*selectedProducts1[i].discountPercent;
                                qline.ERP7__Discount_Amount__c=discount;
                                Decimal total=qline.ERP7__List_Price__c*qline.ERP7__Quantity__c;
                                Decimal per=(discount/total)*100;
                                qline.ERP7__Discount_Percent__c=per;
                            }
                            
                            //qline.ERP7__Total_Price__c=qline.ERP7__List_Price__c*qline.ERP7__Quantity__c-discount;
                            if(selectedProducts1[i].discountPlan != '')	qline.ERP7__Discount_Plan__c=selectedProducts1[i].discountPlan;
                            if(selectedProducts1[i].version != '')  qline.ERP7__Product_Version__c=selectedProducts1[i].version;
                            if(selectedProducts1[i].taxId != '') qline.ERP7__Tax__c= selectedProducts1[i].taxId;
                            if(selectedProducts1[i].vatAmount != 0) qline.ERP7__VAT_Amount__c = selectedProducts1[i].vatAmount;
                            if(selectedProducts1[i].otherTax != 0) qline.ERP7__Other_Tax__c = selectedProducts1[i].otherTax;
                            //qline.ERP7__Total_Price__c=qline.ERP7__List_Price__c*qline.ERP7__Quantity__c-discount+selectedProducts1[i].vatAmount+selectedProducts1[i].otherTax;
if(Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Other_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Other_Tax__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__VAT_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__VAT_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Tax__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Tax__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__List_Price__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__List_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Percent__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Percent__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Total_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Plan__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Plan__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product_Version__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product_Version__c.isUpdateable()) upsert qline; else('User is not allowed to update or insert Quote Line');
                            break;
                        }
                    }
                }
                //============Sort in descending order the List otherwise it will give Exception List index out of Bounds===========
                for(Integer i = 0 ; i < orderLineIndex.size() ; i ++) {
                    for(integer j = i+1 ; j <= orderLineIndex.size() -1 ; j ++ ){
                        integer x = 0 ;
                        if(orderLineIndex[i] <  orderLineIndex[j]){
                            x = orderLineIndex[i]  ;
                            orderLineIndex[i] = orderLineIndex[j]  ;
                            orderLineIndex[j]  = x;
                            
                        }
                    }
                }
                //============Sort the List otherwise it will give Exception List index out of Bounds===========
                if(orderLineIndex.size() >0){
                    for(Integer i:orderLineIndex)
                    	selectedProducts1.remove(i);
                }                
                if(selectedProducts1.size() > 0){
                    for(pbeWrapper items : selectedProducts1){
                        ERP7__Quote_Line_Items__c quoteLine=new ERP7__Quote_Line_Items__c(ERP7__Quotes__c=quoteId);
                        quoteLine.Name = items.pbe.Product2.Name;
                        quoteLine.ERP7__Product__c=items.pbe.Product2.Id;
                        quoteLine.ERP7__List_Price__c=items.pbe.UnitPrice;
                        quoteLine.ERP7__Quantity__c=items.quantity;
                        if(items.isPercent){
                            quoteLine.ERP7__Discount_Percent__c=items.discountPercent;
                            discount=(((items.pbe.UnitPrice*items.quantity)*items.discountPercent)/100);
                        }else{
                            discount=items.quantity*items.discountPercent;
                            quoteLine.ERP7__Discount_Amount__c=discount;
                        }
                        //quoteLine.ERP7__Total_Price__c=quoteLine.ERP7__List_Price__c*quoteLine.ERP7__Quantity__c-discount;
                        if(items.discountPlan != '') quoteLine.ERP7__Discount_Plan__c=items.discountPlan;
                        if(items.version != '') quoteLine.ERP7__Product_Version__c=items.version;
                        if(items.taxId != '') quoteLine.ERP7__Tax__c= items.taxId;
                        if(items.vatAmount != 0) quoteLine.ERP7__VAT_Amount__c = items.vatAmount;
                        if(items.otherTax != 0) quoteLine.ERP7__Other_Tax__c = items.otherTax;
                        quoteLine.ERP7__Total_Price__c=quoteLine.ERP7__List_Price__c*quoteLine.ERP7__Quantity__c-discount+items.vatAmount+items.otherTax;
                        if(Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Other_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Other_Tax__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__VAT_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__VAT_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Tax__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Tax__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__List_Price__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__List_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Percent__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Percent__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Total_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Plan__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Plan__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product_Version__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product_Version__c.isUpdateable()) upsert quoteLine; else 'User is not allowed to update or insert Quote Line');
                        //upsert quoteLine; 
                    }
                }
            }else{
                for(pbeWrapper items : selectedProducts1){                    
                    ERP7__Quote_Line_Items__c quoteLine=new ERP7__Quote_Line_Items__c(ERP7__Quotes__c=quoteId);
                    quoteLine.Name = items.pbe.Product2.Name;
                    quoteLine.ERP7__Product__c=items.pbe.Product2.Id;
                    quoteLine.ERP7__List_Price__c=items.pbe.UnitPrice;
                    quoteLine.ERP7__Quantity__c=items.quantity;
                    if(items.isPercent){
                        quoteLine.ERP7__Discount_Percent__c=items.discountPercent;
                        discount=(((items.pbe.UnitPrice*items.quantity)*items.discountPercent)/100);
                    }else{
                        discount=items.quantity*items.discountPercent;
                        quoteLine.ERP7__Discount_Amount__c=discount;
                    }
                    //quoteLine.ERP7__Total_Price__c=quoteLine.ERP7__List_Price__c*quoteLine.ERP7__Quantity__c-discount;
                    if(items.discountPlan != '')  quoteLine.ERP7__Discount_Plan__c=items.discountPlan;
                    if(items.version != '') quoteLine.ERP7__Product_Version__c=items.version;
                    if(items.taxId != '') quoteLine.ERP7__Tax__c= items.taxId;
                    if(items.vatAmount != 0) quoteLine.ERP7__VAT_Amount__c = items.vatAmount;
                    if(items.otherTax != 0) quoteLine.ERP7__Other_Tax__c = items.otherTax;
                    quoteLine.ERP7__Total_Price__c=quoteLine.ERP7__List_Price__c*quoteLine.ERP7__Quantity__c-discount+items.vatAmount+items.otherTax;
                    if(Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Other_Tax__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Other_Tax__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__VAT_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__VAT_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Tax__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Tax__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.Name.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__List_Price__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__List_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Quantity__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Quantity__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Percent__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Percent__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Amount__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Amount__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Total_Price__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Total_Price__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Plan__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Discount_Plan__c.isUpdateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product_Version__c.isCreateable() && Schema.sObjectType.ERP7__Quote_Line_Items__c.fields.ERP7__Product_Version__c.isUpdateable()) upsert quoteLine; else 'User is not allowed to update or insert Quote Line');
                    //upsert quoteLine; 
                }
            }*/       
        }catch(Exception e){ return e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return null;        
    } 
    
    
    
    class ordLineWrapper{
        @AuraEnabled public OrderItem ordLine			{ get; set; }
        @AuraEnabled public List<Discount_Plan__c> disPlans				{ get; set; }
        @AuraEnabled public List<Tier_Discount_Allocation__c> tierDists	{ get; set; }
        @AuraEnabled public List<selectOptions1> CurrentDiscounts       { get; set; }
        @AuraEnabled public Decimal stock								{ get; set; }
        @AuraEnabled public Boolean isPercent							{ get; set; }
        @AuraEnabled public Decimal minDiscount							{ get; set; }
        @AuraEnabled public Decimal maxDiscount							{ get; set; }
        @AuraEnabled public Decimal discountPercent                    	{ get; set; }
        @AuraEnabled public String discountPlan							{ get; set; }
        @AuraEnabled public ERP7__Tax__c tax							{ get; set; }
        @AuraEnabled public String taxId								{ get; set; }
        @AuraEnabled public Decimal vatAmount							{ get; set; }
        @AuraEnabled public Decimal otherTax							{ get; set; }
        
        public ordLineWrapper(){
            ordLine=new OrderItem();
            disPlans=new List<Discount_Plan__c>();
            tierDists=new List<Tier_Discount_Allocation__c>();
            CurrentDiscounts=new List<selectOptions1>();
            stock=0;
            isPercent=true;
            minDiscount=0;
            maxDiscount=0;
            discountPercent=0;
            discountPlan='';
            tax=new ERP7__Tax__c();
            taxId='';
            vatAmount=0;
            otherTax=0;
        }
    }
    
    public class OrdWrapper{
        @AuraEnabled public String errorMsg									{ get; set; }
        @AuraEnabled public Order ord							{ get; set; }
        @AuraEnabled public List<OrderItem> ordLine			{ get; set; }
        @AuraEnabled public List<ordLineWrapper> ordLineWapper				{ get; set; }
        
        public OrdWrapper(){
            errorMsg = '';
            ord=new Order();
            ordLine=new List<OrderItem>();
            ordLineWapper=new List<ordLineWrapper>();
        }
    }
    
    public class ProWrapper {
        @AuraEnabled public String errorMsg 					{ get; set; }
        @AuraEnabled public Order ord 				{ get; set; }
        @AuraEnabled public List<pbeWrapper> pbe1				{ get; set; }
        @AuraEnabled public List<selectOptions1> prodFam 		{ get; Set; } 
        @AuraEnabled public List<selectOptions1> prodCat 		{ get; Set; } 
        @AuraEnabled public List<OrderItem> orderLine 		{ get; Set; } 
        @AuraEnabled public List<selectOptions1> allpriBook 		{ get; Set; }
        @AuraEnabled public boolean isPBAssign					{ get; Set; }
        
        public ProWrapper() {
            errorMsg='';
            ord=new Order();    
            pbe1=new List<pbeWrapper>();
            prodFam = new List<selectOptions1>();
            prodCat = new List<selectOptions1>();
            orderLine=new List<OrderItem>();
            allpriBook=new List<selectOptions1>();
            isPBAssign=false;
        }
    }
    
    public class pbeWrapper {
        @AuraEnabled public PricebookEntry pbe							{ get; set; }
        @AuraEnabled public Decimal quantity							{ get; set; }
        @AuraEnabled public Decimal minDiscount							{ get; set; }
        @AuraEnabled public Decimal maxDiscount							{ get; set; }
        @AuraEnabled public String version								{ get; set; }
        @AuraEnabled public Decimal stock								{ get; set; }
        @AuraEnabled public List<selectOptions1> CurrentDiscounts       { get; set; }
        @AuraEnabled public Decimal discountPercent                    	{ get; set; }
        @AuraEnabled public List<Discount_Plan__c> disPlans				{ get; set; }
        @AuraEnabled public List<Tier_Discount_Allocation__c> tiesDists	{ get; set; }
        @AuraEnabled public Boolean isPercent							{ get; set; }
        @AuraEnabled public String description							{ get; set; }
        @AuraEnabled public String discountPlan							{ get; set; }
        @AuraEnabled public ERP7__Tax__c tax							{ get; set; }
        @AuraEnabled public String taxId								{ get; set; }
        @AuraEnabled public Decimal vatAmount							{ get; set; }
        @AuraEnabled public Decimal otherTax							{ get; set; }
        @AuraEnabled public String orderLineId							{ get; set; }
        
        public pbeWrapper(PricebookEntry pro,String version1,List<selectOptions1> CurrentDiscounts1,Decimal stock1,List<Discount_Plan__c> disPlans1,List<Tier_Discount_Allocation__c> tiesDists1,ERP7__Tax__c tax1,String taxId1,Decimal vatAmount1,Decimal otherTax1) {	//
            pbe=pro;
            quantity = 1;
            version=version1;
            stock=stock1;
            discountPercent=0;
            CurrentDiscounts=CurrentDiscounts1;
            disPlans=disPlans1;
            tiesDists=tiesDists1;
            minDiscount=0;
            maxDiscount=0;
            isPercent=true;
            description='';
            discountPlan='';
            tax=tax1;
            taxId=taxId1;
            vatAmount=vatAmount1;
            otherTax=otherTax1;
            orderLineId='';
        }
    }
    
    public class selectOptions1 {
        @AuraEnabled public String label     { get; set; }
        @AuraEnabled public String value     { get; set; }
        
        public selectOptions1(String lab, string val) {
            label = lab;
            value = val;
        }
    }
    
    //========================Product Configuration start=====================
    @AuraEnabled
    public static OptionProd getOptionProd(String proforConfig, String OrderId){
        OptionProd optPr=new OptionProd();
        try{
            String pricebookId='';
            Set<Id> siteIds=new Set<Id>();
            Order ord=[Select Id,Name,OrderNumber,ERP7__Bill_To_Address__c,ERP7__Ship_To_Address__c,ERP7__Channel__c,AccountId,EffectiveDate,ERP7__Order_Profile__c,Status,ERP7__Contact__c from Order where Id =:OrderId Limit 1];
            
            if(ord.ERP7__Order_Profile__c != null){
                ERP7__Profiling__c profile=[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c from ERP7__Profiling__c where Id =:ord.ERP7__Order_Profile__c Limit 1];
                pricebookId = profile.ERP7__Price_Book__c;
                ERP7__Channel__c channel = [Select Id, Name from ERP7__Channel__c where Id=:profile.ERP7__Channel__c and ERP7__Active__c=true Limit 1];                
                List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                                      where ERP7__Channel__c=:channel.Id and ERP7__Active__c=true];                
                if(DistributionChannels.size() > 0) {
                    for(Distribution_Channel__c DC: DistributionChannels) {
                        siteIds.add(DC.Site__c);
                    }
                }
            }else if(ord.AccountId != null){
                Account Customer=[Select Id,Name,ERP7__Order_Profile__c from Account where Id =:ord.AccountId Limit 1];
                ERP7__Profiling__c profile=[Select Id,Name,ERP7__Channel__c,ERP7__Price_Book__c,ERP7__Organisation__c from ERP7__Profiling__c where ERP7__Organisation__c =:Customer.Id Limit 1];
                pricebookId = profile.ERP7__Price_Book__c;
                ERP7__Channel__c channel = [Select Id, Name from ERP7__Channel__c where Id=:profile.ERP7__Channel__c and ERP7__Active__c=true Limit 1];                
                List<Distribution_Channel__c> DistributionChannels = [Select Id, Name, ERP7__Channel__c, ERP7__Site__c, ERP7__Priority__c from Distribution_Channel__c
                                                                      where ERP7__Channel__c=:channel.Id and ERP7__Active__c=true];                
                if(DistributionChannels.size() > 0) {
                    for(Distribution_Channel__c DC: DistributionChannels) {
                        siteIds.add(DC.Site__c);
                    }
                }
            }else{
                Pricebook2 pricebook=[Select Id,Name,IsStandard from Pricebook2 where IsStandard=true Limit 1]; pricebookId=pricebook.Id;
                List<ERP7__Site__c> siteList=[Select Id,Name,ERP7__Address__c,ERP7__Address__r.ERP7__Country__c from ERP7__Site__c where ERP7__Active__c =true AND ERP7__Address__c !=null AND ERP7__Address__r.ERP7__Country__c =:'United Kingdom' Limit 2];
                for(ERP7__Site__c st:siteList){  siteIds.add(st.Id);
                }
            }
            Set<Id> prodIds=new Set<Id>();
            optPr.product=[Select Id,Name from Product2 where Id =:proforConfig Limit 1];
            List<ERP7__Product_Feature__c> pfList=[Select Id,Name,ERP7__Product__c,ERP7__Is_Multiple_BOM__c from ERP7__Product_Feature__c where ERP7__Product__c =:proforConfig];
            List<ERP7__Product_Option__c> optprodsList=[Select Id,Name,ERP7__Product_Feature__r.Name,ERP7__Configured_SKU__c,ERP7__Optional_SKU__r.Name,ERP7__Optional_SKU__r.ProductCode,ERP7__Optional_SKU__r.ERP7__Picture__c,ERP7__Optional_SKU__r.ERP7__Allow_Back_Orders__c,ERP7__Optional_SKU__c from ERP7__Product_Option__c where ERP7__Configured_SKU__c =:proforConfig];
            
            if(optprodsList.size() >0){
                for(ERP7__Product_Option__c po:optprodsList){
                    prodIds.add(po.ERP7__Optional_SKU__c);
                }
            }        
            
            List<PricebookEntry> pbe1= [Select Product2Id,UnitPrice,Product2.Id,Product2.Name,Product2.ProductCode,Product2.Description,Product2.ERP7__Version__c,Product2.ERP7__Configure__c,Product2.ERP7__Allow_Back_Orders__c,Product2.ERP7__Serialise__c from PricebookEntry where Pricebook2Id =:pricebookId AND Product2Id IN (Select Id From Product2 where IsActive=TRUE AND Id In :prodIds) AND IsActive=TRUE];
            
            //Set<Id> proFeatureIds=new Set<Id>();        
            for(ERP7__Product_Feature__c pf : pfList){      
                FeatureWrapper fw=new FeatureWrapper();
                for(ERP7__Product_Option__c po : optprodsList){
                    if(pf.Name == po.ERP7__Product_Feature__r.Name){
                        //proFeatureIds.add(pf.Id);                  
                        fw.feature = pf;
                        fw.featOpt.add(po);
                        for(PricebookEntry pb: pbe1){
                            if(po.ERP7__Optional_SKU__c == pb.Product2Id){                                
                                fw.pbe.add(pb);
                            }                            
                        }                        
                    }
                }
                if(fw.featOpt.size() > 0)
                    optPr.featrWrapper.add(fw);
            }
            	/*FeatureWrapper fw1=new FeatureWrapper();
                List<ERP7__Product_Option__c> otherOpt=[Select Id,Name,ERP7__Product_Feature__r.Name,ERP7__Configured_SKU__c,ERP7__Optional_SKU__r.Name,ERP7__Optional_SKU__r.ProductCode from ERP7__Product_Option__c where ERP7__Configured_SKU__c =:proforConfig AND ERP7__Product_Feature__c NOT IN :proFeatureIds];
                if(otherOpt.size() > 0){
                fw1.othersPro.addAll(otherOpt);
                //optPr.othersPro = otherOpt;
                optPr.featrWrapper.add(fw1);
                }*/        
            
            List <Inventory_Stock__c> WarehouseItemInventoryStocks = new List <Inventory_Stock__c>();
            if(prodIds.size() > 0) {
                WarehouseItemInventoryStocks = [Select Id, Name, Active__c, Organisation__c, Organisation_Business_Unit__c, Warehouse__c, product__c,
                                                ERP7__Number_of_Item_In_Stock__c, ERP7__Version__c From Inventory_Stock__c
                                                Where product__c In: prodIds And
                                                Active__c = true And
                                                Warehouse__c In: siteIds And                                                 
                                                ERP7__Number_of_Item_In_Stock__c > 0
                                               ];
            }
            if(prodIds.size() > 0) {
                for(Id prId:prodIds){
                    Stock st=new Stock();
                    Decimal stock=0;
                    for(Inventory_Stock__c inven : WarehouseItemInventoryStocks){
                        if(prId == inven.product__c){
                            stock += inven.ERP7__Number_of_Item_In_Stock__c;
                        }
                    }
                    st.ProId=prId;
                    st.stockAvlb=stock;
                    optPr.totalStock.add(st);
                }
            }
        }catch(Exception e){ optPr.errorMsg=e.getMessage() +' Line Number @ : '+ e.getLineNumber(); }
        return optPr;
    }
    
    @AuraEnabled
    public static OptionProd getAllOptionRules(String proId){
        OptionProd optRule=new OptionProd();
        optRule.optionRules = [Select Id,Name,ERP7__Configured_SKU__c,ERP7__Active__c,ERP7__Parent_Option__c,ERP7__Parent_Option__r.ERP7__Optional_SKU__r.Name,ERP7__Child_Option__c,ERP7__Type__c from ERP7__Rule__c where ERP7__Configured_SKU__c =:proId AND ERP7__Active__c =true];
        return optRule;
    }
    
    @AuraEnabled
    public static String createVersion(String selectedProds,String prodId, String proFeatureMap){  //Map<String, Object> selectedProds , String proOptions
        try{
        Map<String, Integer> selectedProds1=new Map<String, Integer>();
        Map<String, Decimal> proOptions1=(Map<String, Decimal>) JSON.deserialize(selectedProds, Map<String, Decimal> .class);
       
        for(String objVar : proOptions1.keySet()){
            selectedProds1.put(objVar,(Integer)proOptions1.get(objVar));          	
        }
        //List<FeatureWrapper> proOptions1=(List<FeatureWrapper>) JSON.deserialize(proOptions, List<FeatureWrapper> .class);
        Date dToday = Date.today();
        Date toDate = Date.today()+30;
        String dateStr = dToday.day() + '/' + dToday.month() + '/' + dToday.year();
        String toDateStr = toDate.day() + '/' + toDate.month() + '/' + toDate.year();
        Product2 mainPro=[Select Id,Name,ERP7__Issue_Manufacturing_Order__c,ERP7__Serialise__c from Product2 where Id =:prodId];
        
        Id verRT = Schema.SObjectType.ERP7__Version__c.getRecordTypeInfosByDeveloperName().get('Manufacturing').getRecordTypeId();
        Id bomRT = Schema.SObjectType.ERP7__BOM__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_BOM').getRecordTypeId();

        Boolean isVersAvailable=false;
        Boolean isRoutAvailable=false;
        String existingVersion='';
        //========Search for version with available with related BOM============
        List<ERP7__Version__c> verList=[Select Id,Name from ERP7__Version__c where RecordTypeId =:verRT AND ERP7__Product__c =:prodId AND ERP7__Active__c=true
                                        AND ERP7__Start_Date__c <= Today AND ERP7__To_Date__c >= Today];
        
        if(verList.size() > 0){
            for(ERP7__Version__c vr:verList){
                List<ERP7__BOM__c> bomList=[Select Id,Name,ERP7__BOM_Product__c,ERP7__BOM_Component__c,RecordTypeId,ERP7__BOM_Version__c,ERP7__Type__c,ERP7__Status__c,ERP7__Quantity__c from ERP7__BOM__c where 
                                            ERP7__BOM_Product__c =:mainPro.Id AND
                                            RecordTypeId =:bomRT AND
                                            ERP7__BOM_Version__c =:vr.Id AND
                                            ERP7__Type__c ='Primary' AND 
                                            ERP7__Active__c=true AND
                                            ERP7__Status__c ='Certified'];
                
                if(bomList.size() > 0){
                    Map<String, Decimal> selectedProdsexist=new Map<String, Decimal>();
                    for(ERP7__BOM__c bom1:bomList){ selectedProdsexist.put(bom1.ERP7__BOM_Component__c, (Integer)bom1.ERP7__Quantity__c);
                    }
                    if(selectedProdsexist.equals(proOptions1)){ isVersAvailable=true; existingVersion = vr.Id;}                                    
                }
                
            }
        }
        //========/Search for version with available with related BOM===========
            if(isVersAvailable){ return existingVersion;}
            else{
                //=========create version and BOM start================
                /*ERP7__Version__c version=new ERP7__Version__c(RecordTypeId = verRT,Name='Version',ERP7__Product__c=prodId,
                                                              ERP7__Active__c=true,ERP7__Type__c='Assembly',ERP7__Status__c='Certified',
                                                              ERP7__Quantity__c=1,ERP7__Start_Date__c=Date.parse(dateStr),ERP7__To_Date__c=Date.parse(toDateStr),ERP7__Unit_of_Measure__c='Each',
                                                              ERP7__Sales_Ready__c=true);*/
                ERP7__Version__c version=new ERP7__Version__c();
                if(Schema.sObjectType.ERP7__Version__c.fields.Name.isCreateable()) version.Name='Version';
                if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Product__c.isCreateable()) version.ERP7__Product__c=prodId;
                if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Active__c.isCreateable()) version.ERP7__Active__c=true;
                if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Type__c.isCreateable()) version.ERP7__Type__c='Assembly';
                if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Status__c.isCreateable()) version.ERP7__Status__c='Certified';
                if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Quantity__c.isCreateable()) version.ERP7__Quantity__c=1;
                if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Start_Date__c.isCreateable()) version.ERP7__Start_Date__c= system.today();
                if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__To_Date__c.isCreateable()) version.ERP7__To_Date__c= system.today()+30;
                if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Unit_of_Measure__c.isCreateable()) version.ERP7__Unit_of_Measure__c='Each';
                if(Schema.sObjectType.ERP7__Version__c.fields.ERP7__Sales_Ready__c.isCreateable()) version.ERP7__Sales_Ready__c=true;
                version.RecordTypeId = verRT;
                if(Schema.sObjectType.ERP7__Version__c.isCreateable()) {insert version;} else {/*'User is not allowed to insert Version');*/}
                //insert version;
                
                List<ERP7__BOM__c> bomList=new List<ERP7__BOM__c>();
                Map<String, String> proFeatureMap1=(Map<String, String>) JSON.deserialize(proFeatureMap, Map<String, String> .class);
                for(String sp : proOptions1.keySet()){
                    //for(String sp:selectedProds){
                    
                    Product2 pro=[Select Id,Name from Product2 where Id=:sp];
                    ERP7__Product_Feature__c pfeat=[Select Id,Name,ERP7__Process_Cycle__c,ERP7__Routing_Link__c from ERP7__Product_Feature__c where Id =:proFeatureMap1.get(sp)];
                    
                    ERP7__BOM__c bom=new ERP7__BOM__c(RecordTypeId=bomRT,Name=pro.Name,ERP7__BOM_Product__c=mainPro.Id,ERP7__Active__c=true,
                                                      ERP7__BOM_Version__c=version.Id,ERP7__Type__c='Primary',ERP7__Status__c='Certified',
                                                      ERP7__Unit_of_Measure__c='Each',ERP7__BOM_Component__c=pro.Id,ERP7__Quantity__c=proOptions1.get(sp),
                                                      ERP7__Process_Cycle__c=pfeat.ERP7__Process_Cycle__c,ERP7__Routing_Link__c=pfeat.ERP7__Routing_Link__c);
                    bomList.add(bom);  
                    //insert bom;                    
                }
                if(Schema.sObjectType.ERP7__BOM__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.Name.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Product__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Active__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Version__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Type__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Status__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Unit_of_Measure__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__BOM_Component__c.isCreateable() && Schema.sObjectType.ERP7__BOM__c.fields.ERP7__Quantity__c.isCreateable()){ insert bomList;} else{/*'User is not allowed to insert Bill of Materials');  */}              
                //=========create version and BOM end================
                
                if(mainPro.ERP7__Issue_Manufacturing_Order__c){
                    //=========create Routing=============
                    ERP7__Routing__c rtngForClone=new ERP7__Routing__c();
                    rtngForClone=[Select Id,Name,ERP7__Channel__c,ERP7__Product__c,ERP7__Status__c,ERP7__Process__c,ERP7__Raw_Materials_Site__c,ERP7__Finished_Products_Site__c,ERP7__Work_Center__c,ERP7__Auto_Stock_Allocation__c,ERP7__Project__c,ERP7__Address__c,ERP7__Minimum_Lot_Size__c,ERP7__Maximum_Lot_Size__c from ERP7__Routing__c where ERP7__Product__c =:mainPro.Id Limit 1];
                    
                    Id RTRouting = Schema.SObjectType.ERP7__Routing__c.getRecordTypeInfosByDeveloperName().get('Manufacturing_Routing').getRecordTypeId();

                    List<ERP7__Routing__c> rtngList=new List<ERP7__Routing__c>();
                    ERP7__Routing__c newRtng=new ERP7__Routing__c();
                    if(Schema.sObjectType.ERP7__Routing__c.fields.Name.isCreateable()) newRtng.Name='Routing';
                    if(Schema.sObjectType.ERP7__Routing__c.fields.RecordTypeId.isCreateable()) newRtng.RecordTypeId=RTRouting;
                    if(rtngForClone.ERP7__Channel__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Channel__c.isCreateable()) newRtng.ERP7__Channel__c=rtngForClone.ERP7__Channel__c; }
                    if(rtngForClone.ERP7__Product__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Product__c.isCreateable()) newRtng.ERP7__Product__c=rtngForClone.ERP7__Product__c; }
                    if(rtngForClone.ERP7__Status__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Status__c.isCreateable()) newRtng.ERP7__Status__c=rtngForClone.ERP7__Status__c; }
                    if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__BOM_Version__c.isCreateable()) newRtng.ERP7__BOM_Version__c=version.Id;
                    if(rtngForClone.ERP7__Process__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Process__c.isCreateable()) newRtng.ERP7__Process__c=rtngForClone.ERP7__Process__c; }
                    if(rtngForClone.ERP7__Raw_Materials_Site__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Raw_Materials_Site__c.isCreateable()) newRtng.ERP7__Raw_Materials_Site__c=rtngForClone.ERP7__Raw_Materials_Site__c; }
                    if(rtngForClone.ERP7__Finished_Products_Site__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Finished_Products_Site__c.isCreateable()) newRtng.ERP7__Finished_Products_Site__c=rtngForClone.ERP7__Finished_Products_Site__c; }
                    if(rtngForClone.ERP7__Work_Center__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Work_Center__c.isCreateable()) newRtng.ERP7__Work_Center__c=rtngForClone.ERP7__Work_Center__c; }
                    if(rtngForClone.ERP7__Auto_Stock_Allocation__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Auto_Stock_Allocation__c.isCreateable()) newRtng.ERP7__Auto_Stock_Allocation__c=rtngForClone.ERP7__Auto_Stock_Allocation__c; }
                    if(rtngForClone.ERP7__Address__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Address__c.isCreateable()) newRtng.ERP7__Address__c=rtngForClone.ERP7__Address__c; }
                    if(rtngForClone.ERP7__Minimum_Lot_Size__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Minimum_Lot_Size__c.isCreateable()) newRtng.ERP7__Minimum_Lot_Size__c=rtngForClone.ERP7__Minimum_Lot_Size__c; } 
                    if(rtngForClone.ERP7__Maximum_Lot_Size__c != null){ if(Schema.sObjectType.ERP7__Routing__c.fields.ERP7__Maximum_Lot_Size__c.isCreateable()) newRtng.ERP7__Maximum_Lot_Size__c=rtngForClone.ERP7__Maximum_Lot_Size__c; } 
                    rtngList.add(newRtng);
                    
                    if(rtngList.size() > 0 && Schema.sObjectType.ERP7__Routing__c.isCreateable()){insert rtngList;}else{/*not allowed to insert*/}
                    //=========create Routing ends=============
                    
                    //==========creating Operation==============
                    ERP7__Routing__c rtng1=[Select Id,Name from ERP7__Routing__c where ERP7__BOM_Version__c =:version.Id Limit 1];
                    
                    String rtng1Id=rtngForClone.Id;
                    String pFields = UtilClass.selectStarFromSObject('ERP7__Operation__c');
                    utilClass.FLSCheck(pFields.split(','),'ERP7__Operation__c');  
                    String  query1 = 'select ' + String.escapeSingleQuotes(pFields) + ' from ERP7__Operation__c Where ERP7__Routing__c =: rtng1Id ';
                    List< ERP7__Operation__c > Operations = Database.query(query1);
                    
                    List<ERP7__Operation__c> Operations2Upsert = new List<ERP7__Operation__c>();
                    for(ERP7__Operation__c Operation : Operations){
                        ERP7__Operation__c Oprn = Operation.clone(false, false, false, false);
                        if(Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.fields.ERP7__Routing__c.isUpdateable()) Oprn.ERP7__Routing__c = rtng1.Id;   
                        Operations2Upsert.add(Oprn);
                    }
                    if(Operations2Upsert.size() > 0 && Schema.sObjectType.ERP7__Operation__c.isCreateable() && Schema.sObjectType.ERP7__Operation__c.isUpdateable()){ upsert Operations2Upsert;}else{/*upsert not allowed*/}
                    //==========/creating Operation ends==============
                    
                    //==========Create WIP Link=======================
                    ERP7__WIP_Link__c WIPLink;
                    for(ERP7__WIP_Link__c record:[Select Id,Name,ERP7__Finished_Products_Site__c,ERP7__Process_Cycle__c,ERP7__Process_Output_Product__c,ERP7__Process_Output_Version__c,ERP7__Product__c,ERP7__Quantity_Unit_Of_Measure__c,ERP7__Quantity_Unit__c,ERP7__Type__c,ERP7__Version__c from ERP7__WIP_Link__c where ERP7__Product__c =:mainPro.Id Limit 1])
                        WIPLink=record;
                    if(WIPLink != null){
                        ERP7__WIP_Link__c WLink=new ERP7__WIP_Link__c();
                        WLink=WIPLink.clone();
                        if(Schema.sObjectType.ERP7__WIP_Link__c.fields.ERP7__Version__c.isCreateable()) WLink.ERP7__Version__c=version.Id;
                        if(Schema.sObjectType.ERP7__WIP_Link__c.isCreateable()){insert WLink;}else{/*not allowed to insert*/}
                    }                    
                    //==========Create WIP Link ends===================
                }
                return version.Id;
            }
        }catch(Exception e){return e.getMessage()+' Line Number @ : '+e.getLineNumber();}
            //return null;
    }
    
    public class Stock{
        @AuraEnabled public String ProId                { get ; set ; }
        @AuraEnabled public Decimal stockAvlb           { get ; set ; }
        public Stock(){
            ProId='';
            stockAvlb=0;
        }
    }
    
    public class FeatureWrapper{
        @AuraEnabled public ERP7__Product_Feature__c feature                { get ; set ; }
        @AuraEnabled public List<ERP7__Product_Option__c> featOpt           { get ; set ; }
        //@AuraEnabled public List<ERP7__Product_Option__c> othersPro         { get ; set ; }
        @AuraEnabled public List<PricebookEntry> pbe						{ get ; set ; }
        public FeatureWrapper(){
            feature = new ERP7__Product_Feature__c();
            featOpt = new List<ERP7__Product_Option__c>();
            //othersPro = new List<ERP7__Product_Option__c>();
            pbe=new List<PricebookEntry>();
        }
    }
    
    public class OptionProd{
        @AuraEnabled public List<FeatureWrapper> featrWrapper               { get ; set ; }
        @AuraEnabled public List<ERP7__Rule__c> optionRules                 { get ; set ; }
        @AuraEnabled public Product2 product                        		{ get ; set ; }
        @AuraEnabled public List<Stock> totalStock                     		{ get ; set ; }
		@AuraEnabled public String errorMsg                     			{ get ; set ; }         
                
        public OptionProd(){
            featrWrapper=new List<FeatureWrapper>();
            optionRules = new List<ERP7__Rule__c>();
            product = new Product2();
            totalStock=new List<Stock>();
            errorMsg='';
        }
    }
    //========================Product Configuration start=====================
}