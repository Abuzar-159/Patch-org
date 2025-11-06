import { NavigationMixin } from 'lightning/navigation';
import { LightningElement, track, wire, api } from 'lwc';

export default class SupplyPlanningSidebar extends  NavigationMixin(LightningElement) {
    @api organisationId;
    @api vendorId;
    @api selectedYear;

}
/*function formatDateLocal(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}


import { LightningElement, track, wire, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartJs from '@salesforce/resourceUrl/ChartJS';

//apex classes

import getMonthlyDemandSupply from '@salesforce/apex/supplyPlanningController.getMonthlySupplyDemand';
import getSupplyDemandByCountry from '@salesforce/apex/supplyPlanningController.getSupplyDemandByCountry';
import getSpendOverTime from '@salesforce/apex/supplyPlanningController.getSpendOverTime';
import getOnTimeDeliveryMapped from '@salesforce/apex/supplyPlanningController.getOnTimeDeliveryMapped';
import getMonthlyQualityData from '@salesforce/apex/supplyPlanningController.getMonthlyQualityData';
// import getInventoryData from '@salesforce/apex/supplyPlanningController.getInventoryData';
import getTop5SupplyAndDemand from '@salesforce/apex/supplyPlanningController.getTop5SupplyAndDemand';
import getTop5CountrySupplyDemand from '@salesforce/apex/supplyPlanningController.getTop5CountrySupplyDemand';
// import getInventoryByProductAndDate from '@salesforce/apex/supplyPlanningController.getInventoryByProductAndDate';
import getSummedInventory from '@salesforce/apex/supplyPlanningController.getSummedInventory';
import getTop5Inventory from '@salesforce/apex/supplyPlanningController.getTop5Inventory';
import getOrgFiscalStartMonth from '@salesforce/apex/supplyPlanningController.getOrgFiscalStartMonth';
import getDefaultTopVendor from '@salesforce/apex/supplyPlanningController.getDefaultTopVendor';
import getCurrencySymbol from '@salesforce/apex/supplyPlanningController.getCurrencySymbol';
import { NavigationMixin } from 'lightning/navigation';
 


export default class SupplyPlanningSidebar extends  NavigationMixin(LightningElement) {
   

    @track isSupplyOverview = true;
    @track isSupplierScorecard = false;
    @track isInventoryLevel = false;
    @track isProcurementPlanning = false;
    @track inventoryProduct = { Id: '', Name: '' }; // stores selected product {Id, Name}
    @track chartInstances = {};
    //@track productOptions = [];
    //@track supplyDemandData = [];
    @track countrySupplyDemandData;
    chartInstances = {};
    isChartJsInitialized = false;
    @track issuppydemandloaded = false;
    @track availableYears = [];
    @track selectedYear;
    onTimeDeliveryData = [];
    listqualitydata = [];
    @track selectedProductName = null;
    @track topFiveRows = [];   // merged Demand+Supply rows
    @track inventoryProduct = {}; // or however you're storing selected product
    @track countrySupplyDemandData = []; // populated from Apex
    @track selectedProductId;




    //supplier
    @track selectedYearSup = new Date().getFullYear();
    @track yearOptions = this.generateYearOptions();
    @track selectedVendorId;
    @track selectedVendorName;
    @track deliveryData = []; // Add this line to store the delivery data
    @track qualitydata = [];
    @track goodData = [];
    @track badData = [];
    @track labelsForQualityChart = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    @api vendorId;
    @api selectedYear;
    @track currencySymbol = '$'; // default fallback


    //Inventory
    @track rawData = [];
    @track wipData = [];
    @track finishedData = [];
    @track fromDate;
    @track toDate;
    @track filterDate;
    @track productId;
    @track productName;
    @track inventoryData = [];
    @track inventoryLevelData = {};
    top5ChartPending = false;
    singleChartPending = false;
    isSingleProductView = false;

    @track showTable = false;
    @track error;
    @track summaryData;
    @track top5Data;
    @track chartRendered = false;
    chartJsInitialized = false;



    chart;          // Chart.js instance
    chartJsReady = false;
    hasRenderedCountryChart = false;



    get chartTitle() {
        return this.selectedProductId
            ? `${this.selectedProductName}  Monthly Supply vs Demand`
            : 'Top 5 Products   Supply vs Demand';
    }

    get isProductSelected() {
        return this.inventoryProduct && this.inventoryProduct.Id;
    }

    // get isShowDefaultData() {
    //     console.log('selectedProductId =>>', this.selectedProductId);
    //     console.log('inventoryProduct.Id ===>>>>',this.inventoryProduct.Id);


    //     return this.selectedProductId == null;


    // }
    chartInstances = {
        spendChart: null,
        deliveryChart: null,
        qualityChart: null
    };
   connectedCallback() {
    if (this.hasRenderedCountryChart) return;

    const canvas = this.template.querySelector('.breakdown-placeholder-chart');
    if (this.chartJsInitialized && this.isSupplierScorecard && !this.renderedOnce) {
        this.renderedOnce = true;
        console.log('fetch supplier before');
        this.fetchSupplierData();
        console.log('fetch after');
    } else {
        console.log('⏳ Waiting for canvas or data...');
    }

    loadScript(this, chartJs)
        .then(() => {
            console.log('✅ Chart.js loaded');
            this.chartJsReady = true;
            this.chartJsInitialized = true;

            // Get currency symbol
            getCurrencySymbol()
                .then(symbol => {
                    this.currencySymbol = symbol;
                    console.log(`💱 Currency Symbol: ${this.currencySymbol}`);
                })
                .catch(error => {
                    console.error('❌ Error fetching currency symbol:', error);
                    this.currencySymbol = '₹'; // fallback
                });

            // ✅ Get fiscal start month and compute fromDate/toDate
            // ✅ Use existing method
            this.setFiscalDates()
                .then(() => {
                    console.log(`📅 Dates set: ${this.fromDate} → ${this.toDate}`);
                    this.loadAllChartData();
                })
                .catch(error => {
                    console.error('❌ Failed to set fiscal dates:', error);
                });

            // ✅ Only run vendor logic for supplier scorecard
            if (this.isSupplierScorecard) {
                console.log('📊 Fetching default vendor for Supplier Scorecard');
                getDefaultTopVendor({ organisationId: this.organisationId })
                    .then(vendor => {
                        if (vendor?.Id) {
                            this.selectedVendorId = vendor.Id;
                            this.selectedVendorName = vendor.Name;
                            console.log(`✅ Default vendor selected: ${vendor.Name}`);
                            this.fetchSupplierData();
                        } else {
                            console.warn('⚠️ No default vendor returned from Apex.');
                        }
                    })
                    .catch(error => {
                        console.error('❌ Error fetching default vendor:', error);
                    });
            }

            // ✅ Initialize supply forecast chart (can be safely done here)
            this.initializeSupplyForecastChart();

            // ❌ Do NOT call other data loading methods here (they will be called from loadAllChartData)
        })
        .catch(error => {
            console.error('❌ ChartJS load error:', error);
        });



   }
    handleCreatePO() {
        console.log('create po');
        
    this[NavigationMixin.Navigate]({
        type: 'standard__component',
        attributes: {
            componentName: 'ERP7__CreatePurchaseOrder'
        }
        // state: {
        //     c__recordId: this.selectedProduct?.Id
        // }
    });
}
 
   
handleCreateMO() {
    this[NavigationMixin.Navigate]({
        type: 'standard__component',
        attributes: {
            componentName: 'ERP7__WorkCenterSchedule'
        }
    });
}

    loadAllChartData() {
    this.fetchCountrySupplyDemand(this.fromDate, this.toDate);
    this.loadTopFive(this.fromDate, this.toDate);
    this.loadTop5CountrySupplyDemand(this.fromDate, this.toDate);

    if (!this.selectedProductId) {
        this.loadTop5Data(this.fromDate, this.toDate);
        this.initializeTop5CountryChart(this.fromDate, this.toDate);
        this.loadTopFive(this.fromDate, this.toDate);
        this.loadTop5CountrySupplyDemand(this.fromDate, this.toDate);


        

    } else {
        this.fetchData(this.fromDate, this.toDate);
    }

        this.initializeSupplyForecastChart();
        this.initializeTop5CountryChart();
        this.resolveSupplyOverviewData();        // Monthly chart
        this.resolveCountrySupplyDemand();   // Country-wise chart
}



    // Tab CSS Classes
    get supplyOverviewTabClass() { return this.isSupplyOverview ? 'sub-tab-horizontal active' : 'sub-tab-horizontal'; }
    get supplierScorecardTabClass() { return this.isSupplierScorecard ? 'sub-tab-horizontal active' : 'sub-tab-horizontal'; }

    // New tab classes
    get inventoryLevelTabClass() { return this.isInventoryLevel ? 'sub-tab-horizontal active' : 'sub-tab-horizontal'; }
    get procurementPlanningTabClass() { return this.isProcurementPlanning ? 'sub-tab-horizontal active' : 'sub-tab-horizontal'; }



    
    resetTabs() {
        this.isSupplyOverview = false;
        this.isSupplierScorecard = false;
        this.isInventoryLevel = false;
        this.isProcurementPlanning = false;
    }


    loadAvailableYears() {
        try {
            const currentYear = new Date().getFullYear();
            const numYearsToShow = 5;

            const years = [];
            for (let i = 0; i < numYearsToShow; i++) {
                years.push(currentYear - i);
            }

            this.availableYears = years;
            this.selectedYear = years[0];

            if (this.inventoryProduct?.Id && this.organisationId) {
                this.resolveSupplyOverviewData();
                this.resolveCountrySupplyDemand();
            }
        } catch (error) {
            console.error('❌ Error in loadAvailableYears():', error);
        }
    }

   handleSearchClick() {
    if (this.fromDate && this.toDate) {
        console.log(`🔍 Loading data from ${this.fromDate} to ${this.toDate}`);
        this.loadAllChartData(); // This method should handle all data/chart reloads
    } else {
        console.warn('⚠️ From or To Date is missing!');
    }
}


    // handleYearChange(event) {
    //     this.selectedYear = parseInt(event.target.value, 10);
    //     console.log(' this.selectedYear->', this.selectedYear);
    //     this.selectedProductId ?    // refresh current view
    //         this.handleProductSelect({ detail: { value: this.selectedProductId } }) :
    //         this.loadTopFive();
    //     this.loadTop5CountrySupplyDemand();
    //     this.resolveSupplyOverviewData();        // Monthly chart
    //     this.resolveCountrySupplyDemand();   // Country-wise chart
    // }

    // handleTabSwitchToSupplierScorecard() {
    //     this.isSupplierScorecard = true;
    //     this.renderedOnce = false; // so it reloads in renderedCallback
    // }

    // Tab Selection Methods
    selectSupplyOverview() {
        this.productId = null;
        this.productName = null;
        this.resetTabs();
        console.log('in selectSupplyOverview');
        
        this.isSupplyOverview = true;
        if (! this.inventoryProduct.Id) {
            console.log('calling load top 5');
            
            // ⬅️ If no product is selected, load both default charts
            this.loadTopFive(); // Top 5 Products
            this.loadTop5CountrySupplyDemand(); // Top 5 Countries
        }
        setTimeout(() => {
            this.initializeSupplyForecastChart();
             this.initializeBreakdownChart();
           this.initializeInventoryLevelChart();
        }, 100);

    }


    selectSupplierScorecard() {
        this.productId = null;
        this.productName = null;
        this.inventoryProduct.Id = null;
        this.inventoryProduct.Name = null;
        //this.selectedProductId = null;
        this.productId = null;
        this.resetTabs();
        this.isSupplierScorecard = true;

        const year = this.selectedYearSup || new Date().getFullYear();

        getDefaultTopVendor({ organisationId: this.organisationId, year: year })
            .then((vendor) => {
                if (vendor && vendor.Id) {
                    this.selectedVendorId = vendor.Id;
                    this.selectedVendorName = vendor.Name;
                    console.log(`✅ Default vendor selected: ${vendor.Name}`);
                    this.fetchSupplierData();
                } else {
                    console.warn('⚠️ No default vendor returned for Supplier Scorecard');
                }
            })
            .catch((error) => {
                console.error('❌ Error fetching default vendor on tab click:', error);
            });
    }

    // selectSupplierScorecard() {
    //     this.resetTabs();
    //     this.isSupplierScorecard = true;
    // }



    selectInventoryLevel() {
         this.inventoryProduct.Id = null;
        this.inventoryProduct.Name = null;
        this.resetTabs();
        this.isInventoryLevel = true;
        if (!this.productId) {
            this.isTop5View = true;
            this.isSingleProductView = false;
            this.top5ChartPending = true;
            this.loadTop5Data(); // Fetch and render Top 5 products chart
        }
        setTimeout(() => this.initializeInventoryLevelChart(), 100);

    }

    // selectProcurementPlanning() {
    //     this.resetTabs();
    //     this.isProcurementPlanning = true;
    //     setTimeout(() => this.initializeProcurementChart(), 100);
    // }


    // handleMOSelection(event) {
    //     const detail = event.detail;
    //     console.log('🧩 handleMOSelection: event.detail =', JSON.stringify(detail));

    //     this.selectedMOId = detail.Id;
    //     this.selectedMOName = detail.Name;


    //     console.log('🆔 selectedMOId:', this.selectedMOId);
    //     console.log('📝 selectedMOName:', this.selectedMOName);

    //     if (!this.selectedMOId) {
    //         console.error('❌ No Manufacturing Order ID received.');
    //         return;
    //     }

    //     getInventoryData({ manufacturingOrderId: this.selectedMOId })
    //         .then(result => {
    //             this.rawData = result.raw || [];
    //             this.wipData = result.wip || [];
    //             this.finishedData = result.finished || [];
    //             console.log('✅ Raw Data:', this.rawData);
    //             console.log('✅ WIP Data:', this.wipData);
    //             console.log('✅ finishedData:', this.finishedData);

    //         })
    //         .catch(error => {
    //             console.error('❌ Error fetching inventory data:', JSON.stringify(error));
    //         });
    // }




    // Reusable destroy function
    destroyChart(name) {
        if (this.chartInstances[name]) {
            this.chartInstances[name].destroy();
            this.chartInstances[name] = null;
        }
    }
    // Called when a product is selected from <c-custom-input-lookup-l-w-c>


    resolveSupplyOverviewData() {
        if (!this.inventoryProduct?.Id || !this.organisationId) {
            console.warn('Product or Organisation not selected.');
            return;
        }

        this.isSupplyDataLoading = true;

        getMonthlyDemandSupply({
            productId: this.inventoryProduct.Id,
            organisationId: this.organisationId,
            //selectedYear: this.selectedYear,
            fromDate: this.fromDate, // 'YYYY-MM-DD' from LWC
    toDate: this.toDate

        })
            .then(result => {
                console.log('📊 Supply Overview Data:', result);
                this.supplyDemandRaw = result;
                this.processMonthlyDataForChart(result); // ✅ replaces transformToChartData + render
                //this.issuppydemandloaded = true; 
            })
            .catch(error => {
                console.error('Error fetching Supply Overview data:', error);
                //this.showToast('Error', error.body?.message || 'Failed to fetch supply overview.', 'error');
            })
            .finally(() => {
                setTimeout(() => {
                    this.isSupplyDataLoading = false;

                }, 500);
            });
    }



    //for defaault 

    fetchCountrySupplyDemand() {
        getSupplyDemandByCountry({
            organisationId: this.organisationId,
            selectedYear: this.selectedYear,
            productId: this.inventoryProduct.Id,
           // productId: this.selectedProductId || null,
            fromDate: this.fromDate,
    toDate: this.toDate
        })
            .then(result => {
                this.countrySupplyDemandData = result;
                this.hasRenderedCountryChart = false; // allow chart to render after DOM update

                console.log('✅✅✅before calling renderCountryChart from fetchCountrySupplyDemand getSupplyDemandByCountry ');

                this.renderCountryChart();
            })
            .catch(error => {
                console.error('Error fetching country supply-demand:', error);
            });
    }

    //country forselected product
    resolveCountrySupplyDemand() {
        if (!this.inventoryProduct?.Id || !this.organisationId) {
            console.warn('Missing product or organisation.');
            return;
        }
        console.log('cal to apex by country');
        getSupplyDemandByCountry({
            productId: this.inventoryProduct.Id,
            organisationId: this.organisationId,
            selectedYear: this.selectedYear,
            fromDate: this.fromDate, // 'YYYY-MM-DD' from LWC
    toDate: this.toDate
            // productId: this.selectedProductId || null


        })
            .then(result => {
                console.log('🌍 Supply/Demand by Country:', result);
                this.countrySupplyDemandData = result;
                console.log("👍👍countrychart");

                this.renderCountryChart(); // use the real chart rendering here
            })
            .catch(error => {
                console.error('Error fetching country data:', error);
                //this.showToast('Error', error.body?.message || 'Failed to fetch country-level data.', 'error');
            });
        console.log("out of err");

    }




    // handleINVProductSelected(event) {
    //     //const selected = event.detail; // { Id, Name }
    //     //console.log('🔍 Product selected:', selected);


    //     console.log('in ssjva');
    //     this.inventoryProduct.Id = event.detail.Id;
    //     this.inventoryProduct.Name = event.detail.Name;
    //     console.log('the year');

    //     this.loadAvailableYears(); // <-- call here
    //     console.log("lode available years",this.loadAvailableYears);

    //     //this.selectedProductId = selected.Id;
    //     console.log('inventoryProduct ID ',this.inventoryProduct.Id);
    //     console.log('selected product name ', this.inventoryProduct.Name);

    //     this.fetchSupplyDemandALL();
    //     // this.resolveSupplyOverviewData();
    //     // // 🌍 Country chart ✅
    //     // console.log('hcgh');
    //     // console.log('issuppydemandloaded ' , this.issuppydemandloaded);
    //     // if (this.issuppydemandloaded) {
    //     //     console.log('callig resolve by country');
    //     //         this.resolveCountrySupplyDemand();
    //     //     console.log('aftr calling resolve');
    //     // }
    // }


    handleINVProductSelected(event) {
        console.log('in inv selected');

        // The custom lookup fires:
         //  • event.detail   = { Id, Name }   when a product is chosen
          // • event.detail   = {} OR null     when the lookup is cleared          
        const selId = event.detail && event.detail.Id ? event.detail.Id : null;
        const selName = event.detail && event.detail.Name ? event.detail.Name : null;

        // ── keep your existing model updates ── 
        this.inventoryProduct.Id = selId;
        this.inventoryProduct.Name = selName;

        // Refresh the year dropdown (your existing helper) 
        this.loadAvailableYears();

        //───────────────────────────── 1) No product selected → show Top 5 ──────────────────────────── 
        if (!selId) {

            this.selectedProductId = null;
            this.selectedProductName = null;

            // If a line chart was showing, destroy it
            this.destroyChart && this.destroyChart('lineChart');

            // Re‑draw the Top‑5 bar chart (uses data already cached by loadTopFive)
            //this.renderTopFiveChart && this.renderTopFiveChart();
            //this.renderTop5CountryChart && this.renderTop5CountryChart();

            return;
        }

        // ───────────────────────────── 2) Same product re‑selected → do nothing ─────────────────────── 
        if (this.selId === this.selectedProductId) {
            return;
        }

        // ───────────────────────────── 3) New product selected → drill‑down chart ───────────────────── 
        this.selectedProductId = selId;
        this.selectedProductName = selName;

        getMonthlySupplyDemand({
            productId: this.selId,
            organisationId: this.organisationId,
            selectedYear: this.selectedYear,
            fromDate: this.fromDate, // 'YYYY-MM-DD' from LWC
    toDate: this.toDate
        })
            .then(data => {
                // Your existing helper that draws the monthly line chart 
                this.processMonthlyDataForChart(data);
            })
            .catch(err => console.error('Error fetching monthly Supply/Demand', err));

        //     //for default country top 5
        //         this.selectedProductId = event.detail.recordId;
        //         this.isProductSelected = !!this.selectedProductId;
        //         this.fetchCountrySupplyDemand();
    }


    fetchSupplyDemandALL() {
        console.log('inside the fetch all');
        this.resolveSupplyOverviewData();
        console.log('resolve supply overview');
        //  if (this.issuppydemandloaded ) {
        //     console.log('callig resolve by country');
        this.resolveCountrySupplyDemand();
        //     console.log('aftr calling resolve');
        // }  
    }



    // Optional: Clear chart if product is deselected
    // handleRemoveInventoryProduct() {
    //     this.inventoryProduct = {};
    //     this.selectedProductId = null;
    //     this.selectedYear = '';
    //     this.destroyChart('supplyForecastChart');
    //     console.log('❌ Product deselected, chart removed');
    // }

    //top 5 supply demand

    // ───────────────────────────────── Top‑5 overview ───────────────────────── 
    loadTopFive() {
        console.log('in load top 5');

        if (!this.chartJsReady) return;

        getTop5SupplyAndDemand({
            organisationId: this.organisationId,
            selectedYear: this.selectedYear,
            fromDate: this.fromDate, // 'YYYY-MM-DD' from LWC
    toDate: this.toDate
        })
            .then(rows => {
                this.topFiveRows = rows;

                // rows already carry rankingType
                console.log('rows =>', rows);

                console.log('before calling render top 5');
                this.processTopFiveChartData(rows);


                // ⬅️ DOM will be ready now
            })
            .catch(e => console.error('Apex error (Top‑5)', e));
    }

    // get canvasContext() {
    //     const canvas = this.template.querySelector('.main-chart');
    //     if (!canvas) {
    //         console.error('❌ Canvas not found in DOM when trying to render chart');
    //         return null;
    //     }
    //     return canvas.getContext('2d');
    // }

    processTopFiveChartData(data) {
        console.log('in processTopFiveChartData');

        const demandRows = data.filter(r => r.rankingType === 'Demand');
        const supplyRows = data.filter(r => r.rankingType === 'Supply');

        // Full product names
        const fullLabels = demandRows.map(r => r.productName);

        // Truncated for X-axis
        const labels = fullLabels.map(name =>
            name.length > 10 ? name.substring(0, 10) + '...' : name
        );

        const supplyByName = new Map(
            supplyRows.map(r => [r.productName, r.totalSupply])
        );

        const demandData = demandRows.map(r => r.totalDemand);
        const supplyData = fullLabels.map(name => supplyByName.get(name) || 0);

        this.initializeTopFiveChart(labels, supplyData, demandData, fullLabels);
    }


    // processTopFiveChartData(data) {
    //     console.log('in processTopFiveChartData');

    //     const demandRows = data.filter(r => r.rankingType === 'Demand');
    //     const supplyRows = data.filter(r => r.rankingType === 'Supply');

    //     const labels = demandRows.map(r => r.productName);
    //     const supplyByName = new Map(
    //         supplyRows.map(r => [r.productName, r.totalSupply])
    //     );
    //     const demandData = demandRows.map(r => r.totalDemand);
    //     const supplyData = labels.map(name => supplyByName.get(name) || 0);

    //     console.log('📊 Top 5 Demand:', demandData);
    //     console.log('📊 Top 5 Supply:', supplyData);

    //     this.initializeTopFiveChart(labels, supplyData, demandData);
    // }

    initializeTopFiveChart(labels, supply, demand, fullLabels) {
        const canvas = this.template.querySelector('.main-chart');
        if (!canvas) {
            console.error('❌ Canvas for Top 5 chart not found in DOM');
            return;
        }

        const ctx = canvas.getContext('2d');
        this.destroyChart('topFiveChart');
        this.chartInstances.topFiveChart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels, // Truncated labels for x-axis
                datasets: [
                    {
                        label: 'Demand',
                        data: demand,
                        backgroundColor: 'rgba(50, 144, 237, 0.7)',
                        borderColor: '#3290ED',
                        borderWidth: 1
                    },
                    {
                        label: 'Supply',
                        data: supply,
                        backgroundColor: 'rgba(157, 83, 242, 0.7)',
                        borderColor: '#9D53F2',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                responsive: true,
                interaction: {
                    mode: 'nearest',       // ✅ Picks the nearest data point along x-axis
                    axis: 'x',
                    intersect: false       // ✅ Works even when hovering on x-axis label
                },
                plugins: {
                    legend: { position: 'top' },
                    title: {
                        display: true,
                        text: 'Top 5 Products by Demand & Supply'
                    },
                    tooltip: {
                        mode: 'index',      // ✅ Show both demand/supply for the same product
                        intersect: false,
                        callbacks: {
                            title: (tooltipItems) => {
                                const index = tooltipItems[0].dataIndex;
                                return fullLabels[index]; // ✅ Show full label in tooltip
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        ticks: {
                            maxRotation: 0,
                            minRotation: 0
                        },
                        title: {
                            display: true,
                            text: 'Product'
                        }
                    },
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Units'
                        }
                    }
                }
            }
        });

        console.log('✅ Top 5 Chart initialized with truncated X labels + full hover tooltips');
    }


    //for default getTop5CountrySupplyDemand

    loadTop5CountrySupplyDemand() {
        console.log('🌍 Loading top 5 country-level supply/demand');

        if (!this.chartJsReady) return;

        getTop5CountrySupplyDemand({
            organisationId: this.organisationId,
            selectedYear: this.selectedYear,
            fromDate: this.fromDate,
    toDate: this.toDate
        })
            .then(rows => {
                this.topCountryRows = rows;
                console.log('🌍 Country rows =>', rows);

                this.processTop5CountryChartData(rows);
            })
            .catch(e => {
                console.error('❌ Apex error (Top‑5 Country Supply/Demand)', e);
            });
    }

    processTop5CountryChartData(data) {
        const labels = data.map(r => r.country);
        const demandData = data.map(r => r.totalDemand);
        const supplyData = data.map(r => r.totalSupply);

        this.initializeTop5CountryChart(labels, supplyData, demandData);
    }

    initializeTop5CountryChart(labels, supply, demand) {
        const canvas = this.template.querySelector('.country-chart'); // Ensure correct selector
        if (!canvas) {
            console.error('❌ Canvas for Top 5 Country Chart not found');
            return;
        }

        const ctx = canvas.getContext('2d');
        this.destroyChart('topFiveCountryChart');
        this.chartInstances.topFiveCountryChart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Demand',
                        data: demand,
                        backgroundColor: 'rgba(255, 99, 132, 0.6)',
                        borderColor: '#FF6384',
                        borderWidth: 1
                    },
                    {
                        label: 'Supply',
                        data: supply,
                        backgroundColor: 'rgba(54, 162, 235, 0.6)',
                        borderColor: '#36A2EB',
                        borderWidth: 1
                    }
                ]
            },
            options: {
                responsive: true,
                interaction: {
                    mode: 'nearest',
                    axis: 'x',
                    intersect: false // ✅ Enables tooltip on x-axis label and empty space
                },
                plugins: {
                    legend: { position: 'top' },
                    title: {
                        display: true,
                        text: 'Top 5 Countries by Demand & Supply'
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false // ✅ Tooltip appears even if not directly over a bar
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Units'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Country'
                        }
                    }
                }
            }
        });


        console.log('✅ Top 5 Country Chart initialized');
    }



    //renders the supply and demand

    processMonthlyDataForChart(data) {
        const monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        const supplyData = new Array(12).fill(0);
        const demandData = new Array(12).fill(0);

        data.forEach(item => {
            const index = item.month - 1; // months are 1-indexed
            supplyData[index] = item.totalSupply || 0;
            demandData[index] = item.totalDemand || 0;
        });

        this.initializeSupplyForecastChart(monthLabels, supplyData, demandData);
        this.issuppydemandloaded = true;
    }

    initializeSupplyForecastChart(labels, supply, demand) {
        // const canvas = this.template.querySelector('.main-chart');
        const canvas = this.template.querySelector('.supply-forecast-chart');
        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        this.destroyChart('supplyForecastChart');

        this.chartInstances.supplyForecastChart = new window.Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Supply',
                        data: supply,
                        borderColor: '#9D53F2',
                        backgroundColor: 'rgba(157, 83, 242, 0.1)',
                        fill: true,
                        tension: 0.4,
                        borderWidth: 2
                    },
                    {
                        label: 'Demand',
                        data: demand,
                        borderColor: '#3290ED',
                        backgroundColor: 'rgba(50, 144, 237, 0.1)',
                        fill: true,
                        tension: 0.4,
                        borderWidth: 2
                    }
                ]
            },
            options: {
                responsive: true,
                interaction: {
                    mode: 'nearest',
                    axis: 'x',
                    intersect: false // ✅ enables tooltip on x-axis label and empty space
                },
                plugins: {
                    legend: { position: 'top' },
                    title: {
                        display: true,
                        text: 'Monthly Supply vs Demand'
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false // ✅ show both supply & demand on label hover
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Units'
                        }
                    },
                    x: {
                        title: {
                            display: true,
                            text: 'Month'
                        }
                    }
                }
            }
        });
    }

    destroyChart(chartKey) {
        if (this.chartInstances[chartKey]) {
            this.chartInstances[chartKey].destroy();
            delete this.chartInstances[chartKey];
        }
    }



    //supplier score card

    loadChartJs() {
        if (this.chartJsInitialized) return;

        loadScript(this, chartJs)
            .then(() => {
                this.chartJsInitialized = true;
                console.log('ChartJS loaded');
            })
            .catch((error) => {
                console.error('Error loading ChartJS', error);
            });
    }

    generateYearOptions() {
        const currentYear = new Date().getFullYear();
        const years = [];
        for (let i = currentYear; i >= currentYear - 5; i--) {
            years.push({ label: i.toString(), value: i });
        }
        return years;
    }

    handleYearChangeSup(event) {
        this.selectedYearSup = parseInt(event.detail.value, 10);
        this.fetchSupplierData();
    }

    handleVendorSelect(event) {
        const vendor = event.detail;
        // if (vendor == null) {
        //     this.destroyChart('spendChart');
        //     this.destroyChart('countryBreakdownChart');
        //     this.destroyChart('onTimeDeliveryChart');

        // }
        this.selectedVendorId = vendor.Id;
        this.selectedVendorName = vendor.Name;
        this.fetchSupplierData();
    }
    fetchSupplierData() {
        console.log("📥 In fetchSupplierData");

        const filtersMissing = !this.selectedVendorId || !this.selectedYearSup || !this.organisationId;

        // If filters are missing, render empty charts with axis only
        if (filtersMissing) {
            console.warn('⚠️ Missing filters: rendering empty chart');
            this.renderOnTimeDeliveryChart([]);
            this.renderSpendChart([]);
            this.renderQualityChart([]);

            return;
        }

        // ✅ All filters present → fetch real data
        getSpendOverTime({
            vendorId: this.selectedVendorId,
            organisationId: this.organisationId,
            year: this.selectedYearSup
        })
            .then((spendData) => {
                console.log('📊 Spend Over Time:', spendData);
                this.renderSpendChart(spendData);
            })
            .catch(error => {
                console.error('❌ Error fetching spend over time', error);
                this.renderSpendChart([]); // Fallback
            });

        getOnTimeDeliveryMapped({
            vendorId: this.selectedVendorId,
            organisationId: this.organisationId,
            year: this.selectedYearSup
        })
            .then((deliveryData) => {
                console.log('🚚 On-Time Delivery Data:', deliveryData);
                this.deliveryData = deliveryData;
                this.renderOnTimeDeliveryChart(this.deliveryData);
            })
            .catch((error) => {
                console.error('❌ Error fetching On-Time Delivery data:', error);
                this.renderOnTimeDeliveryChart([]); // Fallback
            });

        getMonthlyQualityData({
            vendorId: this.selectedVendorId,
            // vendorContactId: this.selectedVendorContactId,
            organisationId: this.organisationId,
            year: this.selectedYearSup
        })

            .then((qualitydata) => {
                console.log('🚚 Quality Data ab:', qualitydata);
                this.qualitydata = qualitydata;
                console.log("Before renderQualityChart");

                setTimeout(() => {
                    this.renderQualityChart(this.qualitydata);
                }, 0);
                console.log("After renderQualityChart");

            })
            .catch(error => {
                console.error(' ❌ Error fetching quality data', error);
            });

        // getSupplierScorecardData({

        //     vendorId: this.selectedVendorId,
        //     year: this.selectedYearSup
        // }).then((result) => {
        //     console.log('📦 Scorecard Data:', result);

        //      this.renderSpendChart(result.spendOverTime);
        //     this.renderDeliveryChart(result.onTimeDelivery);
        //     this.renderQualityChart(result.qualityAnalysis);
        // }).catch((error) => {
        //     console.error('Error fetching scorecard data', error);
        // });
    }

    destroyChart(chartKey) {
        if (this.chartInstances[chartKey]) {
            this.chartInstances[chartKey].destroy();
            this.chartInstances[chartKey] = null;
        }
    }

    // renderSpendChart(data) {
    //     const ctx = this.template.querySelector('.spend-over-time-chart')?.getContext('2d');
    //     if (!ctx) return;
    //     this.destroyChart('spendChart');

    //     const labels = data.map(d => d.month); // e.g. 'January'
    //     const amounts = data.map(d => d.amount);

    //     this.chartInstances.spendChart = new window.Chart(ctx, {
    //         type: 'line',
    //         data: {
    //             labels,
    //             datasets: [{
    //                 label: 'Spend (₹)',
    //                 data: amounts,
    //                 borderColor: '#0070d2',
    //                 backgroundColor: 'rgba(0, 112, 210, 0.3)',
    //                 tension: 0.3,
    //                 fill: true
    //             }]
    //         }
    //     });
    // }


    // renderDeliveryChart(data) {
    //     const ctx = this.template.querySelector('.on-time-delivery-chart')?.getContext('2d');
    //     if (!ctx) return;
    //     this.destroyChart('deliveryChart');

    //     const labels = data.map(d => d.product);
    //     const expected = data.map(d => new Date(d.expectedDate).getTime());
    //     const actual = data.map(d => new Date(d.actualDate).getTime());
    //     const ordered = data.map(d => new Date(d.orderedDate).getTime());

    //     const diffDays = (from, to) => Math.round((to - from) / (1000 * 60 * 60 * 24));

    //     this.chartInstances.deliveryChart = new window.Chart(ctx, {
    //         type: 'bar',
    //         data: {
    //             labels,
    //             datasets: [
    //                 {
    //                     label: 'Lead Time (days)',
    //                     data: data.map(d => d.leadTimeDays),
    //                     backgroundColor: '#6a0dad'
    //                 },
    //                 {
    //                     label: 'Delay (days)',
    //                     data: data.map(d => Math.max(0, diffDays(new Date(d.expectedDate), new Date(d.actualDate)))),
    //                     backgroundColor: '#ff0000'
    //                 }
    //             ]
    //         },
    //         options: {
    //             responsive: true,
    //             scales: {
    //                 x: { stacked: true },
    //                 y: { stacked: true, beginAtZero: true }
    //             }
    //         }
    //     });
    // }



    renderCountryChart() {

        // if (!this.countrySupplyDemandData || this.countrySupplyDemandData.length === 0) {
        //     console.warn('⚠️ No country supply/demand data available');
        //     return;
        // }

        // console.log('this.countrySupplyDemandData=>',this.countrySupplyDemandData);


        console.log('in renderCountryChart');

        console.log("in render country xhart");

        const canvas = this.template.querySelector('.breakdown-placeholder-chart');
        if (!canvas) {
            console.log('✅ ');

            console.warn('❌ No canvas found for country chart');
            return;
        }

        const countries = this.countrySupplyDemandData.map(item => item.country);
        const demand = this.countrySupplyDemandData.map(item => item.totalDemand);
        const supply = this.countrySupplyDemandData.map(item => item.totalSupply);

        console.log("country", countries);
        console.log("demand", demand);
        console.log("supply", supply);

        // const canvas = this.template.querySelector('.breakdown-placeholder-chart');
        console.log('✅ Canvas element found:', canvas);

        if (!canvas) return;

        const ctx = canvas.getContext('2d');
        this.destroyChart('countryBreakdownChart'); // clear previous

        console.log('rendering bar chart');

        this.chartInstances.countryBreakdownChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: countries,
                datasets: [
                    {
                        label: 'Demand',
                        data: demand,
                        backgroundColor: '#3290ED',
                        borderColor: '#3290ED',
                        borderWidth: 1, // reduced thickness

                    },
                    {
                        label: 'Supply',
                        data: supply,
                        backgroundColor: '#9D53F2',
                        borderColor: '#9D53F2',
                        borderWidth: 1 // reduced thickness
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: 'Supply vs Demand by Country'
                    }
                },

                scales: {
                    y: {
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Units'
                        }
                    }
                }
            }
        });
    }


    renderSpendChart(data) {

        const canvas = this.template.querySelector('.spend-over-time-chart');
        if (!canvas) return;
        const ctx = this.template.querySelector('.spend-over-time-chart')?.getContext('2d');
        // if (!ctx) return;
        this.destroyChart('spendChart');

        const monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        // Convert input data into a map for quick access
        const monthToAmount = {};
        data.forEach(item => {
            monthToAmount[item.month] = item.amount;
        });

        // Build amounts in fixed month order
        const amounts = monthLabels.map(label => {
            // Match full month names to labels
            const fullMonthNames = {
                'January': 'Jan', 'February': 'Feb', 'March': 'Mar', 'April': 'Apr',
                'May': 'May', 'June': 'Jun', 'July': 'Jul', 'August': 'Aug',
                'September': 'Sep', 'October': 'Oct', 'November': 'Nov', 'December': 'Dec'
            };

            // Find corresponding full month key in data (e.g., "January")
            const match = Object.keys(fullMonthNames).find(
                full => fullMonthNames[full] === label
            );

            return monthToAmount[match] || 0;
        });

        this.chartInstances.spendChart = new window.Chart(ctx, {
            type: 'line',
            data: {
                labels: monthLabels,
                datasets: [{
                    label: `Spend (${this.currencySymbol})`,
                    data: amounts,
                    borderColor: '#9D53F2',
                    backgroundColor: 'rgba(157, 83, 242, 0.3)',
                    tension: 0.3,
                    fill: true,
                    borderWidth: 2 // reduced thickness
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'top' },
                    tooltip: {
                        mode: 'index',
                        intersect: false // triggers tooltip on X label hover
                    }
                },
                scales: {
                    y: { beginAtZero: true }
                }
            }
        });
    }


    renderOnTimeDeliveryChart(data) {
        const ctx = this.template.querySelector('.on-time-delivery-chart')?.getContext('2d');
        if (!ctx) {
            console.warn('ChartJS canvas context not found.');
            return;
        }

        this.destroyChart('onTimeDeliveryChart');

        const monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        // Default 0-values if no data or filters not selected
        let onTimeData = new Array(12).fill(0);
        let lateData = new Array(12).fill(0);

        if (Array.isArray(data) && data.length > 0) {
            const deliveryMap = {};
            monthLabels.forEach(label => {
                deliveryMap[label] = { onTime: 0, late: 0 };
            });

            data.forEach(entry => {
                const rawMonth = entry.month; // e.g., "1/2025"
                if (!rawMonth.includes('/')) return;

                const [monthStr] = rawMonth.split('/');
                const monthIndex = parseInt(monthStr, 10) - 1;
                const monthLabel = monthLabels[monthIndex];

                if (monthLabel) {
                    deliveryMap[monthLabel].onTime += entry.onTime || 0;
                    deliveryMap[monthLabel].late += entry.late || 0;
                }
            });

            onTimeData = monthLabels.map(label => deliveryMap[label].onTime);
            lateData = monthLabels.map(label => deliveryMap[label].late);
        }

        // Render the chart with either real or empty data
        this.chartInstances.onTimeDeliveryChart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: monthLabels,
                datasets: [
                    {
                        label: 'On Time',
                        backgroundColor: '#9D53F2',
                        data: onTimeData,
                        stack: 'stack1'
                    },
                    {
                        label: 'Late',
                        backgroundColor: '#3290ED',
                        data: lateData,
                        stack: 'stack1'
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'top' },
                    title: {
                        display: true,
                        text: 'On-Time Delivery Performance'
                    },
                    tooltip: {
                        mode: 'index',
                        intersect: false // ← show tooltip even when not directly over a bar
                    }
                },
                interaction: {
                    mode: 'nearest',
                    axis: 'x',
                    intersect: false // ← show tooltip even on the x-axis label
                },

                scales: {
                    x: {
                        stacked: true,
                        title: { display: true, text: 'Month' }
                    },
                    y: {
                        stacked: true,
                        beginAtZero: true,
                        title: { display: true, text: 'Deliveries' },
                        ticks: { precision: 0 }
                    }
                }
            }
        });
    }



    //Quality analysis chart

    renderQualityChart(data) {
        const ctx = this.template.querySelector('.quality-analysis-chart')?.getContext('2d');
        if (!ctx) {
            console.warn('⚠️ ChartJS canvas context not found for quality chart.');
            return;
        }

        this.destroyChart('qualityChart');

        const monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        let goodData = [];
        let badData = [];

        for (let i = 1; i <= 12; i++) {
            const monthData = data[i] || { good: 0, bad: 0 };
            goodData.push(monthData.good);
            badData.push(monthData.bad);
        }

        this.chartInstances.qualityChart = new window.Chart(ctx, {
            type: 'bar',
            data: {
                labels: monthLabels,
                datasets: [
                    {
                        label: 'Good Quality',
                        backgroundColor: '#9D53F2',
                        data: goodData,
                        stack: 'stack1'
                    },
                    {
                        label: 'Bad Quality',
                        backgroundColor: '#3290ED',
                        data: badData,
                        stack: 'stack1'
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'top' },
                    title: {
                        display: true,
                        text: 'Monthly Quality Performance'
                    },
                    tooltip: {
                        mode: 'index',         // Show all bars at the same x-axis index
                        intersect: false        // Show tooltip even if not directly over the bar
                    }
                },
                interaction: {
                    mode: 'nearest',          // Nearest point on the x-axis
                    axis: 'x',
                    intersect: false          // Allow tooltip on x-axis hover
                },
                scales: {
                    x: {
                        stacked: true,
                        title: {
                            display: true,
                            text: 'Month'
                        }
                    },
                    y: {
                        stacked: true,
                        beginAtZero: true,
                        title: {
                            display: true,
                            text: 'Line Items'
                        },
                        ticks: {
                            precision: 0
                        }
                    }
                }
            }
        });
        // --- Generate Text Summary ---
        // const summaryContainer = this.template.querySelector('.quality-summary');
        // if (summaryContainer) {
        //     let summaryHtml = `<table style="margin-top: 1rem; border-collapse: collapse;">
        //     <thead>
        //         <tr style="font-weight: bold;">
        //             <td style="padding: 4px 8px;">Month</td>
        //             <td style="padding: 4px 8px; color: #36a2eb;">Good Quality</td>
        //             <td style="padding: 4px 8px; color: #ff6384;">Bad Quality</td>
        //         </tr>
        //     </thead>
        //     <tbody>`;

        //     for (let i = 0; i < 12; i++) {
        //         summaryHtml += `
        //         <tr>
        //             <td style="padding: 4px 8px;">${monthLabels[i]}</td>
        //             <td style="padding: 4px 8px;">${goodData[i]}</td>
        //             <td style="padding: 4px 8px; ">${badData[i]}</td>
        //         </tr>`;
        //     }

        //     summaryHtml += `</tbody></table>`;
        //     summaryContainer.innerHTML = summaryHtml;
        // }

        const summaryContainer = this.template.querySelector('.quality-summary');
if (summaryContainer) {
    let summaryHtml = `
        <table style="margin-top: 1rem; border-collapse: collapse; width: 100%;">
            <thead>
                <tr style="font-weight: bold; background-color: #f3f3f3;">
                    <td style="padding: 6px 10px;">📅 Month</td>
                    <td style="padding: 6px 10px; color: #36a2eb;">✅ Good Quality</td>
                    <td style="padding: 6px 10px; color: #ff6384;">❌ Bad Quality</td>
                </tr>
            </thead>
            <tbody>`;

    let hasData = false;

    for (let i = 0; i < 12; i++) {
        const good = goodData[i];
        const bad = badData[i];

        if (good === 0 && bad === 0) {
            continue; // ❌ Skip months with no data
        }

        hasData = true;

        summaryHtml += `
            <tr>
                <td style="padding: 6px 10px;">${monthLabels[i]}</td>
                <td style="padding: 6px 10px;">${good}</td>
                <td style="padding: 6px 10px;">${bad}</td>
            </tr>`;
    }

    summaryHtml += `
            </tbody>
        </table>`;

    summaryContainer.innerHTML = hasData ? summaryHtml : `<p style="margin-top:1rem;">📭 No quality data available for this year.</p>`;
}

    }

    //Inventory overview

    // handleMoClick(event) {
    //     const recordId = event.currentTarget.dataset.id;
    //     window.open('/' + recordId, '_blank');
    // }

    // handleProductSelection(event) {
    //     console.log('Lookup Event:', JSON.stringify(event.detail));
    //     this.productId = event.detail.Id;
    //     this.productName = event.detail.Name;
    // }

    // handleFromDateChange(event) {
    //     this.fromDate = event.target.value;
    //     console.log('From Date selected:', this.fromDate);
    // }

    // handleToDateChange(event) {
    //     this.toDate = event.target.value;
    //     console.log('To Date selected:', this.toDate);
    // }


    // handleSearch() {
    //     console.log('handle search');
    //     console.log('Product ID:', this.productId);
    //     console.log('From Date:', this.fromDate);
    //     console.log('To Date:', this.toDate);

    //     if (this.productId && this.fromDate && this.toDate) {
    //         console.log("AZ product Id ==>>", this.productId);
    //         console.log('calling the apex====');

    //         getInventoryByProductAndDate({
    //             productId: this.productId,
    //             fromDate: this.fromDate,
    //             toDate: this.toDate
    //         })
    //         .then(result => {
    //             this.inventoryData = result;
    //             console.log('AZ inventoryData==>>', this.inventoryData);
    //             this.showTable = true;
    //             this.error = null;
    //         })
    //         .catch(error => {
    //             console.error('Apex call failed:', error);
    //             this.error = error;
    //             this.showTable = false;
    //         });
    //     } else {
    //         console.warn('Search blocked: missing inputs');
    //     }
    // }


    // navigateToRecord(recordId) {
    //     window.open('/' + recordId, '_blank');
    // }



    // setFiscalDates() {
    //     const today = new Date();
    //     const month = today.getMonth() + 1;
    //     const year = month >= 4 ? today.getFullYear() : today.getFullYear() - 1;
    //     this.fromDate = `${year}-${startMonth}-01`;
    //     this.toDate = `${year + 1}-{addMonths(12)}-31`;
    // }

    // setFiscalDates(fromProductSelection = false) {
    //     return getOrgFiscalStartMonth()
    //         .then(startMonth => {
    //             const today = new Date();
    //             const currentMonth = today.getMonth() + 1;
    //             const fiscalYear = currentMonth >= startMonth ? today.getFullYear() : today.getFullYear() - 1;

    //             const fromDate = new Date(fiscalYear, startMonth - 1, 1);
    //             const toDate = new Date(fromDate);
    //             toDate.setMonth(toDate.getMonth() + 12);
    //             toDate.setDate(0); // Last day of the previous month

    //             this.fromDate = fromDate.toISOString().split('T')[0];
    //             this.toDate = toDate.toISOString().split('T')[0];

    //             console.log(`📆 Fiscal Dates Set - From: ${this.fromDate}, To: ${this.toDate}`);

    //             return Promise.resolve();
    //         })
    //         .catch(error => {
    //             console.error('Error fetching fiscal start month:', error);
    //             return Promise.reject(error);
    //         });


    // }



    setFiscalDates(fromProductSelection = false) {
        return getOrgFiscalStartMonth()
            .then(startMonth => {
                console.log('Start month: ', startMonth);

                const today = new Date();
                const currentMonth = today.getMonth() + 1;

                // Fiscal year starts this year if today is >= start month, else previous year
                let fiscalYearStart;
                if (currentMonth >= startMonth) {
                    fiscalYearStart = today.getFullYear();
                    console.log('if part today.getFullYear', today.getFullYear);

                } else {
                    fiscalYearStart = today.getFullYear() - 1;
                    console.log('else part today.getFullYear', today.getFullYear);

                }
                console.log('fiscalYearStart = ', fiscalYearStart);
                console.log('startMonth = ', startMonth);
                const fromDate = new Date(fiscalYearStart, startMonth - 1, 1); // e.g., Jan 1
                const toDate = new Date(fiscalYearStart, startMonth - 1 + 12, 0);

                console.log(`📆 Fiscal Dates Set - From: ${fromDate}, To: ${toDate}`);

                // this.fromDate = fromDate.toISOString().split('T')[0];
                // this.toDate = toDate.toISOString().split('T')[0];


                this.fromDate = formatDateLocal(fromDate);
                this.toDate = formatDateLocal(toDate);

                console.log(`📆 Fiscal Dates Set - From: ${this.fromDate}, To: ${this.toDate}`);

                // Optionally fetch data immediately if triggered by product selection
                // if (fromProductSelection && this.productId) {
                //     return this.fetchData();
                // }

                return Promise.resolve();
            })
            .catch(error => {
                console.error('Error fetching fiscal start month:', error);
                return Promise.reject(error);
            });
    }


    // setFiscalDates() {
    //     getOrgFiscalStartMonth()
    //         .then(startMonth => {
    //             const today = new Date();
    //             const currentMonth = today.getMonth() + 1;
    //             const fiscalYear = currentMonth >= startMonth ? today.getFullYear() : today.getFullYear() - 1;

    //             // Start of fiscal year
    //             const fromDate = new Date(fiscalYear, startMonth - 1, 1); // 1st day of startMonth

    //             // End of fiscal year
    //             const toDate = new Date(fiscalYear, startMonth - 1, 1);
    //             toDate.setMonth(toDate.getMonth() + 12); // Move 12 months ahead
    //             toDate.setDate(0); // Last day of previous month = last day of fiscal year

    //             // Format to yyyy-MM-dd
    //             this.fromDate = fromDate.toISOString().split('T')[0];
    //             this.toDate = toDate.toISOString().split('T')[0];

    //             if (triggerFetch && this.productId) {
    //                 // ✅ Auto-fetch for selected product with default dates
    //                 this.fetchData();
    //             }
    //         })
    //         .catch(error => {
    //             console.error('⚠️ Error fetching fiscal start month:', error);
    //         });
    // }

    handleProductSelection(event) {
        console.log('Lookup Event:', JSON.stringify(event.detail));
        this.productId = event.detail.Id;
        this.productName = event.detail.Name;

        // Optional: Clear existing chart
        if (this.chart) {
            this.chart.destroy();
            this.chart = null;
        }

        this.isSingleProductView = true;
        this.isTop5View = false;
        this.singleChartPending = true; // Optional: prepares canvas rendering

        // ⚠️ Call setFiscalDates and fetch data AFTER dates are set
        this.setFiscalDates(true).then(() => {
            this.fetchData(); // Now dates are ready
            // this.loadTop5Data();

        }).catch(error => {
            console.error('❌ Failed to set fiscal dates:', error);
        });

    }

    handleFromDateChange(event) {
        this.fromDate = event.target.value;
        console.log('From Date selected:', this.fromDate);
    }

    handleToDateChange(event) {
        this.toDate = event.target.value;
    }

    handleSearch() {
        console.log('🔍 handleSearch triggered');

        if (this.productId && this.fromDate && this.toDate) {
            console.log('📦 Fetching single product data:', this.productId, this.fromDate, this.toDate);

            this.fetchData(); // For selected product
        } else {
            console.log('🔄 Fallback to Top 5');

            this.loadTop5Data(); // Default fallback for top 5 products
        }
    }

    //     loadTop5Data() {
    //     getTop5Inventory()
    //         .then(result => {
    //             this.top5Data = result;
    //             this.inventoryLevelData = null;
    //             console.log('Call top 5 chart renderer');

    //             this.renderTop5Chart(); // Call top 5 chart renderer
    //         })
    //         .catch(error => {
    //             console.error('Error loading top 5 inventory:', error);
    //         });
    // }


    // fetchData() {
    //     getSummedInventory({
    //         productId: this.productId,
    //         fromDate: this.fromDate,
    //         toDate: this.toDate
    //     })
    //     .then(result => {
    //         this.inventoryLevelData = result;
    //         this.top5Data = null;
    //         this.renderChartSingleProductInventoryLevel(); // Call single-product chart renderer
    //     })
    //     .catch(error => {
    //         console.error('Error fetching inventory:', error);
    //     });
    // }

    loadTop5Data() {
        getTop5Inventory()
            .then(result => {
                this.top5Data = result;
                this.inventoryLevelData = null;
                this.isTop5View = true;
                this.isSingleProductView = false;
                this.top5ChartPending = true; // will trigger in renderedCallback
            })
            .catch(error => {
                console.error('Error loading top 5 inventory:', error);
            });
    }

    fetchData() {
        console.log('📤 Calling getSummedInventory Apex method...');
        console.log('📤 Fetching for:', this.productId, 'From:', this.fromDate, 'To:', this.toDate);


        getSummedInventory({
            productId: this.productId,
            fromDate: this.fromDate,
            toDate: this.toDate
        })
            .then(result => {
                console.log('✅ Received inventory data:', result);

                this.inventoryLevelData = result || {};
                this.top5Data = null;
                this.isTop5View = false;
                this.isSingleProductView = true;
                this.singleChartPending = true; // will trigger in renderedCallback
                console.log('inventoryLevelData====>>> AZAZ', this.inventoryLevelData);

                this.renderInitial();

            })
            .catch(error => {
                console.error('Error fetching inventory:', error);
            });
    }
    renderedCallback() {
        this.renderInitial();
    }

    renderInitial() {
        console.log('in render call back');

        if (this.chartJsReady) {
            if (this.top5ChartPending && this.isTop5View) {
                const canvas = this.template.querySelector('canvas.barChartTop5');
                if (canvas) {
                    this.renderTop5Chart();
                    this.setFiscalDates();
                    this.top5ChartPending = false;
                }
            }

            if (this.singleChartPending && this.isSingleProductView) {
                console.log('🔍 Looking for single chart canvas...');

                const canvas = this.template.querySelector('canvas.barChartSingle');
                if (canvas) {
                    console.log('🎯 Canvas found, rendering chart...');

                    this.renderChartSingleProductInventoryLevel();
                    this.singleChartPending = false;
                } else {
                    console.warn('🕳️ Canvas not in DOM yet.');
                }
            }
        }
    }

    get rawExpected() {
        return this.inventoryLevelData?.totalExpectedRaw ?? 0;
    }
    get rawConsumed() {
        return this.inventoryLevelData?.totalConsumedRaw ?? 0;
    }
    get rawScrapped() {
        return this.inventoryLevelData?.totalScrappedRaw ?? 0;
    }
    get wipQuantity() {
        return this.inventoryLevelData?.totalWipQuantity ?? 0;
    }
    get wipScrapped() {
        return this.inventoryLevelData?.totalWipScrapped ?? 0;
    }
    get finishedRequested() {
        return this.inventoryLevelData?.totalFinishedRequested ?? 0;
    }
    get finishedInStock() {
        return this.inventoryLevelData?.totalFinishedInStock ?? 0;
    }
    get finishedScrapped() {
        return this.inventoryLevelData?.totalFinishedScrapped ?? 0;
    }

    renderChartSingleProductInventoryLevel() {
        console.log('before return renderChartSingleProductInventoryLevel', this.inventoryLevelData);
        console.log('before return this.chartJsReady', this.chartJsReady);

        if (!this.chartJsReady || !this.inventoryLevelData) return;
        console.log('inventoryLevelData===>>>', this.inventoryLevelData);

        // Wait until canvas is in DOM
        setTimeout(() => {
            const canvas = this.template.querySelector('canvas.barChartSingle');
            if (!canvas) {
                console.warn('⚠️ Single product canvas not found');
                return;
            }

            const ctx = canvas.getContext('2d');
            if (this.chart) {
                this.chart.destroy();
                this.chart = null;

            }

            this.chart = new window.Chart(ctx, {
                type: 'bar',
                data: {
                    labels: ['Raw', 'WIP', 'Finished'],
                    datasets: [
                        {
                            label: 'Expected',
                            data: [
                                this.inventoryLevelData.totalExpectedRaw,
                                this.inventoryLevelData.totalWipQuantity,
                                this.inventoryLevelData.totalFinishedRequested
                            ],
                            backgroundColor: '#0070d2'
                        },
                        {
                            label: 'Consumed / In Stock',
                            data: [
                                this.inventoryLevelData.totalConsumedRaw,
                                this.inventoryLevelData.totalWipScrapped,
                                this.inventoryLevelData.totalFinishedInStock
                            ],
                            backgroundColor: '#00c853'
                        },
                        {
                            label: 'Scrapped',
                            data: [
                                this.inventoryLevelData.totalScrappedRaw,
                                this.inventoryLevelData.totalWipScrapped,
                                this.inventoryLevelData.totalFinishedScrapped
                            ],
                            backgroundColor: '#d50000'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { position: 'top' },
                        title: {
                            display: true,
                            text: this.productName
                                ? `Inventory Summary for ${this.productName}`
                                : 'Inventory Summary for Fiscal Year'
                        },
                        tooltip: {
                            mode: 'index',     // ✅ Show tooltip for all datasets at a label
                            intersect: false
                        }
                    }
                }
            });
        }, 0); // Defer until DOM is rendered
    }

    renderTop5Chart() {
        if (!this.chartJsReady || !this.top5Data || this.top5Data.length === 0) {
            console.warn('🚫 Top 5 data not available or Chart.js not ready');
            return;
        }

        console.log('📊 Top 5 data:', JSON.stringify(this.top5Data));

        // Wait until canvas is rendered in DOM
        setTimeout(() => {
            const canvas = this.template.querySelector('canvas.barChartTop5');
            if (!canvas) {
                console.warn('⚠️ Top 5 inventory canvas not found');
                return;
            }

            const ctx = canvas.getContext('2d');
            if (this.chart) this.chart.destroy();


            const labels = this.top5Data.map(item => item.productName);
            const raw = this.top5Data.map(item => item.totalExpectedRaw);
            const wip = this.top5Data.map(item => item.totalWipQuantity);
            const finished = this.top5Data.map(item => item.totalFinishedInStock);
            //         console.log('Labels:', labels);
            // console.log('Raw:', raw);
            // console.log('WIP:', wip);
            // console.log('Finished:', finished);
            // const labels = this.top5Data.map(item => item.productName);
            // const raw = this.top5Data.map(item => item.totalRaw);
            // const wip = this.top5Data.map(item => item.totalWip);
            // const finished = this.top5Data.map(item => item.totalFinished);

            this.chart = new window.Chart(ctx, {
                type: 'bar',
                data: {
                    labels,
                    datasets: [
                        { label: 'Raw', backgroundColor: '#1f77b4', data: raw },
                        { label: 'WIP', backgroundColor: '#ff7f0e', data: wip },
                        { label: 'Finished', backgroundColor: '#2ca02c', data: finished }
                    ]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: { position: 'top' },
                        title: {
                            display: true,
                            text: 'Top 5 Products Inventory Summary (Current Fiscal Year)'
                        },
                        tooltip: {
                            mode: 'index',
                            intersect: false
                        }
                    },
                    scales: {
                        x: { stacked: true },
                        y: { stacked: true }
                    }
                }
            });
        }, 0); // Wait for render cycle
    }


}*/