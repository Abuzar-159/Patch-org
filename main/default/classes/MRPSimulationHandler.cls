public with sharing class MRPSimulationHandler     /*implements Schedulable*/{
  /* public void execute(SchedulableContext sc) {
   Set<Id> mrpIds = new Set<Id>(); // This should be populated with the relevant MRP IDs
   handleAlgorithm(mrpIds);
   }*/
  @future
  public static void handleAlgorithm(Set<Id> MrpIds){
    // try{
    List<ERP7__Manufacturing_Order__c> mos2create = new List<ERP7__Manufacturing_Order__c>();
    List<ERP7__PO__c> pos2Create = new List<ERP7__PO__c>();
    List<ERP7__Purchase_Line_Items__c> polineItems = new List<ERP7__Purchase_Line_Items__c>();
    Map<ERP7__PO__c, List<ERP7__Purchase_Line_Items__c>> POAndLineItems = new Map<ERP7__PO__c, List<ERP7__Purchase_Line_Items__c>>();
    Map<Id, ERP7__PO__c> vendorPOMap = new Map<Id, ERP7__PO__c>();

    if (MrpIds.size() > 0){
      Map<Id, ERP7__Distribution_Channel__c> siteDCMap = new Map<Id, ERP7__Distribution_Channel__c>();
      List<ERP7__MPS__c> mpsList = [SELECT Id, Name, CreatedById, ERP7__Schedule_Period__c, ERP7__Product__r.ERP7__Storage_Holding_Cost__c, ERP7__Awaiting_Qty__c, ERP7__Master_MRP__r.ERP7__To_Date__c, ERP7__Version__c, ERP7__Reordering_Rule__r.ERP7__Minimum_Quantity__c, ERP7__Reordering_Rule__r.ERP7__Maximum_Quantity__c, ERP7__Reordering_Rule__r.ERP7__Warning_Quantity__c, ERP7__Reserved_SO__c, ERP7__Issued_WIP__c, ERP7__Product__r.ERP7__Routing__c, ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__Product__r.ERP7__Issue_Purchase_Order__c, ERP7__Reordering_Rule__c, ERP7__Default_Demand_Forecast__c, ERP7__Reordering_Rule__r.ERP7__MinimumOrderingQuantity__c, ERP7__Reordering_Rule__r.ERP7__Routing__c, ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c, ERP7__Reordering_Rule__r.ERP7__Lead_Time__c, ERP7__Starting_Inventory__c, ERP7__Product__c, ERP7__Master_MRP__c, ERP7__Product__r.ERP7__Default_Vendor__c, ERP7__Master_MRP__r.ERP7__Algorithm__c, ERP7__Master_MRP__r.ERP7__Site__c, ERP7__Product__r.ERP7__Estimated_Manufacturing_Cost__c, (SELECT Id, Name, CreatedById, ERP7__Schedule_Period__c, ERP7__Product__r.ERP7__Storage_Holding_Cost__c, ERP7__Awaiting_Qty__c, ERP7__Version__c, ERP7__Reordering_Rule__r.ERP7__Minimum_Quantity__c, ERP7__Reordering_Rule__r.ERP7__Maximum_Quantity__c, ERP7__Reordering_Rule__r.ERP7__Warning_Quantity__c, ERP7__Reserved_SO__c, ERP7__Issued_WIP__c, ERP7__Product__r.ERP7__Routing__c, ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c, ERP7__Product__r.ERP7__Issue_Purchase_Order__c, ERP7__Reordering_Rule__c, ERP7__Default_Demand_Forecast__c, ERP7__Reordering_Rule__r.ERP7__MinimumOrderingQuantity__c, ERP7__Reordering_Rule__r.ERP7__Routing__c, ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c, ERP7__Reordering_Rule__r.ERP7__Lead_Time__c, ERP7__Starting_Inventory__c, ERP7__Product__c, ERP7__Master_MRP__c, ERP7__Product__r.ERP7__Default_Vendor__c, ERP7__Product__r.ERP7__Estimated_Manufacturing_Cost__c, ERP7__Product__r.Name
                                    FROM ERP7__Master_Production_Schedules__r)
                                    FROM ERP7__MPS__c
                                    WHERE ERP7__Master_MRP__c IN:MrpIds];


      Set<Id> productIDs = new Set<Id>();
      Set<Id> vendorIDs = new Set<Id>();
      Set<Id> routingIDs = new Set<Id>();
      Set<Id> BOMproductIDs = new Set<Id>();
      Set<Id> BOMvendorIDs = new Set<Id>();
      Set<Id> BOMroutingIDs = new Set<Id>();

      // Loop through each MPS record in the mpsList
      for (ERP7__MPS__c mpsRecord : mpsList){

        // Loop through related Master Production Schedules (if they exist) within each MPS record
        if (mpsRecord.ERP7__Master_Production_Schedules__r != null){
          for (ERP7__MPS__c mp : mpsRecord.ERP7__Master_Production_Schedules__r){            BOMproductIDs.add(mp.ERP7__Product__c);            System.debug('--- BOM Product: ' + BOMproductIDs);            if (mpsRecord.ERP7__Reordering_Rule__c != null){              if (mpsRecord.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c != null){                BOMvendorIDs.add(mpsRecord.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c);                System.debug('--- Vendor Account: ' + BOMvendorIDs);              } else if (mp.ERP7__Product__r.ERP7__Default_Vendor__c != null){                BOMvendorIDs.add(mp.ERP7__Product__r.ERP7__Default_Vendor__c);                System.debug('--- Default Vendor: ' + BOMvendorIDs);              }              if (mpsRecord.ERP7__Reordering_Rule__r.ERP7__Routing__c != null){                BOMroutingIDs.add(mpsRecord.ERP7__Reordering_Rule__r.ERP7__Routing__c);                System.debug('--- Routing: ' + BOMroutingIDs);              } else if (mp.ERP7__Product__r.ERP7__Routing__c != null){                BOMroutingIDs.add(mp.ERP7__Product__r.ERP7__Routing__c);                System.debug('--- Default Routing: ' + BOMroutingIDs);              }            }          }      
        }
      }

      Map<Id, Map<Id, ERP7__Cost_Card__c>> BOMproductVendorCostMap = new Map<Id, Map<Id, ERP7__Cost_Card__c>>();
      Map<Id, ERP7__Routing__c> BOMRoutingVersionMap = new Map<Id, ERP7__Routing__c>();
      Map<Id, Contact> BOMvendorContactMap = new Map<Id, Contact>();
      Map<Id, ERP7__Address__c> BOMvendorAddressMap = new Map<Id, ERP7__Address__c>();
      if (BOMroutingIds.size() > 0){        BOMRoutingVersionMap = new Map<Id, ERP7__Routing__c>([SELECT Id, Name, ERP7__BOM_Version__c, ERP7__Finished_Products_Site__c, ERP7__Raw_Materials_Site__c, ERP7__Product__c, ERP7__Process__c                                                           FROM ERP7__Routing__c                                                           WHERE Id IN:BOMroutingIds AND ERP7__BOM_Version__c != null AND ERP7__Product__c != null]);      }
        

      if (vendorIDs.size() > 0){        List<ERP7__Cost_Card__c> BOMcclist = [SELECT Id, Name, ERP7__Cost__c, ERP7__Active__c, ERP7__Supplier__c, ERP7__Product__c, ERP7__Product__r.Name                                           FROM ERP7__Cost_Card__c                                           WHERE ERP7__Product__c IN:BOMproductIDs AND ERP7__Supplier__c IN:BOMvendorIDs];        for (ERP7__Cost_Card__c BOMcostCard : BOMcclist){          if (!BOMproductVendorCostMap.containsKey(BOMcostCard.ERP7__Product__c)){            BOMproductVendorCostMap.put(BOMcostCard.ERP7__Product__c, new Map<Id, ERP7__Cost_Card__c>());          }          BOMproductVendorCostMap.get(BOMcostCard.ERP7__Product__c).put(BOMcostCard.ERP7__Supplier__c, BOMcostCard);        }        List<Contact> BOMcontactlst = [Select Id, Name, ERP7__Primary__c, AccountId                                    from Contact                                    where AccountId IN:BOMvendorIDs and ERP7__Primary__c = true];        for (Contact BOMcon : BOMcontactlst){          if (!BOMvendorContactMap.containsKey(BOMcon.AccountId))          BOMvendorContactMap.put(BOMcon.AccountId, BOMcon);        }        List<ERP7__Address__c> BOMaddList = [Select Id, Name, ERP7__Customer__c                                          from ERP7__Address__c                                          where ERP7__Customer__c IN:BOMvendorIDs and ERP7__Active__c = true                                          order by CreatedDate ASC];        for (ERP7__Address__c BOMaddress : BOMaddList){          if (!BOMvendorAddressMap.containsKey(BOMaddress.ERP7__Customer__c))          BOMvendorAddressMap.put(BOMaddress.ERP7__Customer__c, BOMaddress);        }      }
        
      for (ERP7__Distribution_Channel__c BOMDC : [SELECT Id, Name, ERP7__Site__c, ERP7__Channel__c
                                               FROM ERP7__Distribution_Channel__c
                                               where ERP7__Active__c = true]){
        siteDCMap.put(BOMDC.ERP7__Site__c, BOMDC);
      }

      // Loop through each MPS record in the mpsList
      for (ERP7__MPS__c mpsRecord : mpsList){
          // Loop through related Master Production Schedules (if they exist) within each MPS record
          if (mpsRecord.ERP7__Master_Production_Schedules__r != null){
            for (ERP7__MPS__c mps : mpsRecord.ERP7__Master_Production_Schedules__r){              Decimal requiredqty = 0;              Decimal netRequirements = 0;              Decimal fixedqty = 0;              String prodId = mps.ERP7__Product__c;              System.debug('BOMID'+ prodId);              system.debug('mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c : ' + mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c);              if (mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Lot-for-Lot (L4L)'){                netRequirements = mps.ERP7__Default_Demand_Forecast__c;              } else if (mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Fixed Order Quantity (FOQ)'){                netRequirements = mpsRecord.ERP7__Reordering_Rule__r.ERP7__MinimumOrderingQuantity__c;              } else if (mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Economic Order Quantity (EOQ)'){                requiredqty = mps.ERP7__Default_Demand_Forecast__c;                Decimal orderingCostPerOrder = 0;                if (mps.ERP7__Product__r.ERP7__Issue_Purchase_Order__c){                  if (mpsRecord.ERP7__Reordering_Rule__c != null && mpsRecord.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c != null){                    if (BOMproductVendorCostMap.containsKey(mps.ERP7__Product__c) && BOMproductVendorCostMap.get(mps.ERP7__Product__c).containsKey(mpsRecord.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c)){                      orderingCostPerOrder = BOMproductVendorCostMap.get(mps.ERP7__Product__c).get(mpsRecord.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c).ERP7__Cost__c;                    }                  }                } else{                  if (mps.ERP7__Product__r.ERP7__Estimated_Manufacturing_Cost__c != null && mps.ERP7__Product__r.ERP7__Estimated_Manufacturing_Cost__c > 0)                    orderingCostPerOrder = mps.ERP7__Product__r.ERP7__Estimated_Manufacturing_Cost__c;                }                Decimal handlingCost = (mps.ERP7__Product__r.ERP7__Storage_Holding_Cost__c > 0) ? mps.ERP7__Product__r.ERP7__Storage_Holding_Cost__c : 1;                Decimal eoq = Math.sqrt((2 * requiredqty * orderingCostPerOrder) / handlingCost);                netRequirements = eoq;              } else if (mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Period Order Quantity (POQ)'){                requiredqty = mps.ERP7__Default_Demand_Forecast__c;                Decimal orderFrequency = (mps.ERP7__Schedule_Period__c == 'Monthly') ? 1 : 3;                Decimal periodsPerYear = (mps.ERP7__Schedule_Period__c == 'Monthly') ? 12 : 4;                netRequirements = (requiredqty / (orderFrequency * periodsPerYear));              } else if (mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Safety Stock Method'){                requiredqty = mps.ERP7__Default_Demand_Forecast__c;                Decimal safetyStock = (mpsRecord.ERP7__Reordering_Rule__r.ERP7__Warning_Quantity__c > 0) ? mpsRecord.ERP7__Reordering_Rule__r.ERP7__Warning_Quantity__c : 0;                netRequirements = (safetyStock - (mps.ERP7__Starting_Inventory__c - requiredqty));              } else if (mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Demand Driven MRP (DDMRP)'){                requiredqty = mps.ERP7__Default_Demand_Forecast__c;                Decimal netFlow = ((mps.ERP7__Starting_Inventory__c + mps.ERP7__Awaiting_Qty__c) - (mps.ERP7__Reserved_SO__c + mps.ERP7__Issued_WIP__c + requiredqty));                if (netFlow <= mpsRecord.ERP7__Reordering_Rule__r.ERP7__Warning_Quantity__c){                  netRequirements = mpsRecord.ERP7__Reordering_Rule__r.ERP7__Minimum_Quantity__c - requiredqty;                } else if (netFlow <= mpsRecord.ERP7__Reordering_Rule__r.ERP7__Minimum_Quantity__c){                  netRequirements = mpsRecord.ERP7__Reordering_Rule__r.ERP7__Maximum_Quantity__c - requiredqty;                } else{                  netRequirements = 0;                }              } else if (mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Just-In-Time (JIT)'){                requiredqty = mps.ERP7__Default_Demand_Forecast__c;                netRequirements = requiredqty;              } else if (mpsRecord.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Min-Max System'){                requiredqty = mps.ERP7__Default_Demand_Forecast__c;                netRequirements = (mps.ERP7__Starting_Inventory__c < mpsRecord.ERP7__Reordering_Rule__r.ERP7__Minimum_Quantity__c ? (mpsRecord.ERP7__Reordering_Rule__r.ERP7__Maximum_Quantity__c - mps.ERP7__Starting_Inventory__c) : 0);              }              system.debug('netRequirements : ' + netRequirements);              netRequirements = Math.ceil(netRequirements);              if (netRequirements > 0){                if (mps.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c){                  String routing = (mpsRecord.ERP7__Reordering_Rule__r.ERP7__Routing__c != null) ? mpsRecord.ERP7__Reordering_Rule__r.ERP7__Routing__c : mps.ERP7__Product__r.ERP7__Routing__c;                  System.debug('routing : ' + routing);                  System.debug('ERP7__Version__c =' + (BOMRoutingVersionMap.containsKey(routing) ? BOMRoutingVersionMap.get(routing).ERP7__BOM_Version__c : null));                  if (routing != null && routing != ''){                    ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(                      ERP7__Status__c = 'Draft',                      Name = 'MO' + mpsRecord.ERP7__Master_MRP__r.ERP7__To_Date__c,                      ERP7__Quantity__c = netRequirements,                      ERP7__Product__c = mps.ERP7__Product__c,                      ERP7__Routing__c = routing,                      ERP7__ExpectedDate__c = mpsRecord.ERP7__Master_MRP__r.ERP7__To_Date__c,                      ERP7__StartDate__c = system.now(),                      ERP7__End_Date__c = mpsRecord.ERP7__Master_MRP__r.ERP7__To_Date__c,                      ERP7__Owner__c = mps.CreatedById,                      ERP7__Initiate_MO__c = true,                      ERP7__Escape_Process__c = false,                      ERP7__Material_Requirement_Planning__c = mpsRecord.ERP7__Master_MRP__c                    );                    mos2create.add(MO);                  }                } else if (mps.ERP7__Product__r.ERP7__Issue_Purchase_Order__c){                  String BOMVendorAccount = (mpsRecord.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c != null) ? mpsRecord.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c : mps.ERP7__Product__r.ERP7__Default_Vendor__c;                  if (BOMVendorAccount != null && BOMVendorAccount != ''){                    Decimal unitCost = (BOMproductVendorCostMap.containsKey(mps.ERP7__Product__c) && BOMproductVendorCostMap.get(mps.ERP7__Product__c).containsKey(BOMVendorAccount)) ? BOMproductVendorCostMap.get(mps.ERP7__Product__c).get(BOMVendorAccount).ERP7__Cost__c : 0;                    if (!vendorPOMap.containsKey(BOMVendorAccount)){                      ERP7__PO__c newPO = new ERP7__PO__c(                        ERP7__Active__c = true,                        ERP7__Vendor__c = BOMVendorAccount,                        ERP7__Material_Requirement_Planning__c = mpsRecord.ERP7__Master_MRP__c,                        ERP7__Expected_Date__c = Date.today().addDays(Integer.valueOf(mpsRecord.ERP7__Reordering_Rule__r.ERP7__Lead_Time__c)),                        ERP7__Status__c = 'Draft',                        ERP7__Vendor_Contact__c = BOMvendorContactMap.containsKey(BOMVendorAccount) ? BOMvendorContactMap.get(BOMVendorAccount).Id : null,                        ERP7__Vendor_Address__c = BOMvendorAddressMap.containsKey(BOMVendorAccount) ? BOMvendorAddressMap.get(BOMVendorAccount).Id : null,                        ERP7__Channel__c = siteDCMap.containsKey(mpsRecord.ERP7__Master_MRP__r.ERP7__Site__c) ? siteDCMap.get(mpsRecord.ERP7__Master_MRP__r.ERP7__Site__c).ERP7__Channel__c : null,                        ERP7__Distribution_Channel__c = siteDCMap.containsKey(mpsRecord.ERP7__Master_MRP__r.ERP7__Site__c) ? siteDCMap.get(mpsRecord.ERP7__Master_MRP__r.ERP7__Site__c).Id : null                      );                      pos2Create.add(newPO);                      vendorPOMap.put(BOMVendorAccount, newPO);                    }                    ERP7__PO__c BOMcurrentPO = vendorPOMap.get(BOMVendorAccount);                    ERP7__Purchase_Line_Items__c BOMnewPOItem = new ERP7__Purchase_Line_Items__c(                      ERP7__Active__c = true,                      ERP7__Product__c = mps.ERP7__Product__c,                      ERP7__Quantity__c = netRequirements,                      ERP7__Unit_Price__c = unitCost,                      ERP7__Total_Price__c = unitCost * netRequirements,                      ERP7__Cost_Card__c = (BOMproductVendorCostMap.containsKey(mps.ERP7__Product__c) && BOMproductVendorCostMap.get(mps.ERP7__Product__c).containsKey(BOMVendorAccount)) ? BOMproductVendorCostMap.get(mps.ERP7__Product__c).get(BOMVendorAccount).Id : null                    );                    if (!POAndLineItems.containsKey(BOMcurrentPO)){                      POAndLineItems.put(BOMcurrentPO, new List<ERP7__Purchase_Line_Items__c>{ BOMnewPOItem });                    } else{                      POAndLineItems.get(BOMcurrentPO).add(BOMnewPOItem);                    }                    system.debug('POAndLineItems : ' + POAndLineItems);                  }                }              }            }        
          }
      }


      // Iterating through mpsList and related records for debugging
      for (ERP7__MPS__c mpsRecord : mpsList){
        System.debug('Main Record: ' + mpsRecord.Name);

        // Check if there are related records and iterate through them
        if (mpsRecord.ERP7__Master_Production_Schedules__r != null && !mpsRecord.ERP7__Master_Production_Schedules__r.isEmpty()){
          for (ERP7__MPS__c schedule : mpsRecord.ERP7__Master_Production_Schedules__r){
            System.debug('--- BOM Record Name: ' + schedule.Name);
            System.debug('--- BOM Manufacturable: ' + schedule.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c);
            System.debug('--- BOM Purchasable: ' + schedule.ERP7__Product__r.ERP7__Issue_Purchase_Order__c);
          }
        } else{
          System.debug('--- No related schedules found for this main record.');
        }
      }


      for (ERP7__MPS__c mp : mpsList){
        productIDs.add(mp.ERP7__Product__c);
        if (mp.ERP7__Reordering_Rule__c != null){
          if (mp.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c != null){
            vendorIDs.add(mp.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c);
          } else if (mp.ERP7__Product__r.ERP7__Default_Vendor__c != null){
            vendorIDs.add(mp.ERP7__Product__r.ERP7__Default_Vendor__c);
          }
          if (mp.ERP7__Reordering_Rule__r.ERP7__Routing__c != null){
            routingIds.add(mp.ERP7__Reordering_Rule__r.ERP7__Routing__c);
          } else if (mp.ERP7__Product__r.ERP7__Routing__c != null){
            routingIds.add(mp.ERP7__Product__r.ERP7__Routing__c);
          }
        }
      }

      Map<Id, Map<Id, ERP7__Cost_Card__c>> productVendorCostMap = new Map<Id, Map<Id, ERP7__Cost_Card__c>>();
      Map<Id, ERP7__Routing__c> RoutingVersionMap = new Map<Id, ERP7__Routing__c>();
      Map<Id, Contact> vendorContactMap = new Map<Id, Contact>();
      Map<Id, ERP7__Address__c> vendorAddressMap = new Map<Id, ERP7__Address__c>();
      if (routingIds.size() > 0){
        RoutingVersionMap = new Map<Id, ERP7__Routing__c>([SELECT Id, Name, ERP7__BOM_Version__c, ERP7__Finished_Products_Site__c, ERP7__Raw_Materials_Site__c, ERP7__Product__c, ERP7__Process__c
                                                           FROM ERP7__Routing__c
                                                           WHERE Id IN:routingIds AND ERP7__BOM_Version__c != null AND ERP7__Product__c != null]);
      }

      if (vendorIDs.size() > 0){
        List<ERP7__Cost_Card__c> cclist = [SELECT Id, Name, ERP7__Cost__c, ERP7__Active__c, ERP7__Supplier__c, ERP7__Product__c, ERP7__Product__r.Name
                                           FROM ERP7__Cost_Card__c
                                           WHERE ERP7__Product__c IN:productIDs AND ERP7__Supplier__c IN:vendorIDs];

        for (ERP7__Cost_Card__c costCard : cclist){
          if (!productVendorCostMap.containsKey(costCard.ERP7__Product__c)){
            productVendorCostMap.put(costCard.ERP7__Product__c, new Map<Id, ERP7__Cost_Card__c>());
          }
          productVendorCostMap.get(costCard.ERP7__Product__c).put(costCard.ERP7__Supplier__c, costCard);
        }
        List<Contact> contactlst = [Select Id, Name, ERP7__Primary__c, AccountId
                                    from Contact
                                    where AccountId IN:vendorIDs and ERP7__Primary__c = true];
        for (Contact con : contactlst){
          if (!vendorContactMap.containsKey(con.AccountId))
            vendorContactMap.put(con.AccountId, con);
        }
        List<ERP7__Address__c> addList = [Select Id, Name, ERP7__Customer__c
                                          from ERP7__Address__c
                                          where ERP7__Customer__c IN:vendorIDs and ERP7__Active__c = true
                                          order by CreatedDate ASC];
        for (ERP7__Address__c address : addList){
          if (!vendorAddressMap.containsKey(address.ERP7__Customer__c))
            vendorAddressMap.put(address.ERP7__Customer__c, address);
        }

      }

      for (ERP7__Distribution_Channel__c DC : [SELECT Id, Name, ERP7__Site__c, ERP7__Channel__c
                                               FROM ERP7__Distribution_Channel__c
                                               where ERP7__Active__c = true]){
        siteDCMap.put(DC.ERP7__Site__c, DC);
      }

      for (ERP7__MPS__c mps : mpsList){
        Decimal requiredqty = 0;
        Decimal netRequirements = 0;
        Decimal fixedqty = 0;
        String prodId = mps.ERP7__Product__c;
        system.debug('mps.ERP7__Master_MRP__r.ERP7__Algorithm__c : ' + mps.ERP7__Master_MRP__r.ERP7__Algorithm__c);
        if (mps.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Lot-for-Lot (L4L)'){
          netRequirements = mps.ERP7__Default_Demand_Forecast__c;
        } else if (mps.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Fixed Order Quantity (FOQ)'){
          netRequirements = mps.ERP7__Reordering_Rule__r.ERP7__MinimumOrderingQuantity__c;
        } else if (mps.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Economic Order Quantity (EOQ)'){
          requiredqty = mps.ERP7__Default_Demand_Forecast__c;
          Decimal orderingCostPerOrder = 0;
          if (mps.ERP7__Product__r.ERP7__Issue_Purchase_Order__c){
            if (mps.ERP7__Reordering_Rule__c != null && mps.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c != null){
              if (productVendorCostMap.containsKey(mps.ERP7__Product__c) && productVendorCostMap.get(mps.ERP7__Product__c).containsKey(mps.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c)){
                orderingCostPerOrder = productVendorCostMap.get(mps.ERP7__Product__c).get(mps.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c).ERP7__Cost__c;
              }
            }
          } else{
            if (mps.ERP7__Product__r.ERP7__Estimated_Manufacturing_Cost__c != null && mps.ERP7__Product__r.ERP7__Estimated_Manufacturing_Cost__c > 0)
              orderingCostPerOrder = mps.ERP7__Product__r.ERP7__Estimated_Manufacturing_Cost__c;
          }

          Decimal handlingCost = (mps.ERP7__Product__r.ERP7__Storage_Holding_Cost__c > 0) ? mps.ERP7__Product__r.ERP7__Storage_Holding_Cost__c : 1;
          Decimal eoq = Math.sqrt((2 * requiredqty * orderingCostPerOrder) / handlingCost);
          netRequirements = eoq;
        } else if (mps.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Period Order Quantity (POQ)'){
          requiredqty = mps.ERP7__Default_Demand_Forecast__c;
          Decimal orderFrequency = (mps.ERP7__Schedule_Period__c == 'Monthly') ? 1 : 3;
          Decimal periodsPerYear = (mps.ERP7__Schedule_Period__c == 'Monthly') ? 12 : 4;
          netRequirements = (requiredqty / (orderFrequency * periodsPerYear));
        } else if (mps.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Safety Stock Method'){
          requiredqty = mps.ERP7__Default_Demand_Forecast__c;
          Decimal safetyStock = (mps.ERP7__Reordering_Rule__r.ERP7__Warning_Quantity__c > 0) ? mps.ERP7__Reordering_Rule__r.ERP7__Warning_Quantity__c : 0;
          netRequirements = (safetyStock - (mps.ERP7__Starting_Inventory__c - requiredqty));
        } else if (mps.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Demand Driven MRP (DDMRP)'){
          requiredqty = mps.ERP7__Default_Demand_Forecast__c;
          Decimal netFlow = ((mps.ERP7__Starting_Inventory__c + mps.ERP7__Awaiting_Qty__c) - (mps.ERP7__Reserved_SO__c + mps.ERP7__Issued_WIP__c + requiredqty));
          if (netFlow <= mps.ERP7__Reordering_Rule__r.ERP7__Warning_Quantity__c){
            netRequirements = mps.ERP7__Reordering_Rule__r.ERP7__Minimum_Quantity__c - requiredqty;
          } else if (netFlow <= mps.ERP7__Reordering_Rule__r.ERP7__Minimum_Quantity__c){
            netRequirements = mps.ERP7__Reordering_Rule__r.ERP7__Maximum_Quantity__c - requiredqty;
          } else{
            netRequirements = 0;
          }
        } else if (mps.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Just-In-Time (JIT)'){
          requiredqty = mps.ERP7__Default_Demand_Forecast__c;
          netRequirements = requiredqty;
        } else if (mps.ERP7__Master_MRP__r.ERP7__Algorithm__c == 'Min-Max System'){
          requiredqty = mps.ERP7__Default_Demand_Forecast__c;
          netRequirements = (mps.ERP7__Starting_Inventory__c < mps.ERP7__Reordering_Rule__r.ERP7__Minimum_Quantity__c ? (mps.ERP7__Reordering_Rule__r.ERP7__Maximum_Quantity__c - mps.ERP7__Starting_Inventory__c) : 0);
        }
        system.debug('netRequirements : ' + netRequirements);
        netRequirements = Math.ceil(netRequirements);
        if (netRequirements > 0){
          if (mps.ERP7__Product__r.ERP7__Issue_Manufacturing_Order__c){
            String routing = (mps.ERP7__Reordering_Rule__r.ERP7__Routing__c != null) ? mps.ERP7__Reordering_Rule__r.ERP7__Routing__c : mps.ERP7__Product__r.ERP7__Routing__c;
            System.debug('routing : ' + routing);
            if (routing != null && routing != ''){
              ERP7__Manufacturing_Order__c MO = new ERP7__Manufacturing_Order__c(
                ERP7__Status__c = 'Draft',
                Name = 'MO' + mps.ERP7__Master_MRP__r.ERP7__To_Date__c,
                ERP7__Quantity__c = netRequirements,
                ERP7__Product__c = mps.ERP7__Product__c,
                ERP7__Version__c = (RoutingVersionMap.containsKey(routing) ? RoutingVersionMap.get(routing).ERP7__BOM_Version__c : null),
                ERP7__Routing__c = routing,
                ERP7__ExpectedDate__c = mps.ERP7__Master_MRP__r.ERP7__To_Date__c,
                ERP7__StartDate__c = system.now(),
                ERP7__End_Date__c = mps.ERP7__Master_MRP__r.ERP7__To_Date__c,
                ERP7__Owner__c = mps.CreatedById,
                ERP7__Initiate_MO__c = true,
                ERP7__Escape_Process__c = false,
                ERP7__Material_Requirement_Planning__c = mps.ERP7__Master_MRP__c
              );
              mos2create.add(MO);
            }
          } else if (mps.ERP7__Product__r.ERP7__Issue_Purchase_Order__c){
            String VendorAccount = (mps.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c != null) ? mps.ERP7__Reordering_Rule__r.ERP7__Vendor_Account__c : mps.ERP7__Product__r.ERP7__Default_Vendor__c;
            if (VendorAccount != null && VendorAccount != ''){
              Decimal unitCost = (productVendorCostMap.containsKey(mps.ERP7__Product__c) && productVendorCostMap.get(mps.ERP7__Product__c).containsKey(VendorAccount)) ? productVendorCostMap.get(mps.ERP7__Product__c).get(VendorAccount).ERP7__Cost__c : 0;

              if (!vendorPOMap.containsKey(VendorAccount)){
                ERP7__PO__c newPO = new ERP7__PO__c(
                  //Name = 'PO for ' + mps.Name,
                  ERP7__Active__c = true,
                  ERP7__Vendor__c = VendorAccount,
                  ERP7__Material_Requirement_Planning__c = mps.ERP7__Master_MRP__c,
                  ERP7__Expected_Date__c = Date.today().addDays(Integer.valueOf(mps.ERP7__Reordering_Rule__r.ERP7__Lead_Time__c)),
                  ERP7__Status__c = 'Draft',
                  ERP7__Vendor_Contact__c = vendorContactMap.containsKey(VendorAccount) ? vendorContactMap.get(VendorAccount).Id : null,
                  ERP7__Vendor_Address__c = vendorAddressMap.containsKey(VendorAccount) ? vendorAddressMap.get(VendorAccount).Id : null,
                  ERP7__Channel__c = siteDCMap.containsKey(mps.ERP7__Master_MRP__r.ERP7__Site__c) ? siteDCMap.get(mps.ERP7__Master_MRP__r.ERP7__Site__c).ERP7__Channel__c : null,
                  ERP7__Distribution_Channel__c = siteDCMap.containsKey(mps.ERP7__Master_MRP__r.ERP7__Site__c) ? siteDCMap.get(mps.ERP7__Master_MRP__r.ERP7__Site__c).Id : null
                );
                pos2Create.add(newPO);
                vendorPOMap.put(VendorAccount, newPO);
              }

              ERP7__PO__c currentPO = vendorPOMap.get(VendorAccount);
              ERP7__Purchase_Line_Items__c newPOItem = new ERP7__Purchase_Line_Items__c(
                ERP7__Active__c = true,
                ERP7__Product__c = mps.ERP7__Product__c,
                ERP7__Quantity__c = netRequirements,
                ERP7__Unit_Price__c = unitCost,
                ERP7__Total_Price__c = unitCost * netRequirements,
                ERP7__Cost_Card__c = (productVendorCostMap.containsKey(mps.ERP7__Product__c) && productVendorCostMap.get(mps.ERP7__Product__c).containsKey(VendorAccount)) ? productVendorCostMap.get(mps.ERP7__Product__c).get(VendorAccount).Id : null
              );

              if (!POAndLineItems.containsKey(currentPO)){
                POAndLineItems.put(currentPO, new List<ERP7__Purchase_Line_Items__c>{ newPOItem });
              } else{
                POAndLineItems.get(currentPO).add(newPOItem);
              }
              system.debug('POAndLineItems : ' + POAndLineItems);
            }
          }
        }
      }
      system.debug('mos2create : ' + mos2create.size());
      system.debug('pos2Create : ' + pos2Create.size());
      if (!mos2create.isEmpty()){
        insert mos2create;
      }

      if (!pos2Create.isEmpty()){
        insert pos2Create;
        Integer i = 0;
        for (List<ERP7__Purchase_Line_Items__c> lineItem : POAndLineItems.Values()){
          for (ERP7__Purchase_Line_Items__c Item : lineItem){
            Item.ERP7__Purchase_Orders__c = pos2Create[i].Id;
          }
          polineItems.addAll(lineItem);
        }
        /*  for (ERP7__PO__c po : pos2Create) {
         system.debug('po : '+po);
         system.debug('POAndLineItems.containsKey(po) : '+POAndLineItems.containsKey(po));
         if (POAndLineItems.containsKey(po)) {
         for (ERP7__Purchase_Line_Items__c lineItem : POAndLineItems.get(po)) {
         lineItem.ERP7__Purchase_Orders__c = po.Id;
         polineItems.add(lineItem);
         }
         }
         }*/
        system.debug('polineItems : ' + polineItems.size());
        if (!polineItems.isEmpty()){
          insert polineItems;
        }
      }
      List<ERP7__Material_Requirement_Planning__c> mrps2update = new List<ERP7__Material_Requirement_Planning__c>();
      for (ID mrpId : MrpIds){
        mrps2update.add(new ERP7__Material_Requirement_Planning__c(
          Id = mrpId,
          ERP7__Processed__c = true
        ));
      }
      system.debug('+mrps2update.size() : ' + mrps2update.size());
      if (mrps2update.size() > 0)
        update mrps2update;
    }
    // }catch(Exception e){
    // system.debug('error : '+e.getLineNumber()+' Msg : '+e.getMessage());
    //}
  }

}