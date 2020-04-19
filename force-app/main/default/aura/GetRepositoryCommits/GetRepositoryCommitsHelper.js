({
	refreshDelayed : function() {
    	setTimeout(
    		function(){ 
        		$A.get('e.force:refreshView').fire();
			}, 
 			2000
		);
	}
})