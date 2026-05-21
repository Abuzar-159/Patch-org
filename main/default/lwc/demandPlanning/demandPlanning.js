import { LightningElement, track, api } from 'lwc';
import chartJs from '@salesforce/resourceUrl/ChartJS';
import { loadScript } from 'lightning/platformResourceLoader';
//import getDemandData from '@salesforce/apex/sandOP.getDemandData';
import getTopProductsByDemand from '@salesforce/apex/sandOP.getTopProductsByDemand';
import getWarehouseInventory from '@salesforce/apex/sandOP.getWarehouseInventory';
import getLocationInventory from '@salesforce/apex/sandOP.getLocationInventory';
import getStockAlertData from '@salesforce/apex/sandOP.getStockAlertData';
import getAgingTrendData from '@salesforce/apex/sandOP.getAgingTrendData';
import getCustomerOrderTrend from '@salesforce/apex/sandOP.getCustomerOrderTrend';
import getCustomerSummary from '@salesforce/apex/sandOP.getCustomerSummary';
import getDynamicStockAgingData from '@salesforce/apex/sandOP.getDynamicStockAgingData';
import getDemandForecastWithHistory from '@salesforce/apex/sandOP.getDemandForecastWithHistory';
import getTopCustomersForProduct from '@salesforce/apex/sandOP.getTopCustomersForProduct';
import getDefaultProductFromOrderItem from '@salesforce/apex/sandOP.getDefaultProductFromOrderItem';
import getDefaultCustomerFromOrders from '@salesforce/apex/sandOP.getDefaultCustomerFromOrders';
import getDefaultWarehouseByStock from '@salesforce/apex/sandOP.getDefaultWarehouseByStock';
import generateForecastFromHistorical from '@salesforce/apex/sandOP.generateForecastFromHistorical';
import { NavigationMixin } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DemandPlanning extends NavigationMixin(LightningElement) {
    @track isDemandProductSel = false;
    @track isWarehouseSelectedForAging = false;
    @track isDemand = false;
    @track isInventory = false;
    @api organisationId;
    @api isDemandTabOpen;
    @api isInventoryTabOpen;
    @track isSiteSlectSelected = false;
    @track selectedProduct = { Id: null, Name: null };
    @track custProd = { Id: null, Name: null };
    @track selectedSite = { Id: null, Name: null };
    @track selectedLocation = { Id: '', Name: '' };
    @track siteFilter;
    @track demandData = {};
    @track topProductsData = {};
    @track showallWarehouses = false;
    chartJsInitialized = false;
    charts = {};
    @track selectedWarehouse = null;
    @track selectedWarehouseForSafetyStock = { Id: null, Name: null };
    @track isWarehouseSelectedForsafetyStock = false;
    @track locationFIlter = '';
    @track inventoryData = {};
    @track locationInventoryData = {};
    @track isLoading = false;
    @track inventoryProduct = { Id: '', Name: '' };
    @track isSafety = false;
    @api isSafetyTabOpen;
    @track safetyStockData = [];
    @track filteredSafetyStockData = [];
    @track selectedProductFilterForSafetyStock = '';
    @track warehouseOptions = [];
    @track locationOptions = [];
    @track productOptions = [];
    stockTableColumns = [
    { label: 'Product', fieldName: 'productName' },
    { label: 'Warehouse', fieldName: 'warehouse' },
    { label: 'Location', fieldName: 'location' },
    { label: 'Current Stock', fieldName: 'currentStock', type: 'number' },
    { label: 'Reorder Level', fieldName: 'reorderLevel', type: 'number' },
    { label: 'Safety Stock', fieldName: 'safetyStock', type: 'number' },
    {
  label: 'Status',
  fieldName: 'badgeLabel',
  cellAttributes: {
    class: { fieldName: 'badgeClass' }
  }
}
];
@track selectedWarehouseForAging = {Id:null,Name:null};
@track isAging = false;
@api isAgingTabOpen;
@track stockAgingData = [];
filteredAgingData = [];
agingTableColumns = [
    { label: 'Product', fieldName: 'productName', sortable: true },
    { label: 'Quantity', fieldName: 'quantity', type: 'number', sortable: true },
    { label: 'Received Date', fieldName: 'receivedDate', type: 'date', sortable: true },
    { label: 'Age (Days)', fieldName: 'ageInDays', type: 'number', sortable: true },
    { label: 'Bucket', fieldName: 'bucket', sortable: true },
    {
        label: 'Status',
        fieldName: 'status',
        sortable: true,
        cellAttributes: {
            class: { fieldName: 'statusClass' }
        }
    }
];

@track agingFilters = {
    product: '',
    bucket: '',
    status: ''
};
@track isCustomerSelected = false;
@track productOptionsAging = [];
@track bucketOptions = [
    { label: '<30d', value: '<30d' },
    { label: '30–90d', value: '30–90d' },
    { label: '90–180d', value: '90–180d' },
    { label: '180–365d', value: '180–365d' },
    { label: '>365d', value: '>365d' },
     { label: 'Expired', value: 'Expired' } 
];

@track statusOptions = [
    { label: 'Fresh', value: 'Fresh' },
    { label: 'Slow Moving', value: 'Slow Moving' },
    { label: 'Aging', value: 'Aging' },
    { label: 'At Risk', value: 'At Risk' },
    { label: 'Obsolete', value: 'Obsolete' },
     { label: 'Expired', value: 'Expired' } 
];
@track agingTrendData = [];
shouldRenderAgingTrend = false;
// Sorting
sortBy = 'productName';
sortDirection = 'asc';

// Pagination
pageSize = 10;
currentPage = 1;

@track yearOptions = this.generateYearOptions();
@track selectedYear;
@track isCustomerPattern = false;
@api isCustomerPatternTabOpen;
@track selectedCustomer = { Id: null, Name: null };
@track customerFilter="";
@track selectedCustomerYear;
@track customerYearOptions = [];

@track customerSummary = {
    frequency: null,
    monetary: null,
    recencyDays: null,
    lastOrderDate: null
};

@track showSimulationPanel = false;
@track simulationHasRun = false;
@track simulationInputs = [];
@track simulatedForecast = [];
@track fullHistoricalLabels = [];  
@track fullHistoricalValues = [];
@track futureForecastInputs = [];
@track selectedModel = 'HOLT_WINTERS';

@track modelOptions = [
    { label: 'Holt-Winters (Seasonal)', value: 'HOLT_WINTERS' },
    { label: 'Moving Average', value: 'MOVING_AVERAGE' }
];

generateYearOptions() {
        const currentYear = new Date().getFullYear();
        const years = [];
        for (let i = currentYear; i >= currentYear - 5; i--) {
            years.push({ label: i.toString(), value: i });
        }
        return years;
}
get totalPages() {
    return this.filteredAgingData ? Math.ceil(this.filteredAgingData.length / this.pageSize) : 1;
}


get isFirstPage() {
    return this.currentPage === 1;
}

get isLastPage() {
    return this.currentPage === this.totalPages;
}

get sortedData() {
    if (!this.filteredAgingData) return [];
    return [...this.filteredAgingData].sort((a, b) => {
        const aVal = a[this.sortBy] ? a[this.sortBy].toString().toLowerCase() : '';
        const bVal = b[this.sortBy] ? b[this.sortBy].toString().toLowerCase() : '';
        const multiplier = this.sortDirection === 'asc' ? 1 : -1;
        return aVal > bVal ? multiplier : aVal < bVal ? -multiplier : 0;
    });
}


get pagedAgingData() {
    if (!this.sortedData || this.sortedData.length === 0) return [];
    const start = (this.currentPage - 1) * this.pageSize;
    const end = start + this.pageSize;
    return this.sortedData.slice(start, end);
}

handleSort(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.currentPage = 1; // reset to page 1 on sort
}

handlePrevPage() {
    if (this.currentPage > 1) this.currentPage--;
}

handleNextPage() {
    if (this.currentPage < this.totalPages) this.currentPage++;
}

// Sorting for Safety Stock Table
sortBySafety = 'productName';
sortDirectionSafety = 'asc';

// Pagination for Safety Stock Table
pageSizeSafety = 10;
currentPageSafety = 1;
//forecast download 
@track customFileName = ''; 
get totalPagesSafety() {
    return this.filteredSafetyStockData ? Math.ceil(this.filteredSafetyStockData.length / this.pageSizeSafety) : 1;
}

get isFirstPageSafety() {
    return this.currentPageSafety === 1;
}

get isLastPageSafety() {
    return this.currentPageSafety === this.totalPagesSafety;
}

get sortedSafetyData() {
    if (!this.filteredSafetyStockData) return [];
    return [...this.filteredSafetyStockData].sort((a, b) => {
        const aVal = a[this.sortBySafety] ? a[this.sortBySafety].toString().toLowerCase() : '';
        const bVal = b[this.sortBySafety] ? b[this.sortBySafety].toString().toLowerCase() : '';
        const multiplier = this.sortDirectionSafety === 'asc' ? 1 : -1;
        return aVal > bVal ? multiplier : aVal < bVal ? -multiplier : 0;
    });
}

get pagedSafetyData() {
    if (!this.sortedSafetyData || this.sortedSafetyData.length === 0) return [];
    const start = (this.currentPageSafety - 1) * this.pageSizeSafety;
    const end = start + this.pageSizeSafety;
    return this.sortedSafetyData.slice(start, end);
}
handleSortSafety(event) {
    this.sortBySafety = event.detail.fieldName;
    this.sortDirectionSafety = event.detail.sortDirection;
    this.currentPageSafety = 1;
}

handlePrevPageSafety() {
    if (this.currentPageSafety > 1) this.currentPageSafety--;
}

handleNextPageSafety() {
    if (this.currentPageSafety < this.totalPagesSafety) this.currentPageSafety++;
}
get agingTabClass() {
    return this.isAging ? 'sub-tab-horizontal active' : 'sub-tab-horizontal';
}
handleExpiredToggle(event) {
    this.showExpired = event.target.checked;
    this.applyAgingFilters();
}
handleYearChange(event) {
    this.selectedYear = parseInt(event.detail.value, 10);
    console.log('Selected Year is :', this.selectedYear);
    this.shouldRenderAgingTrend = true;
    this.fetchAgingTrendData();
}
    selectAging() {
        this.clearCharts();
        this.isDemand = false;
        this.isInventory = false;
        this.isSafety = false;
        this.isAging = true;
        this.isCustomerPattern = false;
        this.selectedProduct={Id:null,Name:null};
        getDefaultWarehouseByStock({ organisationId: this.organisationId })
        .then(site => {
            if (site) {
                this.selectedWarehouseForAging.Id = site.Id;
                this.selectedWarehouseForAging.Name = site.Name;
                this.isWarehouseSelectedForAging=true;
                this.fetchStockAgingData();
                console.log('loading years ');
                this.loadAvailableYears();  
            } else {
                console.warn('No default warehouse found based on stock');
            }
        })
        .catch(error => {
            console.error('Error fetching default warehouse by stock:', error);
        });
       // this.fetchStockAgingData();
        //this.shouldRenderAgingTrend = true; 
   }

    get demandTabClass() {
        return this.isDemand ?'sub-tab-horizontal active' : 'sub-tab-horizontal';
    }
    get safetyTabClass() {
        return this.isSafety ? 'sub-tab-horizontal active' : 'sub-tab-horizontal';
    }

    get inventoryTabClass() {
        return this.isInventory ? 'sub-tab-horizontal active' : 'sub-tab-horizontal';
    }

    selectDemand() {
        this.clearCharts();
        this.isDemand = true;
        this.isInventory = false;
        this.selectedWarehouse = null;
        this.isCustomerPattern = false;
        this.selectedCustomerYear = null
        this.selectedCustomer = { Id: null, Name: null };
         getDefaultProductFromOrderItem()
                            .then(product => {  console.log('default product: ',product);
                                if (product) {
                                    this.selectedProduct = {
                                        Id: product.Id,
                                        Name: product.Name
                                    };
                                    this.isDemandProductSel = true;
                                    this.fetchDemandData();
                                    this.fetchTopCustomers();
                                    this.fetchTopProducts();
                                } else {
                                    console.warn('No default product found from OrderItem.');
                                }
                            })
                            .catch(error => {
                                console.error('Error fetching default product from OrderItem:', error);
                            });
        this.custProd = { Id: null, Name: null };
       // this.scheduleChartRender();
        
    }

    selectInventory() {
        this.clearCharts();
        this.isDemand = false;
        this.isSafety = false;
        this.isAging = false;
        this.isCustomerPattern = false;
        this.isInventory = true;
        this.showallWarehouses = true;
        this.isLoading = true;
        this.isSiteSlectSelected = false;
        this.locationInventoryData = {};
        this.selectedProduct={Id:null,Name:null};
        getWarehouseInventory({ organisationId: this.organisationId , productId: this.inventoryProduct.Id })
        .then(result => {
            this.inventoryData = result;
            console.log('Fetched Warehouse Inventory Data:', this.inventoryData);
            this.scheduleChartRender();
        })
        .catch(error => {
            console.error('Error fetching warehouse inventory:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'Failed to fetch warehouse inventory.',
                    variant: 'error'
                })
            );
        }).finally(() => {
            setTimeout(() => {
                this.isLoading = false;
            }, 500); 
        });
    }
    selectSafety() {
    this.clearCharts();
    this.isDemand = false;
    this.isInventory = false;
    this.isAging = false;
    this.isCustomerPattern = false;
    this.isSafety = true;
     // Get default warehouse
    getDefaultWarehouseByStock({ organisationId: this.organisationId })
        .then(site => {
            if (site) {
                this.selectedWarehouseForSafetyStock.Id = site.Id;
                this.selectedWarehouseForSafetyStock.Name = site.Name;
                //console.log('warehouse default ->',this.selectedWarehouseForSafetyStock);
                this.isWarehouseSelectedForsafetyStock = true;
                this.locationFilter = "ERP7__Organisation__c = '" + this.organisationId + "' AND ERP7__Active__c = true AND ERP7__Site__c = '" + this.selectedWarehouseForSafetyStock.Id + "'";
                this.fetchSafetyStockData();
                this.renderSafetyStockChart();
            } else {
                console.warn('No default warehouse found based on stock');
            }
        })
        .catch(error => {
            console.error('Error fetching default warehouse by stock:', error);
        });
    }

    handleProductSelected(event) {
        this.selectedProduct.Id = event.detail.Id;
        this.selectedProduct.Name = event.detail.Name;
        this.isDemandProductSel = true;
        console.log('Selected product:', this.selectedProduct);
        this.fetchDemandData();
        this.fetchTopCustomers();
        this.fetchTopProducts();
    }
    handleDemandProdRemove(){
        this.selectedProduct = { Id: null, Name: null };
        this.isDemandProductSel = false;
        this.showSimulationPanel = false;
        this.simulationHasRun = false;
        this.simulationInputs = [];
        this.simulatedForecast = [];
        this.simulatedForecast = [];
        console.log('Removed Demand product');
        
    //    window.location.reload();
    }
    handleRemoveInventoryProduct() {
        this.inventoryProduct = { Id: '', Name: '' };
        console.log('Removed Inventory product');
        this.resolveInventoryFetch();
    }

    handleRemoveSite() {
            this.selectedSite = { Id: '', Name: '' };
            console.log('Site removed');
            this.resolveInventoryFetch();
    }



handleINVProductSelected(event) {
    this.inventoryProduct.Id = event.detail.Id;
    this.inventoryProduct.Name = event.detail.Name;
    console.log('Selected Inventory product:', this.inventoryProduct);
    this.resolveInventoryFetch();
}


handleSiteSelected(event) {
    this.selectedSite.Id = event.detail.Id;
    this.selectedSite.Name = event.detail.Name;
    console.log('Selected Site:', this.selectedSite);
    this.resolveInventoryFetch();
}


    connectedCallback() {
        console.log('organisationId:', this.organisationId);
        console.log('isDemandTabOpen:', this.isDemandTabOpen);
        console.log('isInventoryTabOpen:', this.isInventoryTabOpen);
        this.siteFilter = "ERP7__Organisation__c = '" + this.organisationId + "' AND ERP7__Active__c = true";
        this.customerFilter = "ERP7__Organisation__c = '" + this.organisationId + "' AND ERP7__Active__c = true AND (" +
                      "ERP7__Account_Type__c = 'Customer' OR " +
                      "ERP7__Account_Type__c = 'Customer / Partner' OR " +
                      "ERP7__Account_Type__c = 'Customer / Vendor' OR " +
                      "ERP7__Account_Type__c = 'Customer / Partner / Vendor')";

        this.isDemand = this.isDemandTabOpen;
        this.isInventory = this.isInventoryTabOpen;
        if(this.isInventory) this.showallWarehouses = true;
        console.log('isDemand:', this.isDemand, 'isInventory:', this.isInventory);
        if (!this.chartJsInitialized) {
            console.log('Loading Chart.js from:', chartJs);
            loadScript(this, chartJs)
                .then(() => {
                    console.log('Chart.js loaded successfully');
                    console.log('Chart.js version:', window.Chart ? window.Chart.version : 'Not available');
                    // if (!window.Chart || window.Chart.version !== '2.9.4') {
                    //     console.error('Incorrect Chart.js version loaded. Expected 2.9.4, got:', window.Chart ? window.Chart.version : 'undefined');
                    // }
                    this.chartJsInitialized = true;
                    // Fetch top products data immediately after Chart.js is loaded
                    if(this.isDemandTabOpen) {
                        if (this.isDemand) {
                        getDefaultProductFromOrderItem()
                            .then(product => { console.log('default product: ',product);
                                if (product) {
                                    this.selectedProduct = {
                                        Id: product.Id,
                                        Name: product.Name
                                    };
                                    this.isDemandProductSel = true;
                                    this.fetchDemandData();
                                    this.fetchTopCustomers();
                                    this.fetchTopProducts();
                                } else {
                                    console.warn('No default product found from OrderItem.');
                                }
                            })
                            .catch(error => {
                                console.error('Error fetching default product from OrderItem:', error);
                            });
                    }

                        //this.fetchTopProducts();
                    }
                    if(this.isInventoryTabOpen) {
                       this.selectInventory();
                    }
                    
                })
                .catch(error => {
                    console.error('Error loading Chart.js:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Failed to load Chart.js library.',
                            variant: 'error'
                        })
                    );
                });
        }
    }
fetchDemandData() {
    this.isLoading = true;
console.log(' in fetch demand data orgId:', this.organisationId);
    getDemandForecastWithHistory({
        productId: this.selectedProduct.Id,
         modelName: this.selectedModel,
    })
    .then(result => {
        // 🔹 Extract data
        const historicalLabels = result.historicalMonths;
        const historicalData = result.historicalValues;
        const forecastLabels = result.forecastMonths;
        const forecastData = result.forecastValues;

        // 🔒 Store original reference copies (for resets, simulation)
        this.fullHistoricalLabels = [...historicalLabels];
        this.fullHistoricalValues = [...historicalData];
        this.forecastLabels = [...forecastLabels];
        this.forecastData = [...forecastData];

        // 🔁 Filter only current year data for visible chart + input panel
        const currentYear = new Date().getFullYear();
        this.filteredHistLabels = [];
        this.filteredHistData = [];

        for (let i = 0; i < historicalLabels.length; i++) {
            if (historicalLabels[i].includes(currentYear.toString())) {
                this.filteredHistLabels.push(historicalLabels[i]);
                this.filteredHistData.push(historicalData[i]);
            }
        }

        // 🎯 Draw the original chart (historical + forecast)
        this.renderDemandForecastChart(
            this.fullHistoricalLabels,
            this.fullHistoricalValues,
            this.forecastLabels,
            this.forecastData,
            [] // no simulation yet
        );
    })
    .catch(error => {
        console.error('Error fetching demand forecast:', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Failed to fetch demand forecast.',
                variant: 'error'
            })
        );
    })
    .finally(() => {
        this.isLoading = false;
    });
}

// renderDemandForecastChart(histLabels, histData, forecastLabels, forecastData) {
//     const ctx = this.template.querySelector("canvas[data-id='demandByMonth']");
//     if (!ctx || !window.Chart) return;

//     if (this.charts.demandChart) {
//         this.charts.demandChart.destroy();
//     }

//     // ⏱️ Filter only current year's data
//     const currentYear = new Date().getFullYear();
//     const filteredHistLabels = [];
//     const filteredHistData = [];

//     for (let i = 0; i < histLabels.length; i++) {
//         const label = histLabels[i]; // e.g., "Jan 2023"
//         if (label.includes(currentYear.toString())) {
//             filteredHistLabels.push(label);
//             filteredHistData.push(histData[i]);
//         }
//     }

//     // ⏩ Add forecast labels and data
//     const allLabels = [...filteredHistLabels, ...forecastLabels];
//     const forecastPlottedData = new Array(filteredHistLabels.length).fill(null).concat(forecastData);

//     // 🧠 Build chart
//     this.charts.demandChart = new Chart(ctx, {
//         type: 'line',
//         data: {
//             labels: allLabels,
//             datasets: [
//                 {
//                     label: 'Historical Demand',
//                     data: filteredHistData,
//                     borderColor: '#9D53F2',
//                     backgroundColor: 'rgba(157, 83, 242, 0.1)',
//                     // borderColor: '#0070d2',
//                     // backgroundColor: 'rgba(0,112,210,0.1)',
//                     tension: 0.3,
//                     fill: true
//                 },
//                 {
//                     label: 'Forecasted Demand',
//                     data: forecastPlottedData,
//                     borderColor: '#3290ED',
//                     borderDash: [5, 5],
//                     tension: 0.3,
//                     fill: false
//                 }
//             ]
//         },
//         options: {
//             responsive: true,
//             plugins: {
//                 legend: {
//                     display: true,
//                     position: 'bottom'
//                 },
//                 tooltip: {
//                     mode: 'index',
//                     intersect: false
//                 }
//             },
//             scales: {
//                 y: {
//                     beginAtZero: true,
//                     ticks: {
//                         precision: 0
//                     }
//                 }
//             }
//         }
//     });
// }
renderDemandForecastChart(histLabels, histData, forecastLabels, forecastData, simulatedData = []) {
    const currentYear = new Date().getFullYear();
    
    this.filteredHistLabels = [];
    this.filteredHistData = [];
    // Save full history
    this.fullHistoricalLabels = histLabels;
    this.fullHistoricalValues = histData;

    this.forecastLabels = forecastLabels;
    this.forecastData = forecastData;
    for (let i = 0; i < histLabels.length; i++) {
        const label = histLabels[i]; // e.g., "Jan 2024"
        if (label.includes(currentYear.toString())) {
            this.filteredHistLabels.push(label);
            this.filteredHistData.push(histData[i]);
        }
    }

    const ctx = this.template.querySelector("canvas[data-id='demandByMonth']");
    if (!ctx || !window.Chart) return;

    if (this.charts.demandChart) {
        this.charts.demandChart.destroy();
    }

    const allLabels = [...this.filteredHistLabels, ...forecastLabels];
    const forecastPlottedData = new Array(this.filteredHistLabels.length).fill(null).concat(forecastData);
    const simulatedPlottedData = simulatedData.length > 0
        ? new Array(this.filteredHistLabels.length).fill(null).concat(simulatedData)
        : [];

    const datasets = [
        {
            label: 'Historical Demand',
            data: this.filteredHistData,
            borderColor: '#9D53F2',
            backgroundColor: 'rgba(157, 83, 242, 0.1)',
            tension: 0.3,
            fill: true
        },
        {
            label: 'Forecasted Demand',
            data: forecastPlottedData,
            borderColor: '#3290ED',
            borderDash: [5, 5],
            tension: 0.3,
            fill: false
        }
    ];

    if (simulatedPlottedData.length > 0) {
        datasets.push({
            label: 'Simulated Forecast',
            data: simulatedPlottedData,
            borderColor: '#F26522',
            borderDash: [2, 3],
            tension: 0.3,
            fill: false
        });
    }

    this.charts.demandChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: allLabels,
            datasets: datasets
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: true,
                    position: 'bottom'
                },
                tooltip: {
                    mode: 'index',
                    intersect: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        precision: 0
                    }
                }
            }
        }
    });
}


    // fetchDemandData() {
    //      this.isLoading = true;
    //     if (!this.selectedProduct.Id || !this.organisationId) {
    //         console.log('Missing productId or organisationId:', {
    //             productId: this.selectedProduct.Id,
    //             organisationId: this.organisationId
    //         });
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error',
    //                 message: 'Product ID or Organisation ID is missing.',
    //                 variant: 'error'
    //             })
    //         );
    //         return;
    //     }
    //     console.log('Fetching demand data for product:', this.selectedProduct.Id);
    //     getDemandData({ productId: this.selectedProduct.Id, organisationId: this.organisationId })
    //         .then(result => {
    //             this.demandData = result || {};
    //             console.log('Demand data fetched:', this.demandData);
    //             this.scheduleChartRender();
    //         })
    //         .catch(error => {
    //             console.error('Error fetching demand data:', error);
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error',
    //                     message: error.body?.message || 'Failed to fetch demand data.',
    //                     variant: 'error'
    //                 })
    //             );
    //         }).finally(() => {
    //         setTimeout(() => {
    //             this.isLoading = false;
    //         }, 500); 
    //     });
    // }
renderTopCustomerPieChart(labels, values) {
    const ctx = this.template.querySelector("canvas[data-id='topCustomerPie']");
    if (!ctx || !window.Chart) return;

    if (this.charts.topCustomerPie) {
        this.charts.topCustomerPie.destroy();
    }

    this.charts.topCustomerPie = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: labels,
            datasets: [{
                data: values,
                backgroundColor: [
                    // '#0070d2', '#ff6384', 
                    '#9D53F2', '#77B5F2',
                    '#3290ED','#26ABA4',
                    //'#36a2eb', '#ffce56',
                    '#8bc34a'
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}
fetchTopCustomers() {
    if (!this.selectedProduct?.Id) return;

    getTopCustomersForProduct({
        productId: this.selectedProduct.Id,
        topN: 5,
        OrgId: this.organisationId
    })
    .then(result => {
        const labels = result.map(row => row.accountName);
        const values = result.map(row => row.quantity);
        this.renderTopCustomerPieChart(labels, values);
    })
    .catch(error => {
        console.error('Error fetching top customers:', error);
    });
}

    fetchTopProducts() {
        this.isLoading = true;
        if (!this.organisationId) {
            console.log('Missing organisationId for top products');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Organisation ID is missing.',
                    variant: 'error'
                })
            );
            return;
        }
        console.log('Fetching top products for organisation:', this.organisationId);
        getTopProductsByDemand({ organisationId: this.organisationId })
            .then(result => {
                this.topProductsData = result || {};
                console.log('Top products data fetched:', this.topProductsData);
                this.scheduleChartRender();
            })
            .catch(error => {
                console.error('Error fetching top products:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.message || 'Failed to fetch top products data.',
                        variant: 'error'
                    })
                );
            }).finally(() => {
            setTimeout(() => {
                this.isLoading = false;
            }, 500); 
        });
    }
    fetchWarehouseInventory() {
    this.isLoading = true;
    getWarehouseInventory({
        organisationId: this.organisationId,
        productId: this.inventoryProduct.Id
    })
        .then(result => {
            this.inventoryData = result;
            console.log('Fetched Warehouse Inventory Data:', this.inventoryData);
            this.scheduleChartRender();
        })
        .catch(error => {
            console.error('Error fetching warehouse inventory:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || 'Failed to fetch warehouse inventory.',
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            setTimeout(() => {
                this.isLoading = false;
            }, 500);
        });
    }
    fetchLocationInventory() {
    this.isSiteSlectSelected = true;
    this.showallWarehouses = false;
    this.isLoading = true;
    
    getLocationInventory({
        siteId: this.selectedSite.Id,
        organisationId: this.organisationId,
        productId: this.inventoryProduct.Id
    })
    .then(result => {
        this.locationInventoryData = result;
        console.log('Fetched Location Inventory Data:', this.locationInventoryData);
        this.scheduleChartRender();
    })
    .catch(error => {
        console.error('Error fetching location inventory:', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: error.body?.message || 'Failed to fetch location inventory.',
                variant: 'error'
            })
        );
    })
    .finally(() => {
        setTimeout(() => {
            this.isLoading = false;
        }, 500);
    });
    }
   fetchSafetyStockData() {
        if (!this.selectedWarehouseForSafetyStock) {
            this.showToast('Missing Input', 'Please select a warehouse.', 'warning');
            return;
        }

        this.isLoading = true;

        getStockAlertData({
            siteId: this.selectedWarehouseForSafetyStock.Id,
            location:  this.selectedLocation?.Id || null,
            product: this.selectedProduct?.Id || null,
            OrgId: this.organisationId
        })
            .then(result => {
                this.safetyStockData = result.map(item => {
                    let badgeLabel = '', badgeClass = 'slds-text-align_left custom-align-left';

                    if (item.currentStock < item.safetyStock) {
                        badgeLabel = 'Critical';
                        badgeClass += ' badge-red';
                    } else if (item.currentStock < item.reorderLevel) {
                        badgeLabel = 'Reorder';
                        badgeClass += ' badge-yellow';
                    } else {
                        badgeLabel = 'Safe';
                        badgeClass += ' badge-green';
                    }

                    return { ...item, badgeLabel, badgeClass };
                });
                
               // Update filtered data even if it's empty
        this.filteredSafetyStockData = [...this.safetyStockData];

        // Always update the chart — even if empty
        this.renderSafetyStockChart();

        // Optional: Show message/toast if no data
        if (this.safetyStockData.length === 0) {
            this.showToast('No Data', 'No inventory found for the selected filters.', 'info');
        }
                this.renderSafetyStockChart();
            })
            .catch(error => {
                console.error('Fetch error:', error);
                this.showToast('Error', error.body?.message || 'Failed to fetch safety stock data.', 'error');
            })
            .finally(() => this.isLoading = false);
    }
    prepareFilterOptions() {
    const warehouses = new Set();
    const locations = new Set();
    const products = new Set();

    this.safetyStockData.forEach(item => {
        warehouses.add(item.warehouse);
        locations.add(item.location);
        products.add(item.productName);
    });

    this.warehouseOptions = [...warehouses].map(val => ({ label: val, value: val }));
    this.locationOptions = [...locations].map(val => ({ label: val, value: val }));
    this.productOptions = [...products].map(val => ({ label: val, value: val }));
}
applyFiltersForSafetyStock() {
    this.filteredSafetyStockData = this.safetyStockData.filter(item => {
        return (!this.selectedWarehouseForSafetyStock.Id || item.warehouse === this.selectedWarehouseForSafetyStock.Id) &&
               (!this.selectedLocationForSafetyStock || item.location === this.selectedLocationForSafetyStock) &&
               (!this.selectedProductFilterForSafetyStock || item.productName === this.selectedProductFilterForSafetyStock);
    });
}
handleWarehouseSaveForSafetyStock(event) {
     this.selectedWarehouseForSafetyStock.Id = event.detail.Id;
     this.selectedWarehouseForSafetyStock.Name = event.detail.Name;
    console.log('Selected Warehouse for Safety Stock:', this.selectedWarehouseForSafetyStock.Name);
    this.isWarehouseSelectedForsafetyStock=true;
    this.locationFilter = "ERP7__Organisation__c = '" + this.organisationId + "' AND ERP7__Active__c = true AND ERP7__Site__c = '" + this.selectedWarehouseForSafetyStock.Id + "'";
    this.fetchSafetyStockData();
    this.renderSafetyStockChart();
}
handleSiteRemovedForSafety(){
    this.selectedWarehouseForSafetyStock = {Id:null,Name:null};
    this.isWarehouseSelectedForsafetyStock = false;
    this.safetyStockData = [];
    this.filteredSafetyStockData = [];
    this.locationFilter=null;
}
handleLocationSelect(event) {
    this.selectedLocation={Id: event.detail.Id, Name: event.detail.Name};
    this.fetchSafetyStockData();
}
handleLocationRemove(){
    this.selectedLocation={Id:'',Name:''}
    this.fetchSafetyStockData();
}
handleSafetyStockProductSelected(event) {
    this.selectedProduct = { Id: event.detail.Id, Name: event.detail.Name };
    this.fetchSafetyStockData();
}

handleSafetyProductRemove(){
    this.selectedProduct = { Id:null,Name:null};
    this.fetchSafetyStockData();
}
scheduleChartRender() {
        setTimeout(() => {
            this.renderCharts();
        }, 0);
    }
renderCharts() {
        if (!this.chartJsInitialized || (!this.isDemand && !this.isInventory)) {
            console.log('Charts not rendered: isDemand=', this.isDemand, 'chartJsInitialized=', this.chartJsInitialized, 'isInventory=', this.isInventory);
            return;
        }

        console.log('Rendering charts...');
        if (this.isInventory) {

        // Render Inventory by Warehouse Chart
            if (this.inventoryData.warehouseLabels && this.showallWarehouses) {
            console.log('in renderCharts for Inventory');
            const warehouseCanvas = this.template.querySelector('[data-id="inventoryByWarehouse"]');
            if (warehouseCanvas) {
                console.log('Warehouse canvas found');
                try {
                    const ctxWarehouse = warehouseCanvas.getContext('2d');
                    if (ctxWarehouse) {
                        if (this.charts.warehouse) this.charts.warehouse.destroy();
                        this.charts.warehouse = new window.Chart(ctxWarehouse, {
                            type: 'pie',
                            data: {
                                labels: this.inventoryData.warehouseLabels,
                                datasets: [{
                                    label: 'Inventory in Warehouse',
                                    data: this.inventoryData.warehouseInventory,
                                    backgroundColor: [
                                        'rgba(157, 83, 242, 0.5)',   // #9D53F2
                                        'rgba(50, 144, 237, 0.5)',   // #3290ED
                                        'rgba(119, 181, 242, 0.5)',  // #77B5F2
                                        'rgba(38, 38, 170, 0.5)'  
                                                                            ],
                                    borderColor: [
                                        'rgba(157, 83, 242, 0.5)',   // #9D53F2
                                        'rgba(50, 144, 237, 0.5)',   // #3290ED
                                        'rgba(119, 181, 242, 0.5)',  // #77B5F2
                                        'rgba(38, 38, 170, 0.5)' 
                                    ],
                                    borderWidth: 1
                                }]
                            },
                            options: {
                                responsive: true,
                                maintainAspectRatio: false,
                                legend: {
                                    position: 'right'
                                },
                                title: {
                                    display: true,
                                    text: 'Inventory in Warehouse'
                                },
                                animation: {
                                    animateScale: true,
                                    animateRotate: true
                                },
                                plugins:{
                                    tooltip: {
                                    callbacks: {
                                        label: (context) => {
                                            const label = context.label || '';
                                            const value = context.parsed || 0;
                                            return `${label}: ${this.formatLargeNumber(value)}`;
                                        }
                                    }
                                }

                                }
                            }
                        });
                        console.log('Inventory by Warehouse chart rendered');
                    } else {
                        console.error('Failed to get 2D context for inventoryByWarehouse');
                    }
                } catch (error) {
                    console.error('Error rendering Inventory by Warehouse chart:', error);
                }
            } else {
                console.error('Warehouse canvas not found');
            }
        }
            else if (this.locationInventoryData.locationLabels && !this.showallWarehouses && this.isSiteSlectSelected) {
                    console.log('Condition check:', {
                        locationLabels: this.locationInventoryData.locationLabels,
                        showallWarehouses: this.showallWarehouses,
                        isSiteSlectSelected: this.isSiteSlectSelected
                    });
                    console.log('Will show locations for selected site:', this.selectedSite);
                    // Destroy the warehouse chart if it exists
                    if (this.charts.warehouse) {
                        this.charts.warehouse.destroy();
                        this.charts.warehouse = null;
                        console.log('Inventory by Warehouse chart destroyed');
                    }
                    const warehouseCanvas = this.template.querySelector('[data-id="inventoryByWarehouse"]');
                    const locationInventoryCanvas = this.template.querySelector('[data-id="inventoryByLocation"]');
                    if (warehouseCanvas) warehouseCanvas.style.display = 'none';
                    if (locationInventoryCanvas) locationInventoryCanvas.style.display = 'block';
                    if (locationInventoryCanvas) {
                        console.log('Location canvas found');
                        console.log('Location chart data:', {
                            labels: this.locationInventoryData.locationLabels,
                            data: this.locationInventoryData.locationInventory
                        });
                        try {
                            const ctxLocation = locationInventoryCanvas.getContext('2d');
                            if (ctxLocation) {
                                if (this.charts.location) this.charts.location.destroy();
                                this.charts.location = new window.Chart(ctxLocation, {
                                    type: 'bar', 
                                    data: {
                                        labels: this.locationInventoryData.locationLabels,
                                        datasets: [{
                                            label: 'Stock',
                                            data: this.locationInventoryData.locationInventory,
                                            backgroundColor: [
                                        'rgba(157, 83, 242, 0.5)',   // #9D53F2
                                        'rgba(50, 144, 237, 0.5)',   // #3290ED
                                        'rgba(119, 181, 242, 0.5)',  // #77B5F2
                                        'rgba(38, 38, 170, 0.5)' 
                                            ],
                                            borderColor: [
                                        'rgba(157, 83, 242, 0.5)',   // #9D53F2
                                        'rgba(50, 144, 237, 0.5)',   // #3290ED
                                        'rgba(119, 181, 242, 0.5)',  // #77B5F2
                                        'rgba(38, 38, 170, 0.5)' 
                                            ],
                                            borderWidth: 1
                                        }]
                                    },
                                    options: {
                                        responsive: true,
                                        maintainAspectRatio: false,
                                        legend: {
                                            display: true, // Show legend
                                            position: 'top'
                                        },
                                        title: {
                                            display: true,
                                            text: `Inventory by Location for ${this.selectedSite}`
                                        },
                                        scales: {
                                            yAxes: [{
                                                ticks: {
                                                    beginAtZero: true // Start y-axis at 0
                                                }
                                            }]
                                        },
                                        animation: {
                                            duration: 1000 
                                        }
                                    }
                                });
                                console.log('Inventory by Location chart rendered');
                            } else {
                                console.error('Failed to get 2D context for inventoryByLocation');
                            }
                        } catch (error) {
                            console.error('Error rendering Inventory by Location chart:', error);
                        }
                    } else {
                        console.error('locationInventory canvas not found');
                    }
                }

        }else  if(this.isDemand) {
            // Demand by Month Chart (Changed to Line Chart)
            if (this.demandData.monthLabels) {
                const monthCanvas = this.template.querySelector('[data-id="demandByMonth"]');
                if (monthCanvas) {
                    console.log('Month canvas found');
                    try {
                        const ctxMonth = monthCanvas.getContext('2d');
                        if (ctxMonth) {
                            if (this.charts.month) this.charts.month.destroy();
                            this.charts.month = new window.Chart(ctxMonth, {
                                type: 'line',
                                data: {
                                    labels: this.demandData.monthLabels,
                                    datasets: [{
                                        label: 'Demand by Month',
                                        data: this.demandData.monthData,
                                        borderColor: 'rgba(54, 162, 235, 1)',
                                        borderWidth: 2,
                                        fill: false,
                                        tension: 0.1
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    scales: {
                                        yAxes: [{
                                            ticks: {
                                                beginAtZero: true
                                            },
                                            scaleLabel: {
                                                display: true,
                                                labelString: 'Units'
                                            }
                                        }]
                                    }
                                }
                            });
                            console.log('Demand by Month chart rendered');
                        } else {
                            console.error('Failed to get 2D context for demandByMonth');
                        }
                    } catch (error) {
                        console.error('Error rendering Demand by Month chart:', error);
                    }
                } else {
                    console.error('Month canvas not found');
                }
            }

            // Demand by Customer Chart
            if (this.demandData.customerLabels) {
                const customerCanvas = this.template.querySelector('[data-id="demandByCustomer"]');
                if (customerCanvas) {
                    console.log('Customer canvas found');
                    try {
                        const ctxCustomer = customerCanvas.getContext('2d');
                        if (ctxCustomer) {
                            if (this.charts.customer) this.charts.customer.destroy();
                            this.charts.customer = new window.Chart(ctxCustomer, {
                                type: 'pie',
                                data: {
                                    labels: this.demandData.customerLabels,
                                    datasets: [{
                                        label: 'Demand by Customer',
                                        data: this.demandData.customerData,
                                        backgroundColor: [
                                            'rgba(157, 83, 242, 0.5)',   // #9D53F2
                                        'rgba(50, 144, 237, 0.5)',   // #3290ED
                                        'rgba(119, 181, 242, 0.5)',  // #77B5F2
                                        'rgba(38, 38, 170, 0.5)'
                                        ],
                                        borderColor: [
                                    'rgba(157, 83, 242, 0.5)',   // #9D53F2
                                        'rgba(50, 144, 237, 0.5)',   // #3290ED
                                        'rgba(119, 181, 242, 0.5)',  // #77B5F2
                                        'rgba(38, 38, 170, 0.5)'
                                        ],
                                        borderWidth: 1
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false
                                }
                            });
                            console.log('Demand by Customer chart rendered');
                        } else {
                            console.error('Failed to get 2D context for demandByCustomer');
                        }
                    } catch (error) {
                        console.error('Error rendering Demand by Customer chart:', error);
                    }
                } else {
                    console.error('Customer canvas not found');
                }
            }

            // Demand by Product Chart (Top 5 Products)
            if (this.topProductsData.topProductLabels) {
                const productCanvas = this.template.querySelector('[data-id="demandByProduct"]');
                if (productCanvas) {
                    console.log('Product canvas found');
                    try {
                        const ctxProduct = productCanvas.getContext('2d');
                        if (ctxProduct) {
                            if (this.charts.product) this.charts.product.destroy();
                            this.charts.product = new window.Chart(ctxProduct, {
                                type: 'bar',
                                data: {
                                    labels: this.topProductsData.topProductLabels,
                                    datasets: [{
                                        label: 'Top 5 Products by Demand',
                                        data: this.topProductsData.topProductData,
                                        backgroundColor: 'rgba(119, 181, 242, 0.5)',
                                        borderColor: 'rgba(119, 181, 242, 1)',
                                        borderWidth: 1
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    scales: {
                                        yAxes: [{
                                            ticks: {
                                                beginAtZero: true
                                            },
                                            scaleLabel: {
                                                display: true,
                                                labelString: 'Units'
                                            }
                                        }]
                                    }
                                }
                            });
                            console.log('Demand by Product chart rendered');
                        } else {
                            console.error('Failed to get 2D context for demandByProduct');
                        }
                    } catch (error) {
                        console.error('Error rendering Demand by Product chart:', error);
                    }
                } else {
                    console.error('Product canvas not found');
                }
            }
        }
    }
    clearCharts() {
    for (const key in this.charts) {
        if (this.charts[key]) {
            this.charts[key].destroy();
            this.charts[key] = null;
        }
    }
    }
renderSafetyStockChart() {
    const canvas = this.template.querySelector('[data-id="safetyStockChart"]');

    // Always clear previous chart
    if (this.charts.safety) {
        this.charts.safety.destroy();
        this.charts.safety = null;
    }

    // If no canvas or no data, exit after clearing
    if (!canvas) return;

    const ctx = canvas.getContext('2d');

    // If no data, render placeholder chart or message
    if (!this.filteredSafetyStockData.length) {
        // Optional: Draw 'No data' text on canvas
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.font = '16px Arial';
        ctx.fillStyle = '#666';
        ctx.fillText('No stock data to display.', 20, 40);
        return;
    }

    // Prepare data
    const labels = this.filteredSafetyStockData.map(i => i.productName);
    const currentStock = this.filteredSafetyStockData.map(i => i.currentStock);
    const reorderLevel = this.filteredSafetyStockData.map(i => i.reorderLevel);
    const safetyStock = this.filteredSafetyStockData.map(i => i.safetyStock);
    const currentColors = this.filteredSafetyStockData.map(i =>
        i.currentStock < i.safetyStock ? 'rgba(52, 152, 219, 0.7)' :
        i.currentStock < i.reorderLevel ? 'rgba(243, 156, 18, 0.7)' :
        'rgba(46, 204, 113, 0.7)'
    );

    // Render new chart
    this.charts.safety = new window.Chart(ctx, {
        type: 'bar',
        data: {
            labels,
            datasets: [
                {
                    label: 'Current Stock',
                    data: currentStock,
                    backgroundColor: currentColors
                },
                {
                    label: 'Reorder Level',
                    data: reorderLevel,
                    backgroundColor: 'rgba(52, 152, 219, 0.7)'
                },
                {
                    label: 'Safety Stock',
                    data: safetyStock,
                    backgroundColor: 'rgba(243, 156, 18, 0.7)'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            barThickness: 30,
            scales: {
                xAxes: [{
                    stacked: false,
                    barPercentage: 0.6
                }],
                yAxes: [{
                    stacked: false,
                    ticks: {
                        beginAtZero: true
                    }
                }]
            },
            title: {
                display: true,
                text: 'Filtered Stock Status'
            }
        }
    });
}



resolveInventoryFetch() {
    this.isLoading = true;

    if (this.selectedSite?.Id) {
        this.isSiteSlectSelected = true;
        this.showallWarehouses = false;

        getLocationInventory({
            siteId: this.selectedSite.Id,
            organisationId: this.organisationId,
            productId: this.inventoryProduct.Id || ''
        })
        .then(result => {
            this.locationInventoryData = result;
            console.log('Fetched Location Inventory Data:', this.locationInventoryData);
            this.scheduleChartRender();
        })
        .catch(error => {
            this.showToast('Error', error.body?.message || 'Failed to fetch location inventory.', 'error');
        })
        .finally(() => {
            setTimeout(() => {
                this.isLoading = false;
            }, 500);
        });
    } else {
        this.isSiteSlectSelected = false;
        this.showallWarehouses = true;

        getWarehouseInventory({
            organisationId: this.organisationId,
            productId: this.inventoryProduct.Id || ''
        })
        .then(result => {
            this.inventoryData = result;
            console.log('Fetched Warehouse Inventory Data:', this.inventoryData);
            this.scheduleChartRender();
        })
        .catch(error => {
            this.showToast('Error', error.body?.message || 'Failed to fetch warehouse inventory.', 'error');
        })
        .finally(() => {
            setTimeout(() => {
                this.isLoading = false;
            }, 500);
        });
    }
}
showToast(title, message, variant) {
    this.dispatchEvent(
        new ShowToastEvent({
            title,
            message,
            variant
        })
    );
}
handleWarehouseSelectForAging(event){
    
    this.isWarehouseSelectedForAging=true;
    this.selectedWarehouseForAging = {Id:event.detail.Id,Name:event.detail.Name};
    // console.log('Selected Warehouse for Aging:', this.selectedWarehouseForAging);
    this.fetchStockAgingData();
    console.log('loading years ');
    this.loadAvailableYears(); 
    }
handleWarehouseRemoveAging(){
        this.isWarehouseSelectedForAging=false;
        this.selectedWarehouseForAging = {Id:null,Name:null};
        this.stockAgingData=[];
        this.filteredAgingData=[];
        //window.location.reload();
           // Destroy the trend chart if it exists
    if (this.charts?.agingTrend) {
        this.charts.agingTrend.destroy();
        this.charts.agingTrend = null;
    }
}
// handleWarehouseChangeAging(event){
//     console.log('on change ');
//     this.selectedWarehouseForAging = {Id:event.detail.Id,Name:event.detail.Name};
//     this.fetchStockAgingData();
//     console.log('loading years ');
//     this.loadAvailableYears(); 
// }
fetchStockAgingData() {
    this.isLoading = true;
    console.log('Fetching stock aging data for product:', this.selectedProduct.Id, 'and warehouse:', this.selectedWarehouseForAging.Name, 'organisationId:', this.organisationId);
    getDynamicStockAgingData({ siteId: this.selectedWarehouseForAging.Id, orgId: this.organisationId ,prodId : this.selectedProduct.Id})
        .then(result => {
            console.log('Sucess getDynamicStockAgingData')
            const today = new Date();
            this.stockAgingData = result.map((item, idx) => {
                const receivedDate = new Date(item.receivedDate);
                const ageInDays = Math.floor((today - receivedDate) / (1000 * 60 * 60 * 24));
                let bucket = '', status = '', statusClass = '';
                if (item.isExpired) {
                bucket = 'Expired';
                status = 'Expired';
                statusClass = 'badge-flat-purple';
                } else if (ageInDays < 30)       { bucket = '<30d';       status = 'Fresh';        statusClass = 'badge-blue-m'; }
                else if (ageInDays < 90)  { bucket = '30–90d';     status = 'Slow Moving';  statusClass = 'badge-flat-green'; }
                else if (ageInDays < 180) { bucket = '90–180d';    status = 'Aging';        statusClass = 'badge-flat-purple'; }
                else if (ageInDays < 365) { bucket = '180–365d';   status = 'At Risk';      statusClass = 'badge-flat-gray'; }
                else                      { bucket = '>365d';      status = 'Obsolete';     statusClass = 'badge-flat-red'; }

                return {
                    id: idx.toString(),
                    productId: item.productId,
                    productName: item.productName,
                    quantity: item.quantity,
                    receivedDate: item.receivedDate,
                    ageInDays,
                    bucket,
                    status,
                    statusClass
                };
            });

            this.prepareAgingFilters();
            this.applyAgingFilters();
             
        })
        .catch(error => {
            console.error('Error fetching stock aging data:', error);
        })
        .finally(() => {
            this.isLoading = false;
        });
}


prepareAgingFilters() {
    console.log('Preparing aging filters');
    const products = new Set(this.stockAgingData.map(item => item.productId));
    this.productOptionsAging = [...products].map(p => ({ label: p, value: p }));
}

applyAgingFilters() {
    console.log('Applying filters aging');
   this.filteredAgingData = this.stockAgingData.filter(item =>
        (!this.agingFilters.product || item.productId === this.agingFilters.product) &&
        (!this.agingFilters.bucket || item.bucket === this.agingFilters.bucket) &&
        (!this.agingFilters.status || item.status === this.agingFilters.status) &&
         (this.showExpired || item.status !== 'Expired') 
    );

    this.renderStockAgingChart();
}
handleAgingProductSelected(event) {
    this.selectedProduct.Id = event.detail.Id;
    this.selectedProduct.Name = event.detail.Name;
    this.fetchStockAgingData();
    this.fetchAgingTrendData();
}
handleAgingProductRemove(){
    this.selectedProduct={Id:null,Name:null};
    this.fetchStockAgingData();
    this.fetchAgingTrendData();
}
handleAgingProductChange(event) {
    this.agingFilters.product = event.detail.value;
    this.applyAgingFilters();
}
handleAgingBucketChange(event) {
    this.agingFilters.bucket = event.detail.value;
    this.applyAgingFilters();
}
handleAgingStatusChange(event) {
    this.agingFilters.status = event.detail.value;
    this.applyAgingFilters();
}

renderStockAgingChart() {
    const canvas = this.template.querySelector('[data-id="stockAgingChart"]');
     // Always clear previous chart
    if (this.charts.aging) {
        this.charts.aging.destroy();
        this.charts.aging = null;
    }

    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (this.charts.aging) this.charts.aging.destroy();

    const bucketCounts = { '<30d': 0, '30–90d': 0, '90–180d': 0, '180–365d': 0, '>365d': 0 , 'Expired': 0 };
    const dataSource = this.filteredAgingData;

    dataSource.forEach(item => bucketCounts[item.bucket] += item.quantity);

    this.charts.aging = new window.Chart(ctx, {
        type: 'bar',
        data: {
            labels: Object.keys(bucketCounts),
            datasets: [{
                label: 'Qty by Aging Bucket',
                data: Object.values(bucketCounts),
                backgroundColor:['rgba(46, 204, 113, 0.7)', // replaces '#28a745'
                                    'rgba(52, 152, 219, 0.7)', // replaces '#ffc107'
                                    '#9b59b6', // replaces '#fd7e14'
                                    'rgba(127, 140, 141, 0.7)', // replaces '#ff6384'
                                    'rgba(231, 76, 60, 0.7)'
                                    ]
                // backgroundColor: ['#28a745', '#ffc107', '#fd7e14', '#ff6384', '#6c757d']
            }]
        },
        options: { responsive: true, maintainAspectRatio: false }
    });
}
clearAgingFilters() {
    this.agingFilters = { product: '', bucket: '', status: '' };
    this.applyAgingFilters();
}
fetchAgingTrendData() {
    this.isLoading = true;
    console.log('fetching aging trend data ');
    console.log('siteId:', this.selectedWarehouseForAging.Name);
    console.log('orgId:', this.organisationId);
    console.log('prodId:', this.selectedProduct.Id);
    console.log('yearStr:', this.selectedYear);
    getAgingTrendData({
        siteId: this.selectedWarehouseForAging.Id,
        orgId: this.organisationId,
        prodId: this.selectedProduct.Id || null,
        yearStr: this.selectedYear
    })
    .then(result => {
        console.log('Fetched Aging Trend Data:', result);
        this.agingTrendData = result;
        this.renderAgingTrendChart();
    })
    .catch(error => {
        console.error('Error fetching trend data', error);
    })
    .finally(() => {
        this.isLoading = false;
    });
}
renderAgingTrendChart() {
    console.log('in renderAging');
    const canvas = this.template.querySelector('[data-id="agingTrendChart"]');
    if (!canvas) {
        console.warn('Aging Trend canvas not found.');
        return;
    }

    const ctx = canvas.getContext('2d');

    if (!this.charts) this.charts = {};
    if (this.charts.agingTrend) this.charts.agingTrend.destroy();

    const labels = this.agingTrendData.map(row => row.month);
    const datasetKeys = ['<30d', '30–90d', '90–180d', '180–365d', '>365d'];

    const colors = {
        '<30d': 'rgba(46, 204, 113, 0.7)', // replaces '#28a745'
        '30–90d': 'rgba(52, 152, 219, 0.7)', // replaces '#ffc107'
        '90–180d': '#9b59b6', // replaces '#fd7e14'
        '180–365d': 'rgba(127, 140, 141, 0.7)',  // replaces '#ff6384'
        '>365d': 'rgba(231, 76, 60, 0.7)'
    };

    const datasets = datasetKeys.map(bucket => ({
        label: bucket,
        data: this.agingTrendData.map(row => row[bucket]),
        backgroundColor: colors[bucket],
        fill: true,
        tension: 0.3
    }));

    this.charts.agingTrend = new window.Chart(ctx, {
        type: 'line',
        data: {
            labels,
            datasets
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: { mode: 'index', intersect: false },
            stacked: true,
            plugins: {
                title: {
                    display: true,
                    text: 'Inventory Aging Trend (Monthly)'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    stacked: true
                },
                x: {
                    stacked: true
                }
            }
        }
    });
}

 loadAvailableYears() {
        try {
            const currentYear = new Date().getFullYear();
            const numYearsToShow = 5;
        
            const years = [];
            for (let i = 0; i < numYearsToShow; i++) {
                years.push(currentYear - i);
            }
        
           // this.yearOptions = years;
            this.selectedYear = years[0];
            console.log('yearOptions:', JSON.stringify(this.yearOptions));
            console.log('selectedYear:', this.selectedYear);
            if (this.selectedWarehouseForAging.Id && this.organisationId) {
                this.fetchAgingTrendData();
            }
        } catch (error) {
            console.error('❌ Error in loadAvailableYears():', error);
        }
    }
    // customer trend code statrs here 
get customerPatternTabClass() {
    return this.isCustomerPattern ? 'sub-tab-horizontal active' : 'sub-tab-horizontal';
}

selectCustomerPattern() {
    this.clearCharts();
    this.isDemand = false;
    this.isInventory = false;
    this.isSafety = false;
    this.isAging = false;
    this.selectedProduct = {Id:null,Name:null};
    this.isCustomerPattern = true;
    getDefaultCustomerFromOrders()
        .then(customer => {
            if (customer) {
                this.selectedCustomer = {
                    Id: customer.Id,
                    Name: customer.Name
                };
                this.isCustomerSelected = true
                this.customerYearOptions = this.generateYearOptions();
                this.isCustomerSelected = true;
                this.fetchCustomerPatternTrend(); 
                
            } else {
                console.warn('No default customer found.');
            }
        })
        .catch(error => {
            console.error('Error fetching default customer:', error);
        });
}
handleCustomerSelected(event) {
    console.log('Inside customer select');
    this.selectedCustomer.Id = event.detail.Id;
    this.selectedCustomer.Name = event.detail.Name;
    this.customerYearOptions = this.generateYearOptions();
    this.fetchCustomerPatternTrend();
    this.isCustomerSelected = true;
    //this.selectedCustomerYear = new Date().getFullYear().toString();
}
handleCustProdRemove(){
    this.custProd={Id:null,Name:null};
    this.fetchCustomerPatternTrend();
}
handleCustomerYearChange(event) {
    this.selectedCustomerYear =  parseInt(event.detail.value, 10);
    this.fetchCustomerPatternTrend();
}

handleCustomerPatternProductSelected(event) {
    this.custProd.Id = event.detail.Id;
    this.custProd.Name = event.detail.Name;
    this.fetchCustomerPatternTrend();
}
// fetchCustomerPatternTrend() {
//     if (!this.selectedCustomer.Id && !this.selectedProduct.Id) return;
//     console.log('selectedCustomer:', this.selectedCustomer , 'selectedProduct:', this.selectedProduct, 'organisationId:', this.organisationId , 'selectedYear:', this.selectedCustomerYear);
//     this.isLoading = true;
//     getCustomerOrderTrend({
//         customerId: this.selectedCustomer.Id,
//         productId: this.selectedProduct.Id,
//         orgId: this.organisationId,
//         yearStr: this.selectedCustomerYear
//     })
//         .then(result => {
//             this.customerPatternData = result;
//             this.renderCustomerPatternChart();
//         })
//         .catch(error => {
//             console.error('Error fetching customer pattern trend:', error);
//         })
//         .finally(() => {
//             this.isLoading = false;
//         });
// }

fetchCustomerPatternTrend() {
    console.log('in fetchcustomerpatterntrend');
    //if (!this.selectedCustomer.Id && !this.selectedProduct.Id) return;
    if (!this.selectedCustomer?.Id) return;
    console.log('not null customer');
    this.isLoading = true;
    console.log('Calling apex methods');
    Promise.all([
        getCustomerOrderTrend({
            customerId: this.selectedCustomer.Id,
            productId: this.custProd.Id,
            orgId: this.organisationId,
            yearStr: this.selectedCustomerYear
        })
        ,
        getCustomerSummary({
            customerId: this.selectedCustomer.Id,
            productId: this.custProd.Id,
            yearStr: this.selectedCustomerYear,
            orgId: this.organisationId
        })
    ])
    .then(([trendData, summaryData]) => {
        console.log('IN sucess ');
        this.customerPatternData = trendData;
        console.log('customerPatternData trend ',this.customerPatternData);
        this.customerSummary = summaryData;
        this.renderCustomerPatternChart();
    })
    .catch(error => {
        console.error('Error fetching trend or summary:', error);
    })
    .finally(() => {
        this.isLoading = false;
    });
}
handleCustomerRemove(){
    this.selectedCustomer={Id:null,Name:null}
    this.customerYearOptions = [];
    this.isCustomerSelected = false;
    this.customerSummary = {
    frequency: null,
    monetary: null,
    recencyDays: null,
    lastOrderDate: null
};   
}

renderCustomerPatternChart() {
    console.log('In customer pattern chart ');
    const canvas = this.template.querySelector('[data-id="customerPatternChart"]');
    if (!canvas || !this.customerPatternData) return;
    console.log('customerPatternData ',this.customerPatternData);
    const ctx = canvas.getContext('2d');
    if (this.charts.customerPattern) this.charts.customerPattern.destroy();

    this.charts.customerPattern = new window.Chart(ctx, {
        type: 'line',
        data: {
            labels: this.customerPatternData.months,
            datasets: [{
                label: 'Order Quantity',
                data: this.customerPatternData.quantities,
                fill: false,
                borderColor: '#77B5F2', //'rgba(54, 162, 235, 1)',
                tension: 0.3
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            scales: {
                y: {
                    beginAtZero: true
                }
            },
            plugins: {
                title: {
                    display: true,
                    text: 'Customer Order Pattern Over Time'
                }
            }
        }
    });
}
formatLargeNumber(value, digits = 1) {
    if (value === null || value === undefined || isNaN(value)) return '';

    const abs = Math.abs(value);
    const units = [
        { value: 1_000_000_000, symbol: 'B' },
        { value: 1_000_000, symbol: 'M' },
        { value: 1_000, symbol: 'K' }
    ];

    for (let unit of units) {
        if (abs >= unit.value) {
            return (value / unit.value).toFixed(digits) + unit.symbol;
        }
    }

    return value.toLocaleString();
}

// get formattedMonetaryValue() {
//     return this.customerSummary.monetary != null
//         ? new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR' }).format(this.customerSummary.monetary)
//         : '-';
// }

// get formattedLastOrderDate() {
//     return this.customerSummary.lastOrderDate
//         ? new Date(this.customerSummary.lastOrderDate).toLocaleDateString()
//         : '-';
// }
toggleSimulationPanel() {
    this.showSimulationPanel = !this.showSimulationPanel;

    if (this.showSimulationPanel && !this.simulationHasRun) {
        const currentYear = new Date().getFullYear();

        // Setup simulationInputs (current year only)
        this.simulationInputs = this.fullHistoricalLabels.map((label, i) => {
            if (label.includes(currentYear.toString())) {
                return { label, value: this.fullHistoricalValues[i] };
            }
            return null;
        }).filter(Boolean);

        // Setup forecast inputs (first 3 forecast months)
        this.futureForecastInputs = this.forecastLabels.slice(0, 3).map(label => ({
            label,
            value: '' // empty initially
        }));
    }
}

handleFutureForecastChange(event) {
    const label = event.target.dataset.label;
    const newVal = parseFloat(event.target.value) || 0;

    this.futureForecastInputs = this.futureForecastInputs.map(row => {
        return row.label === label ? { ...row, value: newVal } : row;
    });
}



handleSimInputChange(event) {
    const label = event.target.dataset.label;
    const newVal = parseFloat(event.target.value) || 0;

    this.simulationInputs = this.simulationInputs.map(row => {
        return row.label === label ? { ...row, value: newVal } : row;
    });
}
handleSimulateForecast() {
    const baseHistoricalLabels = [...this.fullHistoricalLabels];
    const baseHistoricalValues = [...this.fullHistoricalValues];

    //  Override historical inputs only for current year
    const simOverrideMap = new Map(
        this.simulationInputs.map(row => [row.label, parseFloat(row.value) || 0])
    );

    const patchedHistorical = baseHistoricalLabels.map((label, i) => {
        return simOverrideMap.has(label)
            ? simOverrideMap.get(label)
            : baseHistoricalValues[i];
    });

    //  Append manual future overrides
    const futureOverrideMap = new Map();
    const manualForecastInputs = [];

    this.futureForecastInputs.forEach(row => {
        const val = parseFloat(row.value);
        if (!isNaN(val)) {
            futureOverrideMap.set(row.label, val);
            manualForecastInputs.push(val);
        }
    });

    const simulationSeries = [...patchedHistorical, ...manualForecastInputs];

   
    generateForecastFromHistorical({
        historicalValues: simulationSeries,
        modelName: this.selectedModel
    })
    .then(result => {
       
        const finalSimulatedForecast = result.forecastMonths.map((label, i) =>
            futureOverrideMap.has(label)
                ? futureOverrideMap.get(label)
                : result.forecastValues[i]
        );
        this.simulatedForecast = finalSimulatedForecast;// added for just to store and export
        this.renderDemandForecastChart(
            this.fullHistoricalLabels,       
            this.fullHistoricalValues,     
            this.forecastLabels,           
            this.forecastData,             
            finalSimulatedForecast          
        );
        this.simulationHasRun = true;
        this.showSimulationPanel = false; 

    })
    .catch(error => {
        console.error('Simulation failed:', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Simulation Failed',
                message: error.body?.message || 'Something went wrong during simulation.',
                variant: 'error'
            })
        );
    });
}


resetSimulation() {
    this.simulationInputs = [];
    this.futureForecastInputs = [];
    this.simulatedForecast = [];
    this.simulatedForecastMonths = [];
    this.customFileName = '';
    // 🔒 Restore filtered current-year historical data
    const currentYear = new Date().getFullYear();
    this.filteredHistLabels = [];
    this.filteredHistData = [];

    for (let i = 0; i < this.fullHistoricalLabels.length; i++) {
        const label = this.fullHistoricalLabels[i];
        const value = this.fullHistoricalValues[i];

        if (label.includes(currentYear.toString())) {
            this.filteredHistLabels.push(label);
            this.filteredHistData.push(value);
        }
    }

    // 🚫 Hide simulation panel
    this.showSimulationPanel = false;

    // 📊 Re-render chart with original data only
    this.renderDemandForecastChart(
        this.fullHistoricalLabels,
        this.fullHistoricalValues,
        this.forecastLabels,
        this.forecastData,
        [] // No simulated forecast
    );
    this.simulationHasRun = false;
    this.showSimulationPanel = false;

}

handleModelChange(event) {
    this.selectedModel = event.detail.value;
    this.fetchDemandData();
}
downloadForecastAsCSV() {
    console.log('⬇️ Starting CSV download...');

    if (!Array.isArray(this.simulatedForecast) || this.simulatedForecast.length === 0) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'No Simulation Found',
                message: 'Please run a simulation before downloading.',
                variant: 'warning'
            })
        );
        return;
    }

    let csv = 'Month,Original Forecast,Manual Override,Simulated Forecast,Difference\n';

    const forecastMap = new Map();
    this.forecastLabels.forEach((label, i) => {
        forecastMap.set(label, this.forecastData[i]);
    });

    const overrideMap = new Map();
    this.futureForecastInputs.forEach(input => {
        const parsed = parseFloat(input.value);
        if (!isNaN(parsed)) {
            overrideMap.set(input.label, parsed);
        }
    });

    this.simulatedForecast.forEach((simValue, i) => {
        const month = this.forecastLabels[i];
        const base = forecastMap.get(month) || 0;
        const manual = overrideMap.has(month) ? overrideMap.get(month) : '';
        const diff = (simValue - base).toFixed(2);
        csv += `${month},${base},${manual},${simValue},${diff}\n`;
    });

    console.log('📄 Final CSV content:\n' + csv);

    // ✅ Encode CSV to base64-safe URI
    const encodedUri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);

    const baseName = this.customFileName?.trim();
    const safeName = baseName
        ? `${baseName}.csv`
        : (this.selectedProduct?.Name
            ? `SimulatedForecast_${this.selectedProduct.Name}.csv`
            : 'SimulatedForecast.csv');

    link.setAttribute('download', safeName);

   // link.setAttribute('download', fileName);
    document.body.appendChild(link);

    setTimeout(() => {
        link.click();
        document.body.removeChild(link);
        console.log('✅ Download triggered using data URI');
    }, 50);
}
downloadAgingAsCSV() {
    console.log('⬇️ Starting Stock Aging CSV download...');

    if (!Array.isArray(this.filteredAgingData) || this.filteredAgingData.length === 0) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'No Aging Data Found',
                message: 'Please load or filter aging data before downloading.',
                variant: 'warning'
            })
        );
        return;
    }

    const cleanText = (value) => {
        const text = value != null ? String(value) : '';
        return text
            .replace(/\u2013/g, '-')        // en-dash → hyphen
            .replace(/\u2014/g, '-')        // em-dash → hyphen
            .replace(/[\u2018\u2019]/g, "'") // smart single quotes
            .replace(/[\u201C\u201D]/g, '"') // smart double quotes
            .replace(/[\r\n]+/g, ' ')        // remove newlines
            .trim();
    };

    // Define header
    let csv = 'Product,Quantity,Received Date,Age (Days),Bucket,Status\n';

    // Loop and add rows
    this.filteredAgingData.forEach(item => {
        const product = cleanText(item.productName);
        const quantity = cleanText(item.quantity);
        const receivedDate = cleanText(item.receivedDate);
        const age = cleanText(item.ageInDays);
        const bucket = cleanText(item.bucket);
        const status = cleanText(item.status);

        csv += `${product},${quantity},${receivedDate},${age},${bucket},${status}\n`;
    });

    const encodedUri = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csv);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', 'StockAgingReport.csv');
    document.body.appendChild(link);

    setTimeout(() => {
        link.click();
        document.body.removeChild(link);
        console.log('✅ Aging data CSV download triggered.');
    }, 50);
}

handleFileNameChange(event) {
    this.customFileName = event.target.value;
}
handleCreatePO() {
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
handleStockTakeNav() {
    this[NavigationMixin.Navigate]({
        type: 'standard__component',
        attributes: {
            componentName: 'ERP7__StockTake'  
        }
    });
}

}