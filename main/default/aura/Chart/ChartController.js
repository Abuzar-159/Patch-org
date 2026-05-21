({
	 createGraph : function(component, temp) {
           var yLable = component.get('v.yLabel'); 
           var xLabel = component.get('v.xLabel');
           var k =component.get('v.keys'); 
          
           var v = component.get('v.values');
           var v2 = component.get('v.values2');
           var v3 = component.get('v.values3');
           
           var chartType = component.get('v.chartType');
           var passedlabel =  component.get('v.label');
           var passedlabel2 =  component.get('v.label2');
           var passedlabel3 =  component.get('v.label3');
           var bg = component.get('v.bgColor');
           var bg2 = component.get('v.bgColor2');
           var bg3 = component.get('v.bgColor3');
           var el = component.find('barChart').getElement();
           var ctx = el.getContext('2d');
         
         
       
         if(bg2 != null){
         
           var myChart = new Chart(ctx, {
               type: chartType,
               data: {
                   labels: k,
                   datasets: [
                       {
                           label: passedlabel,
                           data: v,
                           backgroundColor: bg,
                       },
                       {
                           label: passedlabel2,
                           data: v2,
                           backgroundColor: bg2,
                       },
                        {
                           label: passedlabel3,
                           data: v3,
                           backgroundColor: bg3,
                       },
                   ],
                          
               },
               
               options : {
                   layout: {
                       padding: {
                           left: 50,
                           right: 0,
                           top: 0,
                           bottom: 0
                       }
                   },
               scales: {
               yAxes: [{
               scaleLabel: {
               display: true,
               labelString: yLable,
                }
                }],
               xAxes: [{
               scaleLabel: {
               display: true,
               labelString: xLabel,
                }
                }]  
                }     
                }
           });
         }else{
           
              var myChart = new Chart(ctx, {
               type: chartType,
               data: {
                   labels: k,
                   datasets: [
                       {
                           label: passedlabel,
                           data: v,
                           backgroundColor: bg,
                       },
                       
                   ],
                          
               },
               
               options : {
                   layout: {
                       padding: {
                           left: 50,
                           right: 0,
                           top: 0,
                           bottom: 0
                       }
                   },
               scales: {
               yAxes: [{
               scaleLabel: {
               display: true,
               labelString: yLable,
                }
                }],
               xAxes: [{
               scaleLabel: {
               display: true,
               labelString: xLabel,
                }
                }]  
                }     
                }
           });
         }
	},
})