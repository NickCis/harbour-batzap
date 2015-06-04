function doOnPageStackNotBusy(cb) {
    if(!pageStack.busy)
        return cb();

    pageStack.onBusyChanged.connect(function callMe(){
        if(!pageStack.busy){
            pageStack.onBusyChanged.disconnect(callMe);
            cb();
        }
    });
}
