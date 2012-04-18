//Thumbnailer plugin
//Processes an image at a specified path
var Thumbnailer = {    	 
	//Given a width, scales an image at a specified path and returns the path to the scaled image
     scale: function(sourcePath, pxWide, shouldOverwrite, callbackFunction) {
          return PhoneGap.exec(callbackFunction, callbackFunction, "Thumbnailer", "scale", [sourcePath,pxWide,shouldOverwrite]);
     },
	 //Delete all images created by Thumbnailer
	 deleteAllImages:function(){
		 return PhoneGap.exec(null,null,"Thumbnailer","deleteAllImages",[]);
	 }
};