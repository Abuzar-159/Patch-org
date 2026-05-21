import { LightningElement, track, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import chartJs from '@salesforce/resourceUrl/ChartJS';
import getMonthlyIncomeExpense from '@salesforce/apex/financialplanning.getMonthlyIncomeExpense';
import getChartOfAccountsByType from '@salesforce/apex/financialplanning.getChartOfAccountsByType';
import getCustomerInvoiceSummary from '@salesforce/apex/financialplanning.getCustomerInvoiceSummary';
import getMonthlyCreditDebitSummary from '@salesforce/apex/financialplanning.getMonthlyCreditDebitSummary';
import getMonthlyIncomeExpensenew from '@salesforce/apex/financialplanning.getMonthlyIncomeExpensenew';
import getOverallIncomeAndExpenseTotals from '@salesforce/apex/financialplanning.getOverallIncomeAndExpenseTotals';
import getChartOfAccountTotals from '@salesforce/apex/financialplanning.getChartOfAccountTotals';
import getOverallExpenseBreakdown from '@salesforce/apex/financialplanning.getOverallExpenseBreakdown';
import getExpenseTypeBreakdown from '@salesforce/apex/financialplanning.getFilteredExpenseBreakdown';
import getChartOfAccountsWithBudgetAccounts from '@salesforce/apex/financialplanning.getChartOfAccountsWithBudgetAccounts';
import getProjectBudgetsByChartOfAccount from '@salesforce/apex/financialplanning.getProjectBudgetsByChartOfAccount';
import getSingleProjectBudget from '@salesforce/apex/financialplanning.getSingleProjectBudget';
import getProjectsByChartOfAccount from '@salesforce/apex/financialplanning.getProjectsByChartOfAccount';
import getYearlyIncomeAndExpenseWithPrediction from '@salesforce/apex/financialplanning.getYearlyIncomeAndExpenseWithPrediction';
import getDefaultOrg from '@salesforce/apex/financialplanning.getDefaultOrg';
import getCurrencySymbol from '@salesforce/apex/financialplanning.getCurrencySymbol';
import getCustomerTableDetails from '@salesforce/apex/financialplanning.getGroupedInvoiceBillDetails';
import getMonthlyIncomeExpenseWithPrediction from '@salesforce/apex/financialplanning.getMonthlyIncomeExpenseWithPrediction';
import simulateForecastWithInputs from '@salesforce/apex/financialplanning.simulateForecastWithInputs';






export default class FinancialTabs extends LightningElement {

    
     @track isBudget = true;
    @track isCosting = false;
    @track isNewBudget = false;
    @track isNewPlanning = false;
    @api organisationId;
     @track currencySymbol = ''; // 👈 Will hold the returned symbol
    @track fromDate = new Date();
    @track toDate = new Date();
    @track selectedRecordType = 'Assets';
    @track summaryView = 'Overdue';
    @track selectedCoa = '';
    @track showsimulation = true;
    @track availableCoas = [];
    @track coaData = {};
    @track coaKeys = [];
    @track showInitialCharts = false;
    @track showDetailedCharts = true;
    chartInstances = {};
    isChartJsInitialized = false;
    @track isGroupedChartVisible = true; // Flag to control grouped chart visibility
    @track selectedYearforIncome = new Date().getFullYear();
@track availableYearsforIncome = [];
@track selectedCreditDebitYear = new Date().getFullYear();
 @track availableCreditDebitYears = [];
@track selectedChartOfAccount = {};
   @track selectedProject = {};
    @track projectFilter = '';
    @track isProjectPieVisible = false;
@track isProjectChartVisible = false; // Flag to control project chart visibility
@track summaryTableKeys = [];
  @track displayRows = [];
@track showSummaryTable = false;
@track predictedDataMap = {}; // Map to hold predicted income/expense data  
 @track simulatedIncomeInputs = [];
    @track simulatedExpenseInputs = [];
    @track showSimulationPanel = false;
   @track simulatedValuesMap = {};
 @track isLoading = false;
   
    @track simulationResult;
    currentMonth;
  @track showSimulationPanel = false;
@track historicalData = {
        income: [],
        expense: []
    };

    @track predictedIncome = [];
    @track predictedExpense = [];

    allMonthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul',
                      'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];


     @track categoryData = {
        'Cost Budget': [],
        'Time and Material Budget': [],
        'Fixed Budget': []
    };

    @track categories = ['Cost Budget', 'Time and Material Budget', 'Fixed Budget'];

  

populateYearsDropdown() {
    const currentYear = new Date().getFullYear();
    const years = [];
    for (let i = 0; i <= 10; i++) {
        years.push(currentYear - i);
    }
    this.availableYearsforIncome = years.sort((a, b) => b - a);
    this.availableCreditDebitYears = years.sort((a, b) => b - a);
}


handleChartOfAccountRemoved(event) {
    console.log('🟡 handleChartOfAccountRemoved triggered') ;
    console.log('📦 Event detail:', event.detail);
    this.selectedChartOfAccount = {};
    this.isProjectChartVisible = false; // Hide project chart
    this.budgetPlanData();
    console.log('🔄 Chart of Account removed, showing grouped chart');
}

    handleYearChangeforIncome(event) {
        this.selectedYearforIncome = parseInt(event.target.value, 10);
        this.initializeLineChart();
        console.log('🔄 Year changed for Income Chart:', this.selectedYearforIncome);
        this.updateCreditDebitChart();
        console.log('🔄 Year changed for Credit/Debit Chart:', this.selectedYearforIncome);
    }

//    connectedCallback() {
//         const today = new Date();
//         const year = today.getFullYear();
//         this.fromDate = `${year}-01-01`;
//         this.toDate = today.toISOString().split('T')[0];
//         this.populateYearsDropdown();
//        // this.loadCoaOptions();
//     }


// connectedCallback() {
//     const today = new Date();
//     const year = today.getFullYear();
//     this.fromDate = `${year}-01-01`;
//     this.toDate = today.toISOString().split('T')[0];
//     this.populateYearsDropdown();
//     getDefaultOrg()
//         .then(org => {
//             this.organisationId = org.Id;
//             console.log('🔄 Org Id:', this.organisationId);
//         });

//     // Fetch only those Chart of Accounts which have Budget Accounts
//     getChartOfAccountsWithBudgetAccounts()
//         .then(ids => {
//             if (ids.length > 0) {
//                 this.chartOfAccountFilter = `Id IN (${ids.map(id => `'${id}'`).join(',')})`;
//             } else {
//                 this.chartOfAccountFilter = 'Id = null'; // Fallback if no results
//             }
//         })
//         .catch(error => {
//             console.error('❌ Error setting chartOfAccountFilter:', error);
//             this.chartOfAccountFilter = ''; // Fallback on error
//         });
// }


connectedCallback() {
    const today = new Date();
    const year = today.getFullYear();
    this.fromDate = `${year}-01-01`;
    this.toDate = today.toISOString().split('T')[0];



  


    this.populateYearsDropdown();

    // Get org
    getDefaultOrg()
        .then(org => {
            this.organisationId = org.Id;
            console.log('🔄 Org Id:', this.organisationId);
        });



    // Fetch Chart of Accounts with Budget Accounts
    getChartOfAccountsWithBudgetAccounts()
        .then(ids => {
            if (ids.length > 0) {
                this.chartOfAccountFilter = `Id IN (${ids.map(id => `'${id}'`).join(',')})`;
            } else {
                this.chartOfAccountFilter = 'Id = null'; // fallback
            }
        })
        .catch(error => {
            console.error('❌ Error setting chartOfAccountFilter:', error);
            this.chartOfAccountFilter = ''; // fallback
        });

   
}


backtoInitialCharts() {
    this.showInitialCharts = true;
    this.showDetailedCharts = false;

     this.loadInitialCharts();
     this.loadChartDataforYearlySummary();

}

    // renderedCallback() {


        
    //     if (this.isChartJsInitialized) return;
    //     this.isChartJsInitialized = true;
    //     loadScript(this, chartJs)
    //         .then(() => {

    //                 // 🔄 Get Currency Symbol from Apex
    // getCurrencySymbol()
    //     .then(symbol => {
    //         this.currencySymbol = symbol;
    //         console.log('💱 Currency Symbol:', this.currencySymbol);
    //     })
    //     .catch(error => {
    //         console.error('❌ Error fetching currency symbol:', error);
    //         this.currencySymbol = ''; // fallback
    //     });
    //             this.initializeCharts();
    //         })
    //         .catch(error => {
    //             console.error('ChartJS load error:', error);
    //         });


                   
    // }


    renderedCallback() {
    if (this.isChartJsInitialized) return;
    this.isChartJsInitialized = true;

    loadScript(this, chartJs)
        .then(() => {
            // 🔄 Get Currency Symbol from Apex
            return getCurrencySymbol();
        })
        .then(symbol => {
            this.currencySymbol = symbol;
            console.log('💱 Currency Symbol:', this.currencySymbol);

            // ✅ Only initialize chart after currency is set
            this.initializeCharts();
        })
        .catch(error => {
            console.error('❌ Error fetching currency symbol or loading ChartJS:', error);
            this.currencySymbol = ''; // fallback
        });
}


   get budgetTabClass() {
    return this.isBudget ? 'sub-tab-horizontal active' : 'sub-tab-horizontal';
}

get costingTabClass() {
    return this.isCosting ? 'sub-tab-horizontal active' : 'sub-tab-horizontal';
}



get newBudgetTabClass() {
    return this.isNewBudget ? 'sub-tab-horizontal active' : 'sub-tab-horizontal';
}



get newPlanningTabClass() {
    return this.isNewPlanning ? 'sub-tab-horizontal active' : 'sub-tab-horizontal';
}

get newSubscriptionTabClass() {
    return this.isNewSubscription ? 'sub-tab-horizontal active' : 'sub-tab-horizontal';
}   

  resetTabs() {
    this.isBudget = false;
    this.isCosting = false;
    this.isNewBudget = false;
    this.isNewPlanning = false;
}

selectBudget() {
    this.resetTabs();
    this.isBudget = true;
    this.selectedYearforIncome = new Date().getFullYear();
    setTimeout(() => this.initializeCharts(), 20);
}

selectCosting() {
    this.resetTabs();
    this.isCosting = true;
    
    setTimeout(() => this.initializeCharts(), 20);
     this.fetchCustomerSummaryTable();
}



selectNewBudget() {
    this.resetTabs();
    this.isNewBudget = true;
    this.projectFilter = '';
    this.selectedChartOfAccount = {};
    this.selectedProject = {};
    this.isProjectChartVisible = false; // Hide project chart

    setTimeout(() => this.initializeCharts(), 20);
    
}


  selectNewPlanning() {
        this.resetTabs();
        this.selectedChartOfAccount = {};
        this.selectedProject = {};
        this.projectFilter = '';
        this.isNewPlanning = true;

        setTimeout(() => this.initializeCharts(), 20);
    }

    selectNewSubscription() {
        this.resetTabs();   
        this.isNewSubscription = true;

        setTimeout(() => this.initializeCharts(), 20);
    }   

handleRecordTypeChange(event) {
    this.selectedRecordType = event.target.value;
    this.updateDoubleBarChart();
}

    handleCustomerSummaryChange(event) {
        this.summaryView = event.target.value;
        this.updateCustomerHeatmap();
          this.fetchCustomerSummaryTable();
        console.log('🔄 Customer Summary View changed to:', this.summaryView);
    }


 fetchCustomerSummaryTable() {
        getCustomerTableDetails({ type: this.summaryView })
            .then(result => {
                this.summaryTableData = result || {};
            
                this.processSummaryTableData();
                   
            })
            .catch(error => {
                console.error('❌ Error fetching customer summary table:', error);
            });
    }


    processSummaryTableData() {
    const rows = [];

    let currentCustomer = null;
    let colorToggle = false;

    Object.entries(this.summaryTableData).forEach(([customer, records]) => {
        records.forEach((record, index) => {
            if (currentCustomer !== customer) {
                currentCustomer = customer;
                colorToggle = !colorToggle; // Flip color on new customer
            }

            rows.push({
                slno: index + 1,
                customer: index === 0 ? customer : '', // only show name in first row
                recordName: record.recordName,
                recordId: record.recordId,
                amount: record.amount,
                rowGroupClass: colorToggle ? 'group-color-a' : 'group-color-b'
            });
        });
    });

    this.displayRows = rows;
}

handleRecordClick(event) {
        const recordId = event.currentTarget.dataset.recordId;
        if (recordId) {
            const baseUrl = window.location.origin;
            const recordUrl = `${baseUrl}/${recordId}`;
            window.open(recordUrl, '_blank');
        } else {
            console.error('Record ID not found on clicked element');
        }
    }


    initializeCharts() {
        this.initializeLineChart();
        this.updateDoubleBarChart();
        this.updateCustomerHeatmap();
        this.updateCreditDebitChart();
        this.loadIncomeExpenseCharts();
        this.budgetPlanData();
        this.loadChartDataforYearlySummary();
        this.initializeLineChartwithPrediction();

    }



toggleChartsforSimulation() {
    this.showsimulation = false;

    // Delay the chart initialization until after DOM updates
    setTimeout(() => {
        this.initializeLineChartwithPrediction();
    }, 0);
}

    togglebackToMain() {
        this.showsimulation = true;
        this.selectBudget();
    }



    openSimulationModal() {
    const currentMonthIndex = new Date().getMonth(); // 0 = Jan, 11 = Dec
    const monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    // Filter for future months
    this.simulatedIncomeInputs = monthLabels.slice(currentMonthIndex).map(month => ({
        label: month,
        value: null
    }));
    this.simulatedExpenseInputs = monthLabels.slice(currentMonthIndex).map(month => ({
        label: month,
        value: null
    }));
    
    this.showSimulationPanel = true;
}
handleSimInputChange(event) {
   
    
    const month = event.target.dataset.month;
    const type = event.target.dataset.type;
    const value = event.target.value ? parseFloat(event.target.value) : 0;

    if (!this.simulatedValuesMap[month]) {
        this.simulatedValuesMap[month] = { income: null, expense: null };
    }

    this.simulatedValuesMap[month][type] = value;

    console.log('📝 Simulated Values Map:', JSON.stringify(this.simulatedValuesMap));
}


handleSimulateForecast() {
    const inputMap = {};
    const currentYear = new Date().getFullYear();
    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Step 1: Only include non-null simulated values
    for (const [month, values] of Object.entries(this.simulatedValuesMap)) {
        const income = values.income !== null && values.income !== undefined ? parseFloat(values.income) : null;
        const expense = values.expense !== null && values.expense !== undefined ? parseFloat(values.expense) : null;

        // Include only if at least one value is non-null
        if (income !== null || expense !== null) {
            inputMap[month] = {
                income,
                expense
            };
        }
    }

    console.log('🚀 Simulated data to send:', JSON.stringify(inputMap));

    // Step 2: Send to Apex for simulation
    simulateForecastWithInputs({ simulatedValues: inputMap })
        .then((result) => {
            console.log('📊 Simulated Forecast Result from Apex:', JSON.stringify(result));
            this.renderSimulatedForecastChart(result);
        })
        .catch((error) => {
            console.error('❌ Forecast Simulation Error:', error);
        });
}

renderSimulatedForecastChart(data) {
    const ctx = this.template.querySelector('.income-expense-line-prediction')?.getContext('2d');
    if (!ctx) {
        console.warn('⚠️ Chart context not found');
        return;
    }

    const labels = data.monthLabels || [];
    const actualIncome = data.actualIncome || [];
    const actualExpense = data.actualExpense || [];
    const predictedIncome = this.predictedIncome || [];
    const predictedExpense = this.predictedExpense || [];
    const simulatedIncome = data.predictedIncome || []; 
    const simulatedExpense = data.predictedExpense || [];

    this.destroyChart('lineChart');

    const datasets = [
        {
            label: 'Income (Actual)',
            data: actualIncome,
            borderColor: '#9D53F2',
            backgroundColor: 'rgba(157, 83, 242, 0.1)',
            tension: 0.3,
            fill: true,
            pointRadius: 0,
            borderWidth: 2
        },
        {
            label: 'Expenses (Actual)',
            data: actualExpense,
            borderColor: '#3290ED',
            backgroundColor: 'rgba(50, 144, 237, 0.1)',
            tension: 0.3,
            fill: true,
            pointRadius: 0,
            borderWidth: 2
        },
        {
            label: 'Income (Predicted)',
            data: predictedIncome,
            borderColor: '#9D53F2',
            borderDash: [5, 5],
            tension: 0.3,
            fill: false,
            pointRadius: 0,
            borderWidth: 2
        },
        {
            label: 'Expenses (Predicted)',
            data: predictedExpense,
            borderColor: '#3290ED',
            borderDash: [5, 5],
            tension: 0.3,
            fill: false,
            pointRadius: 0,
            borderWidth: 2
        }
    ];

    // Add Simulated only if present
    if (simulatedIncome.length > 0) {
        datasets.push({
            label: 'Income (Simulated)',
            data: simulatedIncome,
            borderColor: '#F26522',
            borderDash: [2, 3],
            tension: 0.3,
            fill: false,
            pointRadius: 0,
            borderWidth: 2
        });
    }

    if (simulatedExpense.length > 0) {
        datasets.push({
            label: 'Expenses (Simulated)',
            data: simulatedExpense,
            borderColor: '#FF3C38',
            borderDash: [2, 3],
            tension: 0.3,
            fill: false,
            pointRadius: 0,
            borderWidth: 2
        });
    }

    this.chartInstances.lineChart = new window.Chart(ctx, {
        type: 'line',
        data: {
            labels,
            datasets
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
                        callback: value => (this.currencySymbol || '') + value.toLocaleString()
                    },
                    title: {
                        display: true,
                        text: 'Amount ' + (this.currencySymbol || '')
                    }
                }
            }
        }
    });
}


initializeLineChart() {
    const ctx = this.template.querySelector('.income-expense-line')?.getContext('2d');
    if (!ctx) {
        console.warn('⚠️ Chart context not found');
        return;
    }

    getMonthlyIncomeExpense({ year: this.selectedYearforIncome })
        .then(result => {
            console.log('📊 Raw Chart Data:', JSON.stringify(result));

            this.historicalData = {
                income: Array.from({ length: 12 }, (_, i) => result.income?.[i] ?? 0),
                expense: Array.from({ length: 12 }, (_, i) => result.expense?.[i] ?? 0)
            };

            // Normalize data
            let incomeData = Array.from({ length: 12 }, (_, i) => result.income?.[i] ?? 0);
            let expenseData = Array.from({ length: 12 }, (_, i) => result.expense?.[i] ?? 0);

            console.log('✅ Final Income Array:', JSON.stringify(incomeData));
            console.log('✅ Final Expense Array:', JSON.stringify(expenseData));

            this.destroyChart('lineChart');

            // Animation config
            const easing = window.Chart.helpers.easingEffects.easeInCubic;
            const totalDuration = 5000;
            const duration = (ctx) => easing(ctx.index / incomeData.length) * totalDuration / incomeData.length;
            const delay = (ctx) => easing(ctx.index / incomeData.length) * totalDuration;
            const previousY = (ctx) =>
                ctx.index === 0
                    ? ctx.chart.scales.y.getPixelForValue(0)
                    : ctx.chart.getDatasetMeta(ctx.datasetIndex).data[ctx.index - 1].getProps(['y'], true).y;

            const animation = {
                x: {
                    type: 'number',
                    easing: 'linear',
                    duration: duration,
                    from: NaN,
                    delay(ctx) {
                        if (ctx.type !== 'data' || ctx.xStarted) {
                            return 0;
                        }
                        ctx.xStarted = true;
                        return delay(ctx);
                    }
                },
                y: {
                    type: 'number',
                    easing: 'linear',
                    duration: duration,
                    from: previousY,
                    delay(ctx) {
                        if (ctx.type !== 'data' || ctx.yStarted) {
                            return 0;
                        }
                        ctx.yStarted = true;
                        return delay(ctx);
                    }
                }
            };

             const symbol = this.currencySymbol || ''; // fallback if not set

            // Chart creation
            this.chartInstances.lineChart = new window.Chart(ctx, {
                type: 'line',
                data: {
                    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                    datasets: [
                        {
                            label: 'Income',
                            data: incomeData,
                            borderColor: '#9D53F2',
                            backgroundColor: 'rgba(157, 83, 242, 0.1)',
                            fill: true,
                            pointRadius: 0,
                            borderWidth: 2
                        },
                        {
                            label: 'Expenses',
                            data: expenseData,
                            borderColor: '#3290ED',
                            backgroundColor: 'rgba(50, 144, 237, 0.1)',
                            fill: true,
                            pointRadius: 0,
                            borderWidth: 2
                        }
                    ]
                },
                options: {
                    responsive: true,
                    animation: animation, // ✅ Using your custom animation here
                    plugins: {
                        legend: { position: 'top' },
                        title: {
                            display: true
                           
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Amount ' + symbol
                            },
                            ticks: {
                                callback: (value) => {
                                    return symbol + value.toLocaleString();
                                }
                            }
                        }
                    }
                }
            });
        })
        .catch(error => {
            console.error('❌ Error loading chart data:', error);
        });
}



// initializeLineChartwithPrediction() {
//     const ctx = this.template.querySelector('.income-expense-line-prediction')?.getContext('2d');
//     console.log('🔄 Initializing Line Chart with Prediction', ctx);
//     if (!ctx) {
//         console.warn('⚠️ Chart context not found');
//         console.log('⚠️ Chart context not found32');  

//         return;
//     }

//     getMonthlyIncomeExpenseWithPrediction()
//         .then(result => {
//             console.log('📊 Chart Data:', JSON.stringify(result));

//             const symbol = this.currencySymbol || ''; // fallback

//             const labels = result.monthLabels || ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//             const incomeData = result.income || [];
//             const expenseData = result.expense || [];
//             const predictedIncome = result.predictedIncome || [];
//             const predictedExpense = result.predictedExpense || [];

//             console.log('✅ Income Data:', JSON.stringify(incomeData));
//             console.log('✅ Expense Data:', JSON.stringify(expenseData));
//             console.log('✅ Predicted Income Data:', JSON.stringify(predictedIncome));
//             console.log('✅ Predicted Expense Data:', JSON.stringify(predictedExpense));



//             this.destroyChart('lineChart');

//             // Animation
//             const easing = window.Chart.helpers.easingEffects.easeInCubic;
//             const totalDuration = 3000;
//             const duration = (ctx) => easing(ctx.index / incomeData.length) * totalDuration / incomeData.length;
//             const delay = (ctx) => easing(ctx.index / incomeData.length) * totalDuration;
//             const previousY = (ctx) =>
//                 ctx.index === 0
//                     ? ctx.chart.scales.y.getPixelForValue(0)
//                     : ctx.chart.getDatasetMeta(ctx.datasetIndex).data[ctx.index - 1]?.getProps(['y'], true).y;

//             const animation = {
//                 x: {
//                     type: 'number',
//                     easing: 'linear',
//                     duration: duration,
//                     from: NaN,
//                     delay(ctx) {
//                         if (ctx.type !== 'data' || ctx.xStarted) return 0;
//                         ctx.xStarted = true;
//                         return delay(ctx);
//                     }
//                 },
//                 y: {
//                     type: 'number',
//                     easing: 'linear',
//                     duration: duration,
//                     from: previousY,
//                     delay(ctx) {
//                         if (ctx.type !== 'data' || ctx.yStarted) return 0;
//                         ctx.yStarted = true;
//                         return delay(ctx);
//                     }
//                 }
//             };

//             // Chart creation
//             this.chartInstances.lineChart = new window.Chart(ctx, {
//                 type: 'line',
//                 data: {
//                     labels: labels,
//                     datasets: [
//                         {
//                             label: 'Income (Actual)',
//                             data: incomeData,
//                             borderColor: '#9D53F2',
//                             backgroundColor: 'rgba(157, 83, 242, 0.1)',
//                             fill: true,
//                             pointRadius: 0,
//                             borderWidth: 2
//                         },
//                         {
//                             label: 'Expenses (Actual)',
//                             data: expenseData,
//                             borderColor: '#3290ED',
//                             backgroundColor: 'rgba(50, 144, 237, 0.1)',
//                             fill: true,
//                             pointRadius: 0,
//                             borderWidth: 2
//                         },
//                         {
//                             label: 'Income (Predicted)',
//                             data: predictedIncome,
//                             borderColor: '#9D53F2',
//                             borderDash: [5, 5],
//                             fill: false,
//                             pointRadius: 0,
//                             borderWidth: 2
//                         },
//                         {
//                             label: 'Expenses (Predicted)',
//                             data: predictedExpense,
//                             borderColor: '#3290ED',
//                             borderDash: [5, 5],
//                             fill: false,
//                             pointRadius: 0,
//                             borderWidth: 2
//                         }
//                     ]
//                 },
//                 options: {
//                     responsive: true,
//                     animation: animation,
//                     plugins: {
//                         legend: { position: 'top' },
//                         title: {
//                             display: false
//                         }
//                     },
//                     scales: {
//                         y: {
//                             beginAtZero: true,
//                             title: {
//                                 display: true,
//                                 text: 'Amount ' + symbol
//                             },
//                             ticks: {
//                                 callback: (value) => symbol + value.toLocaleString()
//                             }
//                         }
//                     }
//                 }
//             });
//         })
//         .catch(error => {
//             console.error('❌ Error loading chart data:', error);
//         });
// }


initializeLineChartwithPrediction() {
    const ctx = this.template.querySelector('.income-expense-line-prediction')?.getContext('2d');
    console.log('🔄 Initializing Line Chart with Prediction', ctx);
    if (!ctx) {
        console.warn('⚠️ Chart context not found');
        return;
    }

    getMonthlyIncomeExpenseWithPrediction()
        .then(result => {
            console.log('📊 Chart Data:', JSON.stringify(result));

            const symbol = this.currencySymbol || '';
            const labels = result.monthLabels || ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            const incomeData = result.income || [];
            const expenseData = result.expense || [];
            const predictedIncome = result.predictedIncome || [];
            const predictedExpense = result.predictedExpense || [];

            this.predictedIncome = predictedIncome;
            this.predictedExpense = predictedExpense;

            console.log('✅ Income Data:', JSON.stringify(incomeData));
            console.log('✅ Expense Data:', JSON.stringify(expenseData));
            console.log('✅ Predicted Income Data:', JSON.stringify(predictedIncome));
            console.log('✅ Predicted Expense Data:', JSON.stringify(predictedExpense));

            // 🔐 Save predicted values for later
            this.predictedDataMap = {};
            labels.forEach((month, index) => {
                this.predictedDataMap[month] = {
                    income: predictedIncome[index] || 0,
                    expense: predictedExpense[index] || 0
                };
            });
            console.log('🧠 Saved predicted data map:', this.predictedDataMap);

            this.destroyChart('lineChart');

            const easing = window.Chart.helpers.easingEffects.easeInCubic;
            const totalDuration = 3000;
            const duration = (ctx) => easing(ctx.index / incomeData.length) * totalDuration / incomeData.length;
            const delay = (ctx) => easing(ctx.index / incomeData.length) * totalDuration;
            const previousY = (ctx) =>
                ctx.index === 0
                    ? ctx.chart.scales.y.getPixelForValue(0)
                    : ctx.chart.getDatasetMeta(ctx.datasetIndex).data[ctx.index - 1]?.getProps(['y'], true).y;

            const animation = {
                x: {
                    type: 'number',
                    easing: 'linear',
                    duration: duration,
                    from: NaN,
                    delay(ctx) {
                        if (ctx.type !== 'data' || ctx.xStarted) return 0;
                        ctx.xStarted = true;
                        return delay(ctx);
                    }
                },
                y: {
                    type: 'number',
                    easing: 'linear',
                    duration: duration,
                    from: previousY,
                    delay(ctx) {
                        if (ctx.type !== 'data' || ctx.yStarted) return 0;
                        ctx.yStarted = true;
                        return delay(ctx);
                    }
                }
            };

            // 🖌️ Draw Chart
            this.chartInstances.lineChart = new window.Chart(ctx, {
                type: 'line',
                data: {
                    labels: labels,
                    datasets: [
                        {
                            label: 'Income (Actual)',
                            data: incomeData,
                            borderColor: '#9D53F2',
                            backgroundColor: 'rgba(157, 83, 242, 0.1)',
                            fill: true,
                            pointRadius: 0,
                            borderWidth: 2
                        },
                        {
                            label: 'Expenses (Actual)',
                            data: expenseData,
                            borderColor: '#3290ED',
                            backgroundColor: 'rgba(50, 144, 237, 0.1)',
                            fill: true,
                            pointRadius: 0,
                            borderWidth: 2
                        },
                        {
                            label: 'Income (Predicted)',
                            data: predictedIncome,
                            borderColor: '#9D53F2',
                            borderDash: [5, 5],
                            fill: false,
                            pointRadius: 0,
                            borderWidth: 2
                        },
                        {
                            label: 'Expenses (Predicted)',
                            data: predictedExpense,
                            borderColor: '#3290ED',
                            borderDash: [5, 5],
                            fill: false,
                            pointRadius: 0,
                            borderWidth: 2
                        }
                    ]
                },
                options: {
                    responsive: true,
                    animation: animation,
                    plugins: {
                        legend: { position: 'top' },
                        title: { display: false }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Amount ' + symbol
                            },
                            ticks: {
                                callback: (value) => symbol + value.toLocaleString()
                            }
                        }
                    }
                }
            });
        })
        .catch(error => {
            console.error('❌ Error loading chart data:', error);
        });
}



     updateDoubleBarChart() {
        const ctx = this.template.querySelector('.coa-pie-chart')?.getContext('2d');
        if (!ctx) return;

        getChartOfAccountsByType({ recordType: this.selectedRecordType })
            .then(result => {
                console.log('📊 COA Chart Data:', result);

                const labels = result.labels;
                const debitData = result.debits;
                const creditData = result.credits;

                this.destroyChart('coaChart');

               let delayed;
                const symbol = this.currencySymbol || ''; // fallback if not set

this.chartInstances.coaChart = new window.Chart(ctx, {
    type: 'bar',
    data: {
        labels: labels,
        datasets: [
            {
                label: `Total Amount ${this.currencySymbol} Debited`,
                data: debitData,
                backgroundColor: '#9D53F2'
            },
            {
                label: `Total Amount ${this.currencySymbol} Credited`,
                data: creditData,
                backgroundColor: '#3290ED'
            }
        ]
    },
    options: {
        responsive: true,
        animation: {
            onComplete: () => {
                delayed = true;
            },
            delay: (context) => {
                let delay = 0;
                if (context.type === 'data' && context.mode === 'default' && !delayed) {
                    delay = context.dataIndex * 300 + context.datasetIndex * 100;
                }
                return delay;
            }
        },
        plugins: {
            legend: { position: 'top' }
        },
        scales: {
            y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Amount ' + symbol
                            },
                            ticks: {
                                callback: (value) => {
                                    return symbol + value.toLocaleString();
                                }
                            }
                        }
        }
    }
});

            })
            .catch(error => console.error('❌ Error fetching COA data:', error));
    }

  updateCustomerHeatmap() {
    const ctx = this.template.querySelector('.heatmap-overdue')?.getContext('2d');
    if (!ctx) return;

    getCustomerInvoiceSummary({ type: this.summaryView }) // 'Overdue' or 'Unpaid'
        .then(result => {
            const customers = result.labels;
            const amounts = result.amounts;
            const counts = result.counts;

            // Dummy third data series — replace with real data if needed
           // const otherMetric = result.otherMetric || customers.map(() => Math.floor(Math.random() * 5000));

            this.destroyChart('heatmap');
 const symbol = this.currencySymbol || ''; // fallback if not set
            this.chartInstances.heatmap = new window.Chart(ctx, {
                type: 'bar',
                data: {
                    labels: customers,
                    datasets: [
                        {
                            label: `Amount ${this.currencySymbol}`,
                            data: amounts,
                            backgroundColor: '#9D53F2 '
                        },
                        {
                            label: 'Count',
                            data: counts,
                            backgroundColor: '#3290ED'
                        }
                        // {
                        //     label: 'Other Metric',
                        //     data: otherMetric,
                        //     backgroundColor: '#26ABA4'
                        // }
                    ]
                },
                options: {
                    responsive: true,
                    indexAxis: 'x',
                    plugins: {
                        legend: {
                            position: 'top'
                        },
                        tooltip: {
                            mode: 'index',
                            intersect: false
                        }
                    },
                    scales: {
                        x: {
                            stacked: false,
                            beginAtZero: true
                        },
                        y: {
                            stacked: false,
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Amount ' + symbol
                            },
                            ticks: {
                                callback: (value) => {
                                    return symbol + value.toLocaleString();
                                }
                            }
                        }
                       
                    }
                }
            });
        })
        .catch(error => {
            console.error('Error loading invoice data:', error);
        });
}




//   // Handle year dropdown change
// handleCreditDebitYearChange(event) {
//     this.selectedCreditDebitYear = parseInt(event.target.value, 10);
//     this.updateCreditDebitChart(); // Replace with your chart refresh function
// }

  updateCreditDebitChart() {
    const ctx = this.template.querySelector('.bar-monthly-notes')?.getContext('2d');
    if (!ctx) {
        console.error('Chart context not found');
        return;
    }

    let delayed; // 👈 Delayed flag to control animation sequence

    getMonthlyCreditDebitSummary({ year: this.selectedYearforIncome })
        .then(result => {
            const months = [
                'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];

            const credits = result.credits ?? [];
            const debits = result.debits ?? [];

            this.destroyChart('creditDebitBar');

            const symbol = this.currencySymbol || ''; // fallback if not set

            this.chartInstances.creditDebitBar = new window.Chart(ctx, {
                type: 'bar',
                data: {
                    labels: months,
                    datasets: [
                        {
                            label: `Credit Note Amount`,
                            data: credits,
                            backgroundColor: '#9D53F2 '
                        },
                        {
                            label: `Debit Note Amount`,
                            data: debits,
                            backgroundColor: '#3290ED'
                        }
                    ]
                },
                options: {
                    responsive: true,
                    animation: {
                        onComplete: () => {
                            delayed = true;
                        },
                        delay: (context) => {
                            let delay = 0;
                            if (context.type === 'data' && context.mode === 'default' && !delayed) {
                                delay = context.dataIndex * 300 + context.datasetIndex * 100;
                            }
                            return delay;
                        }
                    },
                    plugins: {
                        legend: { position: 'bottom' },
                        tooltip: {
                            mode: 'index',
                            intersect: false
                        }
                    },
                    scales: {
                        x: {
                            stacked: true // 👈 Enable stacking on X-axis
                        },
                        y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Amount ' + symbol
                            },
                            ticks: {
                                callback: (value) => {
                                    return symbol + value.toLocaleString();
                                }
                            }

                        }
                    }
                }
            });
        })
        .catch(error => {
            console.error('Error loading Credit/Debit data:', error);
        });
}







    destroyChart(name) {
        if (this.chartInstances[name]) {
            this.chartInstances[name].destroy();
            this.chartInstances[name] = null;
        }
    }




       handleFromDateChange(event) {
        this.fromDate = event.target.value;
    }

    handleToDateChange(event) {
        this.toDate = event.target.value;
    }

loadIncomeExpenseCharts() {
    console.log('🔄 Starting loadIncomeExpenseCharts with fromDate:', this.fromDate, 'toDate:', this.toDate);
    if (!this.fromDate || !this.toDate) {
        console.warn('⛔ Please select both From and To dates.');
        return;
    }

    this.showInitialCharts = false;
    this.showDetailedCharts = true;

    Promise.all([
        getMonthlyIncomeExpensenew({ fromDate: this.fromDate, toDate: this.toDate }),
        getExpenseTypeBreakdown({ fromDate: this.fromDate, toDate: this.toDate })
    ])
    .then(([data, expenseTypeData]) => {
        console.log('📥 Chart Data received:', data);
        console.log('📊 Expense Type Breakdown received:', JSON.stringify(expenseTypeData));

        const labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        console.log('📋 Labels set to:', labels);

        // Paid Chart
        console.log('🎨 Rendering Paid Chart with income:', data.paid.income, 'expense:', data.paid.expense);
        this.renderBarChart(
            '.paid-income-expense-chart',
            labels,
            data.paid.income,
            data.paid.expense,
            'Paid Income',
            'Paid Expense',
            'paidChart'
        );

        // Unpaid Chart
        console.log('🎨 Rendering Unpaid Chart with income:', data.unpaid.income, 'expense:', data.unpaid.expense);
        this.renderBarChart(
            '.unpaid-income-expense-chart',
            labels,
            data.unpaid.income,
            data.unpaid.expense,
            'Unpaid Income',
            'Unpaid Expense',
            'unpaidChart'
        );

        // Total Income vs Expense Pie
        const totalIncome = [...data.paid.income, ...data.unpaid.income].reduce((a, b) => a + b, 0);
        const totalExpense = [...data.paid.expense, ...data.unpaid.expense].reduce((a, b) => a + b, 0);
        console.log('💰 Total Income calculated:', totalIncome, 'Total Expense calculated:', totalExpense);
        this.renderPieChart2(
            '.total-income-expense-pie',
            ['Income', 'Expenses'],
            [totalIncome, totalExpense],
            ['#3290ED', '#9D53F2 '],
            'Total Income vs Expenses',
            'totalPie'
        );

        // Expense Type Breakdown Doughnut
        const expenseLabels = ['Expense Bill', 'PO Bill', 'Advance to Vendor', 'My Expenses'];
        const expenseColors = ['#9D53F2 ', '#3290ED', '#9c27b0', '#263eabff']; // Aligned with getOverallExpenseBreakdown colors
        const expenseData = [
            expenseTypeData.totalExpenseBill || 0,
            expenseTypeData.totalPOBill || 0,
            expenseTypeData.totalAdvance || 0,
            expenseTypeData.totalMyExpense || 0
        ];
        console.log('📊 Expense Data for Doughnut:', expenseData);
        this.renderPieChart2(
            '.expense-type-doughnut',
            expenseLabels,
            expenseData,
            expenseColors,
            'Expense Type Breakdown',
            'expenseTypeDonut'
        );
    })
    .catch(error => {
        console.error('❌ Error fetching chart data:', error);
    });
}



renderBarChart(selector, labels, incomeData, expenseData, incomeLabel, expenseLabel, chartKey) {
    console.log('📊 Rendering Bar Chart for', selector, 'with income:', incomeData, 'expense:', expenseData);
    const ctx = this.template.querySelector(selector)?.getContext('2d');
    if (!ctx) return;

    this.destroyChart(chartKey);

    let delayed;

    const symbol = this.currencySymbol || ''; // fallback if not set
this.chartInstances[chartKey] = new window.Chart(ctx, {
    type: 'bar',
    data: {
        labels: labels,
        datasets: [
            {
                label: incomeLabel,
                data: incomeData,
                backgroundColor: '#3290ED'
            },
            {
                label: expenseLabel,
                data: expenseData,
                backgroundColor: '#9D53F2 '
            }
        ]
    },
    options: {
        responsive: true,
        animation: {
            onComplete: () => {
                delayed = true;
            },
            delay: (context) => {
                let delay = 0;
                if (context.type === 'data' && context.mode === 'default' && !delayed) {
                    delay = context.dataIndex * 300 + context.datasetIndex * 100;
                }
                return delay;
            }
        },
        plugins: {
            legend: { position: 'top' },
            title: {
                display: true,
                text: `${incomeLabel} vs ${expenseLabel}`
            }
        },
        scales: {
            y: {
                            beginAtZero: true,
                            title: {
                                display: true,
                                text: 'Amount ' + symbol
                            },
                            ticks: {
                                callback: (value) => {
                                    return symbol + value.toLocaleString();
                                }
                            }
                        }
        }
    }
});

}

loadInitialCharts() {
    console.log('🔄 Starting loadInitialCharts');
    getOverallIncomeAndExpenseTotals()
        .then(result => {
            console.log('💰 Overall Income and Expense Totals:', result);
            const labels = ['Income', 'Expenses'];
            const values = [result.totalIncome, result.totalExpense];
            const colors = ['#3290ED', '#9D53F2'];
            console.log('📊 Pie Chart Data:', { labels, values, colors });
            this.renderPieChart2('.total-income-expense-pie', labels, values, colors, 'Total Income vs Expenses');
        });

   getOverallExpenseBreakdown()
    .then(result => {
        console.log('📊 Overall Expense Breakdown:', JSON.stringify(result));
        const labels = ['Expense Bill', 'PO Bill', 'Advance to Vendor', 'My Expenses'];
        const values = [
            result.totalExpenseBill || 0,
            result.totalPOBill || 0,
            result.totalAdvance || 0,
            result.totalMyExpense || 0
        ];
        const colors = ['#9D53F2 ', '#3290ED', '#9c27b0', '#263eabff'];
        console.log('📊 Doughnut Chart Data:', { labels, values, colors });
        this.renderPieChart2('.expense-type-doughnut', labels, values, colors, 'Expense Type Breakdown');
    }); 
}

renderPieChart2(selector, labels, data, colors, title) {
    console.log('🖌️ Rendering Pie Chart2 for', selector, 'with data:', data);
    const ctx = this.template.querySelector(selector)?.getContext('2d');
    if (!ctx) return;

    const key = selector.replace('.', '');
    this.destroyChart(key);

  const symbol = this.currencySymbol || ''; // fallback if not set

this.chartInstances[key] = new window.Chart(ctx, {
    type: 'pie',
    data: {
        labels: labels,
        datasets: [{
            data: data,
            backgroundColor: colors
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: { position: 'top' },
            title: {
                display: true,
                text: `${title} (${symbol})` // ← adds ₹, $, etc. in title
            },
            tooltip: {
                callbacks: {
                    label: function(context) {
                        const value = context.parsed || 0;
                        const label = context.label || '';
                        return `${label}: ${symbol}${value.toLocaleString()}`;
                    }
                }
            }
        }
    }
});

}



 budgetPlanData() {
    getChartOfAccountTotals()
        .then(data => {
            console.log('📊 Grouped Budget Plan Data:', JSON.stringify(data));
            if (!data.length) {
                this.coaKeys = [];
                this.isGroupedChartVisible = false;
                return;
            }

            // Set flags
            this.isGroupedChartVisible = true;

            // Prepare arrays
            const labels = [];
            const approved = [];
            const consumed = [];
            const committed = [];
            const remaining = [];

            data.forEach(item => {
                labels.push(item.chartOfAccount || 'N/A');
                approved.push(item.approved || 0);
                consumed.push(item.consumed || 0);
                committed.push(item.committed || 0);
                remaining.push(item.remaining || 0);
            });

            // Ensure DOM is ready
            Promise.resolve().then(() => {
                this.renderGroupedBarChart(labels, approved, consumed, committed, remaining);
            });
        })
        .catch(error => {
            console.error('❌ Error loading budget data:', JSON.stringify(error));
        });
}



renderGroupedBarChart(labels, approved, consumed, committed, remaining) {
    const ctx = this.template.querySelector('canvas.grouped-bar-chart')?.getContext('2d');
    if (!ctx) {
        console.error('Canvas not found for grouped bar chart');
        return;
    }

    // Destroy old chart if exists
    if (this.chartInstances['grouped']) {
        this.chartInstances['grouped'].destroy();
    }

    this.isGroupedChartVisible = true;

   let delayed;

   const symbol = this.currencySymbol || ''; // fallback if not set

this.chartInstances['grouped'] = new window.Chart(ctx, {
    type: 'bar',
    data: {
        labels: labels,
        datasets: [
            { label: 'Approved', data: approved, backgroundColor: '#3290ED' },
            { label: 'Consumed', data: consumed, backgroundColor: '#9D53F2 ' },
            { label: 'Committed', data: committed, backgroundColor: '#26ABA4' },
            { label: 'Remaining', data: remaining, backgroundColor: '#4001d3ff' }
        ]
    },
    options: {
        responsive: true,
        animation: {
            onComplete: () => {
                delayed = true;
            },
            delay: (context) => {
                let delay = 0;
                if (context.type === 'data' && context.mode === 'default' && !delayed) {
                    delay = context.dataIndex * 300 + context.datasetIndex * 100;
                }
                return delay;
            }
        },
        plugins: {
            title: {
                display: true,
                text: 'Budget Summary by Chart of Account'
            },
            legend: {
                position: 'top'
            }
        },
        scales: {
            x: {
                stacked: false
            },
            y: {
                beginAtZero: true,
                title: {
                    display: true,
                    text: 'Amount ' + symbol
                },
                ticks: {
                    callback: (value) => {
                        return symbol + value.toLocaleString();
                    }
                }
            }
        }
    }
});

}




handleChartOfAccountSelected(event) {
    console.log('🟡 handleChartOfAccountSelected triggered');
    console.log('📦 Event detail:', event.detail);

    this.selectedChartOfAccount = event.detail;

    if (this.selectedChartOfAccount?.Id) {
        console.log('✅ Selected COA ID:', this.selectedChartOfAccount.Id);
        console.log('✅ Selected COA Name:', this.selectedChartOfAccount.Name);

        // 👇 Hide the original grouped chart
        this.isGroupedChartVisible = true;

        // 👇 Fetch and show project-wise budget data
        this.fetchProjectBudgets(this.selectedChartOfAccount.Id);
        console.log('🔄 Fetching project budgets for COA:', this.selectedChartOfAccount.Id);

        // 👇 Reset selected project and pie chart visibility
        this.selectedProject = {};
        this.isSingleProjectChartVisible = false;

        // 👇 Fetch filtered projects for project lookup
        getProjectsByChartOfAccount({ chartOfAccountId: this.selectedChartOfAccount.Id })
            .then(projects => {
                console.log('📋 Filtered Projects:', projects);

                if (projects && projects.length > 0) {
                    const ids = projects.map(p => `'${p.id}'`);
                    this.projectFilter = `Id IN (${ids.join(',')})`;
                    console.log('📌 Applied Project Filter:', this.projectFilter);
                } else {
                    this.projectFilter = 'Id = null';
                    console.warn('⚠️ No projects found for selected COA');
                }
            })
            .catch(error => {
                console.error('❌ Error fetching filtered projects:', error);
                this.projectFilter = 'Id = null';
            });

    } else {
        console.warn('⚠️ No Chart of Account selected');
        this.isGroupedChartVisible = true;
        this.isProjectChartVisible = false;
        this.isSingleProjectChartVisible = false;
        this.projectFilter = 'Id = null';
    }
}




handleProjectSelected(event) {
    console.log('🟡 handleProjectSelected triggered');
        this.selectedProject = event.detail;
    console.log('📦 Selected Project:', this.selectedProject);
        if (this.selectedProject?.Id && this.selectedChartOfAccount?.Id) {
            getSingleProjectBudget({
                chartOfAccountId: this.selectedChartOfAccount.Id,
                projectId: this.selectedProject.Id
            })
                .then(data => {
                    this.isProjectPieVisible = true;
                  setTimeout(() => {
    this.renderProjectPie(data);
}, 0);

                    console.log('🔄 Fetching project budget for:', this.selectedProject.Id);
                    console.log('📊 Project Budget Data:', JSON.stringify(data));
                })
                
                .catch(err => console.error('Pie chart load error:', err));
        }
    }

    handleProjectRemoved() {
        this.selectedProject = {};
        this.isProjectPieVisible = false;
    }

    renderProjectPie(data) {
        const ctx = this.template.querySelector('canvas.project-pie')?.getContext('2d');
        console.log('🖌️ Rendering Project Pie Chart with data:', JSON.stringify(data));
        if (!ctx){
            console.warn('❌ project-pie canvas not found');
            return;
        }

        this.chartInstances.projectPieChart = new window.Chart(ctx, {
            type: 'pie',
            data: {
                labels: ['Total', 'Consumed', 'Committed', 'Remaining'],
                datasets: [{
                    data: [data.total, data.consumed, data.committed, data.remaining],
                    backgroundColor: ['#200079ff', '#9D53F2 ', '#26ABA4', '#2196f3']
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: `Project Budget Breakdown`
                    }
                }
            }
        });
    }


fetchProjectBudgets(chartOfAccountId) {
    getProjectBudgetsByChartOfAccount({ chartOfAccountId })
    
        .then(data => {
            console.log('📊 Project Budgets Data:', JSON.stringify(data)); // ✅ confirmed already

            if (!data || data.length === 0) {
                this.isProjectChartVisible = false;
                console.warn('⚠️ No budget data found.');
                return;
            }

            this.isGroupedChartVisible = true;
            this.isProjectChartVisible = true;

            const labels = data.map(d => d.projectName);
            const totals = data.map(d => d.total);
            const consumed = data.map(d => d.consumed);
            const committed = data.map(d => d.committed);
            const remaining = data.map(d => d.remaining);

            console.log('📊 Labels:', labels);
            console.log('📊 Totals:', totals);
            console.log('📊 Consumed:', consumed);

            this.renderProjectChart(labels, totals, consumed, committed, remaining);
        })
        .catch(error => {
            console.error('❌ Error fetching project budgets:', JSON.stringify(error));
        });
}

renderProjectChart(labels, totals, consumed, committed, remaining) {
    // Wait until DOM updates are complete
    window.requestAnimationFrame(() => {
        const canvas = this.template.querySelector('canvas.project-chart');
        if (!canvas) {
            console.error('❌ Canvas not found for project chart.');
            return;
        }

        const ctx = canvas.getContext('2d');

        // Destroy old chart if exists
        this.destroyChart('projectBudgetChart');

        // Create new chart
       let delayed;

         const symbol = this.currencySymbol || ''; // fallback if not set
this.chartInstances.projectBudgetChart = new window.Chart(ctx, {
    type: 'bar',
    data: {
        labels: labels,
        datasets: [
            { label: 'Total', data: totals, backgroundColor: '#d80ab3ff' },
            { label: 'Consumed', data: consumed, backgroundColor: '#9D53F2 ' },
            { label: 'Committed', data: committed, backgroundColor: '#26ABA4' },
            { label: 'Remaining', data: remaining, backgroundColor: '#4001d3ff' }
        ]
    },
    options: {
        responsive: true,
        animation: {
            onComplete: () => {
                delayed = true;
            },
            delay: (context) => {
                let delay = 0;
                if (context.type === 'data' && context.mode === 'default' && !delayed) {
                    delay = context.dataIndex * 300 + context.datasetIndex * 100;
                }
                return delay;
            }
        },
        plugins: {
            title: {
                display: true,
                text: `Budget Summary by Project `
            },
            legend: {
                position: 'top'
            }
        },
        scales: {
            x: {
                stacked: false
            },
            y: {
                beginAtZero: true,
                title: {
                    display: true,
                    text: 'Amount ' + symbol
                },
                ticks: {
                    callback: (value) => {
                        return symbol + value.toLocaleString();
                    }
                }
            }
        }
    }
});

    });
}


loadChartDataforYearlySummary() {
    console.log('🔄 Starting loadChartDataforYearlySummary');
    getYearlyIncomeAndExpenseWithPrediction()
        .then(result => {
            console.log('📊 Yearly Data:', result);
            const years = result.years;
            const income = result.income;
            const expense = result.expense;
            const predictedIncome = result.predictedIncome;
            const predictedExpense = result.predictedExpense;

            console.log('📅 Years:', years);
            console.log('💰 Income Data:', income);
            console.log('📉 Expense Data:', expense);
            console.log('🔮 Predicted Income:', predictedIncome);
            console.log('🔮 Predicted Expense:', predictedExpense);

            this.renderChart(years, income, expense, predictedIncome, predictedExpense);
            console.log('✅ Yearly Chart Data Rendered');
        })
        .catch(error => {
            console.error('❌ Apex Error:', error);
        });
}

renderChart(labels, incomeData, expenseData, predictedIncome, predictedExpense) {
    const ctx = this.template.querySelector('.yearly-chart')?.getContext('2d');
    if (!ctx) {
        console.error('❌ Canvas context not found');
        return;
    }

    if (this.chart) {
        this.chart.destroy();
    }

    // Animation easing and delay logic
    const easing = window.Chart.helpers.easingEffects.easeOutQuad;
    const totalDuration = 5000;

    const duration = (ctx) => easing(ctx.index / labels.length) * totalDuration / labels.length;
    const delay = (ctx) => easing(ctx.index / labels.length) * totalDuration;
    const previousY = (ctx) =>
        ctx.index === 0
            ? ctx.chart.scales.y.getPixelForValue(100)
            : ctx.chart.getDatasetMeta(ctx.datasetIndex).data[ctx.index - 1].getProps(['y'], true).y;

    // Final animation block
    const animation = {
        x: {
            type: 'number',
            easing: 'linear',
            duration: duration,
            from: NaN,
            delay(ctx) {
                if (ctx.type !== 'data' || ctx.xStarted) return 0;
                ctx.xStarted = true;
                return delay(ctx);
            }
        },
        y: {
            type: 'number',
            easing: 'linear',
            duration: duration,
            from: previousY,
            delay(ctx) {
                if (ctx.type !== 'data' || ctx.yStarted) return 0;
                ctx.yStarted = true;
                return delay(ctx);
            }
        }
    };

    // Set currency symbol
    const symbol = this.currencySymbol || ''; // fallback if not set    

    // Chart data & config
    const data = {
        labels: labels.map(String),
        datasets: [
            {
                label: 'Income',
                fill: false,
                backgroundColor: '#26ABA4',
                borderColor: '#26ABA4',
                data: incomeData
            },
            {
                label: 'Expense',
                fill: false,
                backgroundColor: '#9D53F2',
                borderColor: '#9D53F2',
                data: expenseData
               
            },
            {
                label: 'Predicted Income (Holt’s)',
                fill: false,
                backgroundColor: '#81c784',
                borderColor: '#81c784',
                data: Array(labels.length - predictedIncome.length).fill(null).concat(predictedIncome),
                borderDash: [4, 4],
                pointRadius: 5
            },
            {
                label: 'Predicted Expense (Holt’s)',
                fill: false,
                backgroundColor: '#ef9a9a',
                borderColor: '#ef9a9a',
                data: Array(labels.length - predictedExpense.length).fill(null).concat(predictedExpense),
                borderDash: [4, 4],
                pointRadius: 5
            }
        ]
    };

    const config = {
        type: 'line',
        data: data,
        options: {
            responsive: true,
            animation: animation,
            plugins: {
                title: {
                    display: true,
                    text: 'Yearly Financial Summary with Holt’s Prediction'
                },
                legend: {
                    position: 'top'
                },
                tooltip: {
                    mode: 'index',
                    intersect: false
                }
            },
            interaction: {
                mode: 'index',
                intersect: false
            },
            scales: {
                x: {
                    display: true,
                    title: {
                        display: true,
                        text: 'Year'
                    }
                },
                y: {
                    display: true,
                    title: {
                        display: true,
                        text: 'Amount ' + symbol
                    },
                    ticks: {
                        callback: (value) => {
                            return symbol + value.toLocaleString();
                        }
                    },
                    beginAtZero: true
                }
            }
        }
    };

    this.chart = new window.Chart(ctx, config);
}


}