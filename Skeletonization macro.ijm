skeleton_prominence = 100;  //Set the "Find Maxima" prominence
setBatchMode(true);  //Do not show images to prevent crashing and boost speed 
image = getTitle(); //Get the name of hte current image
getDimensions(width, height, channels, slices, frames);  //Get size of image
skeletonize(image, skeleton_prominence); //Run skeletonization algorithm
setBatchMode("exit and display");
function skeletonize(i, prominence){
	for(x=0; x<width; x++){ //Scan horizontally for local maxima
		selectImage(i);
		run("Select None");
		makeRectangle(x, 0, 1, height); //Select a single pixel wide column from the image
		run("Duplicate...", "title=vector"); //Create a separate image of the vector
		selectImage("vector");
		run("Find Maxima...", "prominence=" + prominence + " output=[Single Points]"); //Find bright spot in the vector
		if(isOpen("Combined Stacks")){
			run("Combine...", "stack1=[Combined Stacks] stack2=[vector Maxima]");
		}
		else{
			selectImage("vector Maxima");
			rename("Combined Stacks");
		}
		close("Vector");
	}
	selectWindow("Combined Stacks");
	rename("X mask");
	for(y=0; y<height; y++){
		selectImage(i);
		run("Select None");
		makeRectangle(0, y, width, 1);
		run("Duplicate...", "title=vector");
		selectImage("vector");
		run("Find Maxima...", "prominence=" + prominence + " output=[Single Points]");
		if(isOpen("Combined Stacks")){
			run("Combine...", "stack1=[Combined Stacks] stack2=[vector Maxima] combine");
		}
		else{
			selectImage("vector Maxima");
			rename("Combined Stacks");
		}
		close("Vector");
	}
	selectWindow("Combined Stacks");
	rename("Y mask");
	imageCalculator("Add create", "X mask","Y mask");
	close("X mask");
	close("Y mask");
	selectWindow("Result of X mask");
	rename(i + " - Skeleton - " + prominence);
	setMetadata("Label", "Prominence = " + prominence);
}
