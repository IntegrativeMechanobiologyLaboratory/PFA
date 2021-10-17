dirLoc = "/home/user/Desktop/p0/phs/";
segDir = "segmentedImages/cellPropMaps/";
bwlmgDir = "bwImages/";
outDir = "dataOut/";
doNormalization = true;

nPlusMinus = 2; // range of images used to quantify standard deviation -2:i:+2 = 5 images

// get total number of image files
run("Image Sequence...", "open="+dirLoc+" sort");
totFiles = nSlices; print(totFiles);

// normalize images to get rid of overall intensity fluctuations between successive images
if(doNormalization){
	rename("seq");
	run("Set Measurements...", "mean min redirect=seq decimal=6");
	run("Clear Results");
	
	// collect mean intensity for each image
	meanVal = newArray(); 
	for(ifr=0;ifr<totFiles;ifr++){
		setSlice(ifr+1);
		run("Measure");
		jr = getResult("Mean",ifr);
		meanVal = Array.concat(meanVal,jr);
	}
	
	// obtain mean of all the means
	Array.getStatistics(meanVal, jr, jr, meanMeanVal, jr);
	run("Clear Results");
	selectWindow("seq");

	// normalize the intensity of images to the mean of the entire sequence
	run("32-bit");
	for(ifr=0;ifr<totFiles;ifr++){
		setSlice(ifr+1);
		run("Multiply...", "value="+d2s(meanMeanVal/meanVal[ifr],3)+" slice");
	}
	run("Image Sequence... ", "format=TIFF use save="+dirLoc+"seq0000.tif");
	selectWindow("seq");
	close("seq");
}



for(iframe=nPlusMinus+1;iframe<totFiles-nPlusMinus-1;iframe++){
	
	// get five successive frames (-2:i:+2)
	run("Image Sequence...", "open="+dirLoc+" number="+d2s(nPlusMinus*2+1,0)+" starting="+d2s(iframe-nPlusMinus,0)+" sort");
	rename("seq");

	// obtain Z-projection that provides standard deviation
	run("Z Project...", "projection=[Standard Deviation]");
	rename("stdDevIm");

	// open 'i'th cell segmentation image (cells are 255 and cell boundaries are 0)
	openFile(iframe,dirLoc,segDir,iframe);

	// invert it to get the cells to be 0 and intercellular boundaries to be 255
	run("Invert");
	setOption("BlackBackground", true);
	rename("segment");

	// open 'i'th monolayer segmentation image (no-cell region is 0 and cell region is 255)
	openFile(iframe,dirLoc,bwlmgDir,iframe);
	rename("bwImg");

	// multiply the cell segmentation image with the monolayer segmentation image to get rid of region that does not have cells
	imageCalculator("Multiply create 32-bit", "segment","bwImg");
	rename("SegBw");
	setOption("ScaleConversions", true);
	run("8-bit");
	setOption("BlackBackground", true);

	// make the intercellular boundaries wider
	run("Dilate");
	run("Dilate");
	run("Dilate");
	run("Dilate");
	run("Dilate");
	run("Dilate");
	run("Divide...", "value=255");
	rename("bdryRgn");

	// make the cell center NaN and cell boundary 1
	imageCalculator("Divide create 32-bit", "bdryRgn","bdryRgn");
	selectWindow("Result of bdryRgn");
	rename("bdryRgnNaN");
	close("bdryRgn");

	// Use above image as a mask to the standard deviation image
	imageCalculator("Multiply create 32-bit", "stdDevIm","bdryRgnNaN");
	selectWindow("Result of stdDevIm");
	rename("stdDevNaNIm");
	close("stdDevIm");
	close("bdryRgnNaN");

	// obtain area, mean, standard deviation, median value of the standard deviation within wide intercellular regions
	run("Set Measurements...", "area mean standard median redirect=stdDevNaNIm decimal=6");
	run("Measure");

	// save the results for 'i'th image
	saveAs("Results", dirLoc+outDir+d2s(iframe,0)+".csv");

	run("Clear Results");
	close();
    	close();
    	close();
}


// open 'i'th image
function openFile(iframe,dirLoc,segDir,iframe){
	if(iframe<10){
		open(dirLoc+segDir+"000"+d2s(iframe,0)+".tif");
	} else if(iframe<100){
		open(dirLoc+segDir+"00"+d2s(iframe,0)+".tif");
	} else if(iframe<1000){
		open(dirLoc+segDir+"0"+d2s(iframe,0)+".tif");
	} else{
		open(dirLoc+segDir+d2s(iframe,0)+".tif");
	}
}

