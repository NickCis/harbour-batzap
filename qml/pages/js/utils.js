function toCapitalLetter(name){
    return name.charAt(0).toUpperCase() + name.slice(1);
}

function epochToDate(epoch){
    var date = new Date(0);
    date.setUTCSeconds(epoch);
    return date;
}
