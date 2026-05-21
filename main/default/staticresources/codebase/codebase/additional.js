
                    gantt.locale.labels["section_WorkOrder"] = "Work Order";
                    gantt.locale.labels["section_lineitem"] = "Line Item";
                    gantt.locale.labels["section_productservice"] = "Product Service";
                    gantt.locale.labels["section_start_date"] = "Start date";
                    gantt.locale.labels["section_scheduleName"] = "Name";
                    gantt.locale.labels["section_processes"] = "Process";
                    gantt.locale.labels["section_scheduleType"] = "Schedule Type";
                    gantt.locale.labels["section_workStation"] = "Work Station Assign";
                    gantt.locale.labels["section_progress"] = "Progress %";
                    gantt.locale.labels["section_status"] = "Status";
                    gantt.locale.labels["section_schedule"] = "Schedule";
                    gantt.locale.labels["section_cycle"] = "Process Cycle";
                    gantt.locale.labels["section_add"] = "add";
                    gantt.config.columns = [{
                            name: "text",
                            label: "Process/Cycle/Schedule",
                            tree: true,
                            width: "180",
                            align: "left",
                            resize: true
                                    }, {
                            name: "WorkOrder",
                            label: "Work Order",
                            width: 120,
                            align: "center",
                            template: function(item) {
                                return item.WorkOrder ? item.WorkOrder : ""
                            },
                            resize: true
                                    }, {
                            /*  name: "lineitem",
                                        label: "Line Item",
                                        width: 90,
                                        align: "center",
                                        template: function(item) {
                                            return item.lineitem ? item.lineitem : ""
                                        },
                                        resize: true
                                    }, { */
                            name: "productservice",
                            label: "Product/Service",
                            width: 100,
                            align: "center",
                            template: function(item) {
                                return item.productservice ? item.productservice : ""
                            },
                            resize: true
                                    },
                        /*{
                                           name: "start_date",
                                           label: "Start Date",
                                           width: 90,
                                           align: "center",
                                           template: function(item) {
                                               return item.start_date ? item.start_date : "start_date"
                                           },
                                           resize: true
                                       }, */
                        {
                            name: "workStation",
                            label: "Work Station",
                            width: 150,
                            align: "center",
                            template: function(item) {
                                return item.workStation ? item.workStation : ""
                            },
                            resize: true
                                    }, {
                            name: "add",
                            label: "",
                            width: "50",
                            align: "left",
                            resize: true
                                    }];
                    gantt.templates.progress_text = function(start, end, task) {
                        return "<span>" + Math.round(task.progress) + "% </span>";
                    };
                    // t.progress = parseFloat(Math.min(1, i / (a.end - a.start))*100).toFixed(0);
                    gantt.config.lightbox.sections = [{
                            name: "scheduleName",
                            height: 27,
                            map_to: "scheduleName",
                            type: "textarea"
                                    },
                        {
                            name: "WorkOrder",
                            height: 30,
                            map_to: "WorkOrder",
                            type: "workorder"
                                    },
                                    /*{
                                        name: "scheduleType",
                                        height: 30,
                                        map_to: "scheduleType",
                                        type: "select",
                                        options: [
                                            {key:"Production Schedule", label: "Production Schedule"},
                                            {key:"Maintenance Schedule", label: "Maintenance Schedule"}
                                        ]
                                    }, */
                        {
                            name: "processes",
                            height: 30,
                            map_to: "Processes",
                            type: "process"
                                    },
                        {
                            name: "productservice",
                            height: 30,
                            map_to: "productservice",
                            type: "product"
                                    },

                        {
                            name: "lineitem",
                            height: 30,
                            map_to: "lineitem",
                            type: "lineitem"
                                    },
                        {
                            name: "cycle",
                            height: 30,
                            map_to: "cycle",
                            type: "cycle"
                                    },

                        {
                            name: "schedule",
                            height: 30,
                            map_to: "schedule",
                            type: "schedule"
                                    },

                        {
                            name: "workStation",
                            height: 30,
                            map_to: "workStation",
                            type: "workstation"
                                    },

                        {
                            name: "status",
                            height: 30,
                            map_to: "status",
                            type: "select",
                            options: [
                                {
                                    key: "In Progress",
                                    label: "In Progress"
                                },
                                {
                                    key: "Complete",
                                    label: "Complete"
                                },
                                {
                                    key: "Cancelled",
                                    label: "Cancelled"
                                }
                                        ]
                                    },
                        {
                            name: "progress",
                            height: 30,
                            map_to: "progress",
                            type: "number"
                                    },
                        {
                            name: "time",
                            type: "time",
                            map_to: "auto",
                            time_format: ["%d", "%m", "%Y", "%H:%i"] //,"%H:%i"
                                    }
                                    ];
                    gantt.init("gantt_here");
                    gantt.form_blocks["my_editor"] = {
                        render: function(sns) {
                            //alert(a);
                            return "<div class='dhx_cal_ltext' style='height:60px;'>Text&nbsp;<input type='text'><br/>Holders&nbsp;<input type='text'></div>";
                        },
                        set_value: function(node, value, task) {
                            node.childNodes[1].value = value || "";
                            node.childNodes[4].value = task.users || "";
                        },
                        get_value: function(node, task) {
                            task.users = node.childNodes[4].value;
                            return node.childNodes[1].value;
                        },
                        focus: function(node) {
                            var a = node.childNodes[1];
                            a.select();
                            a.focus();
                        }
                    };
                    gantt.parse(ik);

                    function ScheduleLookUpTemp() {
                        var baseURL;
                        var fieldId = document.getElementById("schId")
                            .Id;
                        //alert(fieldId);
                        var commVal = communityValue();
                        baseURL = commVal + "/ScheduleSelect?";
                        baseURL = baseURL + "txt=" + escapeUTF("schId");
                        baseURL = baseURL + "&frm=" + escapeUTF("{!$Component.qer}");
                        openPopup(baseURL, "zlookup", 500, 500, "width=1085,height=550,left=0,top=100,toolbar=no,status=no,directories=no,menubar=no,resizable=yes,scrollable=no",
                            true);
                    }
                    var newWin = null;
                    /*
                    function ScheduleLookUp() {
                        var url = "apex/ScheduleSelect";
                        newWin = window.open(url, 'Popup', 'height=600,width=600,left=100,top=100,margin-top=10,resizable=no,scrollbars=yes,toolbar=no,status=no');
                        if(window.focus) {
                            newWin.focus();
                        }
                        return false;
                    }
                    */
                    function processLookUp() {
                        var url = "apex/processSelect";
                        newWin = window.open(url, 'Popup', 'height=600,width=600,left=100,top=100,margin-top=10,resizable=no,scrollbars=yes,toolbar=no,status=no');
                        if(window.focus) {
                            newWin.focus();
                        }
                        return false;
                    }
                    /*
                    function workstationLookUp() {
                        var cycleId = document.getElementById("cycleId").value;
                        alert('cycleId : '+cycleId+' : '+cycleId);
                        if(workorderId != ''){
                            var url = "apex/workstationSelect?cycle="+cycleId;
                            newWin = window.open(url, 'Popup', 'height=600,width=600,left=100,top=100,margin-top=10,resizable=no,scrollbars=yes,toolbar=no,status=no');
                            if(window.focus) {
                                newWin.focus();
                            }
                        }
                        return false;
                    }
                    */
                    function workstationLookUp() {
                        var cycleId = document.getElementById("cycleId")
                            .value;
                        //alert('cycleId : '+cycleId+' : '+cycleId);
                        if(cycleId != '') {
                            var url = "apex/workstationassignSelect?cycle=" + cycleId;
                            newWin = window.open(url, 'Popup', 'height=600,width=600,left=100,top=100,margin-top=10,resizable=no,scrollbars=yes,toolbar=no,status=no');
                            if(window.focus) {
                                newWin.focus();
                            }
                        }
                        return false;
                    }

                    function workorderLookUp() {
                        var url = "apex/workorderSelect";
                        newWin = window.open(url, 'Popup', 'height=600,width=600,left=100,top=100,margin-top=10,resizable=no,scrollbars=yes,toolbar=no,status=no');
                        if(window.focus) {
                            newWin.focus();
                        }
                        return false;
                    }

                    function lineitemLookUp() {
                        var workorder = document.getElementById("workorderName")
                            .value;
                        var workorderId = document.getElementById("workorderId")
                            .value;
                        //alert('workorder : '+workorder+' : '+workorderId);
                        if(workorderId != '') {
                            var url = "apex/lineitemSelect?woId=" + workorderId;
                            newWin = window.open(url, 'Popup', 'height=600,width=600,left=100,top=100,margin-top=10,resizable=no,scrollbars=yes,toolbar=no,status=no');
                            if(window.focus) {
                                newWin.focus();
                            }
                            return false;
                        }
                    }
                    /*
                    function productLookUp() {

                        var url="apex/productSelect";
                        newWin=window.open(url, 'Popup','height=600,width=600,left=100,top=100,margin-top=10,resizable=no,scrollbars=yes,toolbar=no,status=no');

                        if (window.focus)
                        {
                            newWin.focus();
                        }

                        return false;
                    }
                    */
                    function cycleLookUp() {
                        //var workorder = document.getElementById("workorderName").value;
                        var processId = document.getElementById("processId")
                            .value;
                        //alert('workorder : '+workorder+' : '+workorderId);
                        if(processId != '') {
                            var url = "apex/cycleSelect?process=" + processId;
                            newWin = window.open(url, 'Popup', 'height=600,width=600,left=100,top=100,margin-top=10,resizable=no,scrollbars=yes,toolbar=no,status=no');
                            if(window.focus)
                            {
                                newWin.focus();
                            }
                            return false;
                        }
                    }

                    function communityValue() {
                        //alert('hello community value');
                        var comVal = document.getElementById('{!$Component.qer.comVal}')
                            .value;
                        //alert('comVal in community func() ---> ' + comVal);
                        return comVal;
                    }

                    function closeLookupPopup() {
                        if(null != newWin) {
                            newWin.close();
                        }
                    }

                    function dissolveWS(name, id) {
                        //alert(id+name);
                        //alert(id.value+name.value);
                        id.value = '';
                        name.value = '';
                        //alert(id.id);
                        if(id.id == "cycleId") {
                            var elewsn = document.getElementById("workstationName");
                            var elewsid = document.getElementById("workstationId");
                            elewsn.value = '';
                            elewsid.value = '';
                        }
                        if(id.id == "workorderId") {
                            /*
                            document.getElementById("schId").value = e.parent;
                            document.getElementById("workorderId").value = parntask.woId;
                            document.getElementById("processId").value = parntask.processId;
                            document.getElementById("lineitemId").value = parntask.lineId;
                            document.getElementById("productId").value = parntask.productId;
                            //document.getElementById("cycleId").value = parntask.cycleId;
                            document.getElementById("workstationName").value = '';
                            document.getElementById("workstationId").value = '';
                            */
                            document.getElementById("lineitemId")
                                .value = '';
                            document.getElementById("lineitemName")
                                .value = '';
                        }
                        if(id.id == "processId") {
                            /*
                            document.getElementById("schId").value = e.parent;
                            document.getElementById("workorderId").value = parntask.woId;
                            document.getElementById("processId").value = parntask.processId;
                            document.getElementById("lineitemId").value = parntask.lineId;
                            document.getElementById("productId").value = parntask.productId;
                            //document.getElementById("cycleId").value = parntask.cycleId;
                            document.getElementById("workstationName").value = '';
                            document.getElementById("workstationId").value = '';
                            */
                            document.getElementById("productId")
                                .value = '';
                            document.getElementById("productName")
                                .value = '';
                            document.getElementById("cycleId")
                                .value = '';
                            document.getElementById("cycleName")
                                .value = '';
                            document.getElementById("workstationId")
                                .value = '';
                            document.getElementById("workstationName")
                                .value = '';
                        }
                    }

                    function setScaleConfig(value) {
                        switch(value) {
                            case "1":
                                gantt.config.scale_unit = "day";
                                gantt.config.step = 1;
                                gantt.config.date_scale = "%d %M";
                                gantt.config.subscales = [

                                        ];
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
                    setScaleConfig('1');
                    var func = function(e) {
                        e = e || window.event;
                        var el = e.target || e.srcElement;
                        var value = el.value;
                        var els = document.getElementsByName("scale");
                        for(var i = 0; i < els.length; i++) {
                            els[i].style.backgroundColor = '#ffffff';
                        }
                        //el.style.backgroundColor='lightgrey';
                        setScaleConfig(value);
                        gantt.render();
                    };
                    var els = document.getElementsByName("scale");
                    for(var i = 0; i < els.length; i++) {
                        //els[i].style.backgroundColor='#ffffff';
                        els[i].onchange = func;
                    }
                    var PLACEHOLDER = '';
                    var searchObject;
                    var queryTerm;
                    $('[id$=productTextBoxId]')
                        .autocomplete({
                            minLength: 2,
                            source: function(request, response) {
                                queryTerm = request.term;
                                //alert('IN'+queryTerm);
                                Visualforce.remoting.Manager.invokeAction('{!$RemoteAction.Scheduler.searchProducts}', request.term, function(result, event) {
                                    if(event.type == 'exception') {
                                        alert(event.message);
                                    } else {
                                        searchObject = result;
                                        response(searchObject);
                                    }
                                },
                                {
                                    escape: true
                                });
                            },
                            focus: function(event, ui) {
                                $('[id$=productTextBoxId]')
                                    .val(ui.item.Name);
                                //alert('out1');
                                return false;
                            },
                            select: function(event, ui) {
                                $('[id$=productTextBoxId]')
                                    .val(ui.item.Name);
                                $('[id$=searchProductId]')
                                    .val(ui.item.Id);
                                //alert('out2');
                                Evaluate();
                                return false;
                            },
                        })
                        .data("ui-autocomplete")
                        ._renderItem = function(ul, item) {
                            //alert(item.Name);
                            var entry = "<a style='text-decoration:none;color:#333;'>" + item.Name;
                            //alert('out3');
                            entry = entry + "</a>";
                            entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
                            return $("<li class='liclassik'></li>")
                                .data("item.autocomplete", item)
                                .append(entry)
                                .appendTo(ul);
                        };
                    $('[id$=WOTextBoxId]')
                        .autocomplete({
                            minLength: 2,
                            source: function(request, response) {
                                queryTerm = request.term;
                                //alert('IN'+queryTerm);
                                Visualforce.remoting.Manager.invokeAction('{!$RemoteAction.Scheduler.searchWOs}', request.term, function(result, event) {
                                    if(event.type == 'exception') {
                                        alert(event.message);
                                    } else {
                                        searchObject = result;
                                        response(searchObject);
                                    }
                                },
                                {
                                    escape: true
                                });
                            },
                            focus: function(event, ui) {
                                $('[id$=WOTextBoxId]')
                                    .val(ui.item.Name);
                                //alert('out1');
                                return false;
                            },
                            select: function(event, ui) {
                                $('[id$=WOTextBoxId]')
                                    .val(ui.item.Name);
                                $('[id$=searchWOId]')
                                    .val(ui.item.Id);
                                //alert('out2');
                                Evaluate();
                                return false;
                            },
                        })
                        .data("ui-autocomplete")
                        ._renderItem = function(ul, item) {
                            //alert(item.Name);
                            var entry = "<a style='text-decoration:none;color:#333;'>" + item.Name;
                            //alert('out3');
                            entry = entry + "</a>";
                            entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
                            return $("<li class='liclassik'></li>")
                                .data("item.autocomplete", item)
                                .append(entry)
                                .appendTo(ul);
                        };
                    $('[id$=WSTextBoxId]')
                        .autocomplete({
                            minLength: 2,
                            source: function(request, response) {
                                queryTerm = request.term;
                                //alert('IN'+queryTerm);
                                Visualforce.remoting.Manager.invokeAction('{!$RemoteAction.Scheduler.searchWSs}', request.term, function(result, event) {
                                    if(event.type == 'exception') {
                                        alert(event.message);
                                    } else {
                                        searchObject = result;
                                        response(searchObject);
                                    }
                                },
                                {
                                    escape: true
                                });
                            },
                            focus: function(event, ui) {
                                $('[id$=WSTextBoxId]')
                                    .val(ui.item.Name);
                                //alert('out1');
                                return false;
                            },
                            select: function(event, ui) {
                                $('[id$=WSTextBoxId]')
                                    .val(ui.item.Name);
                                $('[id$=searchWSId]')
                                    .val(ui.item.Id);
                                //alert('out2');
                                Evaluate();
                                return false;
                            },
                        })
                        .data("ui-autocomplete")
                        ._renderItem = function(ul, item) {
                            //alert(item.Name);
                            var entry = "<a style='text-decoration:none;color:#333;'>" + item.Name;
                            //alert('out3');
                            entry = entry + "</a>";
                            entry = entry.replace(queryTerm, "<b>" + queryTerm + "</b>");
                            return $("<li class='liclassik'></li>")
                                .data("item.autocomplete", item)
                                .append(entry)
                                .appendTo(ul);
                        };

