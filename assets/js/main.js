'use strict';


function openMore() {
    var currentstatus = document.getElementById("morearrow").className;
    if (currentstatus === "fa-angle-double-down") {
        document.getElementById("morearrow").className = "fa-angle-double-up";
        document.getElementById("More").style.display = "block";
    }
    else {
        document.getElementById("morearrow").className = "fa-angle-double-down";
        document.getElementById("More").style.display = "none";
    }
}

