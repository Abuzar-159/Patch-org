({
    getDetails : function(component, event) {
        var action = component.get("c.getsimilarProjects");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                let data = response.getReturnValue();
                this.drawAGantt(component, data); 
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    console.log("Error message: " + errors);
                    
                } else {
                    console.log("Unknown error~>"+errors);
                } 
            }
        });
        $A.enqueueAction(action);
    },
                
	drawAGantt : function(component, data) {
        this.setGanttScale(component);
        gantt.config.order_branch = true;
        gantt.init("gantt_here");
        gantt.config.columns = [
                {name : "id", label : "ProjectId", width : 100},
                {name : "text", label : "Project", width : 150},
                {name : "start_date", label : "Start Date", width :100, align : "center"},
                {name : "end_date", label : "End Date", width : 100, align : "center"},
        ];
         var tasks =  {
                    data:[
                        {id:"1", text:"Project #1", start_date:"01-04-2020", duration:"18",order:"10",
                         progress:"0.5", open: true},
                        {id:"2", text:"Task #1",    start_date:"02-04-2020", duration:"8", order:"10",
                         progress:"0.6", parent:"1"},
                        {id:"3", text:"Task #2",    start_date:"11-04-2020", duration:"8", order:"20",
                         progress:"0.6", parent:"1"},
                         {id:"4", text:"Task #3",    start_date:"20-04-2020", duration:"8", order:"20",
                         progress:"0.8", parent:"1"}
                    ],
                    links:[
                        { id:"1", source:"1", target:"2", type:"1"},
                        { id:"2", source:"2", target:"3", type:"0"},
                        { id:"3", source:"3", target:"4", type:"0"},
                        { id:"4", source:"2", target:"5", type:"2"},
                    ]
        };
        gantt.parse(tasks);
        $A.util.addClass(component.find('mainSpin'), "slds-hide");
	},
      
	setGanttScale : function(component) {
            var value = "4";
            switch(value) {
                case "1":
                gantt.config.scale_unit = "day";
                gantt.config.step = 1;
                gantt.config.date_scale = "%d %M";
                gantt.config.subscales = [];
                gantt.config.scale_height = 50;
                gantt.config.scale_width = 70;
                gantt.templates.date_scale = null;
                break;
        
                case "2":
                var weekScaleTemplate = function(date) {
                    var dateToStr = gantt.date.date_to_str("%d %M");
                    var endDate = gantt.date.add(gantt.date.add(date, 1, "week"), -1, "day");
                    return dateToStr(date) + " - " + dateToStr(endDate);
                };
                gantt.config.scale_unit = "week";
                gantt.config.step = 1;
                gantt.templates.date_scale = weekScaleTemplate;
                gantt.config.subscales = [
                    {
                        unit: "day",
                        step: 1,
                        date: "%D"
                    }
                ];
                gantt.config.scale_height = 50;
                break;
                case "3":
                gantt.config.scale_unit = "month";
                gantt.config.date_scale = "%F - %Y";
                gantt.config.subscales = [
                    {
                        unit: "day",
                        step: 1,
                        date: "%j - %D"
                    }
                ];
                gantt.config.scale_height = 50;
                gantt.templates.date_scale = null;
                break;
                case "4":
                gantt.config.scale_unit = "year";
                gantt.config.step = 1;
                gantt.config.date_scale = "%Y";
                gantt.config.min_column_width = 70;
                gantt.config.scale_height = 50;
                gantt.templates.date_scale = null;
                gantt.config.subscales = [
                    {
                        unit: "month",
                        step: 1,
                        date: "%M"
                    }
                ];
                break;
                case "5":
                gantt.config.scale_unit = "day";
                gantt.config.step = 1;
                gantt.config.date_scale = "%d %M";
                gantt.config.subscales = [
                    {
                        unit: "hour",
                        step: 1,
                        date: "%g:%i %a"
                    }
                ];
                gantt.config.scale_height = 50;
                gantt.config.scale_width = 70;
                gantt.templates.date_scale = null;
                break;
    	}
	}

})