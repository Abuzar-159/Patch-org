import { LightningElement, wire, track, api } from 'lwc';
import getBOMByVersion from '@salesforce/apex/InventoryManagementReport.getBOMByVersion';
import getInventoryDetails from '@salesforce/apex/InventoryManagementReport.getInventoryDetails';
import getInvnetorybyDate from '@salesforce/apex/InventoryManagementReport.getInventoryDetailsbyDate';
import getInvnetorydatawithFilter from '@salesforce/apex/InventoryManagementReport.getInvnetorydatawithFilter';
import getPicklists from "@salesforce/apex/InventoryManagementReport.getPicklistFamilyAndSubFamily";
import getInvnetoryTrace from '@salesforce/apex/InventoryManagementReport.getInvnetoryTrace';
import getforecast from '@salesforce/apex/InventoryManagementReport.getforecast';
import getforecastByProduct from '@salesforce/apex/InventoryManagementReport.getforecastByProduct';
import getforecastMRPs from '@salesforce/apex/InventoryManagementReport.getforecastforMRPS';

import saveForecasts from '@salesforce/apex/InventoryManagementReport.saveForecasts';
import saveMRPS from '@salesforce/apex/InventoryManagementReport.saveMRPS';
import getReorderingRules from '@salesforce/apex/InventoryManagementReport.getReorderingRules';
import createReorder from '@salesforce/apex/InventoryManagementReport.createReorder';
import getMRPDetails from '@salesforce/apex/InventoryManagementReport.getMRPDetails';
import updateReorder from '@salesforce/apex/InventoryManagementReport.updateReorder';
import deleteMPsRecord from '@salesforce/apex/InventoryManagementReport.deleteMPsRecord';
import getOrderDetailsBasedOnStatus from '@salesforce/apex/InventoryManagementReport.getOrderDetailsBasedOnStatus';

import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import jQuery from '@salesforce/resourceUrl/jQuery';
import bootStrap from '@salesforce/resourceUrl/bootStrap';
import BankReconcile from '@salesforce/resourceUrl/BankReconcile';
//import SLDS from '@salesforce/resourceUrl/SLDS';
import ProjectWorkbench from '@salesforce/resourceUrl/ProjectWorkbench';
import { NavigationMixin } from 'lightning/navigation';
import REPORT_URL from '@salesforce/label/c.View_BOM_report';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import Product_OBJECT from '@salesforce/schema/Product2';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

export default class inventoryManagement extends NavigationMixin(LightningElement) {
  @track selectedBOMDetails = '';
  @track bomDetails = [];
  @track filteredBomDetails = [];
  changesMade = false;
  @track isButtonDisabled = true;
  columns = [
    { label: 'Component Name', fieldName: 'componentName', type: 'text' },
    { label: 'Quantity', fieldName: 'quantity', type: 'number' },
    { label: 'On Hand', fieldName: 'onHand', type: 'number' },
    { label: 'Reserved SO', fieldName: 'reservedSO', type: 'number' },
    { label: 'Awaiting Qty', fieldName: 'awaitingQty', type: 'number' },
    { label: 'Issued WIP', fieldName: 'issuedWIP', type: 'number' },
    { label: 'Demand Sales', fieldName: 'demandSales', type: 'number' },
    { label: 'Demand MO', fieldName: 'demandMO', type: 'number' },
    { label: 'Ordered Qty', fieldName: 'orderedQty', type: 'number' },
  ];
  isLoading = false;
  @track showBOM = false;

  @track demandMOData = {}
  @track demandSalesData = {}
  @track demandValues = {};
  @track showReorderSection = false;
  @track createReorderModal = false;
  @track selectedProductName = '';
  @track rrId = '';
  @track selectedProduct = '';
  @track vendor = { Id: '', Name: '' };
  @track leadtime = 0;
  @track orderingQty = 0;
  @track routingFilter = '';
  @track routing = { Id: '', Name: '' };
  @track routingSelected = false;
  @track routingUrl = '';
  @track vendorUrl = '';
  @track venderSelected = false;
  @track warning = 1;
  @track showReorder = '';
  @track MRPList = [];
  @track MRPProdIds = [];
  @track MPSIdList = [];
  @track mrpUrl = '';
  @track selectedMRPs = [];
  @track mrpSelected = false;
  @track disablePrevlast = false;
  @track disableNextlast = false;
  @track CurrentInv = 0;
  @api recordId;
  @track isLoading = false;
  @track showTab1 = true;
  @track showTab2 = false;
  @track showTab3 = false;
  @track showMRPCreationPage = false;
  @track ForecastBy = 'Monthly';
  @track ForecastType = 'Sales';
  @track Inventorylist = [];
  @track tab3pageSize = 100;
  @track tab3pageNumber = 1;
  @track tab3totalRecords = 0;
  @track tab3totalPages = 0;
  @track tab3recordEnd = 0;
  @track tab2recordStart = 0;
  @track tab31recordEnd = 0;
  @track tab1totalRecords = 0;
  @track tab3recordStart = 0;
  @track tab3isPrev = true;
  @track tab3isNext = true;
  @track showModaltab1 = false;
  //@track pageSize = 50;
  @track pageNumber = 1;
  @track totalRecords = 0;
  @track totalPages = 0;
  @track recordEnd = 0;
  @track recordStart = 0;
  @track isPrev = true;
  @track isNext = true;
  @track site = '';
  @track siteSelected = false;
  @track siteUrl = '';
  @track searchKey = '';
  @track family = '';
  @track subFamily = '';
  @track batchSelected = false;
  @track batchUrl = '';
  @track batch = '';
  @track searchVal2 = '';
  @track serial = '';
  @track serialSelected = false;
  @track serialUrl = '';
  @track trackList = [];
  @track Product = { Id: '', Name: '', ERP7__Lot_Tracked__c: false, ERP7__Serialise__c: false };
  @track serialQry = '';
  @track batchQry = '';
  @track productSelected = false;
  @track productUrl = '';
  @track SortOrder = 'ASC';
  @track inStock = 0;
  @track reservedforMO = 0;
  @track reservedforSO = 0;
  @track qualityCheck = 0;
  @track awaitingStock = 0;
  @track showPagination = false;
  @track soldStocks = 0;
  @track purchasedItems = 0;
  @track selectedDate;
  @track toDate;
  @track index = 0;
  @track site2 = '';
  @track site2Url = '';
  @track site2Selected = false;
  @track pageSize = 100;
  @track dateisSet = false;
  familylt;
  subFamilylst;
  @track toTab2Date;
  @track fromtab1Date;
  @track ForecastStartDate;
  @track ForecastToDate;
  @track forecastTypeOptions = [];
  @track forecastByOptions = [];
  @track forecastProduct = '';
  @track forecastData = [];
  @track tableHeaders = [];
  @track dontSetProduct = false;
  @track showModal = false;
  @track modalTitle = '';
  @track modalData = [];
  @track MRP = { Id: '', Name: '', ERP7__Algorithm__c: '', ERP7__Simulate__c: false, ERP7__To_Date__c: '', ERP7__From_Date__c: '', ERP7__Site__c: '', ERP7__Site__r: { Id: '', Name: '' } }
  @track showProductsList = false;
  @track algorithms = [];
  @track suggestedOrder;
  @track reorderToCreate = { Id: null, Name: '', ERP7__Lead_Time__c: 0, ERP7__MinimumOrderingQuantity__c: 0, ERP7__Warning_Quantity__c: 0, ERP7__Vendor_Account__c: '', ERP7__Vendor_Account__r: { Id: '', Name: '' }, ERP7__Routing__c: '', ERP7__Routing__r: { Id: '', Name: '' }, ERP7__Minimum_Quantity__c: 0, ERP7__Maximum_Quantity__c: '' };
  // for family and sub family dependency
  picklistValuesObj;
  filterOptions = [
    { label: 'None', value: 'None' },
    { label: 'Demand Sales', value: 'high_demand_sales' },
    { label: 'Open Purchase Orders', value: 'only_open_pos' },
    { label: 'Open Manufacturing Orders', value: 'only_open_mos' },
    { label: 'Low Stock On Hand', value: 'low_stock_on_hand' },
    { label: 'Reserved Stock (SO)', value: 'high_reserved_stock' },
    { label: 'QC Hold', value: 'high_qc_hold' },
    { label: 'Awaiting Large Quantities', value: 'awaiting_large_quantities' },
    { label: 'IC Transfer Pending', value: 'ic_transfer_pending' },
    { label: 'High Issued or WIP', value: 'high_issued_wip' },
    { label: 'Excess Inventory', value: 'excess_inventory' },
    { label: 'Production Required', value: 'critical_production_required' }
  ];

  get displayedTracks() {
    return this.trackList.slice(this.index, this.index + this.pageSize);
  }
  get SelectedMRPsExists() {
    if (this.selectedMRPs.length > 0) {
      return true;
    } else false;
  }
  get enableCreateNewReorders() {
    if (this.rrId != null && this.rrId != '' && this.rrId != undefined) {
      return true;
    } else false;
  }
  get showTab3Pagination() {
    if (this.forecastData.length > 50) {
      return true;
    } else false;
  }
  @wire(getObjectInfo, { objectApiName: Product_OBJECT }) prodInfo;
  @wire(getPicklists)
  wiredContacts({ error, data }) {
    if (data) {
      this.isLoading = true;
      //this.familylt = data.family;
      this.algorithms = data.algorithm;
      // this.subFamilylst = data.Subfamily;
      console.log('data : ', data);
      this.site = { Id: data.site.Id, Name: data.site.Name };
      this.siteUrl = '/' + this.site.Id;
      console.log('this.site : ', JSON.stringify(this.site));
      this.siteSelected = true;

      // this.toDate = toDate;
      // console.log('this.toDate : ',this.toDate);
      let options = [];
      options.push({ label: 'Monthly', value: 'Monthly' });
      options.push({ label: 'Quarterly', value: 'Quarterly' });
      this.forecastByOptions = options;

      let typeOptions = [];
      typeOptions.push({ label: 'Sales', value: 'Sales' });
      typeOptions.push({ label: 'Production/Supply', value: 'Production/Supply' });
      this.forecastTypeOptions = typeOptions;

      this.isLoading = false;
      return refreshApex(this.site);
      //this.site = data.site;
    } else if (error) {
      this.isLoading = false;
      this.dispatchEvent(
        new ShowToastEvent({
          message: error.body.message + ' ' + error.stack + ' ' + error.name,
          variant: "error"
        })
      );
    }
  }
  @wire(getPicklistValuesByRecordType, { objectApiName: 'Product2', recordTypeId: '$prodInfo.data.defaultRecordTypeId' })
  newPicklistValues({ error, data }) {
    if (data) {
      //this.error = null;
      this.picklistValuesObj = data.picklistFieldValues;
      console.log('data returned' + JSON.stringify(data.picklistFieldValues));
      let familyValueslist = data.picklistFieldValues.Family.values;
      let familyValues = [];
      //Iterate the picklist values for the car name field
      for (let i = 0; i < familyValueslist.length; i++) {
        familyValues.push({
          label: familyValueslist[i].label,
          value: familyValueslist[i].value
        });
      }
      this.familylt = familyValues;
      console.log('data car values' + JSON.stringify(this.familylt));
    }
    else if (error) {
      //this.error = JSON.stringify(error);
      console.log(JSON.stringify(error));
    }
  }
  renderedCallback() {

    Promise.all([
      loadScript(this, jQuery + '/js/jquery_3.5.0.min.js'),
      loadStyle(this, bootStrap + '/css/bootstrap-4.1.css'),
      loadStyle(this, BankReconcile + '/css/font-awesome.css'),
      //loadStyle(this, SLDS + '/assets/styles/salesforce-lightning-design-system-vf.min.css'),
      //loadStyle(this, SLDS + '/assets/styles/salesforce-lightning-design-system-vf.css'),
      loadStyle(this, ProjectWorkbench + '/css/main-style.css'),
    ])
      .then(() => {
        console.log('Files loaded.');
      })
      .catch(error => {
        console.log(error.body.message);
      });
  }
  connectedCallback() {
    var today = new Date();
    var fromDate = new Date(today.getFullYear(), 0, 1);
    fromDate = fromDate.getFullYear() + '-' + ('0' + (fromDate.getMonth() + 1)).slice(-2) + '-' + ('0' + fromDate.getDate()).slice(-2);
    console.log('fromDate : ' + fromDate);
    this.fromtab1Date = fromDate;

    // this.selectedDate = fromDate;
    var toDate = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
    console.log('toDate : ', toDate);
    this.toTab2Date = toDate;
    this.getbyDate();
    // if (this.fromtab1Date != null && this.fromtab1Date != '' && this.fromtab1Date != undefined && this.toTab2Date != null && this.toTab2Date != '' && this.toTab2Date != undefined) this.getbyDate();
    //else this.getInventorydata();
  }
  updateDemandMOForBOM() {
    this.selectedMRPs.forEach(row => {
      // Find the productId and routingId from the reorder list
      const productId = row.prod.Id;
      const routingId = row.routingId;  // Assuming routingId is part of the selected MRP row

      // Local variables to store demand values for the current product
      const loadDemandMOValue = row.demandMO || 0;
      const loadDemandSalesValue = row.demandSales || 0;

      // Store the values in the demandValues object
      this.demandValues[productId] = {
        demandMO: loadDemandMOValue,
        demandSales: loadDemandSalesValue
      };

      // Log the loaded values for the current product
      console.log("Loaded Demand MO: ", loadDemandMOValue);
      console.log("Loaded Demand Sales: ", loadDemandSalesValue);
      console.log(this.demandValues)

      if (productId && routingId) {
        // Call fetchBOMDetails, it remains unchanged
        this.fetchBOMDetails(productId, routingId, row.prod.Name)
          .then(() => {
            // After fetching BOM details, update demandMO for the corresponding BOM data
            this.bomDetails.forEach(bom => {
              // Check if the productId in BOM details matches the current productId
              if (bom.productId === productId) {
                // Iterate through the bomData to update demandMO
                bom.bomData.forEach(bomData => {
                  // Calculate the new demandMO based on the current MRP values
                  const demandValuesForProduct = this.demandValues[productId] || { demandMO: 0, demandSales: 0 };
                  bomData.demandMO = bomData.quantity * (demandValuesForProduct.demandMO + demandValuesForProduct.demandSales);
                });
              }
            });

            // Optionally, log the updated BOM details
            console.log('Updated BOM details:', this.bomDetails);
          })
          .catch(error => {
            console.error('Error fetching BOM details:', error);
          });
      }
    });
  }
  get showInventorylist() {
    if (this.Inventorylist.length > 0) {
      return true;
    } else false;
  }
  getInventorydata() {
    this.isLoading = true;
    var index = 1;
    if (this.selectedMRPs && this.selectedMRPs.length > 0) index = (this.selectedMRPs.length + parseInt(1));
    console.log(index);
    getInvnetorybyDate({ searchstr: this.searchKey, family: this.family, subfamily: this.subFamily, selectedSite: this.site.Id, pageSize: this.pageSize, pageNumber: this.pageNumber, fromDate: this.fromtab1Date, toDate: this.toTab2Date })
        .then(result => {
          console.log('result : ', result);
          if (result) {
            console.log('getInvnetorybyDate : ', result);
            this.Inventorylist = result.Prodwrap;
            this.pageNumber = result.pageNumber;
            this.totalRecords = result.totalRecords;
            this.recordStart = result.recordStart;
            this.recordEnd = result.recordEnd;
            this.totalPages = Math.ceil(result.totalRecords / this.pageSize);
            this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
            this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
            this.isLoading = false;
          }
        })
        .catch(error => {
          this.isLoading = false;
          this.dispatchEvent(
            new ShowToastEvent({
              message: error.body.message + ' ' + error.stack + ' ' + error.name,
              variant: "error"
            })
          );
        });
   /* getInventoryDetails({ searchstr: this.searchKey, family: this.family, subfamily: this.subFamily, selectedSite: this.site.Id, pageSize: this.pageSize, pageNumber: this.pageNumber, ind: index })
      .then(result => {
        if (result) {
          this.isLoading = false;
          this.Inventorylist = result.Prodwrap;
          this.pageNumber = result.pageNumber;
          this.totalRecords = result.totalRecords;
          this.recordStart = result.recordStart;
          this.recordEnd = result.recordEnd;
          this.totalPages = Math.ceil(result.totalRecords / this.pageSize);
          this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
          this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
        }
      })
      .catch(error => {
        this.isLoading = false;
        this.dispatchEvent(
          new ShowToastEvent({
            message: error.body.message + ' ' + error.stack + ' ' + error.name,
            variant: "error"
          })
        );
      });*/
  }
  onSiteSel(event) {
    this.isLoading = true;
    var selectId = event.detail.Id;
    var selectName = event.detail.Name;
    console.log('selectId : ', selectId, ' NAme : ', selectName);
    this.site = { Id: selectId, Name: selectName };
    this.siteUrl = '/' + this.site.Id;
    console.log('this.DChannelId onDCSel: ', this.site);
    this.getInventorydata();
    // this.fromtab1Date = null;
    //this.toTab2Date = null;
    this.dateisSet = false;
    this.isLoading = false;
  }
  removeSelectedSite(event) {
    this.site = '';
    this.siteSelected = false;
    return refreshApex(this.site);
  }
  handleKeyChange(event) {
    this.isLoading = true;
    var searchval = '';
    if (event) {
      searchval = event.currentTarget.value;
      this.searchKey = searchval;
    }
    console.log('searchval : ', searchval);
    // if(searchval != null && searchval != undefined && searchval != ''){
    this.getbyDate();
    /*if (this.dateisSet) {
        this.getbyDate();
    }
    else this.getInventorydata();*/
    /* }
     else{
         this.dispatchEvent(
             new ShowToastEvent({
                 message: 'Please enter the value',
                 variant: "warning"
             })
         );
     }*/
    this.isLoading = false;

  }
  handleFamilyChange(event) {
    this.isLoading = true;
    var searchval = event.currentTarget.value;
    console.log('searchval : ', searchval);
    if (searchval != null && searchval != undefined && searchval != '') {
      this.family = searchval;
      let data = this.picklistValuesObj;
      let totalSubFamilyValues = data.ERP7__Product_Service_Family__c;
      let controllerValueIndex = totalSubFamilyValues.controllerValues[this.family];
      let colorPicklistValues = data.ERP7__Product_Service_Family__c.values;
      let carColorPicklists = [];
      //Iterate the picklist values for the car name field
      colorPicklistValues.forEach(key => {
        for (let i = 0; i < key.validFor.length; i++) {
          if (controllerValueIndex == key.validFor[i]) {
            carColorPicklists.push({
              label: key.label,
              value: key.value
            });
          }
        }
      })
      console.log(' data carColorPicklists' + JSON.stringify(carColorPicklists));
      if (carColorPicklists && carColorPicklists.length > 0) {
        this.subFamilylst = carColorPicklists;
      }
      this.getbyDate();
      /* if (this.dateisSet) {
           this.getbyDate();
       }
       else this.getInventorydata();*/
    }
    this.isLoading = false;
  }
  handleSubFamilyChange(event) {
    this.isLoading = true;
    var searchval = event.currentTarget.value;
    console.log('searchval : ', searchval);
    if (searchval != null && searchval != undefined && searchval != '') {
      this.subFamily = searchval;
      this.getbyDate();
      /* if (this.dateisSet) {
           this.getbyDate();
       }
       else this.getInventorydata();*/
    }
    this.isLoading = false;
  }
  handleNext() {
    this.pageNumber = this.pageNumber + 1;
    this.getbyDate();
    /* if (this.dateisSet) {
         this.getbyDate();
     }
     else this.getInventorydata();*/
  }
  handleNextlast() {
     const lastPageOffset = Math.max(0, this.totalRecords - 2000);// added by bushra
         pageSize: 2000, // added by bushra
       this.pageNumber= Math.ceil(this.totalRecords / this.pageSize), // added by bushra , if any error on handlenextlast remove this all 3 lines and uncomment below line 
    //this.pageNumber = (this.totalPages); //this.pageNumber+1;
    console.log('pagenum hiiiiiiiiiiii');
    this.getbyDate();
    /*if (this.dateisSet) {
        this.getbyDate();
    }
    else this.getInventorydata();*/
  }
  /*handleNextlast() {
   // this.isLoading = true;
    

    const lastPageOffset = Math.max(0, this.totalRecords - 2000);
    
    getInventoryDetailsbyDate({
        searchstr: this.searchKey,
        family: this.selectedFamily,
        subfamily: this.selectedSubFamily,
        selectedSite: this.selectedSite,
        pageSize: 2000, // Force return exactly 2000 records
        pageNumber: Math.ceil(this.totalRecords / this.pageSize), // Last page number
        fromDate: this.fromDate,
        toDate: this.toDate
    })
    .then(result => {
        this.wrapresult = result;
        
        // Update pagination to reflect we're viewing the last 2000 records
        this.pageNumber = Math.ceil(this.totalRecords / this.pageSize);
        this.recordStart = Math.max(1, this.totalRecords - 1999);
        this.recordEnd = this.totalRecords;
        
        this.isLoading = false;
    })
    .catch(error => {
        this.isLoading = false;
        // Handle error
    });
}*/
  handlePrev() {
    this.pageNumber = this.pageNumber - 1;
    this.getbyDate();
    /*if (this.dateisSet) {
        this.getbyDate();
    }
    else this.getInventorydata();*/
  }
  handlePrevlast() {
    this.pageNumber = 1;//this.pageNumber-1;
    this.getbyDate();
    /* if (this.dateisSet) {
         this.getbyDate();
     }
     else this.getInventorydata();*/
  }
  setpagesize(event) {
    var show = event.target.value;
    this.pageSize = show;
    console.log('page size : ', this.pageSize);
    this.getbyDate();
    /* if (this.dateisSet) {
         this.getbyDate();
     }
     else this.getInventorydata();*/
  }
  NavToRecord(event) {
    const prodId = event.target.id;
    const selectedRow = this.data.find(row => row.prod.Id === prodId);
    this.selectedProduct = selectedRow?.prod;
    var recId = event.target.id;
    if (recId.length > 18) {
      recId = recId.substring(0, 18);
    }
    var RecUrl = "/lightning/r/Product2/" + recId + "/view";
    window.open(RecUrl, '_blank');
  }
  NavRecordPO(recId) {
    this.showTab1 = false;
    this.showTab2 = true;

    //var recId = event.target.id;
    if (recId.length > 18) recId = recId.substring(0, 18);
    this.Product.Id = recId;
    this.productUrl = '/' + recId;
    this.productSelected = true;
    this.batchQry = ' ERP7__Product__c = \'' + this.Product.Id + '\'';
    this.serialQry = ' ERP7__Product__c = \'' + this.Product.Id + '\'';
    this.batch = { Id: '', Name: '' };
    this.serial = { Id: '', Name: '' };
    this.site2 = { Id: '', Name: '' };
    this.serialUrl = '';
    this.batchUrl = '';
    this.batchSelected = false;
    this.serialSelected = false;
    console.log('searchVal2 : ', this.searchVal2);
    var today = new Date();
    var fromDate = new Date(today.getFullYear(), 0, 1);
    fromDate = fromDate.getFullYear() + '-' + ('0' + (fromDate.getMonth() + 1)).slice(-2) + '-' + ('0' + fromDate.getDate()).slice(-2);
    console.log('fromDate : ' + fromDate);
    this.selectedDate = fromDate;
    var toDate = today.getFullYear() + '-' + ('0' + (today.getMonth() + 1)).slice(-2) + '-' + ('0' + today.getDate()).slice(-2);
    console.log('toDate : ', toDate);
    this.toDate = toDate;
    console.log('this.toDate : ', this.toDate);
    this.getInventoryTracking();
  }
  goback() {
    this.showTab1 = true;
    this.showTab2 = false;
    this.searchKey = '';
    //this.site2Selected = false;
    this.handleKeyChange();

  }
  gobacktab1() {
    this.showTab1 = false;
    this.showTab2 = false;
    this.showTab3 = false;
    this.forecastProduct = '';
    this.showMRPCreationPage = true;
  }
  searchTa2(event) {
    var searchval = event.target.value;
    console.log('searchval : ', searchval);
    this.searchVal2 = searchval;
  }
  onBatchChange(event) {
    this.isLoading = true;
    var selectId = event.detail.Id;
    var selectName = event.detail.Name;
    console.log('selectId : ', selectId, ' NAme : ', selectName);
    this.batch = { Id: selectId, Name: selectName };
    this.batchUrl = '/' + this.batch.Id;
    this.batchSelected = true;
    this.getInventoryTracking();
    // this.isLoading = false;
  }
  removeBatch(event) {
    this.batch = '';
    this.batchSelected = false;
    this.getInventoryTracking();
    return refreshApex(this.batch);
  }
  onSerialChange(event) {
    this.isLoading = true;
    var selectId = event.detail.Id;
    var selectName = event.detail.Name;
    console.log('selectId : ', selectId, ' NAme : ', selectName);
    this.serial = { Id: selectId, Name: selectName };
    this.serialUrl = '/' + this.serial.Id;
    this.serialSelected = true;
    this.getInventoryTracking();
    //this.isLoading = false;
  }
  removeSerial(event) {
    this.serial = '';
    this.serialSelected = false;
    return refreshApex(this.serial);
  }
  removeProduct(event) {
    this.Product = '';
    this.productSelected = false;
    return refreshApex(this.Product);
  }
  onProductChange(event) {
    this.isLoading = true;
    var selectId = event.detail.Id;
    var selectName = event.detail.Name;
    console.log('selectId : ', selectId, ' NAme : ', selectName);
    this.Product = { Id: selectId, Name: selectName };
    this.productUrl = '/' + this.Product.Id;
    this.productSelected = true;
    this.batchQry = ' ERP7__Product__c = \'' + this.Product.Id + '\'';
    this.serialQry = ' ERP7__Product__c = \'' + this.Product.Id + '\'';
    this.getInventoryTracking();
    //this.isLoading = false;
  }
  onSiteChange2(event) {
    this.isLoading = true;
    var selectId = event.detail.Id;
    var selectName = event.detail.Name;
    console.log('selectId : ', selectId, ' NAme : ', selectName);
    this.site2 = { Id: selectId, Name: selectName };
    this.site2Url = '/' + this.Product.Id;
    this.site2Selected = true;
    this.getInventoryTracking();
  }
  removeSite2(event) {
    this.site2 = '';
    this.site2Selected = false;
    this.getInventoryTracking();
    return refreshApex(this.site2);

  }
  getInventoryTracking() {
    this.isLoading = true;
    getInvnetoryTrace({ productId: this.Product.Id, Lotnumber: this.batch.Id, SerialNumber: this.serial.Id, searchval: this.searchVal2, site: this.site2.Id, fromselDate: this.selectedDate, toSelDate: this.toDate })
      .then(result => {
        if (result) {
          console.log('getInvnetoryTrace : ', result);
           this.totalRecords = result.totalRecords;
          this.recordStart = result.recordStart;
          this.recordEnd = result.recordEnd;
          this.trackList = result.tracklst;
          this.Product = result.prod;
          this.inStock = result.onHand;
          this.CurrentInv = result.currentStock;
          this.reservedforSO = result.reservedSO;
          this.reservedforMO = result.reservedMO;
          this.qualityCheck = result.QC;
          this.awaitingStock = result.orderedQty;
          this.soldStocks = result.soldStocks;
          this.purchasedItems = result.purchasedItems;
          if (this.trackList.length > 500) this.showPagination = true;
          else this.showPagination = false;
          console.log('this.showPagination  : ', this.showPagination);
          this.isLoading = false;
        }
      })
      .catch(error => {
        this.isLoading = false;
        this.dispatchEvent(
          new ShowToastEvent({
            message: error.body.message + ' ' + error.stack + ' ' + error.name,
            variant: "error"
          })
        );
      });
  }
  getSortedRecords() {
    console.log('getSortedRecords called');
    this.isLoading = true;
    // Toggle sort order
    this.SortOrder = (this.SortOrder === 'ASC') ? 'DESC' : 'ASC';

    // Sort records based on dispositionDate
    this.trackList.sort((a, b) => {
      // Parse dates from strings
      let dateA = new Date(a.dispositionDate);
      let dateB = new Date(b.dispositionDate);

      // Compare dates based on sort order
      if (this.SortOrder === 'ASC') {
        return dateA.getTime() - dateB.getTime();
      } else {
        return dateB.getTime() - dateA.getTime();
      }
    });
    this.isLoading = false;
    return refreshApex(this.trackList);
  }
  get isFirstPage() {
    return this.index === 0;
  }

  get isLastPage() {
    return this.index + this.pageSize >= this.trackList.length;
  }
  get totalRecords() {
    return this.trackList.length;
  }
  previousPage() {
    if (!this.isFirstPage) {
      this.index -= this.pageSize;
    }
  }

  nextPage() {
    if (!this.isLastPage) {
      this.index += this.pageSize;
    }
  }
  goToStockTransfer() {
    this.isLoading = true;
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: '/apex/ERP7__StockTransferVF?siteId=' + this.site.Id,
        target: '_blank'
      }
    });
    this.isLoading = false;
  }
  goToStockTake() {
    this.isLoading = true;
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: '/apex/ERP7__Create_stock_Take',
        target: '_blank'
      }
    });
    this.isLoading = false;
  }
  changeHandler(event) {
    console.log('change handler called');
    const prodId = event.currentTarget.dataset.id;
    console.log('prodId:', prodId);
    this.recordId = prodId;
    let labelval = event.detail.value;
    console.log('labelval : ', labelval);
    let suggestedQty = parseFloat(event.currentTarget.dataset.index);
    suggestedQty = Math.ceil(suggestedQty);
    console.log('suggestedQty : ', suggestedQty);
    if (prodId != null && prodId != '' && prodId != undefined) {
      this.isLoading = true;
      if (labelval === 'Create Purchase Order') {
        console.log('in here');
        this[NavigationMixin.Navigate]({
          type: "standard__webPage",
          attributes: {
            url: '/apex/ERP7__CreatePurchaseOrderLC?prodId=' + this.recordId + '&suggestedqty=' + suggestedQty,
            target: '_blank'
          }
        });
        this.isLoading = false;
      }
      else if (labelval === 'Create Manufacturing Order') {
        console.log('in here');
        this[NavigationMixin.Navigate]({
          type: "standard__webPage",
          attributes: {
            url: '/apex/ERP7__MOScheulerVF?prodId=' + this.recordId + '&suggestedqty=' + suggestedQty,
            target: '_blank'
          }
        });
        this.isLoading = false;
      }
      else if (labelval === 'Create Transfer Order') {
        console.log('in here');
        this[NavigationMixin.Navigate]({
          type: "standard__webPage",
          attributes: {
            url: '/apex/ERP7__CreateTransferOrderLC?prodId=' + this.recordId,
            target: '_blank'
          }
        });
        this.isLoading = false;
      }
      else if (labelval === 'Stock Transfer') {
        console.log('in here');
        this[NavigationMixin.Navigate]({
          type: "standard__webPage",
          attributes: {
            url: '/apex/ERP7__StockTransferVF?prodId=' + this.recordId + '&siteId=' + this.site.Id,
            target: '_blank'
          }
        });
        this.isLoading = false;
      }
      else if (labelval === 'Stock Take') {
        console.log('in here');
        this[NavigationMixin.Navigate]({
          type: "standard__webPage",
          attributes: {
            url: '/apex/ERP7__Create_stock_Take?prodId=' + this.recordId,
            target: '_blank'
          }
        });
        this.isLoading = false;
      }
      else if (labelval === 'Forecast') {
        this.forecastProduct = prodId;
        this.displayForecastbyProduct(event);
      }
      else if (labelval == 'History Tracking') {
        this.NavRecordPO(prodId);
      }
      else if (labelval == 'View BOM Details') {
        const name = event.currentTarget.dataset.name;
        const encodedName = encodeURIComponent(name);
        console.log('REPORT_URL : ', REPORT_URL);
        const reportUrl = `${REPORT_URL}?fv2=${encodedName}`;
        console.log('reportUrl : ', reportUrl);
        window.open(reportUrl, '_blank');
        this.isLoading = false;
      }


    }

  }
  getfromDateInventory(event) {
    let selectedDate = event.currentTarget.value;
    console.log('selectedDate : ', selectedDate);
    this.fromtab1Date = selectedDate;
    if (selectedDate) {
      this.dateisSet = true;
      console.log('in 1');
      this.getbyDate();
    }
    else {
      this.dateisSet = false;
      console.log('else 1');
      this.getInventorydata();
    }
  }
  getToDateInventory(event) {
    let selectedDate = event.currentTarget.value;
    console.log('selectedDate : ', selectedDate);
    this.toTab2Date = selectedDate;
    if (selectedDate) {
      this.dateisSet = true;
      console.log('in 2');
      this.getbyDate();
    }
    else {
      this.dateisSet = false;
      console.log('else 2');
      this.getInventorydata();
    }
  }
  onDateChange(event) {
    this.isLoading = true;
    var selectdate = event.currentTarget.value;
    console.log('selectdate : ', selectdate);
    this.selectedDate = selectdate;
    this.getInventoryTracking();
    //this.isLoading = false;
  }
  toDateChange(event) {
    this.isLoading = true;
    var selectdate = event.currentTarget.value;
    console.log('selectdate : ', selectdate);
    this.toDate = selectdate;
    this.getInventoryTracking();
    //this.isLoading = false;
  }
  getbyDate() {
    try {
      console.log('getbyDate called');
      this.isLoading = true;
      getInvnetorybyDate({ searchstr: this.searchKey, family: this.family, subfamily: this.subFamily, selectedSite: this.site.Id, pageSize: this.pageSize, pageNumber: this.pageNumber, fromDate: this.fromtab1Date, toDate: this.toTab2Date })
        .then(result => {
          console.log('result : ', result);
          if (result) {
            console.log('getInvnetorybyDate : ', result);
            this.Inventorylist = result.Prodwrap;
            this.pageNumber = result.pageNumber;
            this.totalRecords = result.totalRecords;
            this.recordStart = result.recordStart;
            this.recordEnd = result.recordEnd;
            this.totalPages = Math.ceil(result.totalRecords / this.pageSize);
            this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
            this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
            this.isLoading = false;
          }
        })
        .catch(error => {
          this.isLoading = false;
          this.dispatchEvent(
            new ShowToastEvent({
              message: error.body.message + ' ' + error.stack + ' ' + error.name,
              variant: "error"
            })
          );
        });
    }
    catch (e) {
      console.log('error : ', JSON.stringify(e));
    }
  }
  displayForecastbyProduct(event) {
    /*  if(this.dontSetProduct == false){
          var prodId = event.target.name;
          console.log('prodId : ',prodId);
          this.forecastProduct = prodId;
      }*/

    if (this.forecastProduct) {
      this.isLoading = true;
      this.showTab3 = true;
      this.showTab1 = false;
      this.showTab2 = false;
      var today = new Date();
      var toDate = today.getFullYear() + '-12-31';
      console.log('toDate forecast : ', toDate);
      if (this.ForecastStartDate == undefined || this.ForecastStartDate == null || this.ForecastStartDate == '') this.ForecastStartDate = this.fromtab1Date;
      if (this.ForecastToDate == undefined || this.ForecastToDate == null || this.ForecastToDate == '') this.ForecastToDate = toDate;
      getforecastByProduct({ productId: this.forecastProduct, forecastval: this.ForecastBy, forecastTypeval: this.ForecastType, fromDate: this.ForecastStartDate, toDate: this.ForecastToDate })
        .then(result => {
          console.log('result : ', result);
          if (result) {
            this.forecastData = [];
            this.forecastData[0] = result;/*{
                            productId: result.productId,
                            productCode: result.productCode,
                            productName: result.productName,
                            quantity: result.quantity,
                            orderWarp : result.orderWarp,
                            monthQuantitiesArray:Object.entries(result.monthQuantities || {}).map(([key, value]) => ({
                                monthKey: key,
                                monthValue: value,
                                userPredictedValue : 0,
                                FPA : 0
                            }))
                        };*/
            const monthQuantitiesMap = result.monthQuantities || {};
            this.tableHeaders = monthQuantitiesMap; //Object.entries(monthQuantitiesMap).map(([key, value]) => ({ label: key, value: value }));

            console.log('Forecast Data:', JSON.stringify(this.forecastData));
            console.log('Table Headers:', JSON.stringify(this.tableHeaders));
            this.isLoading = false;
            this.dontSetProduct = false;
          }
          else {
            this.isLoading = false;
            console.log('error occurred');
          }
        })
        .catch(error => {
          this.isLoading = false;
          console.log('error : ', error);
          /*this.dispatchEvent(
              new ShowToastEvent({
                 message: error.body.message+' '+error.stack +' '+error.name,
                 variant: "error"
          })
         );*/
        });
    }
  }
  displayForecast() {
    this.isLoading = true;
    this.showTab3 = true;
    this.showTab1 = false;
    this.showTab2 = false;
    var today = new Date();
    var toDate = today.getFullYear() + '-12-31';
    console.log('toDate forecast : ', toDate);

    if (this.ForecastStartDate == undefined || this.ForecastStartDate == null || this.ForecastStartDate == '') this.ForecastStartDate = (this.MRP.ERP7__From_Date__c) ? this.MRP.ERP7__From_Date__c : this.fromtab1Date;
    if (this.ForecastToDate == undefined || this.ForecastToDate == null || this.ForecastToDate == '') this.ForecastToDate = (this.MRP.ERP7__To_Date__c) ? this.MRP.ERP7__To_Date__c : toDate;
    getforecast({ forecastval: this.ForecastBy, forecastTypeval: this.ForecastType, fromDate: this.ForecastStartDate, toDate: this.ForecastToDate, pageSize: this.tab3pageSize, pageNumber: this.tab3pageNumber, ProdIds: this.MRPProdIds })
      .then(result => {
        console.log('result : ', result);
        if (result) {
          this.tab3pageNumber = result.pageNumber;
          this.tab3totalRecords = result.totalRecords;
          this.tab3recordStart = result.recordStart;
          this.tab3recordEnd = result.recordEnd;
          this.tab3totalPages = Math.ceil(result.totalRecords / this.tab3pageSize);
          this.tab3isNext = (this.tab3pageNumber == this.tab3totalPages || this.tab3totalPages == 0);
          this.tab3isPrev = (this.tab3pageNumber == 1 || this.tab3totalRecords < this.tab3pageSize);
          this.forecastData = result.ForecastWrap; /* result.ForecastWrap.map(item =>{
                            return {
                                ...item,
                                monthQuantitiesArray: Object.entries(item.monthQuantities || {}).map(([key, value]) => ({
                                    monthKey: key,
                                    monthValue: value,
                                    userPredictedValue : 0,
                                    FPA : 0
                                }))
                            };
                        });*/
          const monthQuantitiesMap = result.ForecastWrap[0].monthQuantities || {};

          this.tableHeaders = monthQuantitiesMap; //Object.entries(monthQuantitiesMap).map(([key]) => ({ label: key }));

          console.log('Forecast Data:', JSON.stringify(this.forecastData));
          console.log('Table Headers:', JSON.stringify(this.tableHeaders));
          this.isLoading = false;

        }
        else {
          this.isLoading = false;
          console.log('error occurred');
        }
      })
      .catch(error => {
        this.isLoading = false;
        console.log('error : ', error);
        /*this.dispatchEvent(
            new ShowToastEvent({
               message: error.body.message+' '+error.stack +' '+error.name,
               variant: "error"
        })
       );*/
      });
  }
  handleForecastByChange(event) {
    var selectedValue = event.target.value;
    this.ForecastBy = selectedValue;
    console.log('Product selected :', this.forecastProduct);

    this.getForecatsforMRPS();
    /* if (this.forecastProduct) {
         this.dontSetProduct = true;
         this.displayForecastbyProduct(event);
     }
     else {
         this.displayForecast();
     }*/

  }
  handleForecastTypeChange(event) {
    var selectedValue = event.target.value;
    this.ForecastType = selectedValue;
    console.log('Product selected :', this.forecastProduct);

    this.getForecatsforMRPS();
    /*if (this.forecastProduct) {
        this.dontSetProduct = true;
        this.displayForecastbyProduct(event);
    }
    else {
        this.displayForecast();
    }*/

  }
  handleFromDateChange(event) {
    var selectedValue = event.target.value;
    this.ForecastStartDate = selectedValue;
    console.log('Product selected :', this.forecastProduct);
    this.getForecatsforMRPS();
    /*
    if (this.forecastProduct) {
        this.dontSetProduct = true;
        this.displayForecastbyProduct(event);
    }
    else {
        this.displayForecast();
    }*/

  }
  handleToDateChange(event) {
    var selectedValue = event.target.value;
    this.ForecastToDate = selectedValue;
    console.log('Product selected :', this.forecastProduct);
    this.getForecatsforMRPS();
    /*if (this.forecastProduct) {
        this.dontSetProduct = true;
        this.displayForecastbyProduct(event);
    }
    else {
        this.displayForecast();
    }*/

  }
  openModal(event) {
    var index = event.target.dataset.name;
    console.log('index : ', index);
    var qty = event.target.value;
    console.log('qty : ', qty);
    var prodId = event.target.dataset.id; // Retrieve productId from dataset
    console.log('prodId : ', prodId);
    var keyval = event.target.dataset.key; // Retrieve monthKey from dataset
    console.log('keyval : ', keyval);
    if (keyval != 'Predicted Average' && qty > 0) {
      this.showModal = true;
      this.modalData = [];
      if (this.ForecastType == 'Sales') this.modalTitle = 'Sales Orders Detail';
      else this.modalTitle = 'Purchase/Manufacturing Orders Detail';
      var ordelst = this.forecastData[index].orderWarp;
      console.log('ordelst : ', JSON.stringify(ordelst));
      // Iterate over the object entries to find the specific details
      for (const [key, value] of Object.entries(ordelst)) {
        console.log('key loop : ', key);
        if (key == keyval) {
          // Store the specific details in modalData
          this.modalData = value;
          break; // Stop the loop once the specific details are found
        }
      }
      console.log('modalData : ', JSON.stringify(this.modalData));
    }
  }

  closeModal() {
    this.showModal = false;

  }
  calcualteFPA(event) {
    var index = event.target.dataset.name;
    console.log('index : ', index);
    var ind = event.target.dataset.index;
    console.log('ind:', ind);
    var value = event.target.value;
    console.log('value:', value);
    var monthkey = event.target.dataset.key;
    console.log('monthkey:', monthkey);
    if (ind != null && ind != '' && ind != undefined && value > 0) {
      var ordelst = this.forecastData[index].MPSlineitems;
      console.log('ordelst : ', JSON.stringify(ordelst));
      // Iterate over the object entries to find the specific details
      if (ordelst && ordelst.length > ind) {
        ordelst[ind].ERP7__Demand_Forecast__c = parseFloat(value); // Convert to number
        var actual = parseFloat(ordelst[ind].ERP7__Actual_Demand__c); // Convert to number
        console.log('actual:', actual);
        var userInput = parseFloat(ordelst[ind].ERP7__Demand_Forecast__c); // Convert to number
        console.log('userInput:', userInput);

        var FPA = (actual > 0 && userInput > 0) ? (actual / userInput) * 100 : 0; // Calculate FPA
        var limitedFPA = this.limitToRange(FPA, 1, 100);
        console.log('limitedFPA:', limitedFPA);
        ordelst[ind].ERP7__FPA__c = limitedFPA; // Assign to FPA property
        console.log('ordelst[ind] : ', JSON.stringify(ordelst[ind]));
        // Set the updated monthQuantitiesArray back to forecastData
        this.forecastData[index].MPSlineitems = ordelst;
        return refreshApex(this.forecastData[index]);
      } else {
        console.error('Invalid index or monthQuantitiesArray is undefined.');
      }
    }

  }
  handleNexttab3() {
    this.tab3pageNumber = this.tab3pageNumber + 1;
    this.displayForecast();
  }
  handlePrevtab3() {
    this.tab3pageNumber = this.tab3pageNumber - 1;
    this.displayForecast();
  }
  handlePrevlasttab3() {
    this.tab3pageNumber = 1;
    this.displayForecast();
  }
  handleNextlasttab3() {
    this.tab3pageNumber = this.tab3totalPages;
    this.displayForecast();
  }
  setpagesizetab3(event) {
    var show = event.target.value;
    this.tab3pageSize = show;
    this.displayForecast();
  }
   setpagesizetab34(event) {
    var show = event.target.value;
    this.tab3pageSize = show;
    this.NavRecordPO();
  }
  limitToRange(value, min, max) {
    return Math.min(Math.max(value, min), max);
  }
  createForecasts() {
    this.isLoading = true;
    let MRPItems = this.MRPList;
    for (var x in this.forecastData) {
      for (var y in MRPItems) {
        MRPItems[y].ERP7__Forecast_Type__c = this.ForecastType;
        MRPItems[y].ERP7__Schedule_Period__c = this.ForecastBy;
        if (MRPItems[y].ERP7__Product__c == this.forecastData[x].productId) {
          for (var z in this.forecastData[x].MPSlineitems) {
            this.forecastData[x].MPSlineitems[z].ERP7__MPS__c = MRPItems[y].Id;
          }
        }
      }
    }
    console.log('forecastData : ', JSON.stringify(this.forecastData));


    saveForecasts({ ForecastWraplist: JSON.stringify(this.forecastData), MRPId: this.MRP.Id, MRPItems: JSON.stringify(MRPItems) })
      .then(result => {
        console.log('result : ', result);
        if (result) {
          this.isLoading = false;
          this.disableForecastSave = true;
          var recId = this.MRP.Id;
         var RecUrl = "/lightning/r/ERP7__Material_Requirement_Planning__c/" + recId + "/view";
          window.open(RecUrl, '_self');
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Forecast and MRPs created successfully!',
              variant: "success",
              title: 'Success'
            })
          );
        }
        else {
          this.isLoading = false;
          this.disableForecastSave = false;
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Problem in Update of forecast. Retry!',
              variant: "error",
              title: 'error'
            })
          );
        }
      })
      .catch(error => {
        this.isLoading = false;
        console.log('error : ', error);

      });
  }
  displayMRPCreationPage() {
    try {
      this.isLoading = true;
      this.showMRPCreationPage = true;
      this.showTab1 = false;
      this.MRP.ERP7__From_Date__c = this.fromtab1Date;
      this.MRP.ERP7__To_Date__c = this.toTab2Date;
      this.MRP.ERP7__Site__c = this.site.Id;
      this.MRP.ERP7__Site__r.Id = this.site.Id;
      this.MRP.ERP7__Site__r.Name = this.site.Name;
      this.MRP.Name = 'Material Requirement Planning';
      this.siteUrl = '/' + this.MRP.ERP7__Site__c;
      this.siteSelected = true;
      this.isLoading = false;
    }
    catch (e) {
      console.log('error : ', e);
    }

  }
  setMRPFromdate(event) {
    this.MRP.ERP7__From_Date__c = event.target.value;
  }

  setMRPTodate(event) {
    this.MRP.ERP7__To_Date__c = event.target.value;
  }
  onMRPSiteSel(event) {
    this.isLoading = true;
    var selectId = event.detail.Id;
    var selectName = event.detail.Name;
    console.log('selectId : ', selectId, ' NAme : ', selectName);
    this.MRP.ERP7__Site__r = { Id: selectId, Name: selectName };
    this.MRP.ERP7__Site__c = selectId;
    this.siteUrl = '/' + this.MRP.ERP7__Site__c;
    console.log('onMRPSiteSel : ', this.MRP.ERP7__Site__c);
    this.isLoading = false;
  }
  removeMRPSelectedSite(event) {
    this.MRP.ERP7__Site__c = '';
    this.MRP.ERP7__Site__r = { Id: '', Name: '' };
    this.siteSelected = false;
    return refreshApex(this.MRP.ERP7__Site__c);
  }
  showAddProducts() {
    this.Inventorylist = '';
    this.showProductsList = true;
    this.showMRPCreationPage = false;
    this.isLoading = true;
    this.pageNumber = 1;
    this.pageSize = 20;
    this.searchKey = '';
    this.family = '';
    this.subFamily = '';
    this.getInventorydata();
  }
  onMRPChange(event) {
    try {
      this.isLoading = true;
      var selectId = event.detail.Id;
      var selectName = event.detail.Name;
      this.MRP.Name = selectName;
      this.MRP.Id = selectId;
      this.mrpUrl = '/' + selectId;
      this.mrpSelected = true;
      getMRPDetails({ MRPId: this.MRP.Id }).then(result => {
        if (result && result.length > 0) {
          this.MRP = JSON.parse(result[0]);
          this.selectedMRPs = JSON.parse(result[1]);
          console.log("EDIT MRP-->", this.selectedMRPs)
          this.selectedMRPs.map(e => {
            console.log('e : ', JSON.stringify(e));
            if (e.reOrderId != null && e.reOrderId != undefined && e.reOrderId != '') {
              if (e.reorderlist) {
                e.reorderlist.map(item => {
                  console.log('in');
                  if (item.Id == e.reOrderId) {
                    item.selected = true;
                    // this.showBOM = true;
                    console.log(item.ERP7__Routing__c)
                    const routingId = item.ERP7__Routing__c
                    console.log(item.ERP7__Product__c)
                    const productId = item.ERP7__Product__c
                    const productName = item.ERP7__Product__r.Name
                    console.log(item.ERP7__Product__r.Name)
                    if (productId && routingId) {
                      this.fetchBOMDetails(productId, routingId, productName);
                    }
                    console.log("Edit Bom--->", this.bomDetails)
                  }
                  else item.selected = false;
                  if (this.MRP.ERP7__Algorithm__c == 'Fixed Order Quantity (FOQ)') {
                    item.show = (item.ERP7__MinimumOrderingQuantity__c) ? true : false;
                  }
                  else if (this.MRP.ERP7__Algorithm__c == 'Demand Driven MRP (DDMRP)') {
                    item.show = (item.ERP7__Warning_Quantity__c && item.ERP7__Minimum_Quantity__c && item.ERP7__Maximum_Quantity__c) ? true : false;
                  }
                  else if (this.MRP.ERP7__Algorithm__c == 'Min-Max System') {
                    item.show = (item.ERP7__Minimum_Quantity__c && item.ERP7__Maximum_Quantity__c) ? true : false;
                  }
                  else {
                    item.show = true;
                  }
                  console.log('in selected : ', item.show);
                })
              }
            }
          });
          this.showMRPCreationPage = true;
          if (this.MRP.ERP7__Algorithm__c != null && this.MRP.ERP7__Algorithm__c != '' && this.MRP.ERP7__Algorithm__c != undefined && this.MRP.ERP7__Algorithm__c != '--None--') this.showReorderlists = true;
          this.showTab1 = false;
        } else {
          this.isLoading = false;
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Please check the permissions!',
              variant: "error",
              title: 'error'
            })
          );
        }
      })
        .catch(error => {
          this.isLoading = false;
          console.log('error : ', error);

        });
      this.isLoading = false;
    } catch (error) {
      console.log('error : ', error);
    }

  }

  onReorderChange(event) {
    try {
      let index = parseInt(event.currentTarget.dataset.index);
      console.log('index : ', index);
      var selectId = event.detail.Id;
      console.log('event.detail.Id;', selectId);
      var selectName = event.detail.Name;
      let tempPickList = JSON.parse(JSON.stringify(this.Inventorylist));
      tempPickList.map(e => {
        if (e.index === index) {
          console.log('match');
          e.reOrderId = selectId;
          e.reorder = { Id: selectId, Name: selectName };
          e.reorderSelected = true;
        }
      });
      // console.log(tempPickList);
      this.Inventorylist = tempPickList;
      let tempSelected = JSON.parse(JSON.stringify(this.selectedMRPs));
      tempSelected.map(e => {
        if (e.index === index) {
          e.reOrderId = selectId;
          e.reorder = { Id: selectId, Name: selectName };
          e.reorderSelected = true;
        }
      });
      console.log(tempSelected);
      this.selectedMRPs = tempSelected;
    }
    catch (e) {
      console.log('reorder : ', e);
    }

  }
  handleAlgorithmChange(event) {
    try {
      let index = parseInt(event.currentTarget.dataset.index);
      let val = event.currentTarget.value;

      console.log('index : ', index);
      console.log('event.currentTarget.value : ', val);
      let tempPickList = JSON.parse(JSON.stringify(this.Inventorylist));
      tempPickList.map(e => {
        if (e.index === index) {
          e.algorithm = val;
        }
      });
      //console.log(tempPickList);
      this.Inventorylist = tempPickList;

      let tempSelected = JSON.parse(JSON.stringify(this.selectedMRPs));
      tempSelected.map(e => {
        if (e.index === index) {
          e.algorithm = val;
        }
      });
      console.log(tempSelected);
      this.selectedMRPs = tempSelected;

    }
    catch (e) {
      console.log('algo : ', e);
    }

  }
  onProductSelect(event) {
    try {
      let checkedval = event.currentTarget.checked;
      console.log('checkedval : ', checkedval);
      let index = event.currentTarget.dataset.index;
      console.log('index : ', index);
      if (checkedval) {
        let tempPickList = this.Inventorylist[index];
        console.log('tempPickList', JSON.stringify(tempPickList));
        if (!tempPickList.reorderlist) {
          tempPickList.reorderlist = [];
        }
        tempPickList.reorderlist.map(item => {
          if (!Object.isExtensible(item)) {
            item = { ...item };
          }
          // Add the 'selected' property
          item.selected = false;
        });
        console.log('temp : ', JSON.stringify(tempPickList));
        this.selectedMRPs.push(tempPickList);
      } else {
        // Find the index of the element to remove
        let removeIndex = this.selectedMRPs.findIndex(item => item === this.Inventorylist[index]);
        console.log('removeIndex : ', removeIndex);
        // If the element is found, remove it
        if (removeIndex !== -1) {
          this.selectedMRPs.splice(removeIndex, 1);
        }
      }
      console.log('selected MRP : ', JSON.stringify(this.selectedMRPs));
    } catch (error) {
      console.log(error);
    }

  }
  goToMRPCreationPage() {
    this.showProductsList = false;
    this.showMRPCreationPage = true;
  }
  addItems() {
    if (this.selectedMRPs.length > 0) {
      this.showProductsList = false;
      this.showMRPCreationPage = true;
      if (this.MRP.ERP7__Algorithm__c != '--None--' && this.MRP.ERP7__Algorithm__c != undefined && this.MRP.ERP7__Algorithm__c != '' && this.MRP.ERP7__Algorithm__c != null) {
        this.setShowReorderBasedonAlgorithm();
      }
    }
    else {
      const event = new ShowToastEvent({
        title: 'Warning!',
        variant: 'warning',
        message:
          'Please select Item to add',
      });
      this.dispatchEvent(event);
    }
  }
  async onProductDelete(event) {
    let removeIndex = event.currentTarget.dataset.index;
    let prodId = event.currentTarget.dataset.prod;
    if (this.bomDetails.length > 0 || this.showBOM == true) {
      let bomMatch = this.bomDetails.find(bomDetail => bomDetail.productId === prodId);

      console.log("Here---> ", prodId, " = ", this.bomDetails)
      // Check if productId matches and reset bomDetails
      if (bomMatch) {
        console.log("Here---> ", prodId, " = ", this.bomDetails)
        this.bomDetails.splice(removeIndex, 1);   // Clear bomDetails array
        console.log("bom cleared");
      } else {
        console.log("No BOM Yet in this product id: ", productId)
      }
    }
    console.log("Produt removed", prodId)
    console.log('removeIndex : ', removeIndex);
    let recId = event.currentTarget.dataset.id;
    console.log('recId : ', recId);
    const result = await LightningConfirm.open({
      message: 'Do you want to delete the item?',
      variant: 'headerless',
      label: 'Confirmation on delete Action',
      // setting theme would have no effect
    });
    if (result) {
      if (removeIndex !== -1) {
        this.isLoading = true;
        this.selectedMRPs.splice(removeIndex, 1);
        if (recId) {
          deleteMPsRecord({ MPSId: recId }).then(result1 => {
            if (result1) {
              console.log('rec deleted');
            }
          })
            .catch(error => {
              this.isLoading = false;
              console.log('error : ', error);

            });
        }
        this.isLoading = false;
        return refreshApex(this.selectedMRPs);
      }
    }

  }
  onSelectedReorderChange(event) {
    try {
      let index = parseInt(event.currentTarget.dataset.index);
      console.log('index : ', index);
      var selectId = event.detail.Id;
      console.log('event.detail.Id;', selectId);
      var selectName = event.detail.Name;
      let tempPickList = JSON.parse(JSON.stringify(this.selectedMRPs));
      tempPickList.map(e => {
        if (e.index === index) {
          console.log('match');
          e.reOrderId = selectId;
          e.reorder = { Id: selectId, Name: selectName };
        }
      });
      console.log(tempPickList);
      this.selectedMRPs = tempPickList;


    }
    catch (e) {
      console.log('reorder : ', e);
    }

  }
  handleSelectedAlgorithmChange(event) {
    try {
      let index = parseInt(event.currentTarget.dataset.index);
      let val = event.currentTarget.value;

      console.log('index : ', index);
      console.log('event.currentTarget.value : ', val);
      let tempPickList = JSON.parse(JSON.stringify(this.selectedMRPs));
      tempPickList.map(e => {
        if (e.index === index) {
          e.algorithm = val;

        }
      });
      console.log(tempPickList);
      this.selectedMRPs = tempPickList;
    }
    catch (e) {
      console.log('algo : ', e);
    }

  }
  setMRPName(event) {
    this.MRP.Name = event.currentTarget.value;
    console.log(this.MRP.Name)
  }
  createMRPsAndItems() {
    try {
           // if (this.isSaving) return;
    //  this.isSaving = true;
      

      this.isLoading = true;
      let MRPdetails = this.MRP;
      console.log("Name--->", MRPdetails.Name)
      if (MRPdetails.ERP7__Algorithm__c == null || MRPdetails.ERP7__Algorithm__c == '' || MRPdetails.ERP7__Algorithm__c == undefined || MRPdetails.ERP7__Algorithm__c == '--None--') {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'Algorithm is required for MRP',
            variant: "warning",
            title: 'warning'
          })
        );
        this.isLoading = false;
        return;
      }
      else if (MRPdetails.Name == null || MRPdetails.Name == '' || MRPdetails.Name == undefined) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'Name is required for MRP',
            variant: "warning",
            title: 'warning'
          })
        );
        this.isLoading = false;
        return;
      }
      else if (MRPdetails.ERP7__From_Date__c == null || MRPdetails.ERP7__From_Date__c == '' || MRPdetails.ERP7__From_Date__c == undefined) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'From Date is required for MRP',
            variant: "warning",
            title: 'warning'
          })
        );
        this.isLoading = false;
        return;
      }
      else if (MRPdetails.ERP7__To_Date__c == null || MRPdetails.ERP7__To_Date__c == '' || MRPdetails.ERP7__To_Date__c == undefined) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'To Date is required for MRP',
            variant: "warning",
            title: 'warning'
          })
        );
        this.isLoading = false;
        return;
      }
      else if (MRPdetails.ERP7__Site__r.Id == null || MRPdetails.ERP7__Site__r.Id == '' || MRPdetails.ERP7__Site__r.Id == undefined) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'Site is required for MRP',
            variant: "warning",
            title: 'warning'
          })
        );
        this.isLoading = false;
        return;
      }

 if (MRPdetails.Id && MRPdetails.Id !== '') {
          // Existing MRP - keep the ID
          console.log('Updating existing MRP with ID:', MRPdetails.Id);
      } else {
          MRPdetails.Id = null; // New MRP
          console.log('Creating new MRP');
      }
      /*var startMonth = MRPdetails.ERP7__From_Date__c.getMonth();
      console.log('startMonth : ',startMonth);
      var toMonth = MRPdetails.ERP7__To_Date__c.getMonth();
      console.log('toMonth : ',toMonth);
      // Define an array to map month numbers to month names
      var monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];

      // Construct the MRP name string
      if(MRPdetails.Name == 'Material Requirement Planning') MRPdetails.Name = 'MRP for ' + monthNames[startMonth] + ' to ' + monthNames[toMonth];
      */
      console.log('MRPdetails : ', JSON.stringify(MRPdetails));
      let selectedMRPs = this.selectedMRPs;
      let MRPItems = [];
      var prodIds = [];
      for (var x in selectedMRPs) {
        var mrpItem = {};
        if (selectedMRPs[x].reOrderId == '' || selectedMRPs[x].reOrderId == null || selectedMRPs[x].reOrderId == undefined || selectedMRPs[x].reOrderId == '--None--') {
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Please select the reordering rule for product : ' + selectedMRPs[x].prod.Name,
              variant: "warning",
              title: 'warning'
            })
          );
          this.isLoading = false;
          return;
        }
        if (selectedMRPs[x].reOrderId != '--None--') {
          mrpItem.ERP7__Reordering_Rule__c = selectedMRPs[x].reOrderId;

        }
        mrpItem.ERP7__Product__c = selectedMRPs[x].prod.Id;
        prodIds.push(selectedMRPs[x].prod.Id);
        let name = selectedMRPs[x].prod.Name;
        mrpItem.Name = (name.length >= 80) ? name.substring(0, 79) : name;
        mrpItem.ERP7__Start_Date__c = this.MRP.ERP7__From_Date__c;
        mrpItem.ERP7__End_Date__c = this.MRP.ERP7__To_Date__c;
        mrpItem.ERP7__Starting_Inventory__c = selectedMRPs[x].onHand;
        for (let productId in this.demandMOData) {
          if (productId === selectedMRPs[x].prod.Id) {
            console.log(`Match found for Product ID: ${productId}`);
            console.log(`Demand Value: ${this.demandMOData[productId]}`);
            mrpItem.ERP7__Demand_MO__c = this.demandMOData[productId]
            selectedMRPs[x].demandMO = this.demandSalesData[productId]
            console.log("mo change --> ", selectedMRPs[x].demandMO)
          } else {
            console.log(`No match for Product ID: ${productId}`);
            mrpItem.ERP7__Demand_MO__c = selectedMRPs[x].demandMO;
          }
        }
        console.log("Changed Demand MO" + mrpItem.ERP7__Demand_MO__c)
        for (let productId in this.demandSalesData) {
          if (productId === selectedMRPs[x].prod.Id) {
            console.log(`Match found for Product ID: ${productId}`);
            console.log(`Demand Value: ${this.demandSalesData[productId]}`);
            mrpItem.ERP7__Demand_Sales__c = this.demandSalesData[productId]
            selectedMRPs[x].demandSales = this.demandSalesData[productId]
            console.log("sales change --> ", selectedMRPs[x].demandSales)
          } else {
            console.log(`No match for Product ID: ${productId}`);
            mrpItem.ERP7__Demand_Sales__c = selectedMRPs[x].demandSales;
          }
        }
        console.log("Changed Demand sales" + mrpItem.ERP7__Demand_Sales__c)
        mrpItem.ERP7__Reserved_SO__c = selectedMRPs[x].reservedSO;
        mrpItem.ERP7__Issued_WIP__c = selectedMRPs[x].reservedMO;
        mrpItem.ERP7__Awaiting_Qty__c = selectedMRPs[x].orderedQty;
        mrpItem.ERP7__Default_Demand_Forecast__c = parseFloat(selectedMRPs[x].demandMO) + parseFloat(selectedMRPs[x].demandSales);
        if (selectedMRPs[x].MPSId) mrpItem.Id = selectedMRPs[x].MPSId;
        //mrpItem.ERP7__Algorithm__c = selectedMRPs[x].algorith
        let bomMatch = this.bomDetails.find(bomDetail => bomDetail.productId === selectedMRPs[x].prod.Id);
        console.log(bomMatch)

        if (bomMatch) {
          console.log("Bom Data Good")
          // You could save the BOM ID or another field
          mrpItem.ERP7__Version__c = bomMatch.bomData[0].version;  // Assuming you want to save the first BOM ID
          console.log("in", bomMatch.bomData[0].version)
          mrpItem.ERP7__Master_Production_Schedule__c = bomMatch.bomData.Id;
          console.log(bomMatch.bomData[0].Id)
        }
        MRPItems.push(mrpItem);
      }
      console.log('MRPItems : ', JSON.stringify(MRPItems));
      saveMRPS({ MRP: JSON.stringify(MRPdetails), MRPItemList: JSON.stringify(MRPItems) })
        .then(result => {
          console.log('result : ', result);
           console.log('result this one : ', result[1]);
          if (result) {
            this.isLoading = false;
            this.showMRPCreationPage = false;
            this.MRPProdIds = prodIds;
            var mpsIds = [];
            if (result.length > 0) {
              this.MRP = JSON.parse(result[0]);
              this.MRPList = JSON.parse(result[1]);
              for (var x in this.MRPList) {
                if (this.MRPList[x].Id) mpsIds.push(this.MRPList[x].Id);
              }
            }
            this.MPSIdList = mpsIds;
            if (this.MRPList[0].ERP7__Schedule_Period__c) this.ForecastBy = this.MRPList[0].ERP7__Schedule_Period__c;
            if (this.MRPList[0].ERP7__Forecast_Type__c) this.ForecastType = this.MRPList[0].ERP7__Forecast_Type__c;
            this.getForecatsforMRPS();
            this.dispatchEvent(
              new ShowToastEvent({
                message: 'MRPs is created successfully!',
                variant: "success",
                title: 'Success'
              })
            );
          }
          else {
            this.isLoading = false;
            this.dispatchEvent(
              new ShowToastEvent({
                message: 'Problem in creation of MRP. Refresh and retry!',
                variant: "error",
                title: 'error'
              })
            );
          }
        })
        .catch(error => {
          this.isLoading = false;
          console.log('error : ', error);

        });

    } catch (e) {
      console.log('err save MRPs: ', e);
    }
  }
  goToMainScreen() {
    try {
      eval("$A.get('e.force:refreshView').fire();");
    } catch (e) {
      console.log('Error:', e);
    }
  }
  getForecatsforMRPS() {
    this.isLoading = true;
    this.showTab3 = true;
    this.showTab1 = false;
    this.showTab2 = false;
    this.showMRPCreationPage = false;
    if (this.ForecastStartDate == null || this.ForecastStartDate == '' || this.ForecastStartDate == undefined) this.ForecastStartDate = this.MRP.ERP7__From_Date__c;
    if (this.ForecastToDate == null || this.ForecastToDate == '' || this.ForecastToDate == undefined) this.ForecastToDate = this.MRP.ERP7__To_Date__c;
    getforecastMRPs({ forecastval: this.ForecastBy, forecastTypeval: this.ForecastType, fromDate: this.ForecastStartDate, toDate: this.ForecastToDate, pageSize: this.tab3pageSize, pageNumber: this.tab3pageNumber, ProdIds: this.MRPProdIds, MPSIds: this.MPSIdList })
      .then(result => {
        console.log('result : ', result);
        if (result) {
          this.tab3pageNumber = result.pageNumber;
          this.tab3totalRecords = result.totalRecords;
          this.tab3recordStart = result.recordStart;
          this.tab3recordEnd = result.recordEnd;
          this.tab3totalPages = Math.ceil(result.totalRecords / this.tab3pageSize);
          this.tab3isNext = (this.tab3pageNumber == this.tab3totalPages || this.tab3totalPages == 0);
          this.tab3isPrev = (this.tab3pageNumber == 1 || this.tab3totalRecords < this.tab3pageSize);
          this.forecastData = result.ForecastWrap;

          const monthQuantitiesMap = result.ForecastWrap[0].monthQuantities || {};

          this.tableHeaders = monthQuantitiesMap; //Object.entries(monthQuantitiesMap).map(([key]) => ({ label: key }));

          console.log('Forecast Data:', JSON.stringify(this.forecastData));
          console.log('Table Headers:', JSON.stringify(this.tableHeaders));
          this.isLoading = false;

        }
        else {
          this.isLoading = false;
          console.log('error occurred');
        }
      })
      .catch(error => {
        this.isLoading = false;
        console.log('error : ', error);

      });
  }
  /*showReorderingSection(event){
      this.showReorder = true;
      try {
          let index = parseInt(event.currentTarget.dataset.index);
          let val = event.currentTarget.value;

          console.log('index : ', index);
          console.log('event.currentTarget.value : ', val);

          // Deep copy the selectedMRPs array to avoid mutation
          let tempPickList = JSON.parse(JSON.stringify(this.selectedMRPs));

          // Find the object with the specified index
          let foundIndex = tempPickList.findIndex(e => e.index === index);

          // Check if the object exists in the array
          if (foundIndex !== -1) {
              // Check if the ReorderList property exists
              if (!tempPickList[foundIndex].ReorderList) {
                  // If not, initialize it as an empty array
                  tempPickList[foundIndex].ReorderList = [];
              }

              // Push the new object to the ReorderList array
              tempPickList[foundIndex].ReorderList.push({
                  leadTime: 0,
                  Quantity: 0,
                  ERP7__Reordering_Rule__c: {Id: '', Name: ''},
                  reorderUrl: '',
                  reorderSelected: false
              });

              console.log(tempPickList);

              // Update the selectedMRPs array
              this.selectedMRPs = tempPickList;
          } else {
              console.log('Object with index', index, 'not found.');
          }
      } catch (e) {
          console.log('Error: ', e);
      }
  }*/
  showReorderingSection(event) {

    try {
      this.showReorderSection = true;
      this.showReorder = true;
      this.showMRPCreationPage = false;
      let index = parseInt(event.currentTarget.dataset.index);
      // let val = event.currentTarget.value;
      console.log('index : ', index);
      let prodId = event.currentTarget.dataset.id;
      console.log('prodId : ', prodId);
      let prodName = event.currentTarget.dataset.name;
      console.log('prodName : ', prodName);
      this.routingFilter = 'ERP7__Product__c = \'' + prodId + '\'';
      this.selectedProduct = prodId;
      this.selectedProductName = prodName;
      this.rrId = '';
      this.suggestedOrder = [];
      this.vendor = { Id: '', Name: '' };
      this.venderSelected = false;
      this.leadtime = 0;
      this.orderingQty = 0;
      this.routing = { Id: '', Name: '' };

    }
    catch (e) {
      console.log('Error: ', e);
    }
  }
  getCreatedId(event) {
    console.log('Id : ', event.detail.Id);
  }
  setMRPAlgorithm(event) {
    console.log('event.detail.value : ', event.detail.value);
    this.MRP.ERP7__Algorithm__c = event.detail.value;
    if (this.MRP.ERP7__Algorithm__c != '--None--' && this.MRP.ERP7__Algorithm__c != undefined && this.MRP.ERP7__Algorithm__c != '' && this.MRP.ERP7__Algorithm__c != null) {
      this.showReorderlists = true;
        this.isButtonDisabled = false;
      this.setShowReorderBasedonAlgorithm();
    }
  }
  setShowReorderBasedonAlgorithm() {
    let tempSelected = JSON.parse(JSON.stringify(this.selectedMRPs));
    tempSelected.map(e => {
      if (e.reorderlist) {
        e.reorderlist.map(item => {
          if (!Object.isExtensible(item)) {
            item = { ...item };
          }
          if (this.MRP.ERP7__Algorithm__c == 'Fixed Order Quantity (FOQ)') {
            item.show = (item.ERP7__MinimumOrderingQuantity__c) ? true : false;
          }
          else if (this.MRP.ERP7__Algorithm__c == 'Demand Driven MRP (DDMRP)') {
            item.show = (item.ERP7__Warning_Quantity__c && item.ERP7__Minimum_Quantity__c && item.ERP7__Maximum_Quantity__c) ? true : false;
          }
          else if (this.MRP.ERP7__Algorithm__c == 'Min-Max System') {
            item.show = (item.ERP7__Minimum_Quantity__c && item.ERP7__Maximum_Quantity__c) ? true : false;
          }
          else {
            item.show = true;
          }
        });
      }
    });
    console.log('selected MRPS : ', JSON.stringify(tempSelected));
    this.selectedMRPs = tempSelected;
    return refreshApex(this.selectedMRPs);
  }
  onSelectedVendor(event) {
    try {
      var selectId = event.detail.Id;
      var selectname = event.detail.Name;
      this.vendor = { Id: selectId, Name: selectname };
      this.vendorUrl = '/' + selectId;
      this.venderSelected = true;
      this.getReorders();
    }
    catch (e) {
      console.log('error : ', e);
    }

  }
  setLeadTime(event) {
    this.leadtime = parseFloat(event.currentTarget.value);
    if (this.leadtime) {
      this.getReorders();
    }
  }
  setOrderingQty(event) {
    this.orderingQty = parseFloat(event.currentTarget.value);
    if (this.orderingQty) this.getReorders();
  }
  onSelectedRouting(event) {
    var selectId = event.detail.Id;
    var name = event.detail.Name;
    this.routing = { Id: selectId, Name: name };
    this.routingUrl = '/' + selectId;
    this.routingSelected = true;
    this.getReorders();
  }
  closeReorderModal() {
    this.showReorder = false;
    this.showReorderSection = false;
    this.showMRPCreationPage = true;
  }
  getReorders() {
    this.isLoading = true;
    getReorderingRules({ vendor: this.vendor.Id, LeadTime: this.leadtime, qty: this.orderingQty, rotuing: this.routing.Id, prodId: this.selectedProduct })
      .then(result => {
        console.log('result : ', result);
        if (result) {
          this.suggestedOrder = result;
          this.isLoading = false;
        }
        else {
          this.isLoading = false;
          console.log('error occurred');
        }
      }).catch(error => {
        this.isLoading = false;
        console.log('error : ', error);

      });
  }
  onReorderSelectionChange(event) {
    try {
      let reorderId2 = event.currentTarget.dataset.id;
      console.log("reorderId2 : ", reorderId2);
      let rowIndex = parseInt(event.currentTarget.dataset.index);
      console.log("rowIndex : ", rowIndex);

      let tempSelected = JSON.parse(JSON.stringify(this.selectedMRPs));

      tempSelected.map((e) => {
        console.log("e.index : ", e.index);
        if (e.index === rowIndex) {
          console.log("match");
          e.reOrderId = reorderId2;

          if (e.reorderlist) {
            e.reorderlist.map((item) => {
              if (item.Id == reorderId2) {
                item.selected = true;

                const productId = item.ERP7__Product__c;
                const productName = item.ERP7__Product__r.Name;
                const routingId = item.ERP7__Routing__c;
                const reorderId = item.Id;

                // Check and update BOM details
                if (this.bomDetails && this.bomDetails.length > 0) {
                  this.bomDetails = this.bomDetails.filter(
                    (bomDetail, index, array) => {
                      if (bomDetail.productId === productId) {
                        // Retain the first matching item only
                        return (
                          array.findIndex(
                            (detail) => detail.productId === productId
                          ) === null
                        );
                      }
                      // Retain items with other productIds
                      return true;
                    }
                  );

                  console.log(
                    "Updated BOM Details after filtering: ",
                    this.bomDetails
                  );
                }
                // Check and update BOM details
                if (this.bomDetails && this.bomDetails.length > 0) {
                  this.bomDetails = this.bomDetails.filter(
                    (bomDetail, index, array) => {
                      if (bomDetail.routingId === routingId) {
                        // Retain the first matching item only
                        return (
                          array.findIndex(
                            (detail) => detail.routingId === routingId
                          ) === null
                        );
                      }
                      // Retain items with other routingIds
                      return true;
                    }
                  );

                  console.log(
                    "Updated BOM Details after filtering Routing Ids: ",
                    this.bomDetails
                  );
                }

                if (productId && routingId) {
                  this.isLoading = true; // Show loading spinner
                  this.showBOM = false; // Hide BOM card during loading

                  // Wait for fetchBOMDetails to complete
                  this.fetchBOMDetails(
                    productId,
                    routingId,
                    productName,
                    reorderId,
                    reorderId2
                  );

                  this.updateDemandMOForBOM(); // Update demand MO for BOM
                  console.log("Demand MO Calculation entered");
                } else {
                  alert("No associated routing found.");
                }
              } else {
                item.selected = false;
              }
            });
          }
        }
      });

      console.log(tempSelected);
      this.selectedMRPs = tempSelected;
    } catch (error) {
      console.error("Error in onReorderSelectionChange:", error);
    }
  }




  /* fetchBOMDetails(productId, routingId, productName) {
     getBOMByVersion({ productId, routingId })
       .then(result => {
         // Initialize bomDetails if not already
         if (!this.bomDetails) {
           this.bomDetails = [];
         }

         // Fetch the demand values for the current productId
         const demandMO = parseFloat(this.demandMOData[productId] || this.demandValues[productId]?.demandMO || 0);
         const demandSales = parseFloat(this.demandSalesData[productId] || this.demandValues[productId]?.demandSales || 0);
         console.log('Fetched Demand Values:', { demandMO, demandSales });

         // Append BOM details for the current product/routing combination
         this.bomDetails.push({
           productId: productId,
           bomName: "BOM Details for " + productName,
           bomData: result.map(bom => {
             // Calculate demandMO for the current component
             const calculatedDemandMO = bom.Quantity * (demandMO + demandSales);
             console.log('Calculated DemandMO for BOM:', calculatedDemandMO);

             return {
               Id: bom.BOMId,
               componentName: bom.BOMComponentName,
               quantity: bom.Quantity,
               // Add any additional fields here if needed
               onHand: bom.OnHand || 0,
               reservedSO: bom.ReservedSO || 0,
               awaitingQty: bom.AwaitingQty || 0,
               issuedWIP: bom.IssuedWIP || 0,
               demandSales: bom.DemandSales || 0, // Use demand sales from demandValues
               demandMO: calculatedDemandMO, // Use the calculated demand MO
               orderedQty: bom.OrderedQty || 0,
               version: bom.Version || null
             };
           })
         });


         this.showBOM = this.bomDetails.length > 0; // Show BOM card if details are available
         console.log("BOM Details: --> ", this.bomDetails);
       })
       .catch(error => {
         console.error('Error fetching BOM details:', error);
         this.bomDetails = [] || null;
         this.showBOM = false;
       })
       .finally(() => {
         this.isLoading = false; // Hide loading spinner
       });
   }*/
  fetchBOMDetails(productId, routingId, productName, reorderId, reorderId2) {
    getBOMByVersion({ productId, routingId })
      .then(result => {
        // Initialize bomDetails if not already
        if (!this.bomDetails) {
          this.bomDetails = [];
        }

        const demandMO = parseFloat(this.demandMOData[productId] || this.demandValues[productId]?.demandMO || 0);
        const demandSales = parseFloat(this.demandSalesData[productId] || this.demandValues[productId]?.demandSales || 0);
        console.log('Fetched Demand Values:', { demandMO, demandSales });

        // Prepare BOM details
        const bomDetails = result.map(bom => {
          const calculatedDemandMO = bom.Quantity * (demandMO + demandSales);
          console.log('Calculated DemandMO for BOM:', calculatedDemandMO);

          return {
            Id: bom.BOMId,
            componentName: bom.BOMComponentName,
            quantity: bom.Quantity,
            onHand: bom.OnHand || 0,
            reservedSO: bom.ReservedSO || 0,
            awaitingQty: bom.AwaitingQty || 0,
            issuedWIP: bom.IssuedWIP || 0,
            demandSales: bom.DemandSales || 0,
            demandMO: calculatedDemandMO,
            orderedQty: bom.OrderedQty || 0,
            version: bom.Version || null,
            reorderId: reorderId
          };
        });

        if (bomDetails.length > 0) {
          this.bomDetails.push({
            productId: productId,
            reorderId2: reorderId2,
            bomName: "BOM Details for " + productName,
            bomData: bomDetails
          });

          // Update selectedMRPs for the matching productId
          this.selectedMRPs.forEach(mrp => {
            if (mrp.prod.Id === productId) {
              // Find the BOM entry corresponding to the current productId
              const matchingBOM = this.bomDetails.find(bom => bom.productId === productId);

              if (matchingBOM) {
                mrp.showBOM = true;
                mrp.bomDetails = matchingBOM.bomData.map(bom => ({
                  Id: bom.Id,
                  componentName: bom.componentName,
                  quantity: bom.quantity,
                  onHand: bom.onHand,
                  reservedSO: bom.reservedSO,
                  awaitingQty: bom.awaitingQty,
                  issuedWIP: bom.issuedWIP,
                  demandMO: bom.demandMO,
                  demandSales: bom.demandSales,
                  orderedQty: bom.orderedQty,
                  version: bom.version,
                  reorderId: bom.reorderId
                }));
              }
            }
          });

          this.showBOM = this.bomDetails.length > 0; // Show BOM card if details are available
        }

        console.log("BOM Details: --> ", this.bomDetails);
        console.log("Updated selectedMRPs: --> ", JSON.stringify(this.selectedMRPs));
      })
      .catch(error => {
        console.error('Error fetching BOM details:', error);
        this.bomDetails = [] || null;
        this.showBOM = false;
      })
      .finally(() => {
        this.isLoading = false; // Hide loading spinner
      });
  }




  async onProductReorderDelete(event) {
    let prodId = event.currentTarget.dataset.id;
    let removeReorderIndex = event.currentTarget.dataset.name;

    const result = await LightningConfirm.open({
      message: 'Do you want to delete the reordering rule?',
      variant: 'headerless',
      label: 'Confirmation on delete Action',
    });

    if (result) {
      let tempPickList = JSON.parse(JSON.stringify(this.selectedMRPs));
      let foundIndex = tempPickList.findIndex(e => e.prod.Id === prodId);

      if (foundIndex !== -1) {
        // Check if the ReorderList property exists
        if (!tempPickList[foundIndex].reorderlist) {
          // If not, initialize it as an empty array
          tempPickList[foundIndex].reorderlist = [];
        }
        // Corrected line to remove the item from the ReorderList array
        tempPickList[foundIndex].reorderlist.splice(removeReorderIndex, 1);
        if (tempPickList[foundIndex].reorderlist.length == 0) {
          tempPickList[foundIndex].reorderlist = null;
        }
      }

      this.selectedMRPs = tempPickList;
      // Ensure the data is refreshed after updating
      return refreshApex(this.selectedMRPs);
    }
  }

  addReorderstoProdList() {
    var selectedReorder = [];
    for (var x in this.suggestedOrder) {
      if (this.suggestedOrder[x].selected) {
        selectedReorder.push(this.suggestedOrder[x]);
      }
    }
    if (selectedReorder.length > 0) {
      let tempPickList = JSON.parse(JSON.stringify(this.selectedMRPs));

      // Find the object with the specified index
      let foundIndex = tempPickList.findIndex(e => e.prod.Id === this.selectedProduct);

      // Check if the object exists in the array
      if (foundIndex !== -1) {
        // Check if the ReorderList property exists
        if (!tempPickList[foundIndex].reorderlist) {
          // If not, initialize it as an empty array
          tempPickList[foundIndex].reorderlist = [];
        }

        // Push the new object to the ReorderList array
        tempPickList[foundIndex].reorderlist = selectedReorder;

        console.log(tempPickList);

        // Update the selectedMRPs array
        this.selectedMRPs = tempPickList;
        this.showReorder = false;
        this.showReorderSection = false;
        this.showMRPCreationPage = true;
      }
      else {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'Please select Reorders',
            variant: "warning"
          })
        );
      }

    } else {
      console.log('Object with index not found.');
    }

  }

  createReorderingRules(event) {
    this.createReorderModal = true;
    this.showMRPCreationPage = false;
    console.log('this.createReorderModal : ', this.createReorderModal);
    let prodId = event.currentTarget.dataset.id;
    console.log('prodId : ', prodId);
    this.selectedProduct = prodId;
    //this.showReorder = false;
    this.routingFilter = 'ERP7__Product__c = \'' + prodId + '\'';
    this.reorderToCreate = { Id: null, Name: '', ERP7__Lead_Time__c: 0, ERP7__MinimumOrderingQuantity__c: 0, ERP7__Warning_Quantity__c: 0, ERP7__Vendor_Account__c: '', ERP7__Vendor_Account__r: { Id: '', Name: '' }, ERP7__Routing__c: '', ERP7__Routing__r: { Id: '', Name: '' }, ERP7__Minimum_Quantity__c: 0, ERP7__Maximum_Quantity__c: '' };
    this.reorderToCreate.ERP7__Product__c = prodId;


  }
  closeModalcreate() {
    this.createReorderModal = false;
    this.showMRPCreationPage = true;
    this.showReorderSection = false;
    console.log('called close Modal : ', this.createReorderModal);
  }
  saveReorder() {

    console.log('bfr reorder : ', JSON.stringify(this.reorderToCreate));
    console.log('this.selectedProduct',this.selectedProduct);
    console.log('this.selectedProduct',this.selectedProduct?.ERP7__Issue_Manufacturing_Order__c);
    if (!this.reorderToCreate.Name) {
        this.dispatchEvent(new ShowToastEvent({
            message: "Please enter a Reordering Rule Name",
            variant: "warning"
        }));
        return;
    }
    if (this.selectedProduct?.ERP7__Issue_Manufacturing_Order__c && !this.reorderToCreate.ERP7__Routing__c) {
    this.dispatchEvent(new ShowToastEvent({
        message: "Please select a Routing (required for Manufacturing Orders)",
        variant: "warning"
    }));
    return;
}
   else if (this.MRP.ERP7__Algorithm__c == 'Fixed Order Quantity (FOQ)') {
      if (!this.reorderToCreate.ERP7__MinimumOrderingQuantity__c) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: "Please enter the Minimum ordering Quantity",
            variant: "warning"
          })
        );
        return;
      }
    }
    else if (this.MRP.ERP7__Algorithm__c == 'Demand Driven MRP (DDMRP)') {
      if (!this.reorderToCreate.ERP7__Minimum_Quantity__c) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: "Please enter the Minimum ordering Quantity",
            variant: "warning"
          })
        );
        return;
      }
      else if (!this.reorderToCreate.ERP7__Warning_Quantity__c) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: "Please enter the Warning Quantity",
            variant: "warning"
          })
        );
        return;
      }
     else if (this.product?.ERP7__Issue_Manufacturing_Order__c && !this.reorderToCreate.ERP7__Routing__c) {
        this.dispatchEvent(new ShowToastEvent({
            message: "Please select a Routing (required for Manufacturing Orders)",
            variant: "warning"
        }));
        return;
    }
      else if (!this.reorderToCreate.ERP7__Maximum_Quantity__c) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: "Please enter the Maximum Quantity",
            variant: "warning"
          })
        );
        return;
      }
    }
    else if (this.MRP.ERP7__Algorithm__c == 'Min-Max System') {
      if (!this.reorderToCreate.ERP7__Minimum_Quantity__c) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: "Please enter the Warning Quantity",
            variant: "warning"
          })
        );
        return;
      }
      else if (!this.reorderToCreate.ERP7__Maximum_Quantity__c) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: "Please enter the Maximum Quantity",
            variant: "warning"
          })
        );
        return;
      }
    }
    this.isLoading = true;
    // Creating a copy of reorderToCreate
    const reorderToCreateCopy = { ...this.reorderToCreate };

    // Setting related objects to null
    reorderToCreateCopy.ERP7__Routing__r = null;
    reorderToCreateCopy.ERP7__Vendor_Account__r = null;
    reorderToCreateCopy.ERP7__Active__c = true;
    console.log('after reorder : ', JSON.stringify(reorderToCreateCopy));

    createReorder({ routingDetails: JSON.stringify(reorderToCreateCopy) })
      .then(result => {
        console.log('result : ', result);
        if (result) {
          this.reorderToCreate.Id = result.Id;
          this.reorderToCreate.ERP7__Active__c = result.ERP7__Active__c;
          // Handle ERP7__Routing__c and ERP7__Vendor_Account__c properties if they are undefined in the result
          if (!result.ERP7__Routing__c) {
            result.ERP7__Routing__c = '';
            result.ERP7__Routing__r = { Id: '', Name: '' };
          }
          if (!result.ERP7__Vendor_Account__c) {
            result.ERP7__Vendor_Account__c = '';
            result.ERP7__Vendor_Account__r = { Id: '', Name: '' };
          }

          // Update existing object or add new object to ReorderList
          let tempPickList = JSON.parse(JSON.stringify(this.selectedMRPs));
          const foundIndex = tempPickList.findIndex(e => e.prod.Id === this.selectedProduct);
          if (foundIndex !== -1) {
            tempPickList[foundIndex].reOrderId = result.Id;
            // Update existing object
            if (!tempPickList[foundIndex].reorderlist) {
              // If not, initialize it as an empty array
              tempPickList[foundIndex].reorderlist = [];
            }
            tempPickList[foundIndex].reorderlist.map(e => {
              if (e.selected) e.selected = false;
            });
            result.selected = true;
            result.show = true;
            tempPickList[foundIndex].reorderlist.push(result);
          } else {
            // Add new object to ReorderList
            tempPickList[foundIndex].reorderlist = [];
          }

          // Update component state
          this.selectedMRPs = tempPickList;
          this.showReorder = false;
          this.isLoading = false;
          this.showReorderSection = false;
          this.createReorderModal = false;
          this.showMRPCreationPage = true;
        } else {
          this.isLoading = false;
          console.log('error occurred');
        }
      })
      .catch(error => {
        this.isLoading = false;
        console.log('error : ', error);
      });
  }

  handleNewReorderName(event) {
    this.reorderToCreate.Name = event.currentTarget.value;
  }
  handleNewReorderLeadTime(event) {
    this.reorderToCreate.ERP7__Lead_Time__c = event.currentTarget.value;
  }
  handleNewReorderQty(event) {
    this.reorderToCreate.ERP7__MinimumOrderingQuantity__c = event.currentTarget.value;
  }
  onNewReorderSelectedVendor(event) {
    this.reorderToCreate.ERP7__Vendor_Account__c = event.detail.Id;
    this.reorderToCreate.ERP7__Vendor_Account__r.Name = event.detail.Name;
  }

  onNewReorderSelectedRouting(event) {
    this.reorderToCreate.ERP7__Routing__c = event.detail.Id;
    this.reorderToCreate.ERP7__Routing__r.Name = event.detail.Name;
  }
  handleNewReorderMinQty(event) {
    this.reorderToCreate.ERP7__Minimum_Quantity__c = event.currentTarget.value;
  }
  handleNewReorderMaxQty(event) {
    this.reorderToCreate.ERP7__Maximum_Quantity__c = event.currentTarget.value;
  }
  handleNewReorderWarnQty(event) {
    this.reorderToCreate.ERP7__Warning_Quantity__c = event.currentTarget.value;
  }
  markReorderAsInactive(event) {
    try {
      var reorderId = event.currentTarget.dataset.id;
      this.isLoading = true;
      if (reorderId) {
        var prodIndex = event.currentTarget.dataset.name;
        var reorderIndex = event.currentTarget.dataset.index;
        //this.selectedMRPs[prodIndex].reorderlist[reorderIndex].ERP7__Active__c = false;
        console.log('this.selectedMRPs[prodIndex] : ', JSON.stringify(this.selectedMRPs[prodIndex]));
        let tempPickList = JSON.parse(JSON.stringify(this.selectedMRPs));
        if (!tempPickList[prodIndex].reorderlist) {
          tempPickList[prodIndex].reorderlist = [];
        }
        else {
          tempPickList[prodIndex].reOrderId = '';
          tempPickList[prodIndex].selected = false;
          tempPickList[prodIndex].reorderlist[reorderIndex].ERP7__Active__c = false;
        }

        this.updateReorders(false, reorderId);
        this.selectedMRPs = tempPickList;
        console.log('after set');
        this.isLoading = false;
        return refreshApex(this.selectedMRPs);

      }
    } catch (e) {
      console.log('error : ', e);
    }

  }
  markReorderAsActive(event) {
    try {
      var reorderId = event.currentTarget.dataset.id;
      this.isLoading = true;
      if (reorderId) {
        var prodIndex = event.currentTarget.dataset.name;
        var reorderIndex = event.currentTarget.dataset.index;
        //this.selectedMRPs[prodIndex].reorderlist[reorderIndex].ERP7__Active__c = true;
        console.log('this.selectedMRPs[prodIndex] : ', JSON.stringify(this.selectedMRPs[prodIndex]));
        let tempPickList = JSON.parse(JSON.stringify(this.selectedMRPs));
        if (!tempPickList[prodIndex].reorderlist) {
          tempPickList[prodIndex].reorderlist = [];
        }
        else tempPickList[prodIndex].reorderlist[reorderIndex].ERP7__Active__c = true;
                        tempPickList[prodIndex].reorderlist[reorderIndex].selected = false;

        this.updateReorders(true, reorderId);
        this.selectedMRPs = tempPickList;
        console.log('after set');
        this.isLoading = false;
        return refreshApex(this.selectedMRPs);

      }
    } catch (e) {
      console.log('error : ', e);
    }
  }
  updateReorders(activeVal, reorderId) {
    updateReorder({ recId: reorderId, active: activeVal })
      .then(result => {
        console.log('result : ', result);
        if (result) {
          this.isLoading = false;

        } else {
          this.isLoading = false;
          console.log('error occurred');
        }
      }).catch(error => {
        this.isLoading = false;
        console.log('error : ', error);
      });
  }
  setSimulateonMRP(event) {
    var checkedval = event.target.checked;
    console.log('checkedval : ', checkedval);
    this.MRP.ERP7__Simulate__c = checkedval;

  }
  handleReservedClick(event) {
    var prodID = event.currentTarget.dataset.id;
    console.log('prodId : ', prodID);
    var status = event.currentTarget.dataset.index;
    console.log('status : ', status);
    if (status) this.modalTitle = status + ' Details';
    if (prodID != null && prodID != '' && prodID != undefined) {
      this.getOrderDetails(prodID, status);
    }

  }

  navigateToRecord(event) {
    // Get the OrderId from the data-id attribute
    const recordId = event.currentTarget.dataset.id;

    // Navigate to the record page
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: recordId,
        actionName: 'view',
        target: '_blank'
      }
    });
  }
  getOrderDetails(ProductId, Status) {
    console.log('ordDetails called : ', ProductId, ' Status : ', Status);
    if (ProductId && Status) {
      this.isLoading = true;
      getOrderDetailsBasedOnStatus({ recId: ProductId, statusVal: Status, fromDate: this.fromtab1Date, toDate: this.toTab2Date })
        .then(result => {
          console.log('result : ', result);
          if (result) {
            this.isLoading = false;
            this.showModaltab1 = true;
            this.modalData = result;

          } else {
            this.isLoading = false;
            console.log('error occurred');
          }
        }).catch(error => {
          this.isLoading = false;
          console.log('error : ', error);
        });
    }
  }
  closeModaltab1() {
    this.modalData = [];
    this.showModaltab1 = false;
  }
  onDemandChange(event) {
    const productId = event.target.dataset.id; // Get the product ID from data-id
    const newDemandMoValue = parseFloat(event.target.value); // Get the new demandMO value from the input

    // Update the demandMOData for this productId
    this.demandMOData[productId] = newDemandMoValue;
    console.log('demandMOData : ', this.demandMOData);
    console.log('demandMOData : ', this.demandMOData[productId]);

    // Fetch the corresponding demandSales value, use demandValues as fallback
    const newDemandSalesValue = parseFloat(this.demandSalesData[productId] || this.demandValues[productId]?.demandSales || 0);

    // Update bomDetails and selectedMRPs
    this.updateBOMDetailsAndMRPs(productId, newDemandMoValue, newDemandSalesValue);
  }

  onDemandSalesChange(event) {
    const productId = event.target.dataset.id; // Get the product ID from data-id
    const newDemandSalesValue = parseFloat(event.target.value); // Get the new demandSales value from the input

    // Update the demandSalesData for this productId
    this.demandSalesData[productId] = newDemandSalesValue;
    console.log('demandSalesData : ', this.demandSalesData);
    console.log('demandSalesData : ', this.demandSalesData[productId]);

    // Fetch the corresponding demandMO value, use demandValues as fallback
    const newDemandMoValue = parseFloat(this.demandMOData[productId] || this.demandValues[productId]?.demandMO || 0);

    // Update bomDetails and selectedMRPs
    this.updateBOMDetailsAndMRPs(productId, newDemandMoValue, newDemandSalesValue);
  }

  // Helper function to update BOMDetails and selectedMRPs
  updateBOMDetailsAndMRPs(productId, newDemandMoValue, newDemandSalesValue) {
    // Create a new bomDetails array to trigger reactivity
    const newBOMDetails = this.bomDetails.map(bom => {
      if (bom.productId === productId) { // Check if the BOM is related to the current productId
        // Create a new bomData array for reactivity
        const updatedBOMData = bom.bomData.map(bomComponent => {
          // Update demandMO for each component based on new demandMO and demandSales values
          const updatedDemandMO = bomComponent.quantity * (newDemandMoValue + newDemandSalesValue);
          return { ...bomComponent, demandMO: updatedDemandMO }; // Return new object with updated demandMO
        });
        return { ...bom, bomData: updatedBOMData }; // Return new bom object with updated bomData
      }
      return bom; // Return unchanged bom if productId doesn't match
    });

    // Assign the updated bomDetails array to trigger reactivity
    this.bomDetails = newBOMDetails;

    // Update selectedMRPs for the matching productId
    this.selectedMRPs.forEach(mrp => {
      if (mrp.prod.Id === productId) {
        // Update the MRP's bomDetails with the updated BOM details
        const matchingBOM = newBOMDetails.find(bom => bom.productId === productId);

        if (matchingBOM) {
          mrp.showBOM = true;
          mrp.bomDetails = matchingBOM.bomData.map(bom => ({
            Id: bom.Id,
            componentName: bom.componentName,
            quantity: bom.quantity,
            onHand: bom.onHand,
            reservedSO: bom.reservedSO,
            awaitingQty: bom.awaitingQty,
            issuedWIP: bom.issuedWIP,
            demandMO: bom.demandMO, // Updated demandMO
            demandSales: bom.demandSales,
            orderedQty: bom.orderedQty,
            version: bom.version,
            reorderId: bom.reorderId
          }));
        }
      }
    });

    console.log('Updated BOM details:', this.bomDetails); // Check the updated BOM details
    console.log('Updated selectedMRPs:', JSON.stringify(this.selectedMRPs)); // Check the updated MRP details
  }



  handleFilterChange(event) {
    var filterval = event.currentTarget.value;
    this.selectedfilter = filterval;
    console.log('filterval : ', filterval);
    if (filterval == '' || filterval == null || filterval == undefined || filterval == 'None') {
      this.getbyDate();
    }
    else {
      this.getFilteredData();
    }
  }
  getFilteredData() {
    this.isLoading = true;
    getInvnetorydatawithFilter({ filterval: this.selectedfilter, searchkey: this.searchKey, family: this.family, subFamily: this.subFamily, selectedSite: this.site.Id, fromDate: this.fromtab1Date, toDate: this.toTab2Date, pageSize: this.pageSize, pageNumber: this.pageNumber })
      .then(result => {
        console.log('result : ', result);
        if (result) {
          this.isLoading = false;
          this.showModaltab1 = true;
          this.modalData = result;

        } else {
          this.isLoading = false;
          console.log('error occurred');
        }
      }).catch(error => {
        this.isLoading = false;
        console.log('error : ', error);
      });
  }

}