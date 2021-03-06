module.exports = function(ctx, cb) {
    ctx.storage.get(function (error, data) {
        if (error) return cb(error);
        if (!data) {
        	var emptyArray = [];
        	data = emptyArray;
        }
	data.push(ctx.data.text);
		
	//uncomment to clear the storage out
	//var emptyArray = [];
    	//data = emptyArray;
		
        ctx.storage.set(data, function (error) {
            if (error) return cb(error);
        });
        
        var randomItem = data[Math.floor(Math.random()*data.length)];
        cb (null, randomItem);
    });
}
